/**
 * @file bridge_style.cpp
 * @brief QStyle 桥接函数
 */

#include <QStyle>
#include <QIcon>
#include <QPixmap>
#include <QWidget>
#include <QApplication>
#include <QCursor>
#include <QPalette>
#include <QColor>
#include <QPoint>

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

// ============================================================
// QIcon 桥接函数
// ============================================================

int64_t qIconCreate() {
    return reinterpret_cast<int64_t>(new QIcon());
}

int64_t qIconCreateFromFile(const char* filename) {
    return reinterpret_cast<int64_t>(new QIcon(QString::fromUtf8(filename)));
}

bool qIconIsNull(int64_t ptr) {
    QIcon* icon = reinterpret_cast<QIcon*>(ptr);
    return icon ? icon->isNull() : true;
}

void qIconAddFile(int64_t ptr, const char* filename) {
    QIcon* icon = reinterpret_cast<QIcon*>(ptr);
    if (icon) {
        icon->addFile(QString::fromUtf8(filename));
    }
}

void qIconDelete(int64_t ptr) {
    QIcon* icon = reinterpret_cast<QIcon*>(ptr);
    if (icon) {
        delete icon;
    }
}

// ============================================================
// QCursor 桥接函数
// ============================================================

int64_t qCursorCreate() {
    return reinterpret_cast<int64_t>(new QCursor());
}

int64_t qCursorCreateWithShape(int32_t shape) {
    return reinterpret_cast<int64_t>(new QCursor(static_cast<Qt::CursorShape>(shape)));
}

void qCursorDelete(int64_t ptr) {
    QCursor* c = reinterpret_cast<QCursor*>(ptr);
    if (c) delete c;
}

int32_t qCursorShape(int64_t ptr) {
    QCursor* c = reinterpret_cast<QCursor*>(ptr);
    return c ? static_cast<int32_t>(c->shape()) : 0;
}

void qCursorSetShape(int64_t ptr, int32_t shape) {
    QCursor* c = reinterpret_cast<QCursor*>(ptr);
    if (c) c->setShape(static_cast<Qt::CursorShape>(shape));
}

void qCursorSetPos(int32_t x, int32_t y) {
    QCursor::setPos(x, y);
}

int32_t qCursorPosX() {
    return QCursor::pos().x();
}

int32_t qCursorPosY() {
    return QCursor::pos().y();
}

// ============================================================
// QPalette 桥接函数
// ============================================================

int64_t qPaletteCreate() {
    return reinterpret_cast<int64_t>(new QPalette());
}

void qPaletteDelete(int64_t ptr) {
    QPalette* p = reinterpret_cast<QPalette*>(ptr);
    if (p) delete p;
}

int64_t qPaletteColor(int64_t ptr, int32_t group, int32_t role) {
    QPalette* p = reinterpret_cast<QPalette*>(ptr);
    if (p) {
        QColor c = p->color(static_cast<QPalette::ColorGroup>(group),
                            static_cast<QPalette::ColorRole>(role));
        return (static_cast<int64_t>(c.red()) << 0) |
               (static_cast<int64_t>(c.green()) << 8) |
               (static_cast<int64_t>(c.blue()) << 16) |
               (static_cast<int64_t>(c.alpha()) << 24);
    }
    return 0;
}

void qPaletteSetColor(int64_t ptr, int32_t group, int32_t role,
                       int32_t r, int32_t g, int32_t b, int32_t a) {
    QPalette* p = reinterpret_cast<QPalette*>(ptr);
    if (p) {
        p->setColor(static_cast<QPalette::ColorGroup>(group),
                    static_cast<QPalette::ColorRole>(role),
                    QColor(r, g, b, a));
    }
}

} // extern "C"
