/**
 * @file bridge_signal.cpp
 * @brief 信号槽连接机制 - 专用回调函数 (P0 修复版)
 *
 * 修复要点（相对旧版）：
 *  1. 消除共享哈希碰撞：回调表与连接表以复合键 (ptr, signalId) 索引，
 *     同一控件的多个 void 信号（如 QLineEdit 的 returnPressed / editingFinished）
 *     不再互相覆盖、串台。
 *  2. 真正的 disconnect：保存 QMetaObject::Connection 句柄，
 *     disconnect 时调用 QObject::disconnect(conn) 精确断开，并清理回调表，
 *     不再只是 remove 哈希（旧版 lambda 仍挂在对象上）。
 *  3. 统一连接语义：替换式 —— 重复 connect 同一个信号会先断开旧连接再建立新连接，
 *     行为一致且可预测。
 */

#include <QObject>
#include <QEvent>
#include <QWidget>
#include <QPointer>
#include <QPushButton>
#include <QToolButton>
#include <QSlider>
#include <QSpinBox>
#include <QDoubleSpinBox>
#include <QDial>
#include <QCheckBox>
#include <QRadioButton>
#include <QComboBox>
#include <QLineEdit>
#include <QTimer>
#include <QAction>
#include <QQuickItem>
#include <QQmlComponent>
#include <QQuickWindow>
#include <QHash>
#include <functional>
#include <unordered_map>
#include <atomic>
#include <thread>
#include <cstdint>
#include <vector>
#include <QDebug>
#include "signalemitter.h"

// ============================================================
// 复合键与存储
// ============================================================

struct ConnKey {
    int64_t ptr;
    int sig;
    bool operator==(const ConnKey& o) const { return ptr == o.ptr && sig == o.sig; }
};

namespace std {
    template<> struct hash<ConnKey> {
        size_t operator()(const ConnKey& k) const noexcept {
            return std::hash<int64_t>()(k.ptr) ^ (std::hash<int>()(k.sig) << 1);
        }
    };
}

// 信号编号
enum SigId {
    SIG_CLICKED = 1,
    SIG_TOOLCLICKED,
    SIG_RETPRESSED,
    SIG_EDITFINISHED,
    SIG_TIMEOUT,
    SIG_TRIGGERED,
    SIG_DESTROYED,
    SIG_SLIDER_VAL,
    SIG_SPIN_VAL,
    SIG_DIAL_VAL,
    SIG_CHECK_STATE,
    SIG_RADIO_TOGGLED,
    SIG_COMBO_IDX,
    SIG_SLIDER_MOVED,
    SIG_DSPIN_VAL,
    SIG_LE_TEXT,
    SIG_COMBO_TEXT,
    SIG_PRESSED,
    SIG_RELEASED,
    SIG_TOOLPRESSED,
    SIG_TOOLRELEASED,
    SIG_CLOSE,
    // QML/QtQuick 信号
    SIG_ITEM_X,
    SIG_ITEM_Y,
    SIG_ITEM_WIDTH,
    SIG_ITEM_HEIGHT,
    SIG_ITEM_OPACITY,
    SIG_ITEM_ROTATION,
    SIG_ITEM_SCALE,
    SIG_ITEM_Z,
    SIG_ITEM_VISIBLE,
    SIG_ITEM_ENABLED,
    SIG_ITEM_FOCUS,
    SIG_ITEM_PARENT,
    SIG_ITEM_CHILDREN,
    SIG_WIN_WIDTH,
    SIG_WIN_HEIGHT,
    SIG_WIN_VISIBLE,
    SIG_COMP_STATUS,
    // P2：SignalEmitter 通用自定义信号
    SIG_EMIT_VOID = 100,
    SIG_EMIT_INT,
    SIG_EMIT_DOUBLE,
    SIG_EMIT_STRING
};

// 线程安全 - atomic_flag spinlock (无 CRT/OS 原始锁依赖，避免 DLL 加载时的死锁)
static std::atomic_flag g_callbackLock = ATOMIC_FLAG_INIT;

class CallbackSpinLock {
public:
    CallbackSpinLock() {
        while (g_callbackLock.test_and_set(std::memory_order_acquire)) {
            std::this_thread::yield();
        }
    }
    ~CallbackSpinLock() {
        g_callbackLock.clear(std::memory_order_release);
    }
};
#define LOCK_CALLBACKS() CallbackSpinLock _lock

// 回调表（按签名分桶，键含信号编号，故各信号互不干扰）
static std::unordered_map<ConnKey, std::function<void()>>            g_voidCbs;
static std::unordered_map<ConnKey, std::function<void(int32_t)>>     g_int32Cbs;
static std::unordered_map<ConnKey, std::function<void(double)>>      g_float64Cbs;
static std::unordered_map<ConnKey, std::function<void(const char*)>> g_textCbs;
static std::unordered_map<ConnKey, std::function<void(int64_t)>>     g_int64Cbs;
// 连接句柄表
static std::unordered_map<ConnKey, QMetaObject::Connection>          g_conns;

