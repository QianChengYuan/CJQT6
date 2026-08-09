/**
 * @file bridge_ui_poster.cpp
 * @brief UiPoster 桥接 —— 跨线程回投 UI 线程的唯一出口（P1）
 *
 * 仓颉 spawn 出的工作线程没有 Qt 事件循环，消息必须投递到 GUI 线程的事件队列。
 * 本文件提供唯一投递载体：qUiPosterPost 从任意线程调用，经
 * QMetaObject::invokeMethod(Qt::QueuedConnection) 把任务（Cangjie 侧注册的
 * 回调 id）投递到 QCoreApplication（GUI 线程对象）的事件队列；GUI 线程事件
 * 循环取出后调用 g_voidDispatcher(id)，由 Cangjie 侧按 id 查注册表执行闭包。
 *
 * 约束：所有 runOnUiThread / 异步回投都必须走本入口，禁止各模块自建
 * QTimer / 自建投递路径，否则连接类型、线程亲和、释放时序会散乱失控。
 */

#include <QCoreApplication>
#include <QMetaObject>
#include <cstdint>

// bridge_signal.cpp 内 Cangjie 注册的 void 调度器（native 侧按 id 派发闭包）
extern "C" void (*qGetVoidDispatcher())(int64_t);

extern "C" {

/**
 * 把一个已注册的 Cangjie 回调 id 投递到 GUI 线程事件队列。
 * @param id 由 Cangjie 侧 registerVoidCallback 返回的注册表 id（0 忽略）
 */
void qUiPosterPost(int64_t id) {
    QCoreApplication* app = QCoreApplication::instance();
    if (!app || id == 0) return;
    QMetaObject::invokeMethod(app, [id]() {
        void (*disp)(int64_t) = qGetVoidDispatcher();
        if (disp) {
            disp(id);
        }
    }, Qt::QueuedConnection);
}

} // extern "C"
