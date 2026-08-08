/**
 * @file bridge_values.cpp
 * @brief 数值部件桥接函数 - QSpinBox, QDoubleSpinBox, QSlider, QDial, QProgressBar
 */

#include <QSpinBox>
#include <QDoubleSpinBox>
#include <QLCDNumber>
#include <QSlider>
#include <QDial>
#include <QProgressBar>
#include <functional>
#include <unordered_map>
#include "bridge_string_utils.h"

// 回调映射
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_spinBoxCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_sliderCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_sliderMovedCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_sliderPressedCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_sliderReleasedCallbacks;

extern "C" {

// ============================================================
// QSpinBox 桥接函数
// ============================================================

int64_t qSpinBoxCreate() {
    QSpinBox* spinBox = new QSpinBox();
    return reinterpret_cast<int64_t>(spinBox);
}

void qSpinBoxSetValue(int64_t ptr, int32_t value) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox) {
        spinBox->setValue(value);
    }
}

int32_t qSpinBoxValue(int64_t ptr) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox) {
        return spinBox->value();
    }
    return 0;
}

void qSpinBoxSetRange(int64_t ptr, int32_t min, int32_t max) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox) {
        spinBox->setRange(min, max);
    }
}

void qSpinBoxSetSingleStep(int64_t ptr, int32_t step) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox) {
        spinBox->setSingleStep(step);
    }
}

void qSpinBoxSetPrefix(int64_t ptr, const char* prefix) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox && prefix) {
        spinBox->setPrefix(QString::fromUtf8(prefix));
    }
}

const char* qSpinBoxPrefix(int64_t ptr) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (!spinBox) return cjqt6::emptyString();
    return cjqt6::dupUtf8(spinBox->prefix());
}

void qSpinBoxSetSuffix(int64_t ptr, const char* suffix) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox && suffix) {
        spinBox->setSuffix(QString::fromUtf8(suffix));
    }
}

const char* qSpinBoxSuffix(int64_t ptr) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (!spinBox) return cjqt6::emptyString();
    return cjqt6::dupUtf8(spinBox->suffix());
}

void qSpinBoxSetWrapping(int64_t ptr, bool wrapping) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox) {
        spinBox->setWrapping(wrapping);
    }
}

bool qSpinBoxWrapping(int64_t ptr) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    return spinBox ? spinBox->wrapping() : false;
}

void qSpinBoxSetSpecialValueText(int64_t ptr, const char* text) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox && text) {
        spinBox->setSpecialValueText(QString::fromUtf8(text));
    }
}

const char* qSpinBoxCleanText(int64_t ptr) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (!spinBox) return cjqt6::emptyString();
    return cjqt6::dupUtf8(spinBox->cleanText());
}

void qSpinBoxSetOnValueChanged(int64_t ptr, void (*callback)(int64_t)) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox) {
        int64_t widgetPtr = ptr;
        g_spinBoxCallbacks[ptr] = [callback, widgetPtr](int64_t) { callback(widgetPtr); };
        QObject::connect(spinBox, QOverload<int>::of(&QSpinBox::valueChanged), [widgetPtr](int) {
            auto it = g_spinBoxCallbacks.find(widgetPtr);
            if (it != g_spinBoxCallbacks.end()) {
                it->second(widgetPtr);
            }
        });
    }
}

void qSpinBoxDelete(int64_t ptr) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox) {
        g_spinBoxCallbacks.erase(ptr);
        delete spinBox;
    }
}

// ============================================================
// QSlider 桥接函数
// ============================================================

int64_t qSliderCreate() {
    QSlider* slider = new QSlider();
    return reinterpret_cast<int64_t>(slider);
}

void qSliderSetValue(int64_t ptr, int32_t value) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        slider->setValue(value);
    }
}

int32_t qSliderValue(int64_t ptr) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        return slider->value();
    }
    return 0;
}

void qSliderSetRange(int64_t ptr, int32_t min, int32_t max) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        slider->setRange(min, max);
    }
}

void qSliderSetOrientation(int64_t ptr, int32_t orientation) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        slider->setOrientation(static_cast<Qt::Orientation>(orientation));
    }
}

void qSliderSetSingleStep(int64_t ptr, int32_t step) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        slider->setSingleStep(step);
    }
}

int32_t qSliderSingleStep(int64_t ptr) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    return slider ? slider->singleStep() : 1;
}

void qSliderSetPageStep(int64_t ptr, int32_t step) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        slider->setPageStep(step);
    }
}

