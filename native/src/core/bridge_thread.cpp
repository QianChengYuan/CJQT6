/**
 * @file bridge_thread.cpp
 * @brief QThread / QThreadPool / QRunnable 桥接函数
 */

#include <QThread>
#include <QThreadPool>
#include <QRunnable>
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
static std::atomic_flag g_threadLockFlag = ATOMIC_FLAG_INIT;

class ThreadSpinLock {
public:
    ThreadSpinLock() {
        while (g_threadLockFlag.test_and_set(std::memory_order_acquire)) {
            std::this_thread::yield();
        }
    }
    ~ThreadSpinLock() {
        g_threadLockFlag.clear(std::memory_order_release);
    }
};

static QHash<int64_t, std::function<void()>> g_threadVoidCallbacks;

#define LOCK_THREAD_CALLBACKS() ThreadSpinLock _threadLock

// ============================================================
// QRunnable wrapper - 允许仓颉创建可运行任务
// ============================================================

class CjRunnable : public QRunnable {
public:
    CjRunnable(void (*callback)()) : m_callback(callback) {
        setAutoDelete(true);
    }

    void run() override {
        if (m_callback) {
            m_callback();
        }
    }

private:
    void (*m_callback)();
};

int64_t qRunnableCreate(void (*callback)()) {
    CjRunnable* runnable = new CjRunnable(callback);
    return reinterpret_cast<int64_t>(runnable);
}

void qRunnableDelete(int64_t ptr) {
    CjRunnable* runnable = reinterpret_cast<CjRunnable*>(ptr);
    if (runnable) delete runnable;
}

// ============================================================
// QThread 桥接函数
// ============================================================

int64_t qThreadCreate() {
    return reinterpret_cast<int64_t>(new QThread());
}

void qThreadDelete(int64_t ptr) {
    QThread* thread = reinterpret_cast<QThread*>(ptr);
    if (thread) {
        {
            LOCK_THREAD_CALLBACKS();
            g_threadVoidCallbacks.remove(ptr);
        }
        delete thread;
    }
}

void qThreadStart(int64_t ptr) {
    QThread* thread = reinterpret_cast<QThread*>(ptr);
    if (thread) thread->start();
}

void qThreadQuit(int64_t ptr) {
    QThread* thread = reinterpret_cast<QThread*>(ptr);
    if (thread) thread->quit();
}

bool qThreadWait(int64_t ptr, int32_t timeoutMs) {
    QThread* thread = reinterpret_cast<QThread*>(ptr);
    if (thread) {
        if (timeoutMs < 0) return thread->wait();
        return thread->wait(static_cast<unsigned long>(timeoutMs));
    }
    return true;
}

bool qThreadIsRunning(int64_t ptr) {
    QThread* thread = reinterpret_cast<QThread*>(ptr);
    return thread ? thread->isRunning() : false;
}

bool qThreadIsFinished(int64_t ptr) {
    QThread* thread = reinterpret_cast<QThread*>(ptr);
    return thread ? thread->isFinished() : false;
}

void qThreadSetPriority(int64_t ptr, int32_t priority) {
    QThread* thread = reinterpret_cast<QThread*>(ptr);
    if (thread) {
        thread->setPriority(static_cast<QThread::Priority>(priority));
    }
}

int32_t qThreadPriority(int64_t ptr) {
    QThread* thread = reinterpret_cast<QThread*>(ptr);
    if (thread) return static_cast<int32_t>(thread->priority());
    return 0;
}

void qThreadSetStackSize(int64_t ptr, int64_t stackSize) {
    QThread* thread = reinterpret_cast<QThread*>(ptr);
    if (thread) thread->setStackSize(static_cast<uint>(stackSize));
}

int64_t qThreadStackSize(int64_t ptr) {
    QThread* thread = reinterpret_cast<QThread*>(ptr);
    if (thread) return static_cast<int64_t>(thread->stackSize());
    return 0;
}

void qThreadExit(int64_t ptr) {
    QThread* thread = reinterpret_cast<QThread*>(ptr);
    if (thread) thread->exit();
}

