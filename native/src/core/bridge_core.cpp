/**
 * @file bridge_core.cpp
 * @brief 核心模块桥接函数 - QApplication, QWidget, QTimer
 */

#include <QApplication>
#include <QClipboard>
#include <QDebug>
#include <QDesktopServices>
#include <QDir>
#include <QFileSystemWatcher>
#include <QGuiApplication>
#include <functional>
#include <QLibraryInfo>
#include <QLocale>
#include <QPropertyAnimation>
#include <QScreen>
#include <QSettings>
#include <QShortcut>
#include <QStandardPaths>
#include <QThread>
#if defined(Q_OS_WIN)
#include <private/qeventdispatcher_win_p.h>
#include <windows.h>
#elif defined(Q_OS_UNIX)
#include <private/qeventdispatcher_unix_p.h>
#endif
#include <QTimer>
#include <QTranslator>
#include <QUrl>
#include <QWindow>
#include <QAbstractNativeEventFilter>
#include <QMouseEvent>
#include <QKeyEvent>
#include <QCursor>
#include <QObject>
#include <QWidget>
#include <QPushButton>
#include <unordered_map>
#include <atomic>
#include <exception>
#include <thread>
#include <cstdio>
#include <cstdarg>
#include <cstdlib>
#include "bridge_string_utils.h"

// 全局应用程序指针
static QApplication* g_app = nullptr;

// 当前线程正在运行的事件循环（thread_local：每线程独立，
// qApplicationQuit 精确退出本线程循环，不影响其他线程的 exec）
thread_local QEventLoop* t_currentLoop = nullptr;

// 全局翻译器
static QTranslator* g_qtTranslator = nullptr;
static QTranslator* g_appTranslator = nullptr;

// 回调函数映射 - 非static，供其他模块使用
std::unordered_map<int64_t, std::function<void(int64_t)>> g_buttonCallbacks;
std::unordered_map<int64_t, std::function<void(int64_t)>> g_timerCallbacks;

