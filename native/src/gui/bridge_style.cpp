/**
 * @file bridge_style.cpp
 * @brief QStyle 桥接函数
 */

#include <QStyle>
#include <QIcon>
#include <QWidget>
#include <QApplication>

extern "C" {

// ============================================================
// QStyle 桥接函数
// ============================================================

int64_t qWidgetStyle(int64_t widgetPtr) {
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (widget) {
        return reinterpret_cast<int64_t>(widget->style());
    }
    return 0;
}

int64_t qApplicationStyle() {
    return reinterpret_cast<int64_t>(QApplication::style());
}

int32_t qStylePixelMetric(int64_t stylePtr, int32_t metric) {
    QStyle* style = reinterpret_cast<QStyle*>(stylePtr);
    if (style) {
        return style->pixelMetric(static_cast<QStyle::PixelMetric>(metric));
    }
    return 0;
}

int64_t qStyleStandardIcon(int64_t stylePtr, int32_t standardIcon) {
    QStyle* style = reinterpret_cast<QStyle*>(stylePtr);
    if (style) {
        QIcon* icon = new QIcon(style->standardIcon(static_cast<QStyle::StandardPixmap>(standardIcon)));
        return reinterpret_cast<int64_t>(icon);
    }
    return 0;
}

int32_t qStyleLayoutSpacing(int64_t stylePtr, int32_t spacingType) {
    QStyle* style = reinterpret_cast<QStyle*>(stylePtr);
    if (style) {
        return style->layoutSpacing(static_cast<QSizePolicy::ControlType>(spacingType),
                                     static_cast<QSizePolicy::ControlType>(spacingType),
                                     Qt::Horizontal);
    }
    return 0;
}

} // extern "C"
