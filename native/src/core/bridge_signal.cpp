/**
 * @file bridge_signal.cpp
 * @brief 信号槽连接机制 - 专用回调函数
 * 
 * 设计原则：
 * 1. 为常用信号提供专用连接函数，避免动态查找的不稳定性
 * 2. 使用回调存储机制，支持仓颉 CFunc 回调
 * 3. 自动清理机制，防止内存泄漏
 */

#include <QObject>
#include <QPushButton>
#include <QSlider>
#include <QSpinBox>
#include <QCheckBox>
#include <QRadioButton>
#include <QComboBox>
#include <QLineEdit>
#include <QTimer>
#include <QAction>
#include <QHash>
#include <functional>
#include <QDebug>

extern "C" {

// ============================================================
// 回调存储
// ============================================================

// 无参数回调存储
static QHash<int64_t, std::function<void()>> g_voidCallbacks;

// Int32参数回调存储
static QHash<int64_t, std::function<void(int32_t)>> g_int32Callbacks;

// Int64参数回调存储
static QHash<int64_t, std::function<void(int64_t)>> g_int64Callbacks;

// ============================================================
// QPushButton 信号
// ============================================================

void qButtonConnectClicked(int64_t ptr, void (*callback)()) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn && callback) {
        g_voidCallbacks[ptr] = callback;
        QObject::connect(btn, &QPushButton::clicked, [ptr]() {
            auto it = g_voidCallbacks.find(ptr);
            if (it != g_voidCallbacks.end()) {
                it.value()();
            }
        });
    }
}

void qButtonDisconnectClicked(int64_t ptr) {
    g_voidCallbacks.remove(ptr);
}

// ============================================================
// QSlider 信号
// ============================================================

void qSliderConnectValueChanged(int64_t ptr, void (*callback)(int32_t)) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider && callback) {
        g_int32Callbacks[ptr] = callback;
        QObject::connect(slider, &QSlider::valueChanged, [ptr](int value) {
            auto it = g_int32Callbacks.find(ptr);
            if (it != g_int32Callbacks.end()) {
                it.value()(value);
            }
        });
    }
}

void qSliderDisconnectValueChanged(int64_t ptr) {
    g_int32Callbacks.remove(ptr);
}

// ============================================================
// QSpinBox 信号
// ============================================================

void qSpinBoxConnectValueChanged(int64_t ptr, void (*callback)(int32_t)) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox && callback) {
        g_int32Callbacks[ptr] = callback;
        QObject::connect(spinBox, QOverload<int>::of(&QSpinBox::valueChanged), [ptr](int value) {
            auto it = g_int32Callbacks.find(ptr);
            if (it != g_int32Callbacks.end()) {
                it.value()(value);
            }
        });
    }
}

void qSpinBoxDisconnectValueChanged(int64_t ptr) {
    g_int32Callbacks.remove(ptr);
}

// ============================================================
// QCheckBox 信号
// ============================================================

void qCheckBoxConnectStateChanged(int64_t ptr, void (*callback)(int32_t)) {
    QCheckBox* checkBox = reinterpret_cast<QCheckBox*>(ptr);
    if (checkBox && callback) {
        g_int32Callbacks[ptr] = callback;
        QObject::connect(checkBox, &QCheckBox::stateChanged, [ptr](int state) {
            auto it = g_int32Callbacks.find(ptr);
            if (it != g_int32Callbacks.end()) {
                it.value()(state);
            }
        });
    }
}

void qCheckBoxDisconnectStateChanged(int64_t ptr) {
    g_int32Callbacks.remove(ptr);
}

// ============================================================
// QRadioButton 信号
// ============================================================

void qRadioButtonConnectToggled(int64_t ptr, void (*callback)(int32_t)) {
    QRadioButton* radioBtn = reinterpret_cast<QRadioButton*>(ptr);
    if (radioBtn && callback) {
        g_int32Callbacks[ptr] = callback;
        QObject::connect(radioBtn, &QRadioButton::toggled, [ptr](bool checked) {
            auto it = g_int32Callbacks.find(ptr);
            if (it != g_int32Callbacks.end()) {
                it.value()(checked ? 1 : 0);
            }
        });
    }
}

void qRadioButtonDisconnectToggled(int64_t ptr) {
    g_int32Callbacks.remove(ptr);
}

// ============================================================
// QComboBox 信号
// ============================================================

void qComboBoxConnectCurrentIndexChanged(int64_t ptr, void (*callback)(int32_t)) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox && callback) {
        g_int32Callbacks[ptr] = callback;
        QObject::connect(comboBox, QOverload<int>::of(&QComboBox::currentIndexChanged), [ptr](int index) {
            auto it = g_int32Callbacks.find(ptr);
            if (it != g_int32Callbacks.end()) {
                it.value()(index);
            }
        });
    }
}

void qComboBoxDisconnectCurrentIndexChanged(int64_t ptr) {
    g_int32Callbacks.remove(ptr);
}

// ============================================================
// QLineEdit 信号
// ============================================================

// 文本改变回调存储（使用对象指针作为key）
static QHash<int64_t, std::function<void(const char*)>> g_textChangedCallbacks;

void qLineEditConnectTextChanged(int64_t ptr, void (*callback)(const char*)) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit && callback) {
        g_textChangedCallbacks[ptr] = callback;
        QObject::connect(lineEdit, &QLineEdit::textChanged, [ptr](const QString& text) {
            auto it = g_textChangedCallbacks.find(ptr);
            if (it != g_textChangedCallbacks.end()) {
                it.value()(text.toUtf8().constData());
            }
        });
    }
}

void qLineEditDisconnectTextChanged(int64_t ptr) {
    g_textChangedCallbacks.remove(ptr);
}

// ============================================================
// QTimer 信号
// ============================================================

void qTimerConnectTimeout(int64_t ptr, void (*callback)()) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer && callback) {
        g_voidCallbacks[ptr] = callback;
        QObject::connect(timer, &QTimer::timeout, [ptr]() {
            auto it = g_voidCallbacks.find(ptr);
            if (it != g_voidCallbacks.end()) {
                it.value()();
            }
        });
    }
}

void qTimerDisconnectTimeout(int64_t ptr) {
    g_voidCallbacks.remove(ptr);
}

// ============================================================
// QAction 信号
// ============================================================

void qActionConnectTriggered(int64_t ptr, void (*callback)()) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action && callback) {
        g_voidCallbacks[ptr] = callback;
        QObject::connect(action, &QAction::triggered, [ptr]() {
            auto it = g_voidCallbacks.find(ptr);
            if (it != g_voidCallbacks.end()) {
                it.value()();
            }
        });
    }
}

void qActionDisconnectTriggered(int64_t ptr) {
    g_voidCallbacks.remove(ptr);
}

// ============================================================
// 清理函数
// ============================================================

void qSignalCleanup(int64_t ptr) {
    g_voidCallbacks.remove(ptr);
    g_int32Callbacks.remove(ptr);
    g_int64Callbacks.remove(ptr);
    g_textChangedCallbacks.remove(ptr);
}

} // extern "C"