// P1c：闭包捕获支持 —— void 信号的「id 版」连接（Cangjie 侧可捕获闭包经注册表按 id 派发）
static std::unordered_map<ConnKey, int64_t>                          g_voidIds;
// Cangjie 注册的 void 调度器：native 触发信号时回调它，按 id 查注册表并调用闭包
static void (*g_voidDispatcher)(int64_t) = nullptr;

// 触发辅助：取 id 并派发到 Cangjie 调度器（内部辅助，定义在 extern "C" 之外避免链接规范冲突）
static void dispatchVoidId(ConnKey key) {
    int64_t id = 0;
    {
        LOCK_CALLBACKS();
        auto i = g_voidIds.find(key);
        if (i != g_voidIds.end()) id = i->second;
    }
    if (g_voidDispatcher && id != 0) {
        g_voidDispatcher(id);
    }
}

// QWidget close 事件过滤器（P0 修复版同风格）：
// 拦截 QEvent::Close 派发 void 信号。filter 以被监听 widget 为 parent，
// 随 widget 销毁自动回收；g_closeFilters 用 QPointer 持有，杜绝悬垂访问。
class CloseEventFilter : public QObject {
public:
    CloseEventFilter(int64_t widgetPtr)
        : QObject(nullptr), m_widgetPtr(widgetPtr) {}

    bool eventFilter(QObject* watched, QEvent* event) override {
        if (event->type() == QEvent::Close && watched == reinterpret_cast<QObject*>(m_widgetPtr)) {
            dispatchVoidId(ConnKey{m_widgetPtr, SIG_CLOSE});
        }
        // 不吞掉事件：widget 仍按原逻辑正常关闭
        return QObject::eventFilter(watched, event);
    }

private:
    int64_t m_widgetPtr;
};

// close 事件过滤器注册表（QPointer 保证被监听 widget 销毁后自动置空）
static std::unordered_map<ConnKey, QPointer<CloseEventFilter>>       g_closeFilters;

// 按复合键精确断开：取句柄 -> 锁外 QObject::disconnect -> 清理回调表
static void disconnectByKey(ConnKey key) {
    QMetaObject::Connection conn;
    {
        LOCK_CALLBACKS();
        auto it = g_conns.find(key);
        if (it != g_conns.end()) {
            conn = it->second;
            g_conns.erase(it);
        }
    }
    if (conn) {
        QObject::disconnect(conn);
    }
    LOCK_CALLBACKS();
    g_voidCbs.erase(key);
    g_int32Cbs.erase(key);
    g_float64Cbs.erase(key);
    g_textCbs.erase(key);
    g_int64Cbs.erase(key);
    g_voidIds.erase(key);
    // close 事件过滤器清理：先摘除再删除（QPointer 若已随 widget 销毁置空则跳过）
    auto fi = g_closeFilters.find(key);
    if (fi != g_closeFilters.end()) {
        CloseEventFilter* f = fi->second.data();
        if (f) {
            QObject* w = reinterpret_cast<QObject*>(key.ptr);
            if (w) { w->removeEventFilter(f); }
            delete f;
        }
        g_closeFilters.erase(fi);
    }
}

// ============================================================
// SignalEmitter - 通用自定义信号发射器（P2）
// ============================================================

namespace cjfw {

SignalEmitter::SignalEmitter(QObject* parent) : QObject(parent) {}

void SignalEmitter::emitVoid()           { emit signalVoid(); }
void SignalEmitter::emitInt(int v)       { emit signalInt(v); }
void SignalEmitter::emitDouble(double v) { emit signalDouble(v); }
void SignalEmitter::emitString(const QString& s) { emit signalString(s); }

} // namespace cjfw

extern "C" {

// ============================================================
// QPushButton 信号
// ============================================================

void qButtonConnectClicked(int64_t ptr, void (*callback)()) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn && callback) {
        ConnKey key{ptr, SIG_CLICKED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(btn, &QPushButton::clicked, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qButtonDisconnectClicked(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_CLICKED});
}

// ============================================================
// QToolButton 信号
// ============================================================

void qToolButtonConnectClicked(int64_t ptr, void (*callback)()) {
    QToolButton* btn = reinterpret_cast<QToolButton*>(ptr);
    if (btn && callback) {
        ConnKey key{ptr, SIG_TOOLCLICKED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(btn, &QToolButton::clicked, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qToolButtonDisconnectClicked(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_TOOLCLICKED});
}

// ============================================================
// QSlider 信号
// ============================================================

void qSliderConnectValueChanged(int64_t ptr, void (*callback)(int32_t)) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider && callback) {
        ConnKey key{ptr, SIG_SLIDER_VAL};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_int32Cbs[key] = callback;
        g_conns[key] = QObject::connect(slider, &QSlider::valueChanged, [key](int value) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_int32Cbs.find(key);
                if (i != g_int32Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb(static_cast<int32_t>(value)); } catch (...) {} }
        });
    }
}

void qSliderDisconnectValueChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_SLIDER_VAL});
}

// ============================================================
// QSlider::sliderMoved 信号
// ============================================================

void qSliderConnectSliderMoved(int64_t ptr, void (*callback)(int32_t)) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider && callback) {
        ConnKey key{ptr, SIG_SLIDER_MOVED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_int32Cbs[key] = callback;
        g_conns[key] = QObject::connect(slider, &QSlider::sliderMoved, [key](int value) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_int32Cbs.find(key);
                if (i != g_int32Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb(static_cast<int32_t>(value)); } catch (...) {} }
        });
    }
}

void qSliderDisconnectSliderMoved(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_SLIDER_MOVED});
}

// ============================================================
// QSpinBox 信号
// ============================================================

void qSpinBoxConnectValueChanged(int64_t ptr, void (*callback)(int32_t)) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox && callback) {
        ConnKey key{ptr, SIG_SPIN_VAL};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_int32Cbs[key] = callback;
        g_conns[key] = QObject::connect(spinBox, QOverload<int>::of(&QSpinBox::valueChanged), [key](int value) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_int32Cbs.find(key);
                if (i != g_int32Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb(static_cast<int32_t>(value)); } catch (...) {} }
        });
    }
}

void qSpinBoxDisconnectValueChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_SPIN_VAL});
}

// ============================================================
// QDoubleSpinBox 信号
// ============================================================

void qDoubleSpinBoxConnectValueChanged(int64_t ptr, void (*callback)(double)) {
    QDoubleSpinBox* spinBox = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (spinBox && callback) {
        ConnKey key{ptr, SIG_DSPIN_VAL};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_float64Cbs[key] = callback;
        g_conns[key] = QObject::connect(spinBox, QOverload<double>::of(&QDoubleSpinBox::valueChanged), [key](double value) {
            std::function<void(double)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_float64Cbs.find(key);
                if (i != g_float64Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb(value); } catch (...) {} }
        });
    }
}

void qDoubleSpinBoxDisconnectValueChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_DSPIN_VAL});
}

// ============================================================
// QDial 信号
// ============================================================

void qDialConnectValueChanged(int64_t ptr, void (*callback)(int32_t)) {
    QDial* dial = reinterpret_cast<QDial*>(ptr);
    if (dial && callback) {
        ConnKey key{ptr, SIG_DIAL_VAL};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_int32Cbs[key] = callback;
        g_conns[key] = QObject::connect(dial, &QDial::valueChanged, [key](int value) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_int32Cbs.find(key);
                if (i != g_int32Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb(static_cast<int32_t>(value)); } catch (...) {} }
        });
    }
}

void qDialDisconnectValueChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_DIAL_VAL});
}

// ============================================================
// QCheckBox 信号
// ============================================================

void qCheckBoxConnectStateChanged(int64_t ptr, void (*callback)(int32_t)) {
    QCheckBox* cbBox = reinterpret_cast<QCheckBox*>(ptr);
    if (cbBox && callback) {
        ConnKey key{ptr, SIG_CHECK_STATE};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_int32Cbs[key] = callback;
        g_conns[key] = QObject::connect(cbBox, &QCheckBox::stateChanged, [key](int state) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_int32Cbs.find(key);
                if (i != g_int32Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb(static_cast<int32_t>(state)); } catch (...) {} }
        });
    }
}

void qCheckBoxDisconnectStateChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_CHECK_STATE});
}

// ============================================================
// QRadioButton 信号
// ============================================================

void qRadioButtonConnectToggled(int64_t ptr, void (*callback)(int32_t)) {
    QRadioButton* rb = reinterpret_cast<QRadioButton*>(ptr);
    if (rb && callback) {
        ConnKey key{ptr, SIG_RADIO_TOGGLED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_int32Cbs[key] = callback;
        g_conns[key] = QObject::connect(rb, &QRadioButton::toggled, [key](bool checked) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_int32Cbs.find(key);
                if (i != g_int32Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb(checked ? 1 : 0); } catch (...) {} }
        });
    }
}

void qRadioButtonDisconnectToggled(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_RADIO_TOGGLED});
}

// ============================================================
// QComboBox 信号
// ============================================================