int32_t qSliderPageStep(int64_t ptr) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    return slider ? slider->pageStep() : 10;
}

void qSliderSetTickPosition(int64_t ptr, int32_t position) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        slider->setTickPosition(static_cast<QSlider::TickPosition>(position));
    }
}

int32_t qSliderTickPosition(int64_t ptr) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    return slider ? static_cast<int32_t>(slider->tickPosition()) : 0;
}

void qSliderSetTickInterval(int64_t ptr, int32_t interval) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        slider->setTickInterval(interval);
    }
}

int32_t qSliderTickInterval(int64_t ptr) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    return slider ? slider->tickInterval() : 0;
}

void qSliderSetInvertedControls(int64_t ptr, bool inverted) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        slider->setInvertedControls(inverted);
    }
}

bool qSliderInvertedControls(int64_t ptr) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    return slider ? slider->invertedControls() : false;
}

void qSliderSetTracking(int64_t ptr, bool enable) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        slider->setTracking(enable);
    }
}

bool qSliderHasTracking(int64_t ptr) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    return slider ? slider->hasTracking() : true;
}

void qSliderSetOnSliderMoved(int64_t ptr, void (*callback)(int64_t)) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        int64_t widgetPtr = ptr;
        g_sliderMovedCallbacks[ptr] = [callback, widgetPtr](int64_t) { callback(widgetPtr); };
        QObject::connect(slider, &QSlider::sliderMoved, [widgetPtr](int) {
            auto it = g_sliderMovedCallbacks.find(widgetPtr);
            if (it != g_sliderMovedCallbacks.end()) {
                it->second(widgetPtr);
            }
        });
    }
}

void qSliderSetOnSliderPressed(int64_t ptr, void (*callback)(int64_t)) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        int64_t widgetPtr = ptr;
        g_sliderPressedCallbacks[ptr] = [callback, widgetPtr](int64_t) { callback(widgetPtr); };
        QObject::connect(slider, &QSlider::sliderPressed, [widgetPtr]() {
            auto it = g_sliderPressedCallbacks.find(widgetPtr);
            if (it != g_sliderPressedCallbacks.end()) {
                it->second(widgetPtr);
            }
        });
    }
}

void qSliderSetOnSliderReleased(int64_t ptr, void (*callback)(int64_t)) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        int64_t widgetPtr = ptr;
        g_sliderReleasedCallbacks[ptr] = [callback, widgetPtr](int64_t) { callback(widgetPtr); };
        QObject::connect(slider, &QSlider::sliderReleased, [widgetPtr]() {
            auto it = g_sliderReleasedCallbacks.find(widgetPtr);
            if (it != g_sliderReleasedCallbacks.end()) {
                it->second(widgetPtr);
            }
        });
    }
}

void qSliderDeleteCleanup(int64_t ptr) {
    g_sliderMovedCallbacks.erase(ptr);
    g_sliderPressedCallbacks.erase(ptr);
    g_sliderReleasedCallbacks.erase(ptr);
}

void qSliderSetOnValueChanged(int64_t ptr, void (*callback)(int64_t)) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        int64_t widgetPtr = ptr;
        g_sliderCallbacks[ptr] = [callback, widgetPtr](int64_t) { callback(widgetPtr); };
        QObject::connect(slider, &QSlider::valueChanged, [widgetPtr](int) {
            auto it = g_sliderCallbacks.find(widgetPtr);
            if (it != g_sliderCallbacks.end()) {
                it->second(widgetPtr);
            }
        });
    }
}

void qSliderDelete(int64_t ptr) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        g_sliderCallbacks.erase(ptr);
        qSliderDeleteCleanup(ptr);
        delete slider;
    }
}

// ============================================================
// QProgressBar 桥接函数
// ============================================================

int64_t qProgressBarCreate() {
    QProgressBar* progressBar = new QProgressBar();
    return reinterpret_cast<int64_t>(progressBar);
}

void qProgressBarSetValue(int64_t ptr, int32_t value) {
    QProgressBar* progressBar = reinterpret_cast<QProgressBar*>(ptr);
    if (progressBar) {
        progressBar->setValue(value);
    }
}

int32_t qProgressBarValue(int64_t ptr) {
    QProgressBar* progressBar = reinterpret_cast<QProgressBar*>(ptr);
    if (progressBar) {
        return progressBar->value();
    }
    return 0;
}

void qProgressBarSetRange(int64_t ptr, int32_t min, int32_t max) {
    QProgressBar* progressBar = reinterpret_cast<QProgressBar*>(ptr);
    if (progressBar) {
        progressBar->setRange(min, max);
    }
}

