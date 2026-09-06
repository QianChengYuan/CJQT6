/**
 * @file bridge_network.cpp
 * @brief QtNetwork模块桥接实现
 */

#include <QHostAddress>
#include <QTcpSocket>
#include <QTcpServer>
#include <QUdpSocket>
#include <QSslSocket>
#include <QSslCertificate>
#include <QAbstractSocket>
#include <QNetworkProxy>
#include <QLocalServer>
#include <QLocalSocket>
#include <QDebug>
#include <QHash>
#include <QMutex>
#include <functional>
#include <mutex>
#include <atomic>
#include <thread>
#include "bridge_string_utils.h"

extern "C" {

// ============================================================
// 线程安全回调存储
// ============================================================

// 线程安全 - atomic_flag 自旋锁（与 bridge_signal.cpp 保持一致）
// 不能用 std::mutex：其底层 CRT/OS 原始锁在 Cangjie 运行时加载的 DLL 中
// 首次加锁即死锁（已实测：连栈上新构造的 std::mutex::try_lock 都会卡死）
static std::atomic_flag g_networkLockFlag = ATOMIC_FLAG_INIT;

class NetworkSpinLock {
public:
    NetworkSpinLock() {
        while (g_networkLockFlag.test_and_set(std::memory_order_acquire)) {
            std::this_thread::yield();
        }
    }
    ~NetworkSpinLock() {
        g_networkLockFlag.clear(std::memory_order_release);
    }
};

static QHash<int64_t, std::function<void()>> g_networkVoidCallbacks;

// QTcpSocket 各信号独立回调表（修复共用单表互相覆盖的问题）
static QHash<int64_t, std::function<void()>> g_tcpConnectedCbs;
static QHash<int64_t, std::function<void()>> g_tcpDisconnectedCbs;
static QHash<int64_t, std::function<void()>> g_tcpReadyReadCbs;
static QHash<int64_t, std::function<void()>> g_tcpErrorCbs;

// id 版回调（闭包捕获）：ptr -> 注册表 id
static void (*g_netVoidDispatcher)(int64_t) = nullptr;
static QHash<int64_t, int64_t> g_tcpConnectedIds;
static QHash<int64_t, int64_t> g_tcpDisconnectedIds;
static QHash<int64_t, int64_t> g_tcpReadyReadIds;
static QHash<int64_t, int64_t> g_tcpErrorIds;
static QHash<int64_t, int64_t> g_tcpServerNewConnIds;

// S5 修复：各信号分别保存连接句柄。原先每次 ConnectXxx 都 QObject::connect 新
// lambda 且不断开旧连接（替换回调后重复派发）；DisconnectCallbacks/Delete 只清
// 回调表不断开连接（lambda 永久挂在 socket 上泄漏）。统一改为替换式连接 +
// 断开时逐个 QObject::disconnect。
static QHash<int64_t, QMetaObject::Connection> g_tcpConnectedConns;
static QHash<int64_t, QMetaObject::Connection> g_tcpDisconnectedConns;
static QHash<int64_t, QMetaObject::Connection> g_tcpReadyReadConns;
static QHash<int64_t, QMetaObject::Connection> g_tcpErrorConns;
static QHash<int64_t, QMetaObject::Connection> g_tcpServerConns;
static QHash<int64_t, QMetaObject::Connection> g_udpReadyReadConns;
static QHash<int64_t, QMetaObject::Connection> g_udpErrorConns;
static QHash<int64_t, QMetaObject::Connection> g_sslEncryptedConns;
static QHash<int64_t, QMetaObject::Connection> g_sslPeerVerifyConns;
// SSL peerVerifyError 回调表（原先 callback 被直接捕获进 lambda，断开后仍持有悬垂指针）
static QHash<int64_t, std::function<void(const char*)>> g_sslPeerVerifyCbs;
// UDP 独立回调表：原先 readyRead / error 共用 g_networkVoidCallbacks[ptr] 同一键，
// 后注册的覆盖先注册的（与 S3 串台同型），拆分为独立表。
static QHash<int64_t, std::function<void()>> g_udpReadyReadCbs;
static QHash<int64_t, std::function<void()>> g_udpErrorCbs;

#define LOCK_NETWORK_CALLBACKS() NetworkSpinLock _netLock

// 前向声明：id 回调表清理辅助（定义在文件尾部；调用方必须已持有网络回调自旋锁（LOCK_NETWORK_CALLBACKS））
static void removeTcpSocketIdEntriesLocked(int64_t ptr);

// 通用：从指定回调表触发 ptr 对应的回调
static void invokeTcpCallback(QHash<int64_t, std::function<void()>>& table, int64_t ptr) {
    std::function<void()> cb;
    {
        LOCK_NETWORK_CALLBACKS();
        auto it = table.find(ptr);
        if (it != table.end()) {
            cb = it.value();
        }
    }
    if (cb) cb();
}

// ============================================================
// QHostAddress - IP地址
// ============================================================

int64_t qHostAddressCreate() {
    return reinterpret_cast<int64_t>(new QHostAddress());
}

int64_t qHostAddressCreateWithString(const char* address) {
    return reinterpret_cast<int64_t>(new QHostAddress(QString::fromUtf8(address)));
}

void qHostAddressDelete(int64_t ptr) {
    delete reinterpret_cast<QHostAddress*>(ptr);
}

void qHostAddressSetAddress(int64_t ptr, const char* address) {
    QHostAddress* addr = reinterpret_cast<QHostAddress*>(ptr);
    if (addr) {
        addr->setAddress(QString::fromUtf8(address));
    }
}

const char* qHostAddressToString(int64_t ptr) {
    QHostAddress* addr = reinterpret_cast<QHostAddress*>(ptr);
    if (addr) {
        return cjqt6::dupUtf8(addr->toString());
    }
    return cjqt6::emptyString();
}

int32_t qHostAddressProtocol(int64_t ptr) {
    QHostAddress* addr = reinterpret_cast<QHostAddress*>(ptr);
    if (addr) {
        return static_cast<int32_t>(addr->protocol());
    }
    return 0;
}

bool qHostAddressIsNull(int64_t ptr) {
    QHostAddress* addr = reinterpret_cast<QHostAddress*>(ptr);
    return addr ? addr->isNull() : true;
}

bool qHostAddressEqual(int64_t ptr, const char* address) {
    QHostAddress* addr = reinterpret_cast<QHostAddress*>(ptr);
    if (addr) {
        return *addr == QHostAddress(QString::fromUtf8(address));
    }
    return false;
}

// ============================================================
// QTcpSocket - TCP套接字
// ============================================================

int64_t qTcpSocketCreate() {
    return reinterpret_cast<int64_t>(new QTcpSocket());
}

void qTcpSocketDelete(int64_t ptr) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket) {
        QMetaObject::Connection conns[4];
        {
            LOCK_NETWORK_CALLBACKS();
            g_networkVoidCallbacks.remove(ptr);
            g_tcpConnectedCbs.remove(ptr);
            g_tcpDisconnectedCbs.remove(ptr);
            g_tcpReadyReadCbs.remove(ptr);
            g_tcpErrorCbs.remove(ptr);
            auto take = [ptr](QHash<int64_t, QMetaObject::Connection>& table, QMetaObject::Connection& out) {
                auto it = table.find(ptr);
                if (it != table.end()) {
                    out = it.value();
                    table.erase(it);
                }
            };
            take(g_tcpConnectedConns, conns[0]);
            take(g_tcpDisconnectedConns, conns[1]);
            take(g_tcpReadyReadConns, conns[2]);
            take(g_tcpErrorConns, conns[3]);
            removeTcpSocketIdEntriesLocked(ptr);
        }
        for (auto& c : conns) {
            if (c) QObject::disconnect(c);
        }
        delete socket;
    }
}

