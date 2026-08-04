/**
 * @file bridge_network_access.cpp
 * @brief QNetworkAccessManager / QNetworkRequest / QNetworkReply 桥接函数
 */

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QHash>
#include <functional>
#include <mutex>
#include <atomic>
#include <thread>

extern "C" {

// ============================================================
// 线程安全回调存储
// ============================================================

// atomic_flag 自旋锁：std::mutex 在 Cangjie 运行时加载的 DLL 中首次加锁即死锁
static std::atomic_flag g_namLockFlag = ATOMIC_FLAG_INIT;

class NamSpinLock {
public:
    NamSpinLock() {
        while (g_namLockFlag.test_and_set(std::memory_order_acquire)) {
            std::this_thread::yield();
        }
    }
    ~NamSpinLock() {
        g_namLockFlag.clear(std::memory_order_release);
    }
};

static QHash<int64_t, std::function<void(int64_t)>> g_namReplyCallbacks;

#define LOCK_NAM_CALLBACKS() NamSpinLock _namLock

// ============================================================
// QNetworkRequest 桥接函数
// ============================================================

int64_t qNetworkRequestCreate(const char* url) {
    QUrl qurl = url ? QUrl(QString::fromUtf8(url)) : QUrl();
    return reinterpret_cast<int64_t>(new QNetworkRequest(qurl));
}

void qNetworkRequestDelete(int64_t ptr) {
    delete reinterpret_cast<QNetworkRequest*>(ptr);
}

void qNetworkRequestSetUrl(int64_t ptr, const char* url) {
    QNetworkRequest* req = reinterpret_cast<QNetworkRequest*>(ptr);
    if (req) req->setUrl(QUrl(QString::fromUtf8(url)));
}

const char* qNetworkRequestUrl(int64_t ptr) {
    QNetworkRequest* req = reinterpret_cast<QNetworkRequest*>(ptr);
    static QByteArray buffer;
    if (req) {
        buffer = req->url().toString().toUtf8();
        return buffer.constData();
    }
    return "";
}

void qNetworkRequestSetHeader(int64_t ptr, int32_t header, const char* value) {
    QNetworkRequest* req = reinterpret_cast<QNetworkRequest*>(ptr);
    if (req) {
        req->setHeader(static_cast<QNetworkRequest::KnownHeaders>(header), QVariant(QString::fromUtf8(value)));
    }
}

const char* qNetworkRequestHeader(int64_t ptr, int32_t header) {
    QNetworkRequest* req = reinterpret_cast<QNetworkRequest*>(ptr);
    static QByteArray buffer;
    if (req) {
        buffer = req->header(static_cast<QNetworkRequest::KnownHeaders>(header)).toString().toUtf8();
        return buffer.constData();
    }
    return "";
}

void qNetworkRequestSetRawHeader(int64_t ptr, const char* name, const char* value) {
    QNetworkRequest* req = reinterpret_cast<QNetworkRequest*>(ptr);
    if (req) {
        req->setRawHeader(name, value);
    }
}

void qNetworkRequestSetTransferTimeout(int64_t ptr, int32_t timeoutMs) {
    QNetworkRequest* req = reinterpret_cast<QNetworkRequest*>(ptr);
    if (req) req->setTransferTimeout(timeoutMs);
}

// ============================================================
// QNetworkReply 桥接函数
// ============================================================

const char* qNetworkReplyReadAll(int64_t ptr) {
    QNetworkReply* reply = reinterpret_cast<QNetworkReply*>(ptr);
    static QByteArray buffer;
    if (reply) {
        buffer = reply->readAll();
        return buffer.constData();
    }
    return "";
}

int64_t qNetworkReplyBytesAvailable(int64_t ptr) {
    QNetworkReply* reply = reinterpret_cast<QNetworkReply*>(ptr);
    return reply ? reply->bytesAvailable() : 0;
}

int32_t qNetworkReplyError(int64_t ptr) {
    QNetworkReply* reply = reinterpret_cast<QNetworkReply*>(ptr);
    if (reply) return static_cast<int32_t>(reply->error());
    return 0;
}

const char* qNetworkReplyErrorString(int64_t ptr) {
    QNetworkReply* reply = reinterpret_cast<QNetworkReply*>(ptr);
    static QByteArray buffer;
    if (reply) {
        buffer = reply->errorString().toUtf8();
        return buffer.constData();
    }
    return "";
}

int32_t qNetworkReplyStatusCode(int64_t ptr) {
    QNetworkReply* reply = reinterpret_cast<QNetworkReply*>(ptr);
    if (reply) {
        return reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    }
    return 0;
}

const char* qNetworkReplyHeader(int64_t ptr, int32_t header) {
    QNetworkReply* reply = reinterpret_cast<QNetworkReply*>(ptr);
    static QByteArray buffer;
    if (reply) {
        buffer = reply->header(static_cast<QNetworkRequest::KnownHeaders>(header)).toString().toUtf8();
        return buffer.constData();
    }
    return "";
}

bool qNetworkReplyIsFinished(int64_t ptr) {
    QNetworkReply* reply = reinterpret_cast<QNetworkReply*>(ptr);
    return reply ? reply->isFinished() : true;
}

bool qNetworkReplyIsRunning(int64_t ptr) {
    QNetworkReply* reply = reinterpret_cast<QNetworkReply*>(ptr);
    return reply ? reply->isRunning() : false;
}

void qNetworkReplyAbort(int64_t ptr) {
    QNetworkReply* reply = reinterpret_cast<QNetworkReply*>(ptr);
    if (reply) reply->abort();
}

void qNetworkReplyClose(int64_t ptr) {
    QNetworkReply* reply = reinterpret_cast<QNetworkReply*>(ptr);
    if (reply) reply->close();
}

void qNetworkReplyDelete(int64_t ptr) {
    QNetworkReply* reply = reinterpret_cast<QNetworkReply*>(ptr);
    if (reply) {
        {
            LOCK_NAM_CALLBACKS();
            g_namReplyCallbacks.remove(ptr);
        }
        reply->deleteLater();
    }
}

const char* qNetworkReplyUrl(int64_t ptr) {
    QNetworkReply* reply = reinterpret_cast<QNetworkReply*>(ptr);
    static QByteArray buffer;
    if (reply) {
        buffer = reply->url().toString().toUtf8();
        return buffer.constData();
    }
    return "";
}

// ============================================================
// QNetworkAccessManager 桥接函数
// ============================================================

int64_t qNetworkAccessManagerCreate() {
    return reinterpret_cast<int64_t>(new QNetworkAccessManager());
}

void qNetworkAccessManagerDelete(int64_t ptr) {
    QNetworkAccessManager* manager = reinterpret_cast<QNetworkAccessManager*>(ptr);
    if (manager) {
        {
            LOCK_NAM_CALLBACKS();
            g_namReplyCallbacks.remove(ptr);
        }
        delete manager;
    }
}

int64_t qNetworkAccessManagerGet(int64_t ptr, int64_t requestPtr) {
    QNetworkAccessManager* manager = reinterpret_cast<QNetworkAccessManager*>(ptr);
    QNetworkRequest* request = reinterpret_cast<QNetworkRequest*>(requestPtr);
    if (manager && request) {
        QNetworkReply* reply = manager->get(*request);
        return reinterpret_cast<int64_t>(reply);
    }
    return 0;
}

int64_t qNetworkAccessManagerPost(int64_t ptr, int64_t requestPtr, const char* data) {
    QNetworkAccessManager* manager = reinterpret_cast<QNetworkAccessManager*>(ptr);
    QNetworkRequest* request = reinterpret_cast<QNetworkRequest*>(requestPtr);
    if (manager && request) {
        QByteArray postData = data ? QByteArray::fromStdString(data) : QByteArray();
        QNetworkReply* reply = manager->post(*request, postData);
        return reinterpret_cast<int64_t>(reply);
    }
    return 0;
}

int64_t qNetworkAccessManagerPut(int64_t ptr, int64_t requestPtr, const char* data) {
    QNetworkAccessManager* manager = reinterpret_cast<QNetworkAccessManager*>(ptr);
    QNetworkRequest* request = reinterpret_cast<QNetworkRequest*>(requestPtr);
    if (manager && request) {
        QByteArray putData = data ? QByteArray::fromStdString(data) : QByteArray();
        QNetworkReply* reply = manager->put(*request, putData);
        return reinterpret_cast<int64_t>(reply);
    }
    return 0;
}

int64_t qNetworkAccessManagerDeleteResource(int64_t ptr, int64_t requestPtr) {
    QNetworkAccessManager* manager = reinterpret_cast<QNetworkAccessManager*>(ptr);
    QNetworkRequest* request = reinterpret_cast<QNetworkRequest*>(requestPtr);
    if (manager && request) {
        QNetworkReply* reply = manager->deleteResource(*request);
        return reinterpret_cast<int64_t>(reply);
    }
    return 0;
}

void qNetworkAccessManagerSetTransferTimeout(int64_t ptr, int32_t timeoutMs) {
    QNetworkAccessManager* manager = reinterpret_cast<QNetworkAccessManager*>(ptr);
    if (manager) manager->setTransferTimeout(timeoutMs);
}

// 信号连接
void qNetworkReplyConnectFinished(int64_t ptr, void (*callback)(int64_t)) {
    QNetworkReply* reply = reinterpret_cast<QNetworkReply*>(ptr);
    if (reply && callback) {
        LOCK_NAM_CALLBACKS();
        g_namReplyCallbacks[ptr] = callback;
        QObject::connect(reply, &QNetworkReply::finished, [ptr]() {
            std::function<void(int64_t)> cb;
            {
                LOCK_NAM_CALLBACKS();
                auto it = g_namReplyCallbacks.find(ptr);
                if (it != g_namReplyCallbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) cb(ptr);
        });
    }
}

void qNetworkReplyDisconnectCallbacks(int64_t ptr) {
    LOCK_NAM_CALLBACKS();
    g_namReplyCallbacks.remove(ptr);
}

} // extern "C"