void qComboBoxConnectCurrentIndexChanged(int64_t ptr, void (*callback)(int32_t)) {
    QComboBox* cb = reinterpret_cast<QComboBox*>(ptr);
    if (cb && callback) {
        ConnKey key{ptr, SIG_COMBO_IDX};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_int32Cbs[key] = callback;
        g_conns[key] = QObject::connect(cb, QOverload<int>::of(&QComboBox::currentIndexChanged), [key](int index) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_int32Cbs.find(key);
                if (i != g_int32Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb(static_cast<int32_t>(index)); } catch (...) {} }
        });
    }
}

void qComboBoxDisconnectCurrentIndexChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_COMBO_IDX});
}

// ============================================================
// QComboBox::currentTextChanged 信号
// ============================================================

void qComboBoxConnectCurrentTextChanged(int64_t ptr, void (*callback)(const char*)) {
    QComboBox* cb = reinterpret_cast<QComboBox*>(ptr);
    if (cb && callback) {
        ConnKey key{ptr, SIG_COMBO_TEXT};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_textCbs[key] = callback;
        g_conns[key] = QObject::connect(cb, &QComboBox::currentTextChanged, [key](const QString& text) {
            std::function<void(const char*)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_textCbs.find(key);
                if (i != g_textCbs.end()) cb = i->second;
            }
            if (cb) {
                // P2 生命周期修复：用 std::string 持有，确保回调调用期间 const char* 有效
                std::string s = text.toUtf8().constData();
                try { cb(s.c_str()); } catch (...) {}
            }
        });
    }
}

void qComboBoxDisconnectCurrentTextChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_COMBO_TEXT});
}

// ============================================================
// QLineEdit 信号
// ============================================================

void qLineEditConnectTextChanged(int64_t ptr, void (*callback)(const char*)) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    if (le && callback) {
        ConnKey key{ptr, SIG_LE_TEXT};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_textCbs[key] = callback;
        g_conns[key] = QObject::connect(le, &QLineEdit::textChanged, [key](const QString& text) {
            std::function<void(const char*)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_textCbs.find(key);
                if (i != g_textCbs.end()) cb = i->second;
            }
            if (cb) {
                // P2 生命周期修复：用 std::string 持有，确保回调调用期间 const char* 有效
                std::string s = text.toUtf8().constData();
                try { cb(s.c_str()); } catch (...) {}
            }
        });
    }
}

void qLineEditDisconnectTextChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_LE_TEXT});
}

// ============================================================
// QLineEdit::returnPressed 信号
// ============================================================

void qLineEditConnectReturnPressed(int64_t ptr, void (*callback)()) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    if (le && callback) {
        ConnKey key{ptr, SIG_RETPRESSED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(le, &QLineEdit::returnPressed, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qLineEditDisconnectReturnPressed(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_RETPRESSED});
}

// ============================================================
// QLineEdit::editingFinished 信号
// ============================================================

void qLineEditConnectEditingFinished(int64_t ptr, void (*callback)()) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    if (le && callback) {
        ConnKey key{ptr, SIG_EDITFINISHED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(le, &QLineEdit::editingFinished, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qLineEditDisconnectEditingFinished(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_EDITFINISHED});
}

// ============================================================
// QTimer 信号
// ============================================================

void qTimerConnectTimeout(int64_t ptr, void (*callback)()) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer && callback) {
        ConnKey key{ptr, SIG_TIMEOUT};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(timer, &QTimer::timeout, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) {
                try {
                    cb();
                } catch (...) {}
            }
        });
    }
}

void qTimerDisconnectTimeout(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_TIMEOUT});
}

// ============================================================
// QAction 信号
// ============================================================