void qTcpSocketConnectToHost(int64_t ptr, const char* host, uint16_t port) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket) {
        socket->connectToHost(QString::fromUtf8(host), port);
    }
}

void qTcpSocketDisconnectFromHost(int64_t ptr) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket) {
        socket->disconnectFromHost();
    }
}

int64_t qTcpSocketWrite(int64_t ptr, const char* data, int64_t size) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket) {
        return socket->write(data, size);
    }
    return -1;
}

int64_t qTcpSocketRead(int64_t ptr, char* buffer, int64_t maxSize) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket) {
        return socket->read(buffer, maxSize);
    }
    return -1;
}

int64_t qTcpSocketReadAll(int64_t ptr, char* buffer, int64_t bufferSize) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket) {
        QByteArray data = socket->readAll();
        int64_t copySize = qMin(bufferSize, static_cast<int64_t>(data.size()));
        memcpy(buffer, data.constData(), copySize);
        return copySize;
    }
    return -1;
}

int64_t qTcpSocketBytesAvailable(int64_t ptr) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    return socket ? socket->bytesAvailable() : 0;
}

int64_t qTcpSocketBytesToWrite(int64_t ptr) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    return socket ? socket->bytesToWrite() : 0;
}

bool qTcpSocketFlush(int64_t ptr) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    return socket ? socket->flush() : false;
}

bool qTcpSocketAtEnd(int64_t ptr) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    return socket ? socket->atEnd() : true;
}

int32_t qTcpSocketState(int64_t ptr) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket) {
        return static_cast<int32_t>(socket->state());
    }
    return 0;
}

int32_t qTcpSocketError(int64_t ptr) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket) {
        return static_cast<int32_t>(socket->error());
    }
    return 0;
}

const char* qTcpSocketErrorString(int64_t ptr) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket) {
        return cjqt6::dupUtf8(socket->errorString());
    }
    return cjqt6::emptyString();
}

bool qTcpSocketIsValid(int64_t ptr) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    return socket ? socket->isValid() : false;
}

void qTcpSocketClose(int64_t ptr) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket) {
        socket->close();
    }
}

const char* qTcpSocketPeerAddress(int64_t ptr) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket) {
        return cjqt6::dupUtf8(socket->peerAddress().toString());
    }
    return cjqt6::emptyString();
}

uint16_t qTcpSocketPeerPort(int64_t ptr) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    return socket ? socket->peerPort() : 0;
}