extern "C" {

// ============================================================
// 通用字符串释放
// 桥接层用 std::malloc 分配返回字符串；仓颉侧 LibC.free 绑定的是
// msvcrt free，无法释放本库(UCRT) malloc 的内存，必须经由本函数
// 让 malloc/free 处于同一堆，避免堆损坏崩溃/挂起。
// ============================================================
void qCStringFree(const char* s) {
    std::free(const_cast<char*>(s));
}

// ============================================================
// QObject 存活注册表（P0 反向失效通知）
//
// 仓颉侧句柄在对象创建后调用 qTrackObject 注册，close 时调用
// qUntrackObject 注销。当 QObject 被级联销毁（如父控件 close 导致
// 子对象析构）时，QObject::destroyed 信号自动把条目标记为失效，
// 此后 qIsObjectAlive 返回 0，仓颉 isValid()/checkValid() 即可识别。
//
// 约定：
//   - 未 track 的对象（值类型/非 QObject）视为存活，查询返回 1；
//   - destroyed 信号连接以值捕获 ptr（而非裸指针），对象销毁瞬间
//     仍能安全执行，标记失效后连接随发送者销毁自动断开。
// ============================================================

struct AliveEntry {
    bool alive = true;
    QMetaObject::Connection conn;
};

static std::unordered_map<int64_t, AliveEntry> g_aliveObjs;
static std::atomic_flag g_aliveLock = ATOMIC_FLAG_INIT;

class AliveSpinLock {
public:
    AliveSpinLock() {
        while (g_aliveLock.test_and_set(std::memory_order_acquire)) {
            std::this_thread::yield();
        }
    }
    ~AliveSpinLock() {
        g_aliveLock.clear(std::memory_order_release);
    }
};

// 注册：建立 destroyed 连接，销毁时自动标记失效
void qTrackObject(int64_t ptr) {
    QObject* obj = reinterpret_cast<QObject*>(ptr);
    if (!obj) return;
    QMetaObject::Connection oldConn;
    {
        AliveSpinLock lock;
        auto it = g_aliveObjs.find(ptr);
        if (it != g_aliveObjs.end()) {
            oldConn = it->second.conn;
            g_aliveObjs.erase(it);
        }
    }
    if (oldConn) {
        QObject::disconnect(oldConn);
    }
    QMetaObject::Connection conn = QObject::connect(obj, &QObject::destroyed, [ptr]() {
        AliveSpinLock lock;
        auto it = g_aliveObjs.find(ptr);
        if (it != g_aliveObjs.end()) {
            it->second.alive = false;
        }
    });
    AliveSpinLock lock;
    g_aliveObjs[ptr] = AliveEntry{true, conn};
}

// 注销：断开 destroyed 连接并删除条目
void qUntrackObject(int64_t ptr) {
    QMetaObject::Connection conn;
    {
        AliveSpinLock lock;
        auto it = g_aliveObjs.find(ptr);
        if (it != g_aliveObjs.end()) {
            conn = it->second.conn;
            g_aliveObjs.erase(it);
        }
    }
    if (conn) {
        QObject::disconnect(conn);
    }
}

// 查询：未 track 视为存活；已 track 且未销毁返回 1
int32_t qIsObjectAlive(int64_t ptr) {
    if (ptr == 0) return 0;
    AliveSpinLock lock;
    auto it = g_aliveObjs.find(ptr);
    if (it == g_aliveObjs.end()) return 1;
    return it->second.alive ? 1 : 0;
}

// ============================================================
// QApplication 桥接函数
// ============================================================


int64_t qApplicationCreate() {
    // 测试框架/多线程场景：QApplication 是全局单例（线程亲和=创建线程），
    // 其他线程复用它时本线程没有事件分发器，QEventLoop::exec 会立即返回 -1、
    // QTimer::start 直接失败（"Timers can only be used with threads started with QThread"）。
    // 这里为当前线程补建分发器（每线程独立，线程结束时随 QThreadData 销毁）。
    QThread* curThread = QThread::currentThread();
    if (!QAbstractEventDispatcher::instance(curThread)) {
#if defined(Q_OS_WIN)
        QAbstractEventDispatcher* dispatcher = new QEventDispatcherWin32();
#elif defined(Q_OS_UNIX)
        QAbstractEventDispatcher* dispatcher = new QEventDispatcherUNIX();
#endif
        curThread->setEventDispatcher(dispatcher);

    }
    // 多线程并发保护：QApplication 是 Qt 单例，多个线程同时 new 会触发
    // qFatal（"instance already exists"）导致 __fastfail(0xC0000409)。
    // 用 atomic_flag 自旋锁（项目既定模式，std::mutex 在仓颉线程会死锁）。
    static std::atomic_flag g_appCreateLock = ATOMIC_FLAG_INIT;
    while (g_appCreateLock.test_and_set(std::memory_order_acquire)) {
        std::this_thread::yield();
    }
    if (!g_app) {
        // 外部（原生测试 main / 宿主程序）已创建 QApplication 时复用，
        // 避免创建第二个实例崩溃。
        QCoreApplication* existing = QCoreApplication::instance();
        if (existing) {
            g_app = static_cast<QApplication*>(existing);

        } else {
            // 注意：QApplication(int&, char**) 不能传 argv=nullptr，否则 Qt 在解析
            // 命令行/初始化平台插件时可能越界访问 argv[0]，触发 /GS 栈保护
            // (__fastfail STATUS_FAIL_FAST_FATAL_STACK_BUFFER_OVERRUN = 0xC0000409)。
            // 必须给出合法的 argv[0]。
            static int s_argc = 1;
            static char s_arg0[] = "cjqt6";
            static char* s_argv[] = { s_arg0, nullptr };

            try {
                g_app = new QApplication(s_argc, s_argv);

            } catch (const std::exception& e) {
                fprintf(stderr, "[cjqt6_bridge] qApplicationCreate failed: %s\n", e.what());
                g_app = nullptr;
            } catch (...) {
                fprintf(stderr, "[cjqt6_bridge] qApplicationCreate failed: unknown C++ exception\n");
                g_app = nullptr;
            }
        }
    }
    g_appCreateLock.clear(std::memory_order_release);
    return reinterpret_cast<int64_t>(g_app);
}

// 由 bridge_ui_poster.cpp 提供：exec 启动时标记当前线程循环运行并补发积压
extern "C" void qSetGuiThreadForPoster();
// 由 bridge_ui_poster.cpp 提供：exec 退出后标记无循环运行
extern "C" void qUnsetGuiThreadForPoster();

#if defined(Q_OS_WIN)
// ---- 窗口子类化兜底：拦截 WM_NCLBUTTONDOWN(HTCLOSE) 和 WM_CLOSE 调 QWindow::close() ----
// 主方案是 nativeEventFilter（见 qApplicationExec），子类化作为兜底：
// 拦截 SendMessage(WM_CLOSE) 等同步调用（不经过 nativeEventFilter 的消息路径）。
static std::unordered_map<HWND, WNDPROC> g_subclassedWindows;

// 递归查找全局坐标处最深的可见子 widget
static QWidget* findDeepestWidgetAt(QWidget* root, const QPoint& globalPos) {
    if (!root || !root->isVisible()) return nullptr;
    QPoint localPos = root->mapFromGlobal(globalPos);
    if (!root->rect().contains(localPos)) return nullptr;
    QWidget* deepest = root;
    for (QObject* obj : root->children()) {
        QWidget* child = qobject_cast<QWidget*>(obj);
        if (child) {
            QWidget* deeper = findDeepestWidgetAt(child, globalPos);
            if (deeper) deepest = deeper;
        }
    }
    return deepest;
}

static LRESULT CALLBACK cjqt6SubclassWndProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    // 拦截 WM_NCLBUTTONDOWN(HTCLOSE) 和 WM_CLOSE：调 QWindow::close()
    // （SendMessage(WM_CLOSE) 等同步调用不经过 nativeEventFilter，子类化作为兜底）
    if (uMsg == WM_NCLBUTTONDOWN && wParam == HTCLOSE) {
        for (QWindow* win : QGuiApplication::topLevelWindows()) {
            if (reinterpret_cast<HWND>(win->winId()) == hwnd) {
                win->close();
                return 0;
            }
        }
    }
    if (uMsg == WM_CLOSE) {
        for (QWindow* win : QGuiApplication::topLevelWindows()) {
            if (reinterpret_cast<HWND>(win->winId()) == hwnd) {
                win->close();
                return 0;
            }
        }
    }
    // 鼠标消息已移到 nativeEventFilter 中处理
    // （子类化 SetWindowLongPtrW 会被 Qt 内部操作重置，不可靠；
    //  nativeEventFilter 在 DispatchMessage 之前调用，能拦截所有真实鼠标消息）

    auto it = g_subclassedWindows.find(hwnd);
    if (it != g_subclassedWindows.end()) {
        return CallWindowProcW(it->second, hwnd, uMsg, wParam, lParam);
    }
    return DefWindowProcW(hwnd, uMsg, wParam, lParam);
}