void qActionConnectTriggered(int64_t ptr, void (*callback)()) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action && callback) {
        ConnKey key{ptr, SIG_TRIGGERED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(action, &QAction::triggered, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qActionDisconnectTriggered(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_TRIGGERED});
}

// ============================================================
// QWidget::destroyed 信号
// ============================================================

void qWidgetConnectDestroyed(int64_t ptr, void (*callback)()) {
    QObject* obj = reinterpret_cast<QObject*>(ptr);
    if (obj && callback) {
        ConnKey key{ptr, SIG_DESTROYED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(obj, &QObject::destroyed, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qWidgetDisconnectDestroyed(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_DESTROYED});
}

// ============================================================
// P1c：闭包捕获 —— void 信号的 id 版连接
//   Cangjie 侧把可捕获闭包存入注册表，得到 id；native 仅保存 id，
//   信号触发时回调 g_voidDispatcher(id) 由 Cangjie 查表调用闭包。
//   语义与旧版一致：替换式（先断开旧连接再建新连接）。
// ============================================================

void qSetCallbackDispatcher(void (*disp)(int64_t)) {
    g_voidDispatcher = disp;
}

// P1：UiPoster 跨线程回投 —— 供 bridge_ui_poster.cpp 获取 Cangjie 注册的 void 调度器
void (*qGetVoidDispatcher())(int64_t) {
    return g_voidDispatcher;
}

// P1c：捕获路径的断开（供 bridge_ext_wcore.cpp 中按钮扩展信号 disconnect 同步清理）
void qButtonPressedIdDisconnect(int64_t ptr)   { disconnectByKey(ConnKey{ptr, SIG_PRESSED}); }
void qButtonReleasedIdDisconnect(int64_t ptr)  { disconnectByKey(ConnKey{ptr, SIG_RELEASED}); }
void qToolButtonPressedIdDisconnect(int64_t ptr)   { disconnectByKey(ConnKey{ptr, SIG_TOOLPRESSED}); }
void qToolButtonReleasedIdDisconnect(int64_t ptr)  { disconnectByKey(ConnKey{ptr, SIG_TOOLRELEASED}); }

void qButtonConnectClickedId(int64_t ptr, int64_t id) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn) {
        ConnKey key{ptr, SIG_CLICKED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidIds[key] = id;
        g_conns[key] = QObject::connect(btn, &QPushButton::clicked, [key]() { dispatchVoidId(key); });
    }
}

void qToolButtonConnectClickedId(int64_t ptr, int64_t id) {
    QToolButton* btn = reinterpret_cast<QToolButton*>(ptr);
    if (btn) {
        ConnKey key{ptr, SIG_TOOLCLICKED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidIds[key] = id;
        g_conns[key] = QObject::connect(btn, &QToolButton::clicked, [key]() { dispatchVoidId(key); });
    }
}

void qButtonConnectPressedId(int64_t ptr, int64_t id) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn) {
        ConnKey key{ptr, SIG_PRESSED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidIds[key] = id;
        g_conns[key] = QObject::connect(btn, &QPushButton::pressed, [key]() { dispatchVoidId(key); });
    }
}

void qButtonConnectReleasedId(int64_t ptr, int64_t id) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn) {
        ConnKey key{ptr, SIG_RELEASED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidIds[key] = id;
        g_conns[key] = QObject::connect(btn, &QPushButton::released, [key]() { dispatchVoidId(key); });
    }
}

void qToolButtonConnectPressedId(int64_t ptr, int64_t id) {
    QToolButton* btn = reinterpret_cast<QToolButton*>(ptr);
    if (btn) {
        ConnKey key{ptr, SIG_TOOLPRESSED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidIds[key] = id;
        g_conns[key] = QObject::connect(btn, &QToolButton::pressed, [key]() { dispatchVoidId(key); });
    }
}

void qToolButtonConnectReleasedId(int64_t ptr, int64_t id) {
    QToolButton* btn = reinterpret_cast<QToolButton*>(ptr);
    if (btn) {
        ConnKey key{ptr, SIG_TOOLRELEASED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidIds[key] = id;
        g_conns[key] = QObject::connect(btn, &QToolButton::released, [key]() { dispatchVoidId(key); });
    }
}

void qTimerConnectTimeoutId(int64_t ptr, int64_t id) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        ConnKey key{ptr, SIG_TIMEOUT};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidIds[key] = id;
        g_conns[key] = QObject::connect(timer, &QTimer::timeout, [key]() {
            dispatchVoidId(key);
        });
    }
}

void qLineEditConnectReturnPressedId(int64_t ptr, int64_t id) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    if (le) {
        ConnKey key{ptr, SIG_RETPRESSED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidIds[key] = id;
        g_conns[key] = QObject::connect(le, &QLineEdit::returnPressed, [key]() { dispatchVoidId(key); });
    }
}

void qLineEditConnectEditingFinishedId(int64_t ptr, int64_t id) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    if (le) {
        ConnKey key{ptr, SIG_EDITFINISHED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidIds[key] = id;
        g_conns[key] = QObject::connect(le, &QLineEdit::editingFinished, [key]() { dispatchVoidId(key); });
    }
}

void qActionConnectTriggeredId(int64_t ptr, int64_t id) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action) {
        ConnKey key{ptr, SIG_TRIGGERED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidIds[key] = id;
        g_conns[key] = QObject::connect(action, &QAction::triggered, [key]() { dispatchVoidId(key); });
    }
}