const char* qTcpSocketLocalAddress(int64_t ptr) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket) {
        return cjqt6::dupUtf8(socket->localAddress().toString());
    }
    return cjqt6::emptyString();
}

uint16_t qTcpSocketLocalPort(int64_t ptr) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    return socket ? socket->localPort() : 0;
}

// 信号连接（S5 修复版：各信号独立回调表 + 保存连接句柄，替换式断开旧连接）
void qTcpSocketConnectConnected(int64_t ptr, void (*callback)()) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket && callback) {
        QMetaObject::Connection oldConn;
        {
            LOCK_NETWORK_CALLBACKS();
            auto cit = g_tcpConnectedConns.find(ptr);
            if (cit != g_tcpConnectedConns.end()) {
                oldConn = cit.value();
                g_tcpConnectedConns.erase(cit);
            }
            g_tcpConnectedCbs[ptr] = callback;
        }
        if (oldConn) {
            QObject::disconnect(oldConn);
        }
        QMetaObject::Connection conn = QObject::connect(socket, &QTcpSocket::connected, [ptr]() {
            invokeTcpCallback(g_tcpConnectedCbs, ptr);
        });
        LOCK_NETWORK_CALLBACKS();
        g_tcpConnectedConns[ptr] = conn;
    }
}

void qTcpSocketConnectDisconnected(int64_t ptr, void (*callback)()) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket && callback) {
        QMetaObject::Connection oldConn;
        {
            LOCK_NETWORK_CALLBACKS();
            auto cit = g_tcpDisconnectedConns.find(ptr);
            if (cit != g_tcpDisconnectedConns.end()) {
                oldConn = cit.value();
                g_tcpDisconnectedConns.erase(cit);
            }
            g_tcpDisconnectedCbs[ptr] = callback;
        }
        if (oldConn) {
            QObject::disconnect(oldConn);
        }
        QMetaObject::Connection conn = QObject::connect(socket, &QTcpSocket::disconnected, [ptr]() {
            invokeTcpCallback(g_tcpDisconnectedCbs, ptr);
        });
        LOCK_NETWORK_CALLBACKS();
        g_tcpDisconnectedConns[ptr] = conn;
    }
}

void qTcpSocketConnectReadyRead(int64_t ptr, void (*callback)()) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket && callback) {
        QMetaObject::Connection oldConn;
        {
            LOCK_NETWORK_CALLBACKS();
            auto cit = g_tcpReadyReadConns.find(ptr);
            if (cit != g_tcpReadyReadConns.end()) {
                oldConn = cit.value();
                g_tcpReadyReadConns.erase(cit);
            }
            g_tcpReadyReadCbs[ptr] = callback;
        }
        if (oldConn) {
            QObject::disconnect(oldConn);
        }
        QMetaObject::Connection conn = QObject::connect(socket, &QTcpSocket::readyRead, [ptr]() {
            invokeTcpCallback(g_tcpReadyReadCbs, ptr);
        });
        LOCK_NETWORK_CALLBACKS();
        g_tcpReadyReadConns[ptr] = conn;
    }
}

void qTcpSocketConnectError(int64_t ptr, void (*callback)()) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket && callback) {
        QMetaObject::Connection oldConn;
        {
            LOCK_NETWORK_CALLBACKS();
            auto cit = g_tcpErrorConns.find(ptr);
            if (cit != g_tcpErrorConns.end()) {
                oldConn = cit.value();
                g_tcpErrorConns.erase(cit);
            }
            g_tcpErrorCbs[ptr] = callback;
        }
        if (oldConn) {
            QObject::disconnect(oldConn);
        }
        QMetaObject::Connection conn = QObject::connect(socket, &QTcpSocket::errorOccurred, [ptr](QAbstractSocket::SocketError) {
            invokeTcpCallback(g_tcpErrorCbs, ptr);
        });
        LOCK_NETWORK_CALLBACKS();
        g_tcpErrorConns[ptr] = conn;
    }
}

void qTcpSocketDisconnectCallbacks(int64_t ptr) {
    QMetaObject::Connection conns[4];
    {
        LOCK_NETWORK_CALLBACKS();
        g_networkVoidCallbacks.remove(ptr);
        g_tcpConnectedCbs.remove(ptr);
        g_tcpDisconnectedCbs.remove(ptr);
        g_tcpReadyReadCbs.remove(ptr);
        g_tcpErrorCbs.remove(ptr);
        auto take = [ptr](QHash<int64_t, QMetaObject::Connection>& table, QMetaObject::Connection& out) {
            auto it = table.find(ptr);
            if (it != table.end()) {
                out = it.value();
                table.erase(it);
            }
        };
        take(g_tcpConnectedConns, conns[0]);
        take(g_tcpDisconnectedConns, conns[1]);
        take(g_tcpReadyReadConns, conns[2]);
        take(g_tcpErrorConns, conns[3]);
        removeTcpSocketIdEntriesLocked(ptr);
    }
    for (auto& c : conns) {
        if (c) QObject::disconnect(c);
    }
}

// ============================================================
// QTcpServer - TCP服务器
// ============================================================

