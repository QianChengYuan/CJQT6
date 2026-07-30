/**
 * @file bridge_ext_apicomplete.cpp
 * @brief API 补全扩展 - 补齐 QSlider/QFrame/QDoubleSpinBox/QToolButton/QGroupBox/
 *        QProgressBar/QSpinBox 等控件的缺失方法
 *
 * 遵循既有 bridge_ext_*.cpp 风格：
 *   - 入参 ptr 做空指针校验；
 *   - 字符串返回使用 static 缓冲区 + toUtf8().constData()；
 *   - 布尔参数/返回值使用 int32_t（0/1）。
 */
#include <QWidget>
#include <QString>
#include <QByteArray>
#include <functional>

#include <QSlider>
#include <QFrame>
#include <QDoubleSpinBox>
#include <QToolButton>
#include <QGroupBox>
#include <QProgressBar>
#include <QSpinBox>
#include <QAbstractSpinBox>
#include <QAction>

extern "C" {

// ============================================================
// QSlider - setInvertedAppearance / invertedAppearance
// ============================================================

void qSliderSetInvertedAppearance(int64_t ptr, int32_t inverted) {
    QSlider* w = reinterpret_cast<QSlider*>(ptr);
    if (w) w->setInvertedAppearance(inverted != 0);
}

int32_t qSliderInvertedAppearance(int64_t ptr) {
    QSlider* w = reinterpret_cast<QSlider*>(ptr);
    return w ? (w->invertedAppearance() ? 1 : 0) : 0;
}

// ============================================================
// QFrame - lineWidth / frameWidth getters
// ============================================================

int32_t qFrameLineWidth(int64_t ptr) {
    QFrame* w = reinterpret_cast<QFrame*>(ptr);
    return w ? static_cast<int32_t>(w->lineWidth()) : 0;
}

int32_t qFrameFrameWidth(int64_t ptr) {
    QFrame* w = reinterpret_cast<QFrame*>(ptr);
    return w ? static_cast<int32_t>(w->frameWidth()) : 0;
}

// ============================================================
// QDoubleSpinBox - setWrapping / wrapping / setButtonSymbols
// ============================================================

void qDoubleSpinBoxSetWrapping(int64_t ptr, int32_t wrap) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w) w->setWrapping(wrap != 0);
}

int32_t qDoubleSpinBoxWrapping(int64_t ptr) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    return w ? (w->wrapping() ? 1 : 0) : 0;
}

void qDoubleSpinBoxSetButtonSymbols(int64_t ptr, int32_t v) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w) w->setButtonSymbols(static_cast<QAbstractSpinBox::ButtonSymbols>(v));
}

// ============================================================
// QToolButton - text() getter / defaultAction / setDefaultAction
// ============================================================

const char* qToolButtonText(int64_t ptr) {
    QToolButton* w = reinterpret_cast<QToolButton*>(ptr);
    if (w) {
        static QString s;
        s = w->text();
        static QByteArray b;
        b = s.toUtf8();
        return b.constData();
    }
    return "";
}

int64_t qToolButtonDefaultAction(int64_t ptr) {
    QToolButton* w = reinterpret_cast<QToolButton*>(ptr);
    if (w) return reinterpret_cast<int64_t>(w->defaultAction());
    return 0;
}

void qToolButtonSetDefaultAction(int64_t ptr, int64_t actionPtr) {
    QToolButton* w = reinterpret_cast<QToolButton*>(ptr);
    QAction* a = reinterpret_cast<QAction*>(actionPtr);
    if (w && a) w->setDefaultAction(a);
}

// ============================================================
// QGroupBox - setFlat / isFlat
// ============================================================

void qGroupBoxSetFlat(int64_t ptr, int32_t flat) {
    QGroupBox* w = reinterpret_cast<QGroupBox*>(ptr);
    if (w) w->setFlat(flat != 0);
}

int32_t qGroupBoxIsFlat(int64_t ptr) {
    QGroupBox* w = reinterpret_cast<QGroupBox*>(ptr);
    return w ? (w->isFlat() ? 1 : 0) : 0;
}

// ============================================================
// QProgressBar - text() getter
// ============================================================

const char* qProgressBarText(int64_t ptr) {
    QProgressBar* w = reinterpret_cast<QProgressBar*>(ptr);
    if (w) {
        static QString s;
        s = w->text();
        static QByteArray b;
        b = s.toUtf8();
        return b.constData();
    }
    return "";
}

// ============================================================
// QWidget - selectAll / setFocus (通用方法)
// ============================================================

void qWidgetSelectAll(int64_t ptr) {
    QWidget* w = reinterpret_cast<QWidget*>(ptr);
    if (w) {
        // QAbstractSpinBox, QLineEdit, QTextEdit 等都有 selectAll()
        QAbstractSpinBox* sb = qobject_cast<QAbstractSpinBox*>(w);
        if (sb) {
            sb->selectAll();
            return;
        }
    }
}

void qWidgetSetFocus(int64_t ptr) {
    QWidget* w = reinterpret_cast<QWidget*>(ptr);
    if (w) w->setFocus();
}

// ============================================================
// QSpinBox - selectAll 和 setFocus 可以通过 qobject_cast 到 QAbstractSpinBox
// 实际上 qWidgetSelectAll 已经通过 qobject_cast 处理了 QAbstractSpinBox
// 这里加上显式的 spinbox 版本以保持命名一致性
// ============================================================

void qSpinBoxSelectAll(int64_t ptr) {
    QSpinBox* w = reinterpret_cast<QSpinBox*>(ptr);
    if (w) w->selectAll();
}

void qSpinBoxSetFocus(int64_t ptr) {
    QSpinBox* w = reinterpret_cast<QSpinBox*>(ptr);
    if (w) w->setFocus();
}

void qDoubleSpinBoxSelectAll(int64_t ptr) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w) w->selectAll();
}

void qDoubleSpinBoxSetFocus(int64_t ptr) {
    QDoubleSpinBox* w = reinterpret_cast<QDoubleSpinBox*>(ptr);
    if (w) w->setFocus();
}

} // extern "C"
