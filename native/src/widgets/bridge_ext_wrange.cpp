/**
 * @file bridge_ext_wrange.cpp
 * @brief v1.2.0 API 补全扩展 - wrange 批次控件桥接函数
 *
 * 该文件补充 wrange 批次（QSpinBox / QDoubleSpinBox / QDial / QLCDNumber /
 * QProgressBar，QSlider 的刻度/反向/追踪 API 已在 bridge_values.cpp 中实现）
 * 的桥接函数，遵循 bridge_ext_new.cpp 的既有风格：
 *   - 入参 ptr 做空指针校验；
 *   - 字符串返回使用 static 缓冲区 + QByteArray.constData()；
 *   - 信号通过 std::unordered_map 注册回调，connect 前做去重保护。
 */

#include <QWidget>
#include <QSpinBox>
#include <QDoubleSpinBox>
#include <QDial>
#include <QLCDNumber>
#include <QProgressBar>
#include <QString>
#include <QByteArray>
#include <functional>
#include <unordered_map>

extern "C" {

// ============================================================
// QSpinBox 补充 API
// ============================================================

void qSpinBoxSetButtonSymbols(int64_t ptr, int32_t v) {
    QSpinBox* w = reinterpret_cast<QSpinBox*>(ptr);
    if (w) w->setButtonSymbols(static_cast<QAbstractSpinBox::ButtonSymbols>(v));
}

int32_t qSpinBoxButtonSymbols(int64_t ptr) {
    QSpinBox* w = reinterpret_cast<QSpinBox*>(ptr);
    return w ? static_cast<int32_t>(w->buttonSymbols()) : 0;
}

void qSpinBoxSetCorrectionMode(int64_t ptr, int32_t v) {
    QSpinBox* w = reinterpret_cast<QSpinBox*>(ptr);
    if (w) w->setCorrectionMode(static_cast<QAbstractSpinBox::CorrectionMode>(v));
}

void qSpinBoxSetMinimum(int64_t ptr, int32_t v) {
    QSpinBox* w = reinterpret_cast<QSpinBox*>(ptr);
    if (w) w->setMinimum(v);
}

int32_t qSpinBoxMinimum(int64_t ptr) {
    QSpinBox* w = reinterpret_cast<QSpinBox*>(ptr);
    return w ? static_cast<int32_t>(w->minimum()) : 0;
}

void qSpinBoxSetMaximum(int64_t ptr, int32_t v) {
    QSpinBox* w = reinterpret_cast<QSpinBox*>(ptr);
    if (w) w->setMaximum(v);
}

int32_t qSpinBoxMaximum(int64_t ptr) {
    QSpinBox* w = reinterpret_cast<QSpinBox*>(ptr);
    return w ? static_cast<int32_t>(w->maximum()) : 0;
}

void qSpinBoxSetDisplayIntegerBase(int64_t ptr, int32_t v) {
    QSpinBox* w = reinterpret_cast<QSpinBox*>(ptr);
    if (w) w->setDisplayIntegerBase(v);
}

int32_t qSpinBoxDisplayIntegerBase(int64_t ptr) {
    QSpinBox* w = reinterpret_cast<QSpinBox*>(ptr);
    return w ? static_cast<int32_t>(w->displayIntegerBase()) : 0;
}

void qSpinBoxSetGroupSeparatorShown(int64_t ptr, int32_t v) {
    QSpinBox* w = reinterpret_cast<QSpinBox*>(ptr);
    if (w) w->setGroupSeparatorShown(v != 0);
}

const char* qSpinBoxText(int64_t ptr) {
    QSpinBox* w = reinterpret_cast<QSpinBox*>(ptr);
    if (w) {
        static QString s;
        s = w->text();
        static QByteArray b;
        b = s.toUtf8();
        return b.constData();
    }
    return "";
}

// QSpinBox 信号回调映射
static std::unordered_map<int64_t, std::function<void(const QString&)>> g_spinTextChanged;
static std::unordered_map<int64_t, std::function<void()>> g_spinEditingFinished;

void qSpinBoxConnectTextChanged(int64_t ptr, void (*cb)(const char*)) {
    QSpinBox* w = reinterpret_cast<QSpinBox*>(ptr);
    if (w && cb && g_spinTextChanged.find(ptr) == g_spinTextChanged.end()) {
        g_spinTextChanged[ptr] = [cb](const QString& text) {
            cb(text.toUtf8().constData());
        };
        QObject::connect(w, &QSpinBox::textChanged, [ptr](const QString& text) {
            auto it = g_spinTextChanged.find(ptr);
            if (it != g_spinTextChanged.end()) it->second(text);
        });
    }
}

void qSpinBoxConnectEditingFinished(int64_t ptr, void (*cb)()) {
    QSpinBox* w = reinterpret_cast<QSpinBox*>(ptr);
    if (w && cb && g_spinEditingFinished.find(ptr) == g_spinEditingFinished.end()) {
        g_spinEditingFinished[ptr] = [cb]() { cb(); };
        QObject::connect(w, &QSpinBox::editingFinished, [ptr]() {
            auto it = g_spinEditingFinished.find(ptr);
            if (it != g_spinEditingFinished.end()) it->second();
        });
    }
}

// ============================================================
// QDoubleSpinBox 补充 API
// ============================================================

void qDoubleSpinBoxSetPrefix(int64_t ptr, const char* s) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w) w->setPrefix(QString::fromUtf8(s));
}