// 独立于 g_networkVoidCallbacks，避免与套接字回调键冲突
static QHash<int64_t, std::function<void()>> g_tcpServerCallbacks;

int64_t qTcpServerCreate() {
    QTcpServer* s = new QTcpServer();
    return reinterpret_cast<int64_t>(s);
}

void qTcpServerDelete(int64_t ptr) {
    QTcpServer* server = reinterpret_cast<QTcpServer*>(ptr);
    if (server) {
        QMetaObject::Connection conn;
        {
            LOCK_NETWORK_CALLBACKS();
            g_tcpServerCallbacks.remove(ptr);
            g_tcpServerNewConnIds.remove(ptr);
            auto cit = g_tcpServerConns.find(ptr);
            if (cit != g_tcpServerConns.end()) {
                conn = cit.value();
                g_tcpServerConns.erase(cit);
            }
        }
        if (conn) {
            QObject::disconnect(conn);
        }
        delete server;
    }
}

bool qTcpServerListen(int64_t ptr, const char* address, uint16_t port) {
    QTcpServer* server = reinterpret_cast<QTcpServer*>(ptr);
    if (!server) {
        return false;
    }
    QHostAddress addr = QHostAddress::Any;
    if (address && address[0] != '\0') {
        addr = QHostAddress(QString::fromUtf8(address));
    }
    bool ok = server->listen(addr, port);
    return ok;
}

void qTcpServerClose(int64_t ptr) {
    QTcpServer* server = reinterpret_cast<QTcpServer*>(ptr);
    if (server) {
        server->close();
    }
}

bool qTcpServerIsListening(int64_t ptr) {
    QTcpServer* server = reinterpret_cast<QTcpServer*>(ptr);
    return server ? server->isListening() : false;
}

uint16_t qTcpServerServerPort(int64_t ptr) {
    QTcpServer* server = reinterpret_cast<QTcpServer*>(ptr);
    return server ? server->serverPort() : 0;
}

const char* qTcpServerServerAddress(int64_t ptr) {
    QTcpServer* server = reinterpret_cast<QTcpServer*>(ptr);
    if (server) {
        return cjqt6::dupUtf8(server->serverAddress().toString());
    }
    return cjqt6::emptyString();
}

const char* qTcpServerErrorString(int64_t ptr) {
    QTcpServer* server = reinterpret_cast<QTcpServer*>(ptr);
    if (server) {
        return cjqt6::dupUtf8(server->errorString());
    }
    return cjqt6::emptyString();
}

int32_t qTcpServerMaxPendingConnections(int64_t ptr) {
    QTcpServer* server = reinterpret_cast<QTcpServer*>(ptr);
    return server ? server->maxPendingConnections() : 0;
}

void qTcpServerSetMaxPendingConnections(int64_t ptr, int32_t count) {
    QTcpServer* server = reinterpret_cast<QTcpServer*>(ptr);
    if (server) {
        server->setMaxPendingConnections(count);
    }
}

bool qTcpServerHasPendingConnections(int64_t ptr) {
    QTcpServer* server = reinterpret_cast<QTcpServer*>(ptr);
    return server ? server->hasPendingConnections() : false;
}

int64_t qTcpServerNextPendingConnection(int64_t ptr) {
    QTcpServer* server = reinterpret_cast<QTcpServer*>(ptr);
    if (!server) {
        return 0;
    }
    QTcpSocket* client = server->nextPendingConnection();
    if (!client) {
        return 0;
    }
    // 脱离 Qt 父子树，生命周期交由仓颉侧 QTcpSocket 包装对象管理
    client->setParent(nullptr);
    return reinterpret_cast<int64_t>(client);
}

void qTcpServerWaitForNewConnection(int64_t ptr, int32_t msec, bool* result) {
    QTcpServer* server = reinterpret_cast<QTcpServer*>(ptr);
    if (server) {
        bool ok = false;
        server->waitForNewConnection(msec, &ok);
        if (result) {
            *result = ok;
        }
    }
}

void qTcpServerConnectNewConnection(int64_t ptr, void (*callback)()) {
    QTcpServer* server = reinterpret_cast<QTcpServer*>(ptr);
    if (server && callback) {
        QMetaObject::Connection oldConn;
        {
            LOCK_NETWORK_CALLBACKS();
            auto cit = g_tcpServerConns.find(ptr);
            if (cit != g_tcpServerConns.end()) {
                oldConn = cit.value();
                g_tcpServerConns.erase(cit);
            }
            g_tcpServerCallbacks[ptr] = callback;
        }
        if (oldConn) {
            QObject::disconnect(oldConn);
        }
        QMetaObject::Connection conn = QObject::connect(server, &QTcpServer::newConnection, [ptr]() {
            std::function<void()> cb;
            {
                LOCK_NETWORK_CALLBACKS();
                auto it = g_tcpServerCallbacks.find(ptr);
                if (it != g_tcpServerCallbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) cb();
        });
        LOCK_NETWORK_CALLBACKS();
        g_tcpServerConns[ptr] = conn;
    }
}

void qTcpServerDisconnectCallbacks(int64_t ptr) {
    QMetaObject::Connection conn;
    {
        LOCK_NETWORK_CALLBACKS();
        g_tcpServerCallbacks.remove(ptr);
        g_tcpServerNewConnIds.remove(ptr);
        auto cit = g_tcpServerConns.find(ptr);
        if (cit != g_tcpServerConns.end()) {
            conn = cit.value();
            g_tcpServerConns.erase(cit);
        }
    }
    if (conn) {
        QObject::disconnect(conn);
    }
}

// ============================================================
// QUdpSocket - UDP套接字
// ============================================================

int64_t qUdpSocketCreate() {
    return reinterpret_cast<int64_t>(new QUdpSocket());
}

void qUdpSocketDelete(int64_t ptr) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    if (socket) {
        {
            LOCK_NETWORK_CALLBACKS();
            g_networkVoidCallbacks.remove(ptr);
        }
        delete socket;
    }
}

