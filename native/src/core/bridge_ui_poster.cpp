/**
 * @file bridge_ui_poster.cpp
 * @brief UiPoster 桥接 —— 跨线程回投 UI 线程的唯一出口（P1）
 *
 * 仓颉 spawn 出的工作线程没有 Qt 事件循环，消息必须投递到目标线程的事件队列。
 * 本文件提供唯一投递载体：qUiPosterPost(threadPtr, id) 从任意线程调用，
 * 经 QMetaObject::invokeMethod(Qt::QueuedConnection) 把任务（Cangjie 侧注册的
 * 回调 id）投递到目标线程（threadPtr 对应的 QThread）的 poster QObject；
 * 目标线程事件循环取出后调用 g_voidDispatcher(id)，由 Cangjie 侧按 id
 * 查注册表执行闭包。
 *
 * 线程模型：目标线程 = 调用 runOnUiThread / runAsync 的线程（仓颉侧记录
 * QThread.currentThreadPtr 并传入）。每个线程维护独立的 PosterCtx：
 *   - exec 未运行时（qUiPosterPost 在事件循环启动前调用）：投递先积压，
 *     等该线程 qSetGuiThreadForPoster（exec 启动）时统一补发；
 *   - exec 运行中：直接 QueuedConnection 投递到本线程的 poster QObject。
 *
 * 约束：所有 runOnUiThread / 异步回投都必须走本入口，禁止各模块自建
 * QTimer / 自建投递路径，否则连接类型、线程亲和、释放时序会散乱失控。
 */

#include <QMetaObject>
#include <QObject>
#include <QThread>
#include <atomic>
#include <cstdint>
#include <mutex>
#include <thread>
#include <unordered_map>
#include <vector>

// bridge_signal.cpp 内 Cangjie 注册的 void 调度器（native 侧按 id 派发闭包）
extern "C" void (*qGetVoidDispatcher())(int64_t);


namespace {

struct PosterCtx {
    QObject* target = nullptr;        // 投递目标（线程亲和 = 本线程）
    std::vector<int64_t> pending;     // exec 未运行期间积压的回调 id
    bool loopRunning = false;         // 本线程事件循环是否在运行
};

// 线程安全：atomic_flag 自旋锁（与 bridge_signal.cpp 一致）。
// 不能用 std::mutex：其底层 CRT/OS 原始锁在 Cangjie 运行时加载的 DLL 中
// 首次加锁即死锁（已实测：连栈上新构造的 std::mutex::try_lock 都会卡死）。
static std::atomic_flag g_posterLockFlag = ATOMIC_FLAG_INIT;

class PosterSpinLock {
public:
    PosterSpinLock() {
        while (g_posterLockFlag.test_and_set(std::memory_order_acquire)) {
            std::this_thread::yield();
        }
    }
    ~PosterSpinLock() {
        g_posterLockFlag.clear(std::memory_order_release);
    }
};

std::unordered_map<QThread*, PosterCtx*> g_posterMap;

PosterCtx* getOrCreateCtxLocked(QThread* thread) {
    auto it = g_posterMap.find(thread);
    if (it != g_posterMap.end()) {
        return it->second;
    }
    PosterCtx* ctx = new PosterCtx();
    ctx->target = new QObject();
    g_posterMap[thread] = ctx;
    return ctx;
}

void postToTargetLocked(PosterCtx* ctx, int64_t id) {
    QMetaObject::invokeMethod(ctx->target, [id]() {
        void (*disp)(int64_t) = qGetVoidDispatcher();
        if (disp) {
            disp(id);
        }
    }, Qt::QueuedConnection);
}

} // namespace

extern "C" {

/// 由 qApplicationExec 调用：标记当前线程事件循环已启动，并补发积压任务。
/// 必须在即将运行 QEventLoop 的线程调用。
void qSetGuiThreadForPoster() {
    QThread* cur = QThread::currentThread();
    PosterSpinLock _posterLock;
    PosterCtx* ctx = getOrCreateCtxLocked(cur);
    ctx->loopRunning = true;
    for (int64_t id : ctx->pending) {
        postToTargetLocked(ctx, id);
    }
    ctx->pending.clear();
}

/// 由 qApplicationExec 调用：事件循环退出后标记无循环运行，
/// 后续投递进入积压队列。
void qUnsetGuiThreadForPoster() {
    QThread* cur = QThread::currentThread();
    PosterSpinLock _posterLock;
    auto it = g_posterMap.find(cur);
    if (it != g_posterMap.end()) {
        it->second->loopRunning = false;
    }
    
}

/**
 * 把一个已注册的 Cangjie 回调 id 投递到目标线程（threadPtr）事件队列。
 * @param threadPtr 目标 QThread*（仓颉侧 QThread.currentThreadPtr() 记录）
 * @param id        由 Cangjie 侧 registerVoidCallback 返回的注册表 id（0 忽略）
 */
void qUiPosterPost(int64_t threadPtr, int64_t id) {
    if (id == 0) {
        return;
    }
    QThread* target = reinterpret_cast<QThread*>(threadPtr);
    PosterSpinLock _posterLock;
    PosterCtx* ctx = getOrCreateCtxLocked(target);
    if (!ctx->loopRunning) {
        // 目标线程事件循环未运行：先积压，等该线程 exec 启动时补发，
        // 避免事件落进无人消费的线程队列。
        ctx->pending.push_back(id);
        
        return;
    }
    postToTargetLocked(ctx, id);
    
}

} // extern "C"
