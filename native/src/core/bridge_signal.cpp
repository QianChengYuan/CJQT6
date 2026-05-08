/**
 * @file bridge_signal.cpp
 * @brief 信号槽连接机制 - 专用回调函数
 * 
 * 设计原则：
 * 1. 为常用信号提供专用连接函数，避免动态查找的不稳定性
 * 2. 使用回调存储机制，支持仓颉 CFunc 回调
 * 3. 自动清理机制，防止内存泄漏
 * 4. 线程安全：使用互斥锁保护回调映射
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
#include <mutex>
#include <QDebug>

extern "C" {

// ============================================================
// 线程安全回调存储
// ============================================================

// 互斥锁
static std::mutex g_callbackMutex;

// 无参数回调存储
static QHash<int64_t, std::function<void()>> g_voidCallbacks;

// Int32参数回调存储
static QHash<int64_t, std::function<void(int32_t)>> g_int32Callbacks;

// Int64参数回调存储
static QHash<int64_t, std::function<void(int64_t)>> g_int64Callbacks;

// Float64参数回调存储
static QHash<int64_t, std::function<void(double)>> g_float64Callbacks;

// 文本改变回调存储
static QHash<int64_t, std::function<void(const char*)>> g_textChangedCallbacks;

// ============================================================
// 线程安全辅助宏
// ============================================================

#define LOCK_CALLBACKS() std::lock_guard<std::mutex> lock(g_callbackMutex)

// ============================================================
// QPushButton 信号
// ============================================================

void qButtonConnectClicked(int64_t ptr, void (*callback)()) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn && callback) {
        LOCK_CALLBACKS();
        g_voidCallbacks[ptr] = callback;
        QObject::connect(btn, &QPushButton::clicked, [ptr]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto it = g_voidCallbacks.find(ptr);
                if (it != g_voidCallbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) {
                cb();
            }
        });
    }
}

void qButtonDisconnectClicked(int64_t ptr) {
    LOCK_CALLBACKS();
    g_voidCallbacks.remove(ptr);
}

// ============================================================
// QToolButton 信号
// ============================================================

void qToolButtonConnectClicked(int64_t ptr, void (*callback)()) {
    QToolButton* btn = reinterpret_cast<QToolButton*>(ptr);
    if (btn && callback) {
        LOCK_CALLBACKS();
        g_voidCallbacks[ptr] = callback;
        QObject::connect(btn, &QToolButton::clicked, [ptr]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto it = g_voidCallbacks.find(ptr);
                if (it != g_voidCallbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) {
                cb();
            }
        });
    }
}

void qToolButtonDisconnectClicked(int64_t ptr) {
    LOCK_CALLBACKS();
    g_voidCallbacks.remove(ptr);
}

// ============================================================
// QSlider 信号
// ============================================================

void qSliderConnectValueChanged(int64_t ptr, void (*callback)(int32_t)) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider && callback) {
        LOCK_CALLBACKS();
        g_int32Callbacks[ptr] = callback;
        QObject::connect(slider, &QSlider::valueChanged, [ptr](int value) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto it = g_int32Callbacks.find(ptr);
                if (it != g_int32Callbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) {
                cb(value);
            }
        });
    }
}

void qSliderDisconnectValueChanged(int64_t ptr) {
    LOCK_CALLBACKS();
    g_int32Callbacks.remove(ptr);
}

// ============================================================
// QSpinBox 信号
// ============================================================

void qSpinBoxConnectValueChanged(int64_t ptr, void (*callback)(int32_t)) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox && callback) {
        LOCK_CALLBACKS();
        g_int32Callbacks[ptr] = callback;
        QObject::connect(spinBox, QOverload<int>::of(&QSpinBox::valueChanged), [ptr](int value) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto it = g_int32Callbacks.find(ptr);
                if (it != g_int32Callbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) {
                cb(value);
            }
        });
    }
}

void qSpinBoxDisconnectValueChanged(int64_t ptr) {
    LOCK_CALLBACKS();
    g_int32Callbacks.remove(ptr);
}

// ============================================================
// QCheckBox 信号
// ============================================================

void qCheckBoxConnectStateChanged(int64_t ptr, void (*callback)(int32_t)) {
    QCheckBox* checkBox = reinterpret_cast<QCheckBox*>(ptr);
    if (checkBox && callback) {
        LOCK_CALLBACKS();
        g_int32Callbacks[ptr] = callback;
        QObject::connect(checkBox, &QCheckBox::stateChanged, [ptr](int state) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto it = g_int32Callbacks.find(ptr);
                if (it != g_int32Callbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) {
                cb(state);
            }
        });
    }
}

void qCheckBoxDisconnectStateChanged(int64_t ptr) {
    LOCK_CALLBACKS();
    g_int32Callbacks.remove(ptr);
}

// ============================================================
// QRadioButton 信号
// ============================================================

void qRadioButtonConnectToggled(int64_t ptr, void (*callback)(int32_t)) {
    QRadioButton* radioBtn = reinterpret_cast<QRadioButton*>(ptr);
    if (radioBtn && callback) {
        LOCK_CALLBACKS();
        g_int32Callbacks[ptr] = callback;
        QObject::connect(radioBtn, &QRadioButton::toggled, [ptr](bool checked) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto it = g_int32Callbacks.find(ptr);
                if (it != g_int32Callbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) {
                cb(checked ? 1 : 0);
            }
        });
    }
}

void qRadioButtonDisconnectToggled(int64_t ptr) {
    LOCK_CALLBACKS();
    g_int32Callbacks.remove(ptr);
}

// ============================================================
// QComboBox 信号
// ============================================================

void qComboBoxConnectCurrentIndexChanged(int64_t ptr, void (*callback)(int32_t)) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox && callback) {
        LOCK_CALLBACKS();
        g_int32Callbacks[ptr] = callback;
        QObject::connect(comboBox, QOverload<int>::of(&QComboBox::currentIndexChanged), [ptr](int index) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto it = g_int32Callbacks.find(ptr);
                if (it != g_int32Callbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) {
                cb(index);
            }
        });
    }
}

void qComboBoxDisconnectCurrentIndexChanged(int64_t ptr) {
    LOCK_CALLBACKS();
    g_int32Callbacks.remove(ptr);
}

// ============================================================
// QLineEdit 信号
// ============================================================

void qLineEditConnectTextChanged(int64_t ptr, void (*callback)(const char*)) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit && callback) {
        LOCK_CALLBACKS();
        g_textChangedCallbacks[ptr] = callback;
        QObject::connect(lineEdit, &QLineEdit::textChanged, [ptr](const QString& text) {
            std::function<void(const char*)> cb;
            {
                LOCK_CALLBACKS();
                auto it = g_textChangedCallbacks.find(ptr);
                if (it != g_textChangedCallbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) {
                cb(text.toUtf8().constData());
            }
        });
    }
}

void qLineEditDisconnectTextChanged(int64_t ptr) {
    LOCK_CALLBACKS();
    g_textChangedCallbacks.remove(ptr);
}

// ============================================================
// QLineEdit::returnPressed 信号
// ============================================================

void qLineEditConnectReturnPressed(int64_t ptr, void (*callback)()) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit && callback) {
        LOCK_CALLBACKS();
        g_voidCallbacks[ptr] = callback;
        QObject::connect(lineEdit, &QLineEdit::returnPressed, [ptr]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto it = g_voidCallbacks.find(ptr);
                if (it != g_voidCallbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) {
                cb();
            }
        });
    }
}

void qLineEditDisconnectReturnPressed(int64_t ptr) {
    LOCK_CALLBACKS();
    g_voidCallbacks.remove(ptr);
}

// ============================================================
// QLineEdit::editingFinished 信号
// ============================================================

void qLineEditConnectEditingFinished(int64_t ptr, void (*callback)()) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit && callback) {
        LOCK_CALLBACKS();
        g_voidCallbacks[ptr] = callback;
        QObject::connect(lineEdit, &QLineEdit::editingFinished, [ptr]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto it = g_voidCallbacks.find(ptr);
                if (it != g_voidCallbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) {
                cb();
            }
        });
    }
}

void qLineEditDisconnectEditingFinished(int64_t ptr) {
    LOCK_CALLBACKS();
    g_voidCallbacks.remove(ptr);
}

// ============================================================
// QTimer 信号
// ============================================================

void qTimerConnectTimeout(int64_t ptr, void (*callback)()) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer && callback) {
        LOCK_CALLBACKS();
        g_voidCallbacks[ptr] = callback;
        QObject::connect(timer, &QTimer::timeout, [ptr]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto it = g_voidCallbacks.find(ptr);
                if (it != g_voidCallbacks.end()) {
                    cb = it.value();
                }
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
    LOCK_CALLBACKS();
    g_voidCallbacks.remove(ptr);
}

// ============================================================
// QAction 信号
// ============================================================

void qActionConnectTriggered(int64_t ptr, void (*callback)()) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action && callback) {
        LOCK_CALLBACKS();
        g_voidCallbacks[ptr] = callback;
        QObject::connect(action, &QAction::triggered, [ptr]() {
            std::function<void()> cb;
            {
                LOCK_CALLBACKS();
                auto it = g_voidCallbacks.find(ptr);
                if (it != g_voidCallbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) {
                cb();
            }
        });
    }
}

void qActionDisconnectTriggered(int64_t ptr) {
    LOCK_CALLBACKS();
    g_voidCallbacks.remove(ptr);
}

// ============================================================
// QDoubleSpinBox 信号
// ============================================================

void qDoubleSpinBoxConnectValueChanged(int64_t ptr, void (*callback)(double)) {
    QDoubleSpinBox* spinBox = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (spinBox && callback) {
        LOCK_CALLBACKS();
        g_float64Callbacks[ptr] = callback;
        QObject::connect(spinBox, QOverload<double>::of(&QDoubleSpinBox::valueChanged), [ptr](double value) {
            std::function<void(double)> cb;
            {
                LOCK_CALLBACKS();
                auto it = g_float64Callbacks.find(ptr);
                if (it != g_float64Callbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) {
                cb(value);
            }
        });
    }
}

void qDoubleSpinBoxDisconnectValueChanged(int64_t ptr) {
    LOCK_CALLBACKS();
    g_float64Callbacks.remove(ptr);
}

// ============================================================
// QDial 信号
// ============================================================

void qDialConnectValueChanged(int64_t ptr, void (*callback)(int32_t)) {
    QDial* dial = reinterpret_cast<QDial*>(ptr);
    if (dial && callback) {
        LOCK_CALLBACKS();
        g_int32Callbacks[ptr] = callback;
        QObject::connect(dial, &QDial::valueChanged, [ptr](int value) {
            std::function<void(int32_t)> cb;
            {
                LOCK_CALLBACKS();
                auto it = g_int32Callbacks.find(ptr);
                if (it != g_int32Callbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) {
                cb(value);
            }
        });
    }
}

void qDialDisconnectValueChanged(int64_t ptr) {
    LOCK_CALLBACKS();
    g_int32Callbacks.remove(ptr);
}

// ============================================================
// QComboBox::currentTextChanged 信号
// ============================================================

void qComboBoxConnectCurrentTextChanged(int64_t ptr, void (*callback)(const char*)) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox && callback) {
        LOCK_CALLBACKS();
        g_textChangedCallbacks[ptr] = callback;
        QObject::connect(comboBox, &QComboBox::currentTextChanged, [ptr](const QString& text) {
            std::function<void(const char*)> cb;
            {
                LOCK_CALLBACKS();
                auto it = g_textChangedCallbacks.find(ptr);
                if (it != g_textChangedCallbacks.end()) {
                    cb = it.value();
                }
            }
            if (cb) {
                cb(text.toUtf8().constData());
            }
        });
    }
}

void qComboBoxDisconnectCurrentTextChanged(int64_t ptr) {
    LOCK_CALLBACKS();
    g_textChangedCallbacks.remove(ptr);
}

// ============================================================
// 清理函数
// ============================================================

void qSignalCleanup(int64_t ptr) {
    LOCK_CALLBACKS();
    g_voidCallbacks.remove(ptr);
    g_int32Callbacks.remove(ptr);
    g_int64Callbacks.remove(ptr);
    g_float64Callbacks.remove(ptr);
    g_textChangedCallbacks.remove(ptr);
}

} // extern "C"