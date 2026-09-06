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
#include <QWheelEvent>
#include <QCursor>
#include <QObject>
#include <QWidget>
#include <QMenuBar>
#include <QMenu>
#include <QAction>
#include <QSizePolicy>
#include <QPushButton>
#include <qpa/qwindowsysteminterface.h>
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
// D1 修复：线程级钩子只对安装线程生效。记录安装线程 ID，exec 在其他线程调用时
// 卸载重装——否则首次 exec 的线程退出后钩子随线程卸载，但 g_mouseHook 残留非空，
// 此后任何线程都装不上钩子，鼠标拦截永久失效。
static HHOOK g_mouseHook = NULL;
static DWORD g_mouseHookThreadId = 0;

// "再点一次关闭"的状态：为响应"光标落在菜单栏上的 press"，我们主动 hide 掉的旧 popup。
// 若用户点的正是打开它的那个菜单项（想再点一次关闭），Qt 收到我们转发的 press 后会
// 把【同一个菜单】重新打开——时机不确定（可能在 press flush 内，也可能延迟到 release
// 到达时才发生）。只要 activePopup 还是这个对象，就在 press 后 / release 到达时 /
// release 派发后三个时点补关，保证任何时序下"再点一次 → 关闭"都成立。
// 生命周期：press 置位 → 同一次点击的 release 收尾清除。QPointer 防悬垂（hide 过程中
// Qt 可能销毁该 QMenu）。
static QPointer<QWidget> g_menubarCloseTarget;

// 异步窗口拖拽：仓颉 M:N 线程下 DefWindowProc 的拖拽 modal loop 不工作
// （modal loop 内部 GetMessage/DispatchMessage 与仓颉调度器冲突）。
// 改为钩子拦截 WM_NCLBUTTONDOWN(HTCAPTION) 不进入 modal loop，
// 在 WM_NCMOUSEMOVE 中手动 SetWindowPos 移动窗口。
static bool g_windowDragging = false;
static HWND g_dragHwnd = NULL;
static POINT g_dragStartMouse;
static POINT g_dragStartWindow;

// sendEvent 方式下的鼠标捕获：sendEvent 不走 QPA 通道，Qt 不会建立隐式鼠标捕获，