const char* qDoubleSpinBoxPrefix(int64_t ptr) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w) {
        static QString s;
        s = w->prefix();
        static QByteArray b;
        b = s.toUtf8();
        return b.constData();
    }
    return "";
}

void qDoubleSpinBoxSetSuffix(int64_t ptr, const char* s) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w) w->setSuffix(QString::fromUtf8(s));
}

const char* qDoubleSpinBoxSuffix(int64_t ptr) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w) {
        static QString s;
        s = w->suffix();
        static QByteArray b;
        b = s.toUtf8();
        return b.constData();
    }
    return "";
}

void qDoubleSpinBoxSetSpecialValueText(int64_t ptr, const char* s) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w) w->setSpecialValueText(QString::fromUtf8(s));
}

void qDoubleSpinBoxSetStepType(int64_t ptr, int32_t v) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w) w->setStepType(static_cast<QAbstractSpinBox::StepType>(v));
}

void qDoubleSpinBoxSetMinimum(int64_t ptr, double v) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w) w->setMinimum(v);
}

double qDoubleSpinBoxMinimum(int64_t ptr) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    return w ? w->minimum() : 0.0;
}

void qDoubleSpinBoxSetMaximum(int64_t ptr, double v) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w) w->setMaximum(v);
}

double qDoubleSpinBoxMaximum(int64_t ptr) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    return w ? w->maximum() : 0.0;
}

void qDoubleSpinBoxSetGroupSeparatorShown(int64_t ptr, int32_t v) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w) w->setGroupSeparatorShown(v != 0);
}

const char* qDoubleSpinBoxCleanText(int64_t ptr) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w) {
        static QString s;
        s = w->cleanText();
        static QByteArray b;
        b = s.toUtf8();
        return b.constData();
    }
    return "";
}

const char* qDoubleSpinBoxText(int64_t ptr) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w) {
        static QString s;
        s = w->text();
        static QByteArray b;
        b = s.toUtf8();
        return b.constData();
    }
    return "";
}

// QDoubleSpinBox 信号回调映射
static std::unordered_map<int64_t, std::function<void(const QString&)>> g_dspinTextChanged;
static std::unordered_map<int64_t, std::function<void()>> g_dspinEditingFinished;

void qDoubleSpinBoxConnectTextChanged(int64_t ptr, void (*cb)(const char*)) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w && cb && g_dspinTextChanged.find(ptr) == g_dspinTextChanged.end()) {
        g_dspinTextChanged[ptr] = [cb](const QString& text) {
            cb(text.toUtf8().constData());
        };
        QObject::connect(w, &QDoubleSpinBox::textChanged, [ptr](const QString& text) {
            auto it = g_dspinTextChanged.find(ptr);
            if (it != g_dspinTextChanged.end()) it->second(text);
        });
    }
}

void qDoubleSpinBoxConnectEditingFinished(int64_t ptr, void (*cb)()) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w && cb && g_dspinEditingFinished.find(ptr) == g_dspinEditingFinished.end()) {
        g_dspinEditingFinished[ptr] = [cb]() { cb(); };
        QObject::connect(w, &QDoubleSpinBox::editingFinished, [ptr]() {
            auto it = g_dspinEditingFinished.find(ptr);
            if (it != g_dspinEditingFinished.end()) it->second();
        });
    }
}

