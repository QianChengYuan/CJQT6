/**
 * @file bridge_network.cpp
 * @brief QtNetwork模块桥接实现
 */

#include <QHostAddress>
#include <QTcpSocket>
#include <QUdpSocket>
#include <QSslSocket>
#include <QSslCertificate>
#include <QAbstractSocket>
#include <QNetworkProxy>
#include <QLocalServer>
#include <QLocalSocket>
#include <QDebug>
#include <QHash>
#include <functional>
#include <mutex>

extern "C" {

// ============================================================
// 线程安全回调存储
// ============================================================

static std::mutex g_networkCallbackMutex;
static QHash<int64_t, std::function<void()>> g_networkVoidCallbacks;

#define LOCK_NETWORK_CALLBACKS() std::lock_guard<std::mutex> lock(g_networkCallbackMutex)

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
        static QByteArray buffer;
        buffer = addr->toString().toUtf8();
        return buffer.constData();
    }
    return "";
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
        {
            LOCK_NETWORK_CALLBACKS();
            g_networkVoidCallbacks.remove(ptr);
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
        static QByteArray buffer;
        buffer = socket->errorString().toUtf8();
        return buffer.constData();
    }
    return "";
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

// 信号连接
void qTcpSocketConnectConnected(int64_t ptr, void (*callback)()) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket && callback) {
        LOCK_NETWORK_CALLBACKS();
        g_networkVoidCallbacks[ptr] = callback;
        QObject::connect(socket, &QTcpSocket::connected, [ptr]() {
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
    }
}

void qTcpSocketConnectDisconnected(int64_t ptr, void (*callback)()) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket && callback) {
        LOCK_NETWORK_CALLBACKS();
        g_networkVoidCallbacks[ptr] = callback;
        QObject::connect(socket, &QTcpSocket::disconnected, [ptr]() {
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
    }
}

void qTcpSocketConnectReadyRead(int64_t ptr, void (*callback)()) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket && callback) {
        LOCK_NETWORK_CALLBACKS();
        g_networkVoidCallbacks[ptr] = callback;
        QObject::connect(socket, &QTcpSocket::readyRead, [ptr]() {
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
    }
}

void qTcpSocketConnectError(int64_t ptr, void (*callback)()) {
    QTcpSocket* socket = reinterpret_cast<QTcpSocket*>(ptr);
    if (socket && callback) {
        LOCK_NETWORK_CALLBACKS();
        g_networkVoidCallbacks[ptr] = callback;
        QObject::connect(socket, &QTcpSocket::errorOccurred, [ptr](QAbstractSocket::SocketError) {
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
    }
}

void qTcpSocketDisconnectCallbacks(int64_t ptr) {
    LOCK_NETWORK_CALLBACKS();
    g_networkVoidCallbacks.remove(ptr);
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
        static QByteArray buffer;
        buffer = socket->errorString().toUtf8();
        return buffer.constData();
    }
    return "";
}

bool qUdpSocketIsValid(int64_t ptr) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    return socket ? socket->isValid() : false;
}

void qUdpSocketConnectReadyRead(int64_t ptr, void (*callback)()) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    if (socket && callback) {
        LOCK_NETWORK_CALLBACKS();
        g_networkVoidCallbacks[ptr] = callback;
        QObject::connect(socket, &QUdpSocket::readyRead, [ptr]() {
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
    }
}

void qUdpSocketConnectError(int64_t ptr, void (*callback)()) {
    QUdpSocket* socket = reinterpret_cast<QUdpSocket*>(ptr);
    if (socket && callback) {
        LOCK_NETWORK_CALLBACKS();
        g_networkVoidCallbacks[ptr] = callback;
        QObject::connect(socket, &QUdpSocket::errorOccurred, [ptr](QAbstractSocket::SocketError) {
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
    }
}

void qUdpSocketDisconnectCallbacks(int64_t ptr) {
    LOCK_NETWORK_CALLBACKS();
    g_networkVoidCallbacks.remove(ptr);
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
        {
            LOCK_NETWORK_CALLBACKS();
            g_networkVoidCallbacks.remove(ptr);
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
        static QByteArray buffer;
        QSslCertificate cert = socket->peerCertificate();
        buffer = cert.subjectDisplayName().toUtf8();
        return buffer.constData();
    }
    return "";
}

void qSslSocketConnectEncrypted(int64_t ptr, void (*callback)()) {
    QSslSocket* socket = reinterpret_cast<QSslSocket*>(ptr);
    if (socket && callback) {
        LOCK_NETWORK_CALLBACKS();
        g_networkVoidCallbacks[ptr] = callback;
        QObject::connect(socket, &QSslSocket::encrypted, [ptr]() {
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
    }
}

void qSslSocketConnectPeerVerifyError(int64_t ptr, void (*callback)(const char*)) {
    QSslSocket* socket = reinterpret_cast<QSslSocket*>(ptr);
    if (socket && callback) {
        QObject::connect(socket, &QSslSocket::peerVerifyError, [ptr, callback](const QSslError& error) {
            QByteArray errStr = error.errorString().toUtf8();
            callback(errStr.constData());
        });
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

static QByteArray netBuffer;
const char* qNetworkProxyHostName(int64_t ptr) {
    netBuffer = reinterpret_cast<QNetworkProxy*>(ptr)->hostName().toUtf8();
    return netBuffer.constData();
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
    netBuffer = reinterpret_cast<QNetworkProxy*>(ptr)->user().toUtf8();
    return netBuffer.constData();
}

void qNetworkProxySetPassword(int64_t ptr, const char* pass) {
    reinterpret_cast<QNetworkProxy*>(ptr)->setPassword(QString::fromUtf8(pass));
}

const char* qNetworkProxyPassword(int64_t ptr) {
    netBuffer = reinterpret_cast<QNetworkProxy*>(ptr)->password().toUtf8();
    return netBuffer.constData();
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
    netBuffer = reinterpret_cast<QLocalServer*>(ptr)->fullServerName().toUtf8();
    return netBuffer.constData();
}

const char* qLocalServerServerName(int64_t ptr) {
    netBuffer = reinterpret_cast<QLocalServer*>(ptr)->serverName().toUtf8();
    return netBuffer.constData();
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

} // extern "C"