bool qUdpSocketBind(int64_t ptr, const char* address, uint16_t port) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    if (socket) {
        QHostAddress addr(address ? QString::fromUtf8(address) : QString());
        return socket->bind(addr, port);
    }
    return false;
}

void qUdpSocketClose(int64_t ptr) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    if (socket) {
        socket->close();
    }
}

int64_t qUdpSocketWriteDatagram(int64_t ptr, const char* data, int64_t size, const char* host, uint16_t port) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    if (socket) {
        QHostAddress addr(QString::fromUtf8(host));
        return socket->writeDatagram(data, size, addr, port);
    }
    return -1;
}

int64_t qUdpSocketReadDatagram(int64_t ptr, char* buffer, int64_t maxSize, char* senderHost, int64_t hostBufferSize, uint16_t* senderPort) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    if (socket) {
        QHostAddress sender;
        quint16 port = 0;
        int64_t size = socket->readDatagram(buffer, maxSize, &sender, &port);
        if (size > 0) {
            if (senderHost && hostBufferSize > 0) {
                QByteArray hostBytes = sender.toString().toUtf8();
                strncpy(senderHost, hostBytes.constData(), hostBufferSize - 1);
                senderHost[hostBufferSize - 1] = '\0';
            }
            if (senderPort) {
                *senderPort = port;
            }
        }
        return size;
    }
    return -1;
}

bool qUdpSocketHasPendingDatagrams(int64_t ptr) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    return socket ? socket->hasPendingDatagrams() : false;
}

int64_t qUdpSocketPendingDatagramSize(int64_t ptr) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    return socket ? socket->pendingDatagramSize() : 0;
}

int32_t qUdpSocketState(int64_t ptr) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    if (socket) {
        return static_cast<int32_t>(socket->state());
    }
    return 0;
}

int32_t qUdpSocketError(int64_t ptr) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    if (socket) {
        return static_cast<int32_t>(socket->error());
    }
    return 0;
}

const char* qUdpSocketErrorString(int64_t ptr) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    if (socket) {
        return cjqt6::dupUtf8(socket->errorString());
    }
    return cjqt6::emptyString();
}

bool qUdpSocketIsValid(int64_t ptr) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    return socket ? socket->isValid() : false;
}

void qUdpSocketConnectReadyRead(int64_t ptr, void (*callback)()) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    if (socket && callback) {
        QMetaObject::Connection oldConn;
        {
            LOCK_NETWORK_CALLBACKS();
            auto cit = g_udpReadyReadConns.find(ptr);
            if (cit != g_udpReadyReadConns.end()) {
                oldConn = cit.value();
                g_udpReadyReadConns.erase(cit);
            }
            g_udpReadyReadCbs[ptr] = callback;
        }
        if (oldConn) {
            QObject::disconnect(oldConn);
        }
        QMetaObject::Connection conn = QObject::connect(socket, &QUdpSocket::readyRead, [ptr]() {
            std::function<void()> cb;
            {
                LOCK_NETWORK_CALLBACKS();
                auto it = g_udpReadyReadCbs.find(ptr);
                if (it != g_udpReadyReadCbs.end()) {
                    cb = it.value();
                }
            }
            if (cb) cb();
        });
        LOCK_NETWORK_CALLBACKS();
        g_udpReadyReadConns[ptr] = conn;
    }
}

void qUdpSocketConnectError(int64_t ptr, void (*callback)()) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    if (socket && callback) {
        QMetaObject::Connection oldConn;
        {
            LOCK_NETWORK_CALLBACKS();
            auto cit = g_udpErrorConns.find(ptr);
            if (cit != g_udpErrorConns.end()) {
                oldConn = cit.value();
                g_udpErrorConns.erase(cit);
            }
            g_udpErrorCbs[ptr] = callback;
        }
        if (oldConn) {
            QObject::disconnect(oldConn);
        }
        QMetaObject::Connection conn = QObject::connect(socket, &QUdpSocket::errorOccurred, [ptr](QAbstractSocket::SocketError) {
            std::function<void()> cb;
            {
                LOCK_NETWORK_CALLBACKS();
                auto it = g_udpErrorCbs.find(ptr);
                if (it != g_udpErrorCbs.end()) {
                    cb = it.value();
                }
            }
            if (cb) cb();
        });
        LOCK_NETWORK_CALLBACKS();
        g_udpErrorConns[ptr] = conn;
    }
}

