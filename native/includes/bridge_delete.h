#ifndef CJQT6_BRIDGE_DELETE_H
#define CJQT6_BRIDGE_DELETE_H

/**
 * @file bridge_delete.h
 * @brief 跨线程安全的 QObject 删除入口（P1-5 根治）
 *
 * 背景：Qt 要求 QObject（尤其顶层 QWidget）在其**所属线程**销毁。在其它线程直接
 * delete 一个「已显示」的顶层 QWidget，会阻塞在
 *   QWidget::~QWidget → QWindow::close() → QWindowSystemInterface::flushWindowSystemEvents()
 *   → QWaitCondition::wait()
 * 上永久挂起（CPU 0%、不会自愈）。详见 docs/internal/cjmonitor-findings.md P1-5。
 *
 * 桥接层所有 qXxxDelete 统一走本入口，按类型与状态分流：
 *   1) 调用线程 == 对象所属线程 → 立即 delete（原有同步语义，行为不变）；
 *   2) 非所属线程，且对象是**已创建平台窗口**的 QWidget（windowHandle() 非空，
 *      即 P1-5 唯一实测会挂死的形态）→ deleteLater()：Qt 官方跨线程销毁方式，
 *      内部 postEvent 线程安全，销毁排队到对象所属线程的事件循环执行，调用方立即返回；
 *   3) 其它情况（非 QObject 值类型、未建窗口的 QWidget、非 widget 的 QObject）→
 *      仍为裸 delete，与改造前**完全一致**。
 *
 * 为什么只延迟「已建窗口的 QWidget」：只有它在析构时会同步 flush（即 P1-5 的挂死路径）。
 * 其余对象的删除若也推迟到事件循环，会让调用方/用例对「删除已完成」的时序假设失效
 * （实测会让依赖同步销毁的信号用例报错），属于不必要的语义变更。
 *
 * 取舍：延迟删除意味着对象在其所属线程跑到事件循环前短暂存续；若该线程**始终**没有
 * 事件循环（如仓颉测试框架的 worker 线程），该对象将滞留（有界泄漏）。这是刻意选择：
 * 用「有界滞留」换掉「永久挂死」。
 */

#include <QObject>
#include <QThread>
#include <QWidget>
#include <type_traits>

template <typename T>
inline void cjqt6SafeDelete(T* obj) {
    if (!obj) {
        return;
    }
    if constexpr (std::is_base_of<QObject, T>::value) {
        // 无 QApplication 时对象都归属当前线程，直接落到下面的 delete 分支，行为不变
        if (QThread::currentThread() != obj->thread()) {
            QWidget* widget = qobject_cast<QWidget*>(static_cast<QObject*>(obj));
            if (widget != nullptr && widget->windowHandle() != nullptr) {
                widget->deleteLater();
                return;
            }
        }
    }
    delete obj;
}

#endif // CJQT6_BRIDGE_DELETE_H
