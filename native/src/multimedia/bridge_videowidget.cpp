/**
 * @file bridge_videowidget.cpp
 * @brief QVideoWidget 桥接函数
 *
 * 注意：在 Qt6 中，QVideoWidget 移除了 setBrightness/setContrast/setHue/setSaturation
 * 等方法。这些属性通过 QVideoSink 控制。这里仅保留 QVideoWidget 自身有效的方法。
 */

#include <QVideoWidget>

extern "C" {

// ============================================================
// QVideoWidget 桥接函数
// ============================================================

int64_t qVideoWidgetCreate() {
    QVideoWidget* widget = new QVideoWidget();
    return reinterpret_cast<int64_t>(widget);
}

void qVideoWidgetSetAspectRatioMode(int64_t ptr, int32_t mode) {
    QVideoWidget* widget = reinterpret_cast<QVideoWidget*>(ptr);
    if (widget) {
        widget->setAspectRatioMode(static_cast<Qt::AspectRatioMode>(mode));
    }
}

int32_t qVideoWidgetAspectRatioMode(int64_t ptr) {
    QVideoWidget* widget = reinterpret_cast<QVideoWidget*>(ptr);
    if (widget) {
        return static_cast<int32_t>(widget->aspectRatioMode());
    }
    return 0;
}

void qVideoWidgetShow(int64_t ptr) {
    QVideoWidget* widget = reinterpret_cast<QVideoWidget*>(ptr);
    if (widget) {
        widget->show();
    }
}

void qVideoWidgetDelete(int64_t ptr) {
    QVideoWidget* widget = reinterpret_cast<QVideoWidget*>(ptr);
    if (widget) {
        delete widget;
    }
}

} // extern "C"