void qUdpSocketDisconnectCallbacks(int64_t ptr) {
    QMetaObject::Connection conns[2];
    {
        LOCK_NETWORK_CALLBACKS();
            g_networkVoidCallbacks.remove(ptr);
            g_udpReadyReadCbs.remove(ptr);
            g_udpErrorCbs.remove(ptr);
            auto take = [ptr](QHash<int64_t, QMetaObject::Connection>& table, QMetaObject::Connection& out) {
                auto it = table.find(ptr);
                if (it != table.end()) {
                    out = it.value();
                    table.erase(it);
                }
            };
            take(g_udpReadyReadConns, conns[0]);
            take(g_udpErrorConns, conns[1]);
        }
        for (auto& c : conns) {
            if (c) QObject::disconnect(c);
        }
    }



// ============================================================
// QSslSocket - SSL/TLS加密套接字
// ============================================================

int64_t qSslSocketCreate() {
    return reinterpret_cast<int64_t>(new QSslSocket());
}

void qSslSocketDelete(int64_t ptr) {
    QSslSocket* socket = reinterpret_cast<QSslSocket*>(ptr);
    if (socket) {
        QMetaObject::Connection conns[2];
        {
            LOCK_NETWORK_CALLBACKS();
            g_networkVoidCallbacks.remove(ptr);
            g_sslPeerVerifyCbs.remove(ptr);
            auto take = [ptr](QHash<int64_t, QMetaObject::Connection>& table, QMetaObject::Connection& out) {
                auto it = table.find(ptr);
                if (it != table.end()) {
                    out = it.value();
                    table.erase(it);
                }
            };
            take(g_sslEncryptedConns, conns[0]);
            take(g_sslPeerVerifyConns, conns[1]);
        }
        for (auto& c : conns) {
            if (c) QObject::disconnect(c);
        }
        delete socket;
    }
}

void qSslSocketConnectToHostEncrypted(int64_t ptr, const char* host, uint16_t port) {
    QSslSocket* socket = reinterpret_cast<QSslSocket*>(ptr);
    if (socket) {
        socket->connectToHostEncrypted(QString::fromUtf8(host), port);
    }
}

void qSslSocketStartClientEncryption(int64_t ptr) {
    QSslSocket* socket = reinterpret_cast<QSslSocket*>(ptr);
    if (socket) {
        socket->startClientEncryption();
    }
}

void qSslSocketStartServerEncryption(int64_t ptr) {
    QSslSocket* socket = reinterpret_cast<QSslSocket*>(ptr);
    if (socket) {
        socket->startServerEncryption();
    }
}

bool qSslSocketIsEncrypted(int64_t ptr) {
    QSslSocket* socket = reinterpret_cast<QSslSocket*>(ptr);
    return socket ? socket->isEncrypted() : false;
}

int32_t qSslSocketSslMode(int64_t ptr) {
    QSslSocket* socket = reinterpret_cast<QSslSocket*>(ptr);
    return socket ? static_cast<int32_t>(socket->mode()) : 0;
}

void qSslSocketSetPeerVerifyMode(int64_t ptr, int32_t mode) {
    QSslSocket* socket = reinterpret_cast<QSslSocket*>(ptr);
    if (socket) {
        socket->setPeerVerifyMode(static_cast<QSslSocket::PeerVerifyMode>(mode));
    }
}

int32_t qSslSocketPeerVerifyMode(int64_t ptr) {
    QSslSocket* socket = reinterpret_cast<QSslSocket*>(ptr);
    return socket ? static_cast<int32_t>(socket->peerVerifyMode()) : 0;
}

const char* qSslSocketPeerCertificateInfo(int64_t ptr) {
    QSslSocket* socket = reinterpret_cast<QSslSocket*>(ptr);
    if (socket && !socket->peerCertificate().isNull()) {
        QSslCertificate cert = socket->peerCertificate();
        return cjqt6::dupUtf8(cert.subjectDisplayName());
    }
    return cjqt6::emptyString();
}