void qWidgetConnectDestroyedId(int64_t ptr, int64_t id) {
    QObject* obj = reinterpret_cast<QObject*>(ptr);
    if (obj) {
        ConnKey key{ptr, SIG_DESTROYED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidIds[key] = id;
        g_conns[key] = QObject::connect(obj, &QObject::destroyed, [key]() { dispatchVoidId(key); });
    }
}

// ============================================================
// QWidget close 事件（事件过滤器实现，拦截 QEvent::Close）
// 替换式连接：重复连接先断开旧 filter，行为与其他信号一致
// ============================================================

void qWidgetConnectCloseId(int64_t ptr, int64_t id) {
    QWidget* w = reinterpret_cast<QWidget*>(ptr);
    if (w) {
        ConnKey key{ptr, SIG_CLOSE};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidIds[key] = id;
        CloseEventFilter* filter = new CloseEventFilter(ptr);
        filter->setParent(w);
        g_closeFilters[key] = filter;
        w->installEventFilter(filter);
    }
}

void qWidgetDisconnectClose(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_CLOSE});
}

// ============================================================
// P2：SignalEmitter 通用自定义信号发射器
// ============================================================

int64_t qEmitterCreate() {
    return reinterpret_cast<int64_t>(new cjfw::SignalEmitter());
}

void qEmitterDelete(int64_t ptr) {
    cjfw::SignalEmitter* em = reinterpret_cast<cjfw::SignalEmitter*>(ptr);
    if (em) { delete em; }
}

void qEmitterConnectVoid(int64_t ptr, void (*callback)(), int32_t connType) {
    cjfw::SignalEmitter* em = reinterpret_cast<cjfw::SignalEmitter*>(ptr);
    if (em && callback) {
        ConnKey key{ptr, SIG_EMIT_VOID};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(em, &cjfw::SignalEmitter::signalVoid, em, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        }, (Qt::ConnectionType)connType);
    }
}

// P1c 风格：void 信号 id 版连接（Cangjie 侧可捕获闭包经注册表按 id 派发）
void qEmitterConnectVoidId(int64_t ptr, int64_t id, int32_t connType) {
    cjfw::SignalEmitter* em = reinterpret_cast<cjfw::SignalEmitter*>(ptr);
    if (em) {
        ConnKey key{ptr, SIG_EMIT_VOID};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidIds[key] = id;
        g_conns[key] = QObject::connect(em, &cjfw::SignalEmitter::signalVoid, em, [key]() {
            dispatchVoidId(key);
        }, (Qt::ConnectionType)connType);
    }
}

void qEmitterConnectInt(int64_t ptr, void (*callback)(int32_t), int32_t connType) {
    cjfw::SignalEmitter* em = reinterpret_cast<cjfw::SignalEmitter*>(ptr);
    if (em && callback) {
        ConnKey key{ptr, SIG_EMIT_INT};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_int32Cbs[key] = callback;
        g_conns[key] = QObject::connect(em, &cjfw::SignalEmitter::signalInt, em, [key](int v) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_int32Cbs.find(key);
                if (i != g_int32Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb((int32_t)v); } catch (...) {} }
        }, (Qt::ConnectionType)connType);
    }
}

void qEmitterConnectDouble(int64_t ptr, void (*callback)(double), int32_t connType) {
    cjfw::SignalEmitter* em = reinterpret_cast<cjfw::SignalEmitter*>(ptr);
    if (em && callback) {
        ConnKey key{ptr, SIG_EMIT_DOUBLE};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_float64Cbs[key] = callback;
        g_conns[key] = QObject::connect(em, &cjfw::SignalEmitter::signalDouble, em, [key](double v) {
            std::function<void(double)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_float64Cbs.find(key);
                if (i != g_float64Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb(v); } catch (...) {} }
        }, (Qt::ConnectionType)connType);
    }
}

void qEmitterConnectString(int64_t ptr, void (*callback)(const char*), int32_t connType) {
    cjfw::SignalEmitter* em = reinterpret_cast<cjfw::SignalEmitter*>(ptr);
    if (em && callback) {
        ConnKey key{ptr, SIG_EMIT_STRING};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_textCbs[key] = callback;
        g_conns[key] = QObject::connect(em, &cjfw::SignalEmitter::signalString, em,
            [key](const QString& text) {
                std::function<void(const char*)> cb;
                {
                    LOCK_CALLBACKS();
                    auto i = g_textCbs.find(key);
                    if (i != g_textCbs.end()) cb = i->second;
                }
                if (cb) {
                    // P2 生命周期修复：用 std::string 持有，确保回调调用期间 const char* 有效
                    std::string s = text.toUtf8().constData();
                    try { cb(s.c_str()); } catch (...) {}
                }
            }, (Qt::ConnectionType)connType);
    }
}