static void cjqt6SubclassWindow(HWND hwnd) {
    if (g_subclassedWindows.find(hwnd) != g_subclassedWindows.end()) return;
    WNDPROC oldProc = (WNDPROC)SetWindowLongPtrW(hwnd, GWLP_WNDPROC, (LONG_PTR)cjqt6SubclassWndProc);
    if (oldProc) g_subclassedWindows[hwnd] = oldProc;
}

static BOOL CALLBACK cjqt6EnumChildProc(HWND hwnd, LPARAM lParam) {
    cjqt6SubclassWindow(hwnd);
    return TRUE;
}

static void cjqt6SubclassTopLevelWindows() {
    for (QWindow* win : QGuiApplication::topLevelWindows()) {
        if (win->isVisible()) {
            HWND hwnd = reinterpret_cast<HWND>(win->winId());
            if (hwnd) {
                cjqt6SubclassWindow(hwnd);
                // 也子类化子窗口（按钮、输入框等可能有独立 HWND）
                EnumChildWindows(hwnd, cjqt6EnumChildProc, 0);
            }
        }
    }
}
// ---- 窗口子类化结束 ----

// ---- WH_MOUSE 线程级钩子：拦截所有鼠标消息（包括弹出菜单的） ----
// nativeEventFilter 收不到弹出菜单（QComboBoxPrivateContainer 等）的鼠标消息，
// 因为弹出菜单有自己的消息泵。WH_MOUSE 钩子是 Win32 级别的，能拦截所有消息。
static HHOOK g_mouseHook = NULL;

static LRESULT CALLBACK cjqt6MouseHookProc(int code, WPARAM wParam, LPARAM lParam) {
    if (code == HC_ACTION) {
        if (wParam == WM_LBUTTONDOWN || wParam == WM_LBUTTONUP ||
            wParam == WM_RBUTTONDOWN || wParam == WM_RBUTTONUP ||
            wParam == WM_MOUSEMOVE) {
            MOUSEHOOKSTRUCT* mhs = (MOUSEHOOKSTRUCT*)lParam;
            QWidget* widget = QWidget::find(reinterpret_cast<WId>(mhs->hwnd));

            if (widget) {
                // 屏幕坐标（物理坐标）转逻辑坐标
                qreal dpr = widget->devicePixelRatio();
                if (dpr < 0.01) dpr = 1.0;
                QPoint globalPos(mhs->pt.x / dpr, mhs->pt.y / dpr);
                // 消息类型和按钮
                Qt::MouseButton button = Qt::NoButton;
                QEvent::Type type = QEvent::None;
                if (wParam == WM_LBUTTONDOWN) { type = QEvent::MouseButtonPress; button = Qt::LeftButton; }
                else if (wParam == WM_LBUTTONUP) { type = QEvent::MouseButtonRelease; button = Qt::LeftButton; }
                else if (wParam == WM_RBUTTONDOWN) { type = QEvent::MouseButtonPress; button = Qt::RightButton; }
                else if (wParam == WM_RBUTTONUP) { type = QEvent::MouseButtonRelease; button = Qt::RightButton; }
                else if (wParam == WM_MOUSEMOVE) { type = QEvent::MouseMove; button = Qt::NoButton; }
                // buttons 状态（WH_MOUSE 钩子没有 wParam 的 MK_ 标志，用 GetKeyState）
                Qt::MouseButtons buttons;
                if (GetKeyState(VK_LBUTTON) & 0x8000) buttons |= Qt::LeftButton;
                if (GetKeyState(VK_RBUTTON) & 0x8000) buttons |= Qt::RightButton;
                Qt::KeyboardModifiers mods;
                if (GetKeyState(VK_SHIFT) & 0x8000) mods |= Qt::ShiftModifier;
                if (GetKeyState(VK_CONTROL) & 0x8000) mods |= Qt::ControlModifier;
                // mhs->hwnd 是 Windows 报告的鼠标所在最顶层窗口 HWND，QWidget::find
                // 返回的就是该原生窗口对应的 widget。直接在 widget 内部递归找最深的子
                // widget 即可——不要往上找 parentWidget：弹出菜单 QComboBoxPrivateContainer
                // 的逻辑父是 QComboBox，往上找会到主 QMainWindow，导致在主窗口的坐标系里
                // 找弹出菜单坐标处的 widget，找到的是被遮挡的位置（QComboBox 等）而非菜单项。
                QWidget* target = findDeepestWidgetAt(widget, globalPos);

                if (!target) target = widget;  // findDeepestWidgetAt 没找到，直接用 widget
                QPoint localPos = target->mapFromGlobal(globalPos);
                QMouseEvent event(type, QPointF(localPos), QPointF(globalPos), button, buttons, mods);
                QCoreApplication::sendEvent(target, &event);
                if (wParam == WM_LBUTTONDOWN && target->focusPolicy() != Qt::NoFocus) {
                    target->setFocus();
                }
            }
        }
    }
    return CallNextHookEx(g_mouseHook, code, wParam, lParam);
}
// ---- WH_MOUSE 钩子结束 ----
#endif

int32_t qApplicationExec() {
    if (!g_app) {
        return -1;
    }
    QThread* curThread = QThread::currentThread();
    if (!QAbstractEventDispatcher::instance(curThread)) {
#if defined(Q_OS_WIN)
        QAbstractEventDispatcher* dispatcher = new QEventDispatcherWin32();
#elif defined(Q_OS_UNIX)
        QAbstractEventDispatcher* dispatcher = new QEventDispatcherUNIX();
#endif
        curThread->setEventDispatcher(dispatcher);
    }
    // QGuiApplication::exec 强制只能在进程主线程调用（"Must be called from the
    // main thread"），而仓颉测试框架把用例分发到 worker 线程执行。
    // 改用 QCoreApplication::exec（内部即 QEventLoop，无主线程限制），
    // 事件循环/定时器/信号槽行为与 QApplication::exec 一致。
    qSetGuiThreadForPoster();
    // 仓颉 M:N 线程模型下 Qt 6.10 的 QtWndProc 收到 WM_CLOSE / WM_NCLBUTTONDOWN(HTCLOSE)
    // 不触发 QCloseEvent（QWindow::close() 能关，但这些消息不调 close()）。
    // 用 QAbstractNativeEventFilter 拦截这些消息，手动调 QWindow::close()，
    // 使窗口关闭后 QApplication::exec 的 quitOnLastWindowClosed 生效退出。
    class WmCloseNativeFilter : public QAbstractNativeEventFilter {
    public:
        bool nativeEventFilter(const QByteArray& eventType, void* message, qintptr* result) override {
            if (eventType == "windows_generic_MSG" && message) {
                MSG* msg = static_cast<MSG*>(message);
                // 拦截 WM_CLOSE 和 WM_NCLBUTTONDOWN(HTCLOSE)，调 QWindow::close()
                if (msg->message == WM_CLOSE ||
                    (msg->message == WM_NCLBUTTONDOWN && msg->wParam == HTCLOSE)) {
                    for (QWindow* win : QGuiApplication::topLevelWindows()) {
                        if (reinterpret_cast<HWND>(win->winId()) == msg->hwnd) {
                            win->close();
                            if (result) *result = 0;
                            return true;
                        }
                    }
                }
                // 鼠标消息已移到 WH_MOUSE 线程级钩子中处理
                // （nativeEventFilter 收不到弹出菜单的鼠标消息，钩子是 Win32 级别的更可靠）
                // 键盘消息：Qt 6.10 仓颉 M:N 线程下 QtWndProc 不把 Windows 键盘消息转成 QKeyEvent。
                // 手动构造 QKeyEvent 派发给 focus widget。
                if (msg->message == WM_KEYDOWN || msg->message == WM_KEYUP || msg->message == WM_CHAR) {
                    QWidget* focusWidget = QApplication::focusWidget();

                    if (focusWidget) {
                        QEvent::Type type = QEvent::None;
                        if (msg->message == WM_KEYDOWN) type = QEvent::KeyPress;
                        else if (msg->message == WM_KEYUP) type = QEvent::KeyRelease;
                        else if (msg->message == WM_CHAR) type = QEvent::KeyPress;
                        int key = (int)msg->wParam;
                        Qt::KeyboardModifiers mods;
                        if (GetKeyState(VK_SHIFT) & 0x8000) mods |= Qt::ShiftModifier;
                        if (GetKeyState(VK_CONTROL) & 0x8000) mods |= Qt::ControlModifier;
                        if (GetKeyState(VK_MENU) & 0x8000) mods |= Qt::AltModifier;
                        QString text;
                        if (msg->message == WM_CHAR && msg->wParam >= 0x20 && msg->wParam < 0x10000) {
                            text = QChar((ushort)msg->wParam);
                        }
                        QKeyEvent event(type, key, mods, text);
                        QCoreApplication::sendEvent(focusWidget, &event);
                    }
                }
            }
            return false;
        }
    };
    static WmCloseNativeFilter wmCloseFilter;
    QCoreApplication::instance()->installNativeEventFilter(&wmCloseFilter);

#if defined(Q_OS_WIN)
    // 子类化兜底：立即子类化已有顶层窗口，QTimer 定期子类化新创建的窗口
    cjqt6SubclassTopLevelWindows();
    static QTimer* subclassTimer = nullptr;
    if (!subclassTimer) {
        subclassTimer = new QTimer();
        QObject::connect(subclassTimer, &QTimer::timeout, cjqt6SubclassTopLevelWindows);
        subclassTimer->start(1000);
    }
    // 安装 WH_MOUSE 线程级钩子，拦截所有鼠标消息（包括弹出菜单的）
    if (!g_mouseHook) {
        g_mouseHook = SetWindowsHookEx(WH_MOUSE, cjqt6MouseHookProc, NULL, GetCurrentThreadId());

    }
#endif
    int r = g_app->exec();
    qUnsetGuiThreadForPoster();
    return r;
}