void qSslSocketConnectEncrypted(int64_t ptr, void (*callback)()) {
    QSslSocket* socket = reinterpret_cast<QSslSocket*>(ptr);
    if (socket && callback) {
        QMetaObject::Connection oldConn;
        {
            LOCK_NETWORK_CALLBACKS();
            auto cit = g_sslEncryptedConns.find(ptr);
            if (cit != g_sslEncryptedConns.end()) {
                oldConn = cit.value();
                g_sslEncryptedConns.erase(cit);
            }
            g_networkVoidCallbacks[ptr] = callback;
        }
        if (oldConn) {
            QObject::disconnect(oldConn);
        }
        QMetaObject::Connection conn = QObject::connect(socket, &QSslSocket::encrypted, [ptr]() {
            std::function<void()> cb;
            {
                LOCK_NETWORK_CALLBACKS();
                auto it = g_networkVoidCallbacks.find(ptr);
                if (it != g_networkVoidCallbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) cb();
        });
        LOCK_NETWORK_CALLBACKS();
        g_sslEncryptedConns[ptr] = conn;
    }
}

void qSslSocketConnectPeerVerifyError(int64_t ptr, void (*callback)(const char*)) {
    QSslSocket* socket = reinterpret_cast<QSslSocket*>(ptr);
    if (socket && callback) {
        QMetaObject::Connection oldConn;
        {
            LOCK_NETWORK_CALLBACKS();
            auto cit = g_sslPeerVerifyConns.find(ptr);
            if (cit != g_sslPeerVerifyConns.end()) {
                oldConn = cit.value();
                g_sslPeerVerifyConns.erase(cit);
            }
            // S5 修复：callback 不再直接捕获进 lambda（断开后仍持有悬垂指针），改为查表派发
            g_sslPeerVerifyCbs[ptr] = callback;
        }
        if (oldConn) {
            QObject::disconnect(oldConn);
        }
        QMetaObject::Connection conn = QObject::connect(socket, &QSslSocket::peerVerifyError, [ptr](const QSslError& error) {
            QByteArray errStr;
            {
                LOCK_NETWORK_CALLBACKS();
                auto it = g_sslPeerVerifyCbs.find(ptr);
                if (it != g_sslPeerVerifyCbs.end()) {
                    errStr = error.errorString().toUtf8();
                    it.value()(errStr.constData());
                }
            }
        });
        LOCK_NETWORK_CALLBACKS();
        g_sslPeerVerifyConns[ptr] = conn;
    }
}

// ============================================================
// QNetworkProxy 桥接函数
// ============================================================

int64_t qNetworkProxyCreate() {
    return reinterpret_cast<int64_t>(new QNetworkProxy());
}

int64_t qNetworkProxyCreateWithType(int32_t proxyType) {
    return reinterpret_cast<int64_t>(new QNetworkProxy(static_cast<QNetworkProxy::ProxyType>(proxyType)));
}

void qNetworkProxyDelete(int64_t ptr) {
    delete reinterpret_cast<QNetworkProxy*>(ptr);
}

void qNetworkProxySetType(int64_t ptr, int32_t proxyType) {
    reinterpret_cast<QNetworkProxy*>(ptr)->setType(static_cast<QNetworkProxy::ProxyType>(proxyType));
}

int32_t qNetworkProxyType(int64_t ptr) {
    return static_cast<int32_t>(reinterpret_cast<QNetworkProxy*>(ptr)->type());
}

void qNetworkProxySetHostName(int64_t ptr, const char* host) {
    reinterpret_cast<QNetworkProxy*>(ptr)->setHostName(QString::fromUtf8(host));
}

const char* qNetworkProxyHostName(int64_t ptr) {
    return cjqt6::dupUtf8(reinterpret_cast<QNetworkProxy*>(ptr)->hostName());
}

void qNetworkProxySetPort(int64_t ptr, uint16_t port) {
    reinterpret_cast<QNetworkProxy*>(ptr)->setPort(port);
}

uint16_t qNetworkProxyPort(int64_t ptr) {
    return reinterpret_cast<QNetworkProxy*>(ptr)->port();
}

void qNetworkProxySetUser(int64_t ptr, const char* user) {
    reinterpret_cast<QNetworkProxy*>(ptr)->setUser(QString::fromUtf8(user));
}

const char* qNetworkProxyUser(int64_t ptr) {
    return cjqt6::dupUtf8(reinterpret_cast<QNetworkProxy*>(ptr)->user());
}

void qNetworkProxySetPassword(int64_t ptr, const char* pass) {
    reinterpret_cast<QNetworkProxy*>(ptr)->setPassword(QString::fromUtf8(pass));
}

const char* qNetworkProxyPassword(int64_t ptr) {
    return cjqt6::dupUtf8(reinterpret_cast<QNetworkProxy*>(ptr)->password());
}

void qNetworkProxySetApplicationProxy(const char* host, uint16_t port) {
    QNetworkProxy proxy(QNetworkProxy::HttpProxy, QString::fromUtf8(host), port);
    QNetworkProxy::setApplicationProxy(proxy);
}

// ============================================================
// QLocalServer 桥接函数
// ============================================================

int64_t qLocalServerCreate() {
    return reinterpret_cast<int64_t>(new QLocalServer());
}

void qLocalServerDelete(int64_t ptr) {
    delete reinterpret_cast<QLocalServer*>(ptr);
}

bool qLocalServerListen(int64_t ptr, const char* name) {
    return reinterpret_cast<QLocalServer*>(ptr)->listen(QString::fromUtf8(name));
}

void qLocalServerClose(int64_t ptr) {
    reinterpret_cast<QLocalServer*>(ptr)->close();
}

bool qLocalServerIsListening(int64_t ptr) {
    return reinterpret_cast<QLocalServer*>(ptr)->isListening();
}

const char* qLocalServerFullServerName(int64_t ptr) {
    return cjqt6::dupUtf8(reinterpret_cast<QLocalServer*>(ptr)->fullServerName());
}

const char* qLocalServerServerName(int64_t ptr) {
    return cjqt6::dupUtf8(reinterpret_cast<QLocalServer*>(ptr)->serverName());
}

int32_t qLocalServerMaxPendingConnections(int64_t ptr) {
    return reinterpret_cast<QLocalServer*>(ptr)->maxPendingConnections();
}

void qLocalServerSetMaxPendingConnections(int64_t ptr, int32_t count) {
    reinterpret_cast<QLocalServer*>(ptr)->setMaxPendingConnections(count);
}

int64_t qLocalServerWaitForNewConnection(int64_t ptr, int32_t msec) {
    bool ok = reinterpret_cast<QLocalServer*>(ptr)->waitForNewConnection(msec, nullptr);
    if (ok) {
        QLocalSocket* client = reinterpret_cast<QLocalServer*>(ptr)->nextPendingConnection();
        return reinterpret_cast<int64_t>(client);
    }
    return 0;
}

bool qLocalServerHasPendingConnections(int64_t ptr) {
    return reinterpret_cast<QLocalServer*>(ptr)->hasPendingConnections();
}

int64_t qLocalServerNextPendingConnection(int64_t ptr) {
    QLocalSocket* client = reinterpret_cast<QLocalServer*>(ptr)->nextPendingConnection();
    return reinterpret_cast<int64_t>(client);
}

void qLocalServerSetSocketOptions(int64_t ptr, int32_t options) {
    reinterpret_cast<QLocalServer*>(ptr)->setSocketOptions(static_cast<QLocalServer::SocketOption>(options));
}

int32_t qLocalServerSocketOptions(int64_t ptr) {
    return static_cast<int32_t>(reinterpret_cast<QLocalServer*>(ptr)->socketOptions());
}

bool qLocalServerRemoveServer(const char* name) {
    return QLocalServer::removeServer(QString::fromUtf8(name));
}

// ============================================================
// id 版回调派发（闭包捕获支持）
//   Cangjie 侧把可捕获闭包存入全局注册表得到 id；native 仅保存 id，
//   信号触发时回调 Cangjie 注册的调度器 g_netVoidDispatcher(id)。
//   用于服务器等多连接场景：每个套接字注册各自的闭包以区分来源。
//   （相关全局表定义见文件顶部回调存储区）
// ============================================================

void qNetSetVoidDispatcher(void (*disp)(int64_t)) {
    g_netVoidDispatcher = disp;
}

static void dispatchNetId(QHash<int64_t, int64_t>& table, int64_t ptr) {
    int64_t id = 0;
    {
        LOCK_NETWORK_CALLBACKS();
        auto it = table.find(ptr);
        if (it != table.end()) {
            id = it.value();
        }
    }
    if (g_netVoidDispatcher && id != 0) {
        g_netVoidDispatcher(id);
    }
}

void qTcpSocketConnectConnectedId(int64_t ptr, int64_t id) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket && id != 0) {
        {
            LOCK_NETWORK_CALLBACKS();
            g_tcpConnectedIds[ptr] = id;
        }
        QObject::connect(socket, &QTcpSocket::connected, [ptr]() {
            dispatchNetId(g_tcpConnectedIds, ptr);
        });
    }
}