void qEmitterDisconnectVoid(int64_t ptr)   { disconnectByKey(ConnKey{ptr, SIG_EMIT_VOID}); }
void qEmitterDisconnectInt(int64_t ptr)    { disconnectByKey(ConnKey{ptr, SIG_EMIT_INT}); }
void qEmitterDisconnectDouble(int64_t ptr) { disconnectByKey(ConnKey{ptr, SIG_EMIT_DOUBLE}); }
void qEmitterDisconnectString(int64_t ptr) { disconnectByKey(ConnKey{ptr, SIG_EMIT_STRING}); }

void qEmitterEmitVoid(int64_t ptr) {
    cjfw::SignalEmitter* em = reinterpret_cast<cjfw::SignalEmitter*>(ptr);
    if (em) { em->emitVoid(); }
}

void qEmitterEmitInt(int64_t ptr, int32_t v) {
    cjfw::SignalEmitter* em = reinterpret_cast<cjfw::SignalEmitter*>(ptr);
    if (em) { em->emitInt((int)v); }
}

void qEmitterEmitDouble(int64_t ptr, double v) {
    cjfw::SignalEmitter* em = reinterpret_cast<cjfw::SignalEmitter*>(ptr);
    if (em) { em->emitDouble(v); }
}

void qEmitterEmitString(int64_t ptr, const char* s) {
    cjfw::SignalEmitter* em = reinterpret_cast<cjfw::SignalEmitter*>(ptr);
    if (em) { em->emitString(QString::fromUtf8(s ? s : "")); }
}

// ============================================================
// QQuickItem 信号
// ============================================================

void qQuickItemConnectXChanged(int64_t ptr, void (*callback)()) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item && callback) {
        ConnKey key{ptr, SIG_ITEM_X};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(item, &QQuickItem::xChanged, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qQuickItemDisconnectXChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_ITEM_X});
}

void qQuickItemConnectYChanged(int64_t ptr, void (*callback)()) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item && callback) {
        ConnKey key{ptr, SIG_ITEM_Y};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(item, &QQuickItem::yChanged, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qQuickItemDisconnectYChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_ITEM_Y});
}

void qQuickItemConnectWidthChanged(int64_t ptr, void (*callback)()) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item && callback) {
        ConnKey key{ptr, SIG_ITEM_WIDTH};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(item, &QQuickItem::widthChanged, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qQuickItemDisconnectWidthChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_ITEM_WIDTH});
}

void qQuickItemConnectHeightChanged(int64_t ptr, void (*callback)()) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item && callback) {
        ConnKey key{ptr, SIG_ITEM_HEIGHT};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(item, &QQuickItem::heightChanged, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qQuickItemDisconnectHeightChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_ITEM_HEIGHT});
}

void qQuickItemConnectOpacityChanged(int64_t ptr, void (*callback)()) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item && callback) {
        ConnKey key{ptr, SIG_ITEM_OPACITY};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(item, &QQuickItem::opacityChanged, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qQuickItemDisconnectOpacityChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_ITEM_OPACITY});
}

void qQuickItemConnectRotationChanged(int64_t ptr, void (*callback)()) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item && callback) {
        ConnKey key{ptr, SIG_ITEM_ROTATION};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(item, &QQuickItem::rotationChanged, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qQuickItemDisconnectRotationChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_ITEM_ROTATION});
}

void qQuickItemConnectScaleChanged(int64_t ptr, void (*callback)()) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item && callback) {
        ConnKey key{ptr, SIG_ITEM_SCALE};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(item, &QQuickItem::scaleChanged, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qQuickItemDisconnectScaleChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_ITEM_SCALE});
}

void qQuickItemConnectZChanged(int64_t ptr, void (*callback)()) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item && callback) {
        ConnKey key{ptr, SIG_ITEM_Z};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(item, &QQuickItem::zChanged, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qQuickItemDisconnectZChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_ITEM_Z});
}

void qQuickItemConnectVisibleChanged(int64_t ptr, void (*callback)()) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item && callback) {
        ConnKey key{ptr, SIG_ITEM_VISIBLE};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(item, &QQuickItem::visibleChanged, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qQuickItemDisconnectVisibleChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_ITEM_VISIBLE});
}

void qQuickItemConnectEnabledChanged(int64_t ptr, void (*callback)()) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item && callback) {
        ConnKey key{ptr, SIG_ITEM_ENABLED};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(item, &QQuickItem::enabledChanged, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qQuickItemDisconnectEnabledChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_ITEM_ENABLED});
}

void qQuickItemConnectFocusChanged(int64_t ptr, void (*callback)(int32_t)) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item && callback) {
        ConnKey key{ptr, SIG_ITEM_FOCUS};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_int32Cbs[key] = callback;
        g_conns[key] = QObject::connect(item, &QQuickItem::focusChanged, [key](bool focus) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_int32Cbs.find(key);
                if (i != g_int32Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb(focus ? 1 : 0); } catch (...) {} }
        });
    }
}

void qQuickItemDisconnectFocusChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_ITEM_FOCUS});
}

void qQuickItemConnectParentChanged(int64_t ptr, void (*callback)(int64_t)) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item && callback) {
        ConnKey key{ptr, SIG_ITEM_PARENT};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_int64Cbs[key] = callback;
        g_conns[key] = QObject::connect(item, &QQuickItem::parentChanged, [key](QQuickItem* parent) {
            std::function<void(int64_t)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_int64Cbs.find(key);
                if (i != g_int64Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb(reinterpret_cast<int64_t>(parent)); } catch (...) {} }
        });
    }
}

void qQuickItemDisconnectParentChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_ITEM_PARENT});
}

void qQuickItemConnectChildrenChanged(int64_t ptr, void (*callback)()) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item && callback) {
        ConnKey key{ptr, SIG_ITEM_CHILDREN};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_voidCbs[key] = callback;
        g_conns[key] = QObject::connect(item, &QQuickItem::childrenChanged, [key]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_voidCbs.find(key);
                if (i != g_voidCbs.end()) cb = i->second;
            }
            if (cb) { try { cb(); } catch (...) {} }
        });
    }
}

void qQuickItemDisconnectChildrenChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_ITEM_CHILDREN});
}

// ============================================================
// QQuickWindow 信号
// ============================================================

void qQuickWindowConnectWidthChanged(int64_t ptr, void (*callback)(int32_t)) {
    QQuickWindow* win = reinterpret_cast<QQuickWindow*>(ptr);
    if (win && callback) {
        ConnKey key{ptr, SIG_WIN_WIDTH};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_int32Cbs[key] = callback;
        g_conns[key] = QObject::connect(win, &QQuickWindow::widthChanged, [key](int w) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_int32Cbs.find(key);
                if (i != g_int32Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb(static_cast<int32_t>(w)); } catch (...) {} }
        });
    }
}

void qQuickWindowDisconnectWidthChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_WIN_WIDTH});
}

void qQuickWindowConnectHeightChanged(int64_t ptr, void (*callback)(int32_t)) {
    QQuickWindow* win = reinterpret_cast<QQuickWindow*>(ptr);
    if (win && callback) {
        ConnKey key{ptr, SIG_WIN_HEIGHT};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_int32Cbs[key] = callback;
        g_conns[key] = QObject::connect(win, &QQuickWindow::heightChanged, [key](int h) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_int32Cbs.find(key);
                if (i != g_int32Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb(static_cast<int32_t>(h)); } catch (...) {} }
        });
    }
}

void qQuickWindowDisconnectHeightChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_WIN_HEIGHT});
}

void qQuickWindowConnectVisibleChanged(int64_t ptr, void (*callback)(int32_t)) {
    QQuickWindow* win = reinterpret_cast<QQuickWindow*>(ptr);
    if (win && callback) {
        ConnKey key{ptr, SIG_WIN_VISIBLE};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_int32Cbs[key] = callback;
        g_conns[key] = QObject::connect(win, &QQuickWindow::visibleChanged, [key](bool v) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_int32Cbs.find(key);
                if (i != g_int32Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb(v ? 1 : 0); } catch (...) {} }
        });
    }
}

void qQuickWindowDisconnectVisibleChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_WIN_VISIBLE});
}

// ============================================================
// QQmlComponent 信号
// ============================================================

void qQmlComponentConnectStatusChanged(int64_t ptr, void (*callback)(int32_t)) {
    QQmlComponent* comp = reinterpret_cast<QQmlComponent*>(ptr);
    if (comp && callback) {
        ConnKey key{ptr, SIG_COMP_STATUS};
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_int32Cbs[key] = callback;
        g_conns[key] = QObject::connect(comp, &QQmlComponent::statusChanged, [key](QQmlComponent::Status status) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto i = g_int32Cbs.find(key);
                if (i != g_int32Cbs.end()) cb = i->second;
            }
            if (cb) { try { cb(static_cast<int32_t>(status)); } catch (...) {} }
        });
    }
}

void qQmlComponentDisconnectStatusChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_COMP_STATUS});
}

// ============================================================
// 清理函数
// ============================================================

void qSignalCleanup(int64_t ptr) {
    std::vector<ConnKey> toErase;
    {
        LOCK_CALLBACKS();
        for (auto& kv : g_conns) {
            if (kv.first.ptr == ptr) {
                toErase.push_back(kv.first);
            }
        }
        // close 事件过滤器不占用 g_conns，需单独收集
        for (auto& kv : g_closeFilters) {
            if (kv.first.ptr == ptr) {
                toErase.push_back(kv.first);
            }
        }
    }
    for (auto& k : toErase) {
        disconnectByKey(k);
    }
}

} // extern "C"