void qApplicationQuit() {

    if (t_currentLoop) {
        // 退出当前线程正在运行的事件循环（QEventLoop::exit 线程安全，
        // 只退出本 loop，不设置全局 quitNow，同线程后续 exec 不受影响）
        t_currentLoop->exit(0);
        return;
    }
    // 兜底：没有事件循环运行时走 QApplication::quit
    if (g_app) {
        g_app->quit();
    }
}

void qApplicationDelete(int64_t) {
    // 不删除全局 QApplication
}

// ============================================================
// QWidget 桥接函数
// ============================================================

int64_t qWidgetCreate() {
    QWidget* widget = new QWidget();
    return reinterpret_cast<int64_t>(widget);
}

void qWidgetShow(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->show();
        widget->activateWindow();
        widget->raise();
    } else {
        fprintf(stderr, "[cjqt6_bridge] qWidgetShow ERROR: widget is NULL\n");
    }
}

void qWidgetHide(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->hide();
    }
}

void qWidgetSetTitle(int64_t ptr, const char* title) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setWindowTitle(title);
    }
}

void qWidgetResize(int64_t ptr, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->resize(width, height);
    }
}

void qWidgetSetGeometry(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setGeometry(x, y, width, height);
    }
}

void qWidgetSetParent(int64_t ptr, int64_t parentPtr) {
    QWidget* child = reinterpret_cast<QWidget*>(ptr);
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    if (child && parent) {
        child->setParent(parent);
    }
}

void qWidgetSetLayout(int64_t widgetPtr, int64_t layoutPtr) {
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    QLayout* layout = reinterpret_cast<QLayout*>(layoutPtr);
    if (widget && layout) {
        widget->setLayout(layout);
    }
}

void qWidgetDelete(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        delete widget;
    }
}

// ============================================================
// QTimer 桥接函数
// ============================================================

int64_t qTimerCreate() {
    QTimer* timer = new QTimer();
    return reinterpret_cast<int64_t>(timer);
}

void qTimerSetInterval(int64_t ptr, int32_t interval) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        timer->setInterval(interval);
    }
}

void qTimerStart(int64_t ptr) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        timer->start();

    }
}

void qTimerStop(int64_t ptr) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        timer->stop();
    }
}

void qTimerSetTimeout(int64_t ptr, void (*callback)(int64_t)) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        int64_t timerPtr = ptr;
        g_timerCallbacks[ptr] = [callback, timerPtr](int64_t) { callback(timerPtr); };
        QObject::connect(timer, &QTimer::timeout, [timerPtr]() {

            auto it = g_timerCallbacks.find(timerPtr);
            if (it != g_timerCallbacks.end()) {
                it->second(timerPtr);
            }
        });
    }
}

void qTimerDelete(int64_t ptr) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        g_timerCallbacks.erase(ptr);
        delete timer;
    }
}

// ============================================================
// QWidget 样式表支持
// ============================================================

void qWidgetSetStyleSheet(int64_t ptr, const char* styleSheet) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setStyleSheet(QString::fromUtf8(styleSheet));
    }
}

const char* qWidgetStyleSheet(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        return cjqt6::dupUtf8(widget->styleSheet());
    }
    return cjqt6::emptyString();
}

// 应用级全局样式表：QApplication::setStyleSheet / styleSheet
void qApplicationSetStyleSheet(const char* styleSheet) {
    if (g_app) {
        g_app->setStyleSheet(QString::fromUtf8(styleSheet));
    }
}

const char* qApplicationStyleSheet() {
    if (g_app) {
        return cjqt6::dupUtf8(g_app->styleSheet());
    }
    return cjqt6::emptyString();
}

void qWidgetSetEnabled(int64_t ptr, int32_t enabled) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setEnabled(enabled != 0);
    }
}

int32_t qWidgetIsEnabled(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        return widget->isEnabled() ? 1 : 0;
    }
    return 0;
}

void qWidgetSetVisible(int64_t ptr, int32_t visible) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setVisible(visible != 0);
    }
}

int32_t qWidgetIsVisible(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        return widget->isVisible() ? 1 : 0;
    }
    return 0;
}

void qWidgetSetToolTip(int64_t ptr, const char* toolTip) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setToolTip(QString::fromUtf8(toolTip));
    }
}

void qWidgetSetMinimumSize(int64_t ptr, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setMinimumSize(width, height);
    }
}

void qWidgetSetMaximumSize(int64_t ptr, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setMaximumSize(width, height);
    }
}

int32_t qWidgetWidth(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        return widget->width();
    }
    return 0;
}

int32_t qWidgetHeight(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        return widget->height();
    }
    return 0;
}

void qWidgetUpdate(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->update();
    }
}

void qWidgetRepaint(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->repaint();
    }
}

// ============================================================
// 翻译/语言相关函数
// ============================================================