static LRESULT CALLBACK cjqt6MouseHookProc(int code, WPARAM wParam, LPARAM lParam) {
    if (code == HC_ACTION) {
            // 异步窗口拖拽：拦截 WM_NCLBUTTONDOWN(HTCAPTION) 不进入 DefWindowProc modal loop
            if (wParam == WM_NCLBUTTONDOWN) {
                MOUSEHOOKSTRUCT* mhs = (MOUSEHOOKSTRUCT*)lParam;
                if (mhs && mhs->wHitTestCode == HTCAPTION && mhs->hwnd) {
                    g_windowDragging = true;
                    g_dragHwnd = mhs->hwnd;
                    g_dragStartMouse = mhs->pt;
                    RECT rect;
                    GetWindowRect(mhs->hwnd, &rect);
                    g_dragStartWindow.x = rect.left;
                    g_dragStartWindow.y = rect.top;
                    return 1;
                }
            }
            // 拖拽中：WM_NCMOUSEMOVE 手动移动窗口
            if (g_windowDragging && wParam == WM_NCMOUSEMOVE) {
                MOUSEHOOKSTRUCT* mhs = (MOUSEHOOKSTRUCT*)lParam;
                if (mhs && g_dragHwnd) {
                    int newX = g_dragStartWindow.x + (mhs->pt.x - g_dragStartMouse.x);
                    int newY = g_dragStartWindow.y + (mhs->pt.y - g_dragStartMouse.y);
                    SetWindowPos(g_dragHwnd, NULL, newX, newY, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
                    return 1;
                }
            }
            // 拖拽结束：WM_NCLBUTTONUP 或 WM_LBUTTONUP
            if (g_windowDragging && (wParam == WM_NCLBUTTONUP || wParam == WM_LBUTTONUP)) {
                g_windowDragging = false;
                g_dragHwnd = NULL;
                return 1;
            }
            if (wParam == WM_LBUTTONDOWN || wParam == WM_LBUTTONUP || wParam == WM_LBUTTONDBLCLK ||
                wParam == WM_RBUTTONDOWN || wParam == WM_RBUTTONUP || wParam == WM_RBUTTONDBLCLK ||
                wParam == WM_MBUTTONDOWN || wParam == WM_MBUTTONUP || wParam == WM_MBUTTONDBLCLK ||
                wParam == WM_XBUTTONDOWN || wParam == WM_XBUTTONUP || wParam == WM_XBUTTONDBLCLK ||
                wParam == WM_MOUSEMOVE) {
                // D2 修复：补中键/侧键/双击
                const bool isPress = (wParam == WM_LBUTTONDOWN || wParam == WM_RBUTTONDOWN ||
                                      wParam == WM_MBUTTONDOWN || wParam == WM_XBUTTONDOWN);
                const bool isRelease = (wParam == WM_LBUTTONUP || wParam == WM_RBUTTONUP ||
                                        wParam == WM_MBUTTONUP || wParam == WM_XBUTTONUP);
                const bool isDblClick = (wParam == WM_LBUTTONDBLCLK || wParam == WM_RBUTTONDBLCLK ||
                                         wParam == WM_MBUTTONDBLCLK || wParam == WM_XBUTTONDBLCLK);
                const bool isButtonEvent = isPress || isRelease || isDblClick;

                // 构造事件类型和按钮（无 popup 和有 popup 分支共用）
                Qt::MouseButton button = Qt::NoButton;
                QEvent::Type type = QEvent::None;
                if (wParam == WM_LBUTTONDOWN) { type = QEvent::MouseButtonPress; button = Qt::LeftButton; }
                else if (wParam == WM_LBUTTONUP) { type = QEvent::MouseButtonRelease; button = Qt::LeftButton; }
                else if (wParam == WM_LBUTTONDBLCLK) { type = QEvent::MouseButtonDblClick; button = Qt::LeftButton; }
                else if (wParam == WM_RBUTTONDOWN) { type = QEvent::MouseButtonPress; button = Qt::RightButton; }
                else if (wParam == WM_RBUTTONUP) { type = QEvent::MouseButtonRelease; button = Qt::RightButton; }
                else if (wParam == WM_RBUTTONDBLCLK) { type = QEvent::MouseButtonDblClick; button = Qt::RightButton; }
                else if (wParam == WM_MBUTTONDOWN) { type = QEvent::MouseButtonPress; button = Qt::MiddleButton; }
                else if (wParam == WM_MBUTTONUP) { type = QEvent::MouseButtonRelease; button = Qt::MiddleButton; }
                else if (wParam == WM_MBUTTONDBLCLK) { type = QEvent::MouseButtonDblClick; button = Qt::MiddleButton; }
                else if (wParam == WM_XBUTTONDOWN) { type = QEvent::MouseButtonPress; button = (HIWORD(wParam) == 1) ? Qt::BackButton : Qt::ForwardButton; }
                else if (wParam == WM_XBUTTONUP) { type = QEvent::MouseButtonRelease; button = (HIWORD(wParam) == 1) ? Qt::BackButton : Qt::ForwardButton; }
                else if (wParam == WM_XBUTTONDBLCLK) { type = QEvent::MouseButtonDblClick; button = (HIWORD(wParam) == 1) ? Qt::BackButton : Qt::ForwardButton; }
                else if (wParam == WM_MOUSEMOVE) { type = QEvent::MouseMove; button = Qt::NoButton; }
                // buttons 状态（WH_MOUSE 钩子没有 wParam 的 MK_ 标志，用 GetKeyState）
                Qt::MouseButtons buttons;
                if (GetKeyState(VK_LBUTTON) & 0x8000) buttons |= Qt::LeftButton;
                if (GetKeyState(VK_RBUTTON) & 0x8000) buttons |= Qt::RightButton;
                if (GetKeyState(VK_MBUTTON) & 0x8000) buttons |= Qt::MiddleButton;
                if (GetKeyState(VK_XBUTTON1) & 0x8000) buttons |= Qt::BackButton;
                if (GetKeyState(VK_XBUTTON2) & 0x8000) buttons |= Qt::ForwardButton;
                Qt::KeyboardModifiers mods;
                if (GetKeyState(VK_SHIFT) & 0x8000) mods |= Qt::ShiftModifier;
                if (GetKeyState(VK_CONTROL) & 0x8000) mods |= Qt::ControlModifier;
                if (GetKeyState(VK_MENU) & 0x8000) mods |= Qt::AltModifier;

                QPoint globalPos = QCursor::pos();
                QWidget* widget = QApplication::widgetAt(globalPos);
                QWidget* popup = QApplication::activePopupWidget();

                // 无弹出菜单：用 sendEvent 直接派发到光标位置的 widget。
                // 仓颉 M:N 线程下 Qt 原生（QtWndProc）不派发 QMouseEvent 到控件，
                // 钩子必须主动 sendEvent 才能触发 clicked 等信号。
                if (!popup) {
                    if (widget) {
                        // 点击激活：吞掉原生 mouse 消息后 QtWndProc 收不到 WM_MOUSEACTIVATE，
                        // press 时主动请求激活目标顶层窗口。
                        if (isPress) {
                            QWidget* tlw = widget->window();
                            QWindow* tlWin = tlw ? tlw->windowHandle() : nullptr;
                            if (tlWin && !tlWin->isActive()) {
                                tlWin->requestActivate();
                            }
                        }
                        // move + 无 mouseGrabber（纯 hover）：不 sendEvent，让 Qt 原生
                        // 处理 WM_SETCURSOR 更新光标形状。
                        // move + 有 mouseGrabber（控件拖拽中如 slider）：sendEvent + 吞掉，
                        // 避免 Qt 原生 move 干扰控件拖拽状态。
                        // button：sendEvent + 吞掉，避免双重派发致控件状态错乱。
                        if (!isButtonEvent && !QWidget::mouseGrabber()) {
                            return CallNextHookEx(g_mouseHook, code, wParam, lParam);
                        }
                        QMouseEvent seEvent(type, widget->mapFromGlobal(globalPos),
                                             QPointF(globalPos), button, buttons, mods);
                        QCoreApplication::sendEvent(widget, &seEvent);
                        return 1;
                    }
                    return CallNextHookEx(g_mouseHook, code, wParam, lParam);
                }

            if (widget || popup) {
                QWidget* targetForDispatch = widget;
                if (popup && !isButtonEvent) {
                    // move：popup 激活期间一律交给 popup
                    targetForDispatch = popup;
                } else if (popup && isPress) {
                    // ↑ 只在 press 上做菜单栏处理（release 若也做，press 刚打开的菜单
                    //   会被紧随的 release 立刻关掉）
                    // 向上找光标是否落在 QMenuBar 上
                    QMenuBar* menuBar = nullptr;
                    for (QWidget* w = widget; w; w = w->parentWidget()) {
                        if (qobject_cast<QMenuBar*>(w)) { menuBar = qobject_cast<QMenuBar*>(w); break; }
                    }
                    if (menuBar && widget != popup) {
                        // 光标在菜单栏上且已有菜单弹出 → 先关掉旧菜单，把这次 press
                        // 交给 QMenuBar（点别的菜单会打开它=切换；点空白无动作）。
                        // 不用 QMenuBar::actionAt 预判"是否同一个菜单"——实测 popup
                        // 打开时 actionAt 返回的 action 几何错位（+1 项）甚至 null，
                        // hide 后也不立即刷新。改为派发后按 popup 对象复查（见下）。
                        g_menubarCloseTarget = popup;
                        popup->hide();
                    }
                } else if (!popup && isPress) {
                    // 无菜单弹出的新点击：上一击的"再点关闭"标记必然已随 release 清除，
                    // 这里兜底清一次，避免残留标记误伤后续点击。
                    g_menubarCloseTarget = nullptr;
                }

                // "再点一次关闭"（release 到达时补关）：Qt 可能直到现在才把我们要关的
                // 同一个菜单重新打开（延迟重开）。此时 hide + flush（release 是 button，
                // flush 安全），并把这次 release 交给光标所在 widget（菜单已关，无害）。
                if (g_menubarCloseTarget && popup == g_menubarCloseTarget &&
                    isRelease) {
                    g_menubarCloseTarget->hide();
                    QWindowSystemInterface::flushWindowSystemEvents();
                    popup = nullptr;
                    if (targetForDispatch == g_menubarCloseTarget) targetForDispatch = widget;
                }

                if (!targetForDispatch) targetForDispatch = popup;
                // 取鼠标所在窗口的 QWindow（用于走 Qt 官方 QPA 鼠标事件通道）
                QWindow* window = targetForDispatch ? targetForDispatch->windowHandle() : nullptr;
                if (!window && targetForDispatch) {
                    QWidget* topLevel = targetForDispatch->window();
                    if (topLevel) window = topLevel->windowHandle();
                }
                if (window) {

                    // 走 Qt 官方 QPA 鼠标事件通道（Windows 平台插件 QWindowsContext 即用此接口）：
                    // 正确触发隐式鼠标捕获 + popup 管理 + spontaneous 标志，修复原
                    // sendEvent 合成事件在 QMenu 弹出时 setMouseGrabEnabled 报错的问题。
                    // 注意：handleMouseEvent 的 local/global 必须传【原生物理像素】——
                    // Qt 内部会用 QHighDpi::fromNativePosition 再除以 devicePixelRatio
                    // 转回逻辑坐标。若直接传 QCursor::pos() 的 logical 值，会再次 ÷dpr
                    // (1.25)，使 QMenuBar::mousePressEvent 收到的 e->pos() 缩小 1.25 倍，
                    // actionAt 命中前一项 → "点插入/帮助开成格式/插入"(实测)。
                    QPointF localPos = window->mapFromGlobal(globalPos);      // logical
                    qreal hookDpr = window->devicePixelRatio();               // 1.25 @120%
                    QPointF nativeLocal = QPointF(localPos.x() * hookDpr, localPos.y() * hookDpr);
                    QPointF nativeGlobal = QPointF(globalPos.x() * hookDpr, globalPos.y() * hookDpr);
                    QWindowSystemInterface::handleMouseEvent(
                        window, nativeLocal, nativeGlobal, buttons, button, type, mods);
                    // 只对 button 同步 flush，让 press 立即到达 QMenuBar、popup 的 show 在
                    // 本次 flush 内完成；MOUSEMOVE 走异步队列由事件循环自然派发（见上注释）。
                    if (type == QEvent::MouseButtonPress || type == QEvent::MouseButtonRelease) {
                        QWindowSystemInterface::flushWindowSystemEvents();
                    }
                    // "再点一次关闭"（press 后复查）：若 Qt 在刚结束的 flush 内把我们要关的
                    // 菜单【同一个对象】又打开了（用户点的正是打开它的菜单项），立即再关掉，
                    // 并再 flush 一次确保 hide 真正落盘 —— 否则 release 到达时 Qt 仍认为该
                    // 菜单开着，release 会把它再次顶出来（间歇失败的根因）。
                    if (g_menubarCloseTarget && isPress &&
                        QApplication::activePopupWidget() == g_menubarCloseTarget) {
                        g_menubarCloseTarget->hide();
                        QWindowSystemInterface::flushWindowSystemEvents();
                    }
                    // "再点一次关闭"（release 派发后复查）：Qt 若是在 release 的派发过程中
                    // 才重开同一菜单（open-on-release 变体），补最后一次关。
                    if (isRelease && g_menubarCloseTarget &&
                        QApplication::activePopupWidget() == g_menubarCloseTarget) {
                        g_menubarCloseTarget->hide();
                        QWindowSystemInterface::flushWindowSystemEvents();
                    }
                    // release 收尾：清除本次"再点关闭"的标记。
                    if (isRelease && g_menubarCloseTarget) {
                        g_menubarCloseTarget = nullptr;
                    }
                    // 有 popup 时吞掉原始消息，避免 Qt 原生二次派发干扰菜单状态机
                    return 1;
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
#if defined(Q_OS_WIN)
            if (eventType == "windows_generic_MSG" && message) {
                MSG* msg = static_cast<MSG*>(message);
                // 拦截 WM_CLOSE 和 WM_NCLBUTTONDOWN(HTCLOSE)，调 QWindow::close()
                if (msg->message == WM_CLOSE ||
                    (msg->message == WM_NCLBUTTONDOWN && msg->wParam == HTCLOSE)) {
                    for (QWindow* win : QGuiApplication::topLevelWindows()) {
                        if (reinterpret_cast<HWND>(win->winId()) == msg->hwnd) {
                            win->close();
                            // 检查是否还有可见顶层窗口，如果没有则退出事件循环
                            // （QEventLoop 不像 QApplication::exec 有 quitOnLastWindowClosed 逻辑）
                            bool hasVisible = false;
                            for (QWindow* w : QGuiApplication::topLevelWindows()) {
                                if (w->isVisible()) { hasVisible = true; break; }
                            }
                            if (!hasVisible && t_currentLoop) t_currentLoop->exit(0);
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
                        int vk = (int)msg->wParam;
                        // WM_KEYDOWN/WM_KEYUP：只处理特殊键（非可打印字符），
                        // 可打印字符交给 WM_CHAR 处理（提供 text）
                        // WM_CHAR：只处理可打印字符（wParam >= 0x20）
                        // D3 修复：区分特殊键与可打印字符
                        // WM_KEYDOWN/UP：特殊键直接映射 VK→Qt::Key 派发；可打印字符跳过交给 WM_CHAR
                        // WM_CHAR：可打印字符派发（key=0, text=字符）
                        // 原 isPrintable=(vk>=0x20&&vk<=0x7E) 把 F1-F12(VK 0x70-0x7B) 和方向键
                        // (VK 0x25-0x28) 误判为可打印 → WM_KEYDOWN 跳过但无 WM_CHAR 补位 → 事件丢失
                        if (msg->message == WM_KEYDOWN || msg->message == WM_KEYUP) {
                            int key = -1;  // -1 表示可打印字符，交给 WM_CHAR
                            // F1-F24 连续映射（VK_F1..VK_F24 → Qt::Key_F1..F24）
                            if (vk >= VK_F1 && vk <= VK_F24) {
                                key = Qt::Key_F1 + (vk - VK_F1);
                            } else {
                                switch (vk) {
                                    case VK_BACK: key = Qt::Key_Backspace; break;
                                    case VK_TAB: key = Qt::Key_Tab; break;
                                    case VK_RETURN: key = Qt::Key_Return; break;
                                    case VK_ESCAPE: key = Qt::Key_Escape; break;
                                    case VK_INSERT: key = Qt::Key_Insert; break;
                                    case VK_DELETE: key = Qt::Key_Delete; break;
                                    case VK_HOME: key = Qt::Key_Home; break;
                                    case VK_END: key = Qt::Key_End; break;
                                    case VK_LEFT: key = Qt::Key_Left; break;
                                    case VK_UP: key = Qt::Key_Up; break;
                                    case VK_RIGHT: key = Qt::Key_Right; break;
                                    case VK_DOWN: key = Qt::Key_Down; break;
                                    case VK_PRIOR: key = Qt::Key_PageUp; break;
                                    case VK_NEXT: key = Qt::Key_PageDown; break;
                                    // D3 修复：补修饰键、锁定键、空格、暂停、PrintScreen
                                    case VK_SHIFT: key = Qt::Key_Shift; break;
                                    case VK_CONTROL: key = Qt::Key_Control; break;
                                    case VK_MENU: key = Qt::Key_Alt; break;
                                    case VK_LWIN: key = Qt::Key_Meta; break;
                                    case VK_RWIN: key = Qt::Key_Meta; break;
                                    case VK_CAPITAL: key = Qt::Key_CapsLock; break;
                                    case VK_NUMLOCK: key = Qt::Key_NumLock; break;
                                    case VK_SCROLL: key = Qt::Key_ScrollLock; break;
                                    case VK_SPACE: key = Qt::Key_Space; break;
                                    case VK_PAUSE: key = Qt::Key_Pause; break;
                                    case VK_SNAPSHOT: key = Qt::Key_Print; break;
                                    default: break;  // key 保持 -1，交给 WM_CHAR
                                }
                            }
                            if (key != -1) {
                                QEvent::Type type = (msg->message == WM_KEYDOWN) ? QEvent::KeyPress : QEvent::KeyRelease;
                                Qt::KeyboardModifiers mods;
                                if (GetKeyState(VK_SHIFT) & 0x8000) mods |= Qt::ShiftModifier;
                                if (GetKeyState(VK_CONTROL) & 0x8000) mods |= Qt::ControlModifier;
                                if (GetKeyState(VK_MENU) & 0x8000) mods |= Qt::AltModifier;
                                QKeyEvent event(type, key, mods);
                                QCoreApplication::sendEvent(focusWidget, &event);
                            }
                            // else 跳过，交给 WM_CHAR 处理
                        } else if (msg->message == WM_CHAR) {
                            Qt::KeyboardModifiers mods;
                            if (GetKeyState(VK_SHIFT) & 0x8000) mods |= Qt::ShiftModifier;
                            if (GetKeyState(VK_CONTROL) & 0x8000) mods |= Qt::ControlModifier;
                            if (GetKeyState(VK_MENU) & 0x8000) mods |= Qt::AltModifier;
                            QString text = QChar((ushort)vk);
                            QKeyEvent event(QEvent::KeyPress, 0, mods, text);
                            QCoreApplication::sendEvent(focusWidget, &event);
                        }
                    }
                }
                // 滚轮消息：Qt 6.10 仓颉 M:N 线程下 QtWndProc 不把 WM_MOUSEWHEEL 转成 QWheelEvent，
                // 导致 QScrollArea 收不到滚轮、无法自动滚动。
                // 手动构造 QWheelEvent，并沿 parentWidget 链向上传播（QCoreApplication::sendEvent
                // 不自动冒泡，必须手动模拟 Qt 的 wheel 冒泡），直到某个祖先 accept（QScrollArea 滚动）。
                if (msg->message == WM_MOUSEWHEEL) {
                    int zDelta = GET_WHEEL_DELTA_WPARAM(msg->wParam);
                    if (zDelta != 0) {
                        // 用 QCursor::pos() 取逻辑全局坐标（自动处理 DPI 缩放/多屏负坐标）
                        QPoint globalPos = QCursor::pos();
                        QWidget* w = QApplication::widgetAt(globalPos);

                        Qt::MouseButtons buttons;
                        if (GetKeyState(VK_LBUTTON) & 0x8000) buttons |= Qt::LeftButton;
                        if (GetKeyState(VK_RBUTTON) & 0x8000) buttons |= Qt::RightButton;
                        if (GetKeyState(VK_MBUTTON) & 0x8000) buttons |= Qt::MiddleButton;
                        if (GetKeyState(VK_XBUTTON1) & 0x8000) buttons |= Qt::BackButton;
                        if (GetKeyState(VK_XBUTTON2) & 0x8000) buttons |= Qt::ForwardButton;
                        Qt::KeyboardModifiers mods;
                        if (GetKeyState(VK_SHIFT) & 0x8000) mods |= Qt::ShiftModifier;
                        if (GetKeyState(VK_CONTROL) & 0x8000) mods |= Qt::ControlModifier;
                        if (GetKeyState(VK_MENU) & 0x8000) mods |= Qt::AltModifier;
                        bool wheelHandled = false;
                        while (w != nullptr) {
                            QPointF localPos = w->mapFromGlobal(globalPos);
                            QWheelEvent we(localPos, QPointF(globalPos), QPoint(0, 0), QPoint(0, zDelta),
                                           buttons, mods, Qt::ScrollUpdate, false);
                            we.ignore();  // 默认忽略，仅当某级控件真正处理后才 accept
                            QCoreApplication::sendEvent(w, &we);

                            if (we.isAccepted()) {
                                wheelHandled = true;
                                break;
                            }
                            w = w->parentWidget();
                        }
                        if (wheelHandled) {
                            if (result) *result = 0;
                            return true; // 已转成 QWheelEvent 并滚动，拦截原生消息防止二次处理
                        }
                    }
                }
            }
#endif
            return false;
        }

    };
    static WmCloseNativeFilter wmCloseFilter;
    // E1 修复：Qt 对重复安装同一 nativeEventFilter 不去重，二次 exec 起每条 native 消息
    // 会被过滤两次（键盘 WM_KEYDOWN/WM_CHAR 被双派发 → 文本框字符重复输入）。
    // 用静态标志保证只安装一次；filter 对象为函数级 static，生命周期与进程一致。
    static bool s_nativeFilterInstalled = false;
    if (!s_nativeFilterInstalled) {
        QCoreApplication::instance()->installNativeEventFilter(&wmCloseFilter);
        s_nativeFilterInstalled = true;
    }

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
    // D1 修复：线程级钩子绑定安装线程。若当前线程 != 首次安装线程（仓颉 M:N
    // 测试场景 / 二次 exec），旧钩子已随旧线程失效或仍在错误线程上，必须
    // 卸载重装到当前线程；exec 返回时不卸载——对话框模态循环（Qt 内部
    // QEventLoop）不经过本函数，卸载会导致其鼠标拦截断档。线程退出后钩子
    // 由系统自动卸载，残留的 g_mouseHook 由下次 exec 的线程 ID 检测兜底。
    {
        DWORD curId = GetCurrentThreadId();
        if (g_mouseHook && g_mouseHookThreadId != curId) {
            UnhookWindowsHookEx(g_mouseHook);
            g_mouseHook = NULL;
        }
        if (!g_mouseHook) {
            g_mouseHook = SetWindowsHookEx(WH_MOUSE, cjqt6MouseHookProc, NULL, curId);
            if (g_mouseHook) {
                g_mouseHookThreadId = curId;
            }
        }
    }
#endif
    // 统一用 QEventLoop（无主线程限制，worker 线程也能 exec）：
    // - WM_CLOSE 处理中检查可见窗口数，全关闭则 exit(0)（见 nativeEventFilter）
    // - lastWindowClosed 信号作为备份退出机制
    // - qApplicationQuit 通过 t_currentLoop->exit(0) 精确退出
    QEventLoop loop;
    t_currentLoop = &loop;
    // E2 修复：g_app 生命周期贯穿进程，每次 exec 都 connect 会无界累积连接；
    // lastWindowClosed 的处理逻辑与线程无关（lambda 只引用 thread_local 的
    // t_currentLoop，在触发线程求值），因此全局只连接一次即可。
    static bool s_lastWindowConnected = false;
    if (!s_lastWindowConnected) {
        QObject::connect(g_app, &QGuiApplication::lastWindowClosed, []() {
            if (t_currentLoop) t_currentLoop->exit(0);
        });
        s_lastWindowConnected = true;
    }
    int r = loop.exec();
    t_currentLoop = nullptr;
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

// S2 修复：原先每次 setOnTimeout 都 QObject::connect 新 lambda 且不断开旧连接、
// 不保存句柄——替换回调后旧 lambda 仍挂在 timer 上，timeout 触发时多个 lambda
// 均查到同一最新回调 → 回调被执行多次。改为保存连接句柄的替换式语义
//（与 bridge_signal.cpp connectVoidSignal 一致）。
static std::unordered_map<int64_t, QMetaObject::Connection> g_timerConns;

void qTimerSetTimeout(int64_t ptr, void (*callback)(int64_t)) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        int64_t timerPtr = ptr;
        auto cit = g_timerConns.find(ptr);
        if (cit != g_timerConns.end()) {
            if (cit->second) QObject::disconnect(cit->second);
            g_timerConns.erase(cit);
        }
        g_timerCallbacks[ptr] = [callback, timerPtr](int64_t) { callback(timerPtr); };
        g_timerConns[ptr] = QObject::connect(timer, &QTimer::timeout, [timerPtr]() {

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
        auto cit = g_timerConns.find(ptr);
        if (cit != g_timerConns.end()) {
            if (cit->second) QObject::disconnect(cit->second);
            g_timerConns.erase(cit);
        }
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

void qWidgetSetSizePolicy(int64_t ptr, int32_t hPolicy, int32_t vPolicy) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setSizePolicy(QSizePolicy(static_cast<QSizePolicy::Policy>(hPolicy),
                                           static_cast<QSizePolicy::Policy>(vPolicy)));
    }
}

int32_t qWidgetSizePolicyH(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        return static_cast<int32_t>(widget->sizePolicy().horizontalPolicy());
    }
    return -1;
}

int32_t qWidgetSizePolicyV(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        return static_cast<int32_t>(widget->sizePolicy().verticalPolicy());
    }
    return -1;
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