bool qThreadIsInterruptionRequested(int64_t ptr) {
    QThread* thread = reinterpret_cast<QThread*>(ptr);
    return thread ? thread->isInterruptionRequested() : true;
}

void qThreadRequestInterruption(int64_t ptr) {
    QThread* thread = reinterpret_cast<QThread*>(ptr);
    if (thread) thread->requestInterruption();
}

// 静态方法
int64_t qThreadCurrentThread() {
    return reinterpret_cast<int64_t>(QThread::currentThread());
}

int64_t qThreadIdealThreadCount() {
    return static_cast<int64_t>(QThread::idealThreadCount());
}

void qThreadMsleep(int32_t ms) {
    QThread::msleep(static_cast<unsigned long>(ms));
}

// 信号连接
void qThreadConnectStarted(int64_t ptr, void (*callback)()) {
    QThread* thread = reinterpret_cast<QThread*>(ptr);
    if (thread && callback) {
        LOCK_THREAD_CALLBACKS();
        g_threadVoidCallbacks[ptr] = callback;
        QObject::connect(thread, &QThread::started, [ptr]() {
            std::function<void()> cb;
            {
                LOCK_THREAD_CALLBACKS();
                auto it = g_threadVoidCallbacks.find(ptr);
                if (it != g_threadVoidCallbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) cb();
        });
    }
}

void qThreadConnectFinished(int64_t ptr, void (*callback)()) {
    QThread* thread = reinterpret_cast<QThread*>(ptr);
    if (thread && callback) {
        LOCK_THREAD_CALLBACKS();
        g_threadVoidCallbacks[ptr] = callback;
        QObject::connect(thread, &QThread::finished, [ptr]() {
            std::function<void()> cb;
            {
                LOCK_THREAD_CALLBACKS();
                auto it = g_threadVoidCallbacks.find(ptr);
                if (it != g_threadVoidCallbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) cb();
        });
    }
}

void qThreadDisconnectCallbacks(int64_t ptr) {
    LOCK_THREAD_CALLBACKS();
    g_threadVoidCallbacks.remove(ptr);
}

// ============================================================
// QThreadPool 桥接函数
// ============================================================

int64_t qThreadPoolGlobalInstance() {
    return reinterpret_cast<int64_t>(QThreadPool::globalInstance());
}

void qThreadPoolStart(int64_t ptr, int64_t runnablePtr) {
    QThreadPool* pool = reinterpret_cast<QThreadPool*>(ptr);
    QRunnable* runnable = reinterpret_cast<QRunnable*>(runnablePtr);
    if (pool && runnable) pool->start(runnable);
}

bool qThreadPoolWaitForDone(int64_t ptr, int32_t timeoutMs) {
    QThreadPool* pool = reinterpret_cast<QThreadPool*>(ptr);
    if (pool) {
        if (timeoutMs < 0) return pool->waitForDone();
        return pool->waitForDone(timeoutMs);
    }
    return true;
}

int32_t qThreadPoolActiveThreadCount(int64_t ptr) {
    QThreadPool* pool = reinterpret_cast<QThreadPool*>(ptr);
    return pool ? pool->activeThreadCount() : 0;
}

int32_t qThreadPoolMaxThreadCount(int64_t ptr) {
    QThreadPool* pool = reinterpret_cast<QThreadPool*>(ptr);
    return pool ? pool->maxThreadCount() : 0;
}

void qThreadPoolSetMaxThreadCount(int64_t ptr, int32_t count) {
    QThreadPool* pool = reinterpret_cast<QThreadPool*>(ptr);
    if (pool) pool->setMaxThreadCount(count);
}

int32_t qThreadPoolExpiryTimeout(int64_t ptr) {
    QThreadPool* pool = reinterpret_cast<QThreadPool*>(ptr);
    return pool ? pool->expiryTimeout() : 0;
}

void qThreadPoolSetExpiryTimeout(int64_t ptr, int32_t timeout) {
    QThreadPool* pool = reinterpret_cast<QThreadPool*>(ptr);
    if (pool) pool->setExpiryTimeout(timeout);
}

} // extern "C"
