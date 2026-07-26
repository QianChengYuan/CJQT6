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
#include <QHash>
#include <functional>
#include <unordered_map>
#include <mutex>
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
    // P2：SignalEmitter 通用自定义信号
    SIG_EMIT_VOID = 100,
    SIG_EMIT_INT,
    SIG_EMIT_DOUBLE,
    SIG_EMIT_STRING
};

// 线程安全
static std::mutex g_callbackMutex;
#define LOCK_CALLBACKS() std::lock_guard<std::mutex> lock(g_callbackMutex)

// 回调表（按签名分桶，键含信号编号，故各信号互不干扰）
static std::unordered_map<ConnKey, std::function<void()>>            g_voidCbs;
static std::unordered_map<ConnKey, std::function<void(int32_t)>>     g_int32Cbs;
static std::unordered_map<ConnKey, std::function<void(double)>>      g_float64Cbs;
static std::unordered_map<ConnKey, std::function<void(const char*)>> g_textCbs;
// 连接句柄表
static std::unordered_map<ConnKey, QMetaObject::Connection>          g_conns;

// P1c：闭包捕获支持 —— void 信号的「id 版」连接（Cangjie 侧可捕获闭包经注册表按 id 派发）
static std::unordered_map<ConnKey, int64_t>                          g_voidIds;
// Cangjie 注册的 void 调度器：native 触发信号时回调它，按 id 查注册表并调用闭包
static void (*g_voidDispatcher)(int64_t) = nullptr;

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
    g_voidIds.erase(key);
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
            if (cb) cb();
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
            if (cb) cb();
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
            if (cb) cb(static_cast<int32_t>(value));
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
            if (cb) cb(static_cast<int32_t>(value));
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
            if (cb) cb(static_cast<int32_t>(value));
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
            if (cb) cb(value);
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
            if (cb) cb(static_cast<int32_t>(value));
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
            if (cb) cb(static_cast<int32_t>(state));
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
            if (cb) cb(checked ? 1 : 0);
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
            if (cb) cb(static_cast<int32_t>(index));
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
                cb(s.c_str());
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
                cb(s.c_str());
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
            if (cb) cb();
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
            if (cb) cb();
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
            if (cb) cb();
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
            if (cb) cb();
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

// P1c：捕获路径的断开（供 bridge_ext_wcore.cpp 中按钮扩展信号 disconnect 同步清理）
void qButtonPressedIdDisconnect(int64_t ptr)   { disconnectByKey(ConnKey{ptr, SIG_PRESSED}); }
void qButtonReleasedIdDisconnect(int64_t ptr)  { disconnectByKey(ConnKey{ptr, SIG_RELEASED}); }
void qToolButtonPressedIdDisconnect(int64_t ptr)   { disconnectByKey(ConnKey{ptr, SIG_TOOLPRESSED}); }
void qToolButtonReleasedIdDisconnect(int64_t ptr)  { disconnectByKey(ConnKey{ptr, SIG_TOOLRELEASED}); }

// 触发辅助：取 id 并派发到 Cangjie 调度器
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
            if (cb) cb();
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
            if (cb) cb((int32_t)v);
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
            if (cb) cb(v);
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
                    cb(s.c_str());
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
    }
    for (auto& k : toErase) {
        disconnectByKey(k);
    }
}

} // extern "C"