void qProgressBarSetTextVisible(int64_t ptr, bool visible) {
    QProgressBar* progressBar = reinterpret_cast<QProgressBar*>(ptr);
    if (progressBar) {
        progressBar->setTextVisible(visible);
    }
}

void qProgressBarSetFormat(int64_t ptr, const char* format) {
    QProgressBar* progressBar = reinterpret_cast<QProgressBar*>(ptr);
    if (progressBar && format) {
        progressBar->setFormat(QString::fromUtf8(format));
    }
}

const char* qProgressBarFormat(int64_t ptr) {
    QProgressBar* progressBar = reinterpret_cast<QProgressBar*>(ptr);
    if (!progressBar) return cjqt6::emptyString();
    return cjqt6::dupUtf8(progressBar->format());
}

void qProgressBarSetOrientation(int64_t ptr, int32_t orientation) {
    QProgressBar* progressBar = reinterpret_cast<QProgressBar*>(ptr);
    if (progressBar) {
        progressBar->setOrientation(static_cast<Qt::Orientation>(orientation));
    }
}

void qProgressBarSetInvertedAppearance(int64_t ptr, bool invert) {
    QProgressBar* progressBar = reinterpret_cast<QProgressBar*>(ptr);
    if (progressBar) {
        progressBar->setInvertedAppearance(invert);
    }
}

void qProgressBarReset(int64_t ptr) {
    QProgressBar* progressBar = reinterpret_cast<QProgressBar*>(ptr);
    if (progressBar) {
        progressBar->reset();
    }
}

void qProgressBarDelete(int64_t ptr) {
    QProgressBar* progressBar = reinterpret_cast<QProgressBar*>(ptr);
    if (progressBar) {
        delete progressBar;
    }
}

// ============================================================
// QDoubleSpinBox 桥接函数
// ============================================================

int64_t qDoubleSpinBoxCreate() {
    QDoubleSpinBox* spinBox = new QDoubleSpinBox();
    return reinterpret_cast<int64_t>(spinBox);
}

void qDoubleSpinBoxSetValue(int64_t ptr, double value) {
    QDoubleSpinBox* spinBox = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (spinBox) {
        spinBox->setValue(value);
    }
}

double qDoubleSpinBoxValue(int64_t ptr) {
    QDoubleSpinBox* spinBox = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (spinBox) {
        return spinBox->value();
    }
    return 0.0;
}

void qDoubleSpinBoxSetRange(int64_t ptr, double min, double max) {
    QDoubleSpinBox* spinBox = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (spinBox) {
        spinBox->setRange(min, max);
    }
}

void qDoubleSpinBoxSetSingleStep(int64_t ptr, double step) {
    QDoubleSpinBox* spinBox = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (spinBox) {
        spinBox->setSingleStep(step);
    }
}

void qDoubleSpinBoxSetDecimals(int64_t ptr, int32_t decimals) {
    QDoubleSpinBox* spinBox = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (spinBox) {
        spinBox->setDecimals(decimals);
    }
}

int32_t qDoubleSpinBoxDecimals(int64_t ptr) {
    QDoubleSpinBox* spinBox = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (spinBox) {
        return spinBox->decimals();
    }
    return 2;
}

void qDoubleSpinBoxDelete(int64_t ptr) {
    QDoubleSpinBox* spinBox = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (spinBox) {
        delete spinBox;
    }
}

// ============================================================
// QDial 桥接函数
// ============================================================

int64_t qDialCreate() {
    QDial* dial = new QDial();
    return reinterpret_cast<int64_t>(dial);
}

void qDialSetValue(int64_t ptr, int32_t value) {
    QDial* dial = reinterpret_cast<QDial*>(ptr);
    if (dial) {
        dial->setValue(value);
    }
}

int32_t qDialValue(int64_t ptr) {
    QDial* dial = reinterpret_cast<QDial*>(ptr);
    if (dial) {
        return dial->value();
    }
    return 0;
}

void qDialSetRange(int64_t ptr, int32_t min, int32_t max) {
    QDial* dial = reinterpret_cast<QDial*>(ptr);
    if (dial) {
        dial->setRange(min, max);
    }
}

void qDialSetSingleStep(int64_t ptr, int32_t step) {
    QDial* dial = reinterpret_cast<QDial*>(ptr);
    if (dial) {
        dial->setSingleStep(step);
    }
}