void qTcpSocketConnectDisconnectedId(int64_t ptr, int64_t id) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket && id != 0) {
        {
            LOCK_NETWORK_CALLBACKS();
            g_tcpDisconnectedIds[ptr] = id;
        }
        QObject::connect(socket, &QTcpSocket::disconnected, [ptr]() {
            dispatchNetId(g_tcpDisconnectedIds, ptr);
        });
    }
}

void qTcpSocketConnectReadyReadId(int64_t ptr, int64_t id) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket && id != 0) {
        {
            LOCK_NETWORK_CALLBACKS();
            g_tcpReadyReadIds[ptr] = id;
        }
        QObject::connect(socket, &QTcpSocket::readyRead, [ptr]() {
            dispatchNetId(g_tcpReadyReadIds, ptr);
        });
    }
}

void qTcpSocketConnectErrorId(int64_t ptr, int64_t id) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket && id != 0) {
        {
            LOCK_NETWORK_CALLBACKS();
            g_tcpErrorIds[ptr] = id;
        }
        QObject::connect(socket, &QTcpSocket::errorOccurred, [ptr](QAbstractSocket::SocketError) {
            dispatchNetId(g_tcpErrorIds, ptr);
        });
    }
}

void qTcpServerConnectNewConnectionId(int64_t ptr, int64_t id) {
    QTcpServer* server = reinterpret_cast<QTcpServer*>(ptr);
    if (server && id != 0) {
        {
            LOCK_NETWORK_CALLBACKS();
            g_tcpServerNewConnIds[ptr] = id;
        }
        QObject::connect(server, &QTcpServer::newConnection, [ptr]() {
            dispatchNetId(g_tcpServerNewConnIds, ptr);
        });
    } else {
    }
}

// id 表清理辅助（调用方必须已持有网络回调自旋锁（LOCK_NETWORK_CALLBACKS））
static void removeTcpSocketIdEntriesLocked(int64_t ptr) {
    g_tcpConnectedIds.remove(ptr);
    g_tcpDisconnectedIds.remove(ptr);
    g_tcpReadyReadIds.remove(ptr);
    g_tcpErrorIds.remove(ptr);
}

} // extern "C"