// 加载Qt内置翻译（用于对话框等）
bool qApplicationLoadQtTranslation(const char* locale) {
    if (!g_app) return false;
    
    // 删除旧的翻译器
    if (g_qtTranslator) {
        g_app->removeTranslator(g_qtTranslator);
        delete g_qtTranslator;
    }
    
    g_qtTranslator = new QTranslator();
    
    QString localeStr = QString::fromUtf8(locale);
    if (localeStr.isEmpty()) {
        localeStr = QLocale::system().name();  // 例如 "zh_CN"
    }
    
    // 尝试从多个路径加载Qt翻译文件
    QStringList searchPaths;
    
    // 常见的Qt翻译文件路径
    searchPaths << "/usr/share/qt6/translations"
                << "/usr/share/qt/translations"
                << "/usr/lib/qt6/translations"
                << "/usr/lib/qt/translations"
                << "/opt/qt6/translations"
                << QLibraryInfo::path(QLibraryInfo::TranslationsPath);
    
    // 尝试多种文件名格式
    QStringList filePatterns;
    filePatterns << QString("qtbase_%1").arg(localeStr)           // qtbase_zh_CN
                 << QString("qtbase_%1").arg(localeStr.left(2))   // qtbase_zh
                 << QString("qt_%1").arg(localeStr)               // qt_zh_CN
                 << QString("qt_%1").arg(localeStr.left(2));      // qt_zh
    
    for (const QString& path : searchPaths) {
        for (const QString& pattern : filePatterns) {
            QString qmFile = QString("%1.qm").arg(pattern);
            QString fullPath = QString("%1/%2").arg(path).arg(qmFile);
            if (QFile::exists(fullPath)) {
                if (g_qtTranslator->load(qmFile, path)) {
                    g_app->installTranslator(g_qtTranslator);
                    return true;
                }
            }
        }
    }
    
    // 尝试直接加载（从系统路径）
    for (const QString& pattern : filePatterns) {
        QString qmFile = QString("%1.qm").arg(pattern);
        if (g_qtTranslator->load(qmFile)) {
            g_app->installTranslator(g_qtTranslator);
            return true;
        }
    }
    
    delete g_qtTranslator;
    g_qtTranslator = nullptr;
    return false;
}

// 加载应用程序翻译
bool qApplicationLoadAppTranslation(const char* qmFile, const char* directory) {
    if (!g_app) return false;
    
    // 删除旧的翻译器
    if (g_appTranslator) {
        g_app->removeTranslator(g_appTranslator);
        delete g_appTranslator;
    }
    
    g_appTranslator = new QTranslator();
    
    QString qmPath = QString::fromUtf8(qmFile);
    QString dir = QString::fromUtf8(directory);
    
    if (g_appTranslator->load(qmPath, dir.isEmpty() ? QString() : dir)) {
        g_app->installTranslator(g_appTranslator);
        return true;
    }
    
    delete g_appTranslator;
    g_appTranslator = nullptr;
    return false;
}

// 设置应用程序语言环境
void qApplicationSetLocale(const char* locale) {
    QString localeStr = QString::fromUtf8(locale);
    if (localeStr.isEmpty()) {
        QLocale::setDefault(QLocale::system());
    } else {
        QLocale::setDefault(QLocale(localeStr));
    }
}

// 获取当前语言环境
const char* qApplicationLocale() {
    return cjqt6::dupUtf8(QLocale().name());  // 例如 "zh_CN"
}

// 获取系统语言环境
const char* qApplicationSystemLocale() {
    return cjqt6::dupUtf8(QLocale::system().name());
}

// 切换语言（同时加载Qt翻译）
bool qApplicationSwitchLanguage(const char* locale) {
    QString localeStr = QString::fromUtf8(locale);
    
    if (localeStr.isEmpty()) {
        // 恢复系统默认
        QLocale::setDefault(QLocale::system());
    } else {
        QLocale::setDefault(QLocale(localeStr));
    }
    
    // 加载Qt翻译
    return qApplicationLoadQtTranslation(locale);
}


void qWidgetMove(int64_t ptr, int32_t x, int32_t y) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) widget->move(x, y);
}
int32_t qWidgetX(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    return widget ? widget->x() : 0;
}
int32_t qWidgetY(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    return widget ? widget->y() : 0;
}
void qWidgetSetFixedSize(int64_t ptr, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) widget->setFixedSize(width, height);
}
void qWidgetSetWindowIcon(int64_t ptr, const char* iconPath) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget && iconPath) widget->setWindowIcon(QIcon(iconPath));
}

void qWidgetSetWindowFlags(int64_t ptr, int32_t flags) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setWindowFlags(Qt::WindowFlags(QFlag(flags)));
    }
}

// ============================================================
// QClipboard 桥接函数
// ============================================================

const char* qClipboardText() {
    QClipboard* clipboard = QApplication::clipboard();
    if (clipboard) {
        return cjqt6::dupUtf8(clipboard->text());
    }
    return cjqt6::emptyString();
}

void qClipboardSetText(const char* text) {
    QClipboard* clipboard = QApplication::clipboard();
    if (clipboard) {
        clipboard->setText(QString::fromUtf8(text));
    }
}

bool qClipboardHasText() {
    QClipboard* clipboard = QApplication::clipboard();
    if (clipboard) {
        return !clipboard->text().isEmpty();
    }
    return false;
}