void qDialSetWrapping(int64_t ptr, bool wrapping) {
    QDial* dial = reinterpret_cast<QDial*>(ptr);
    if (dial) {
        dial->setWrapping(wrapping);
    }
}

bool qDialWrapping(int64_t ptr) {
    QDial* dial = reinterpret_cast<QDial*>(ptr);
    if (dial) {
        return dial->wrapping();
    }
    return false;
}

void qDialSetNotchesVisible(int64_t ptr, bool visible) {
    QDial* dial = reinterpret_cast<QDial*>(ptr);
    if (dial) {
        dial->setNotchesVisible(visible);
    }
}

bool qDialNotchesVisible(int64_t ptr) {
    QDial* dial = reinterpret_cast<QDial*>(ptr);
    if (dial) {
        return dial->notchesVisible();
    }
    return false;
}

void qDialDelete(int64_t ptr) {
    QDial* dial = reinterpret_cast<QDial*>(ptr);
    if (dial) {
        delete dial;
    }
}


// ============================================================
// QLCDNumber 桥接函数
// ============================================================

int64_t qLCDNumberCreate() {
    QLCDNumber* lcd = new QLCDNumber();
    return reinterpret_cast<int64_t>(lcd);
}

int64_t qLCDNumberCreateWithDigits(int32_t numDigits) {
    QLCDNumber* lcd = new QLCDNumber(numDigits);
    return reinterpret_cast<int64_t>(lcd);
}

void qLCDNumberDisplay(int64_t ptr, double value) {
    QLCDNumber* lcd = reinterpret_cast<QLCDNumber*>(ptr);
    if (lcd) {
        lcd->display(value);
    }
}

void qLCDNumberDisplayInt(int64_t ptr, int32_t value) {
    QLCDNumber* lcd = reinterpret_cast<QLCDNumber*>(ptr);
    if (lcd) {
        lcd->display(value);
    }
}

void qLCDNumberSetMode(int64_t ptr, int32_t mode) {
    QLCDNumber* lcd = reinterpret_cast<QLCDNumber*>(ptr);
    if (lcd) {
        lcd->setMode(static_cast<QLCDNumber::Mode>(mode));
    }
}

int32_t qLCDNumberMode(int64_t ptr) {
    QLCDNumber* lcd = reinterpret_cast<QLCDNumber*>(ptr);
    if (lcd) {
        return static_cast<int32_t>(lcd->mode());
    }
    return 0;
}

void qLCDNumberSetSegmentStyle(int64_t ptr, int32_t style) {
    QLCDNumber* lcd = reinterpret_cast<QLCDNumber*>(ptr);
    if (lcd) {
        lcd->setSegmentStyle(static_cast<QLCDNumber::SegmentStyle>(style));
    }
}

int32_t qLCDNumberSegmentStyle(int64_t ptr) {
    QLCDNumber* lcd = reinterpret_cast<QLCDNumber*>(ptr);
    if (lcd) {
        return static_cast<int32_t>(lcd->segmentStyle());
    }
    return 0;
}

void qLCDNumberSetSmallDecimalPoint(int64_t ptr, bool small) {
    QLCDNumber* lcd = reinterpret_cast<QLCDNumber*>(ptr);
    if (lcd) {
        lcd->setSmallDecimalPoint(small);
    }
}

bool qLCDNumberSmallDecimalPoint(int64_t ptr) {
    QLCDNumber* lcd = reinterpret_cast<QLCDNumber*>(ptr);
    if (lcd) {
        return lcd->smallDecimalPoint();
    }
    return false;
}

int32_t qLCDNumberDigitCount(int64_t ptr) {
    QLCDNumber* lcd = reinterpret_cast<QLCDNumber*>(ptr);
    if (lcd) {
        return lcd->digitCount();
    }
    return 0;
}

void qLCDNumberSetDigitCount(int64_t ptr, int32_t numDigits) {
    QLCDNumber* lcd = reinterpret_cast<QLCDNumber*>(ptr);
    if (lcd) {
        lcd->setDigitCount(numDigits);
    }
}

bool qLCDNumberCheckOverflow(int64_t ptr, double value) {
    QLCDNumber* lcd = reinterpret_cast<QLCDNumber*>(ptr);
    if (lcd) {
        return lcd->checkOverflow(value);
    }
    return true;
}

void qLCDNumberDelete(int64_t ptr) {
    QLCDNumber* lcd = reinterpret_cast<QLCDNumber*>(ptr);
    if (lcd) {
        delete lcd;
    }
}

} // extern "C"