// ============================================================
// QDial 补充 API
// ============================================================

void qDialSetNotchTarget(int64_t ptr, double v) {
    QDial* w = reinterpret_cast<QDial*>(ptr);
    if (w) w->setNotchTarget(v);
}

double qDialNotchTarget(int64_t ptr) {
    QDial* w = reinterpret_cast<QDial*>(ptr);
    return w ? w->notchTarget() : 0.0;
}

void qDialSetPageStep(int64_t ptr, int32_t v) {
    QDial* w = reinterpret_cast<QDial*>(ptr);
    if (w) w->setPageStep(v);
}

int32_t qDialPageStep(int64_t ptr) {
    QDial* w = reinterpret_cast<QDial*>(ptr);
    return w ? static_cast<int32_t>(w->pageStep()) : 0;
}

// ============================================================
// QLCDNumber 补充 API
// ============================================================

double qLCDNumberValue(int64_t ptr) {
    QLCDNumber* w = reinterpret_cast<QLCDNumber*>(ptr);
    return w ? w->value() : 0.0;
}

void qLCDNumberDisplayString(int64_t ptr, const char* s) {
    QLCDNumber* w = reinterpret_cast<QLCDNumber*>(ptr);
    if (w) w->display(QString::fromUtf8(s));
}

// ============================================================
// QProgressBar 补充 API
// ============================================================

void qProgressBarSetMinimum(int64_t ptr, int32_t v) {
    QProgressBar* w = reinterpret_cast<QProgressBar*>(ptr);
    if (w) w->setMinimum(v);
}

int32_t qProgressBarMinimum(int64_t ptr) {
    QProgressBar* w = reinterpret_cast<QProgressBar*>(ptr);
    return w ? static_cast<int32_t>(w->minimum()) : 0;
}

void qProgressBarSetMaximum(int64_t ptr, int32_t v) {
    QProgressBar* w = reinterpret_cast<QProgressBar*>(ptr);
    if (w) w->setMaximum(v);
}

int32_t qProgressBarMaximum(int64_t ptr) {
    QProgressBar* w = reinterpret_cast<QProgressBar*>(ptr);
    return w ? static_cast<int32_t>(w->maximum()) : 0;
}

void qProgressBarSetTextDirection(int64_t ptr, int32_t v) {
    QProgressBar* w = reinterpret_cast<QProgressBar*>(ptr);
    if (w) w->setTextDirection(static_cast<QProgressBar::Direction>(v));
}

int32_t qProgressBarTextDirection(int64_t ptr) {
    QProgressBar* w = reinterpret_cast<QProgressBar*>(ptr);
    return w ? static_cast<int32_t>(w->textDirection()) : 0;
}

int32_t qProgressBarIsTextVisible(int64_t ptr) {
    QProgressBar* w = reinterpret_cast<QProgressBar*>(ptr);
    return w ? (w->isTextVisible() ? 1 : 0) : 0;
}

int32_t qProgressBarInvertedAppearance(int64_t ptr) {
    QProgressBar* w = reinterpret_cast<QProgressBar*>(ptr);
    return w ? (w->invertedAppearance() ? 1 : 0) : 0;
}

void qProgressBarSetAlignment(int64_t ptr, int32_t v) {
    QProgressBar* w = reinterpret_cast<QProgressBar*>(ptr);
    if (w) w->setAlignment(static_cast<Qt::Alignment>(v));
}

// QProgressBar 信号回调映射
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_pbValueChanged;

void qProgressBarConnectValueChanged(int64_t ptr, void (*cb)(int32_t)) {
    QProgressBar* w = reinterpret_cast<QProgressBar*>(ptr);
    if (w && cb && g_pbValueChanged.find(ptr) == g_pbValueChanged.end()) {
        g_pbValueChanged[ptr] = [cb](int32_t v) { cb(v); };
        QObject::connect(w, &QProgressBar::valueChanged, [ptr](int value) {
            auto it = g_pbValueChanged.find(ptr);
            if (it != g_pbValueChanged.end()) it->second(static_cast<int32_t>(value));
        });
    }
}

} // extern "C"