void qClipboardClear() {
    QClipboard* clipboard = QApplication::clipboard();
    if (clipboard) {
        clipboard->clear();
    }
}

// ============================================================
// QDesktopServices 桥接函数
// ============================================================

bool qDesktopServicesOpenUrl(const char* url) {
    return QDesktopServices::openUrl(QUrl(QString::fromUtf8(url)));
}

bool qDesktopServicesOpenFile(const char* filePath) {
    return QDesktopServices::openUrl(QUrl::fromLocalFile(QString::fromUtf8(filePath)));
}

// ============================================================
// QShortcut 桥接函数
// ============================================================

int64_t qShortcutCreate(int64_t parentPtr) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    if (parent) {
        QShortcut* shortcut = new QShortcut(parent);
        return reinterpret_cast<int64_t>(shortcut);
    }
    return 0;
}

void qShortcutSetKey(int64_t ptr, const char* keySequence) {
    QShortcut* shortcut = reinterpret_cast<QShortcut*>(ptr);
    if (shortcut) {
        shortcut->setKey(QKeySequence(QString::fromUtf8(keySequence)));
    }
}

void qShortcutSetEnabled(int64_t ptr, bool enabled) {
    QShortcut* shortcut = reinterpret_cast<QShortcut*>(ptr);
    if (shortcut) {
        shortcut->setEnabled(enabled);
    }
}

void qShortcutSetAutoRepeat(int64_t ptr, bool repeat) {
    QShortcut* shortcut = reinterpret_cast<QShortcut*>(ptr);
    if (shortcut) {
        shortcut->setAutoRepeat(repeat);
    }
}

void qShortcutDelete(int64_t ptr) {
    QShortcut* shortcut = reinterpret_cast<QShortcut*>(ptr);
    if (shortcut) {
        delete shortcut;
    }
}

// ============================================================
// QStandardPaths 桥接函数
// ============================================================

const char* qStandardPathWritableLocation(int32_t type) {
    return cjqt6::dupUtf8(QStandardPaths::writableLocation(static_cast<QStandardPaths::StandardLocation>(type)));
}

const char* qStandardPathLocate(int32_t type, const char* fileName) {
    return cjqt6::dupUtf8(QStandardPaths::locate(static_cast<QStandardPaths::StandardLocation>(type), QString::fromUtf8(fileName)));
}

const char* qStandardPathDisplayName(int32_t type) {
    return cjqt6::dupUtf8(QStandardPaths::displayName(static_cast<QStandardPaths::StandardLocation>(type)));
}

const char* qStandardPathTempDir() {
    return cjqt6::dupUtf8(QStandardPaths::writableLocation(QStandardPaths::TempLocation));
}

// ============================================================
// QFileSystemWatcher 桥接函数
// ============================================================

int64_t qFileSystemWatcherCreate() {
    QFileSystemWatcher* watcher = new QFileSystemWatcher();
    return reinterpret_cast<int64_t>(watcher);
}

void qFileSystemWatcherAddPath(int64_t ptr, const char* path) {
    QFileSystemWatcher* watcher = reinterpret_cast<QFileSystemWatcher*>(ptr);
    if (watcher) {
        watcher->addPath(QString::fromUtf8(path));
    }
}

void qFileSystemWatcherRemovePath(int64_t ptr, const char* path) {
    QFileSystemWatcher* watcher = reinterpret_cast<QFileSystemWatcher*>(ptr);
    if (watcher) {
        watcher->removePath(QString::fromUtf8(path));
    }
}

void qFileSystemWatcherDelete(int64_t ptr) {
    QFileSystemWatcher* watcher = reinterpret_cast<QFileSystemWatcher*>(ptr);
    if (watcher) {
        delete watcher;
    }
}

// ============================================================
// QSettings 桥接函数
// ============================================================

int64_t qSettingsCreate(const char* appName) {
    QSettings* settings = new QSettings(QString::fromUtf8(appName));
    return reinterpret_cast<int64_t>(settings);
}

int64_t qSettingsCreateWithFile(const char* fileName) {
    QSettings* settings = new QSettings(QString::fromUtf8(fileName), QSettings::IniFormat);
    return reinterpret_cast<int64_t>(settings);
}

void qSettingsSetValue(int64_t ptr, const char* key, const char* value) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        settings->setValue(QString::fromUtf8(key), QString::fromUtf8(value));
    }
}

const char* qSettingsValue(int64_t ptr, const char* key, const char* defaultValue) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        return cjqt6::dupUtf8(settings->value(QString::fromUtf8(key), QString::fromUtf8(defaultValue)).toString());
    }
    return cjqt6::dupUtf8(QString::fromUtf8(defaultValue));
}

int32_t qSettingsValueInt(int64_t ptr, const char* key, int32_t defaultValue) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        return settings->value(QString::fromUtf8(key), defaultValue).toInt();
    }
    return defaultValue;
}

bool qSettingsValueBool(int64_t ptr, const char* key, bool defaultValue) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        return settings->value(QString::fromUtf8(key), defaultValue).toBool();
    }
    return defaultValue;
}

void qSettingsBeginGroup(int64_t ptr, const char* prefix) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        settings->beginGroup(QString::fromUtf8(prefix));
    }
}

void qSettingsEndGroup(int64_t ptr) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        settings->endGroup();
    }
}

void qSettingsSync(int64_t ptr) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        settings->sync();
    }
}

bool qSettingsContains(int64_t ptr, const char* key) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        return settings->contains(QString::fromUtf8(key));
    }
    return false;
}

void qSettingsRemove(int64_t ptr, const char* key) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        settings->remove(QString::fromUtf8(key));
    }
}

void qSettingsDelete(int64_t ptr) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        delete settings;
    }
}

// ============================================================
// QPropertyAnimation 桥接函数
// ============================================================

int64_t qPropertyAnimationCreate(int64_t targetPtr, const char* propertyName) {
    QPropertyAnimation* anim = new QPropertyAnimation(
        reinterpret_cast<QObject*>(targetPtr),
        QByteArray(propertyName),
        nullptr
    );
    return reinterpret_cast<int64_t>(anim);
}

void qPropertyAnimationSetDuration(int64_t ptr, int32_t duration) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) anim->setDuration(duration);
}

int32_t qPropertyAnimationDuration(int64_t ptr) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    return anim ? anim->duration() : 0;
}

void qPropertyAnimationSetStartValue(int64_t ptr, double value) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) anim->setStartValue(QVariant(value));
}

void qPropertyAnimationSetEndValue(int64_t ptr, double value) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) anim->setEndValue(QVariant(value));
}

void qPropertyAnimationStart(int64_t ptr) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) anim->start();
}

void qPropertyAnimationStop(int64_t ptr) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) anim->stop();
}

void qPropertyAnimationSetLoopCount(int64_t ptr, int32_t count) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) anim->setLoopCount(count);
}

int32_t qPropertyAnimationLoopCount(int64_t ptr) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    return anim ? anim->loopCount() : 1;
}

void qPropertyAnimationSetEasingCurve(int64_t ptr, int32_t curveType) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) anim->setEasingCurve(static_cast<QEasingCurve::Type>(curveType));
}

void qPropertyAnimationDelete(int64_t ptr) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) delete anim;
}

// ============================================================
// QScreen 桥接函数
// ============================================================

double qScreenPrimaryDpiX() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->logicalDotsPerInchX() : 0.0;
}

double qScreenPrimaryDpiY() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->logicalDotsPerInchY() : 0.0;
}

double qScreenPrimaryPhysicalDpiX() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->physicalDotsPerInchX() : 0.0;
}

double qScreenPrimaryPhysicalDpiY() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->physicalDotsPerInchY() : 0.0;
}

double qScreenPrimaryDevicePixelRatio() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->devicePixelRatio() : 1.0;
}

int32_t qScreenPrimaryWidth() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->size().width() : 0;
}

int32_t qScreenPrimaryHeight() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->size().height() : 0;
}

double qScreenPrimaryRefreshRate() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->refreshRate() : 0.0;
}

// ============================================================
// QLocale 封装（国际化辅助）
// 以堆分配的 QLocale* 为句柄；QLocale 非 QObject，不入存活表。
// ============================================================

int64_t qLocaleCreate(const char* name) {
    QLocale* locale = nullptr;
    if (name && *name) {
        locale = new QLocale(QString::fromUtf8(name));
    } else {
        locale = new QLocale();
    }
    return reinterpret_cast<int64_t>(locale);
}

void qLocaleDelete(int64_t ptr) {
    delete reinterpret_cast<QLocale*>(ptr);
}

const char* qLocaleName(int64_t ptr) {
    QLocale* locale = reinterpret_cast<QLocale*>(ptr);
    return locale ? cjqt6::dupUtf8(locale->name()) : cjqt6::emptyString();
}

const char* qLocaleNativeLanguageName(int64_t ptr) {
    QLocale* locale = reinterpret_cast<QLocale*>(ptr);
    return locale ? cjqt6::dupUtf8(locale->nativeLanguageName()) : cjqt6::emptyString();
}

const char* qLocaleNativeTerritoryName(int64_t ptr) {
    QLocale* locale = reinterpret_cast<QLocale*>(ptr);
    return locale ? cjqt6::dupUtf8(locale->nativeTerritoryName()) : cjqt6::emptyString();
}

const char* qLocaleLanguageName(int64_t ptr) {
    QLocale* locale = reinterpret_cast<QLocale*>(ptr);
    if (!locale) return cjqt6::emptyString();
    return cjqt6::dupUtf8(QLocale::languageToString(locale->language()));
}

const char* qLocaleTerritoryName(int64_t ptr) {
    QLocale* locale = reinterpret_cast<QLocale*>(ptr);
    if (!locale) return cjqt6::emptyString();
    return cjqt6::dupUtf8(QLocale::territoryToString(locale->territory()));
}

int32_t qLocaleLanguage(int64_t ptr) {
    QLocale* locale = reinterpret_cast<QLocale*>(ptr);
    return locale ? static_cast<int32_t>(locale->language()) : 0;
}

int32_t qLocaleTerritory(int64_t ptr) {
    QLocale* locale = reinterpret_cast<QLocale*>(ptr);
    return locale ? static_cast<int32_t>(locale->territory()) : 0;
}

} // extern "C"

