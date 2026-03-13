/**
 * @file bridge_painter.cpp
 * @brief 绘图部件桥接函数 - QPainter, QPen, QBrush, QFont, QColor, QLinearGradient
 */

#include <QPainter>
#include <QPen>
#include <QBrush>
#include <QFont>
#include <QColor>
#include <QLinearGradient>
#include <QRadialGradient>
#include <QConicalGradient>
#include <QPainterPath>
#include <QPixmap>
#include <QImage>

extern "C" {

// ============================================================
// QColor 桥接函数
// ============================================================

int64_t qColorCreate() {
    QColor* color = new QColor();
    return reinterpret_cast<int64_t>(color);
}

int64_t qColorCreateRgb(int32_t r, int32_t g, int32_t b, int32_t a) {
    QColor* color = new QColor(r, g, b, a);
    return reinterpret_cast<int64_t>(color);
}

int64_t qColorFromName(const char* name) {
    QColor* color = new QColor(QString::fromUtf8(name));
    return reinterpret_cast<int64_t>(color);
}

void qColorDelete(int64_t ptr) {
    QColor* color = reinterpret_cast<QColor*>(ptr);
    if (color) {
        delete color;
    }
}

int32_t qColorRed(int64_t ptr) {
    QColor* color = reinterpret_cast<QColor*>(ptr);
    if (color) {
        return color->red();
    }
    return 0;
}

int32_t qColorGreen(int64_t ptr) {
    QColor* color = reinterpret_cast<QColor*>(ptr);
    if (color) {
        return color->green();
    }
    return 0;
}

int32_t qColorBlue(int64_t ptr) {
    QColor* color = reinterpret_cast<QColor*>(ptr);
    if (color) {
        return color->blue();
    }
    return 0;
}

int32_t qColorAlpha(int64_t ptr) {
    QColor* color = reinterpret_cast<QColor*>(ptr);
    if (color) {
        return color->alpha();
    }
    return 255;
}

void qColorSetRed(int64_t ptr, int32_t r) {
    QColor* color = reinterpret_cast<QColor*>(ptr);
    if (color) {
        color->setRed(r);
    }
}

void qColorSetGreen(int64_t ptr, int32_t g) {
    QColor* color = reinterpret_cast<QColor*>(ptr);
    if (color) {
        color->setGreen(g);
    }
}

void qColorSetBlue(int64_t ptr, int32_t b) {
    QColor* color = reinterpret_cast<QColor*>(ptr);
    if (color) {
        color->setBlue(b);
    }
}

void qColorSetAlpha(int64_t ptr, int32_t a) {
    QColor* color = reinterpret_cast<QColor*>(ptr);
    if (color) {
        color->setAlpha(a);
    }
}

// ============================================================
// QPen 桥接函数
// ============================================================

int64_t qPenCreate() {
    QPen* pen = new QPen();
    return reinterpret_cast<int64_t>(pen);
}

int64_t qPenCreateColor(int64_t colorPtr) {
    QColor* color = reinterpret_cast<QColor*>(colorPtr);
    QPen* pen = new QPen(*color);
    return reinterpret_cast<int64_t>(pen);
}

void qPenDelete(int64_t ptr) {
    QPen* pen = reinterpret_cast<QPen*>(ptr);
    if (pen) {
        delete pen;
    }
}

void qPenSetColor(int64_t ptr, int64_t colorPtr) {
    QPen* pen = reinterpret_cast<QPen*>(ptr);
    QColor* color = reinterpret_cast<QColor*>(colorPtr);
    if (pen && color) {
        pen->setColor(*color);
    }
}

int64_t qPenColor(int64_t ptr) {
    QPen* pen = reinterpret_cast<QPen*>(ptr);
    if (pen) {
        QColor* color = new QColor(pen->color());
        return reinterpret_cast<int64_t>(color);
    }
    return 0;
}

void qPenSetWidth(int64_t ptr, int32_t width) {
    QPen* pen = reinterpret_cast<QPen*>(ptr);
    if (pen) {
        pen->setWidth(width);
    }
}

int32_t qPenWidth(int64_t ptr) {
    QPen* pen = reinterpret_cast<QPen*>(ptr);
    if (pen) {
        return pen->width();
    }
    return 1;
}

void qPenSetStyle(int64_t ptr, int32_t style) {
    QPen* pen = reinterpret_cast<QPen*>(ptr);
    if (pen) {
        pen->setStyle(static_cast<Qt::PenStyle>(style));
    }
}

int32_t qPenStyle(int64_t ptr) {
    QPen* pen = reinterpret_cast<QPen*>(ptr);
    if (pen) {
        return static_cast<int32_t>(pen->style());
    }
    return 1; // SolidLine
}

void qPenSetCapStyle(int64_t ptr, int32_t style) {
    QPen* pen = reinterpret_cast<QPen*>(ptr);
    if (pen) {
        pen->setCapStyle(static_cast<Qt::PenCapStyle>(style));
    }
}

void qPenSetJoinStyle(int64_t ptr, int32_t style) {
    QPen* pen = reinterpret_cast<QPen*>(ptr);
    if (pen) {
        pen->setJoinStyle(static_cast<Qt::PenJoinStyle>(style));
    }
}

// ============================================================
// QBrush 桥接函数
// ============================================================

int64_t qBrushCreate() {
    QBrush* brush = new QBrush();
    return reinterpret_cast<int64_t>(brush);
}

int64_t qBrushCreateColor(int64_t colorPtr) {
    QColor* color = reinterpret_cast<QColor*>(colorPtr);
    QBrush* brush = new QBrush(*color);
    return reinterpret_cast<int64_t>(brush);
}

int64_t qBrushCreateGradient(int64_t gradientPtr) {
    QGradient* gradient = reinterpret_cast<QGradient*>(gradientPtr);
    QBrush* brush = new QBrush(*gradient);
    return reinterpret_cast<int64_t>(brush);
}

void qBrushDelete(int64_t ptr) {
    QBrush* brush = reinterpret_cast<QBrush*>(ptr);
    if (brush) {
        delete brush;
    }
}

void qBrushSetColor(int64_t ptr, int64_t colorPtr) {
    QBrush* brush = reinterpret_cast<QBrush*>(ptr);
    QColor* color = reinterpret_cast<QColor*>(colorPtr);
    if (brush && color) {
        brush->setColor(*color);
    }
}

void qBrushSetStyle(int64_t ptr, int32_t style) {
    QBrush* brush = reinterpret_cast<QBrush*>(ptr);
    if (brush) {
        brush->setStyle(static_cast<Qt::BrushStyle>(style));
    }
}

int32_t qBrushStyle(int64_t ptr) {
    QBrush* brush = reinterpret_cast<QBrush*>(ptr);
    if (brush) {
        return static_cast<int32_t>(brush->style());
    }
    return 0; // NoBrush
}

// ============================================================
// QLinearGradient 桥接函数
// ============================================================

int64_t qLinearGradientCreate(float x1, float y1, float x2, float y2) {
    QLinearGradient* gradient = new QLinearGradient(x1, y1, x2, y2);
    return reinterpret_cast<int64_t>(gradient);
}

void qLinearGradientDelete(int64_t ptr) {
    QLinearGradient* gradient = reinterpret_cast<QLinearGradient*>(ptr);
    if (gradient) {
        delete gradient;
    }
}

void qGradientSetColorAt(int64_t ptr, float pos, int64_t colorPtr) {
    QGradient* gradient = reinterpret_cast<QGradient*>(ptr);
    QColor* color = reinterpret_cast<QColor*>(colorPtr);
    if (gradient && color) {
        gradient->setColorAt(pos, *color);
    }
}

void qGradientSetSpread(int64_t ptr, int32_t spread) {
    QGradient* gradient = reinterpret_cast<QGradient*>(ptr);
    if (gradient) {
        gradient->setSpread(static_cast<QGradient::Spread>(spread));
    }
}

// ============================================================
// QRadialGradient 桥接函数
// ============================================================

int64_t qRadialGradientCreate(float cx, float cy, float radius, float fx, float fy) {
    QRadialGradient* gradient = new QRadialGradient(cx, cy, radius, fx, fy);
    return reinterpret_cast<int64_t>(gradient);
}

void qRadialGradientDelete(int64_t ptr) {
    QRadialGradient* gradient = reinterpret_cast<QRadialGradient*>(ptr);
    if (gradient) {
        delete gradient;
    }
}

// ============================================================
// QConicalGradient 桥接函数
// ============================================================

int64_t qConicalGradientCreate(float cx, float cy, float angle) {
    QConicalGradient* gradient = new QConicalGradient(cx, cy, angle);
    return reinterpret_cast<int64_t>(gradient);
}

void qConicalGradientDelete(int64_t ptr) {
    QConicalGradient* gradient = reinterpret_cast<QConicalGradient*>(ptr);
    if (gradient) {
        delete gradient;
    }
}

// ============================================================
// QFont (绘图用) 桥接函数
// ============================================================

int64_t qFontCreate(const char* family, int32_t pointSize, int32_t bold, int32_t italic) {
    QFont* font = new QFont(QString::fromUtf8(family), pointSize);
    font->setBold(bold != 0);
    font->setItalic(italic != 0);
    return reinterpret_cast<int64_t>(font);
}

void qFontDelete(int64_t ptr) {
    QFont* font = reinterpret_cast<QFont*>(ptr);
    if (font) {
        delete font;
    }
}

void qFontSetFamily(int64_t ptr, const char* family) {
    QFont* font = reinterpret_cast<QFont*>(ptr);
    if (font) {
        font->setFamily(QString::fromUtf8(family));
    }
}

void qFontSetPointSize(int64_t ptr, int32_t size) {
    QFont* font = reinterpret_cast<QFont*>(ptr);
    if (font) {
        font->setPointSize(size);
    }
}

void qFontSetBold(int64_t ptr, int32_t bold) {
    QFont* font = reinterpret_cast<QFont*>(ptr);
    if (font) {
        font->setBold(bold != 0);
    }
}

void qFontSetItalic(int64_t ptr, int32_t italic) {
    QFont* font = reinterpret_cast<QFont*>(ptr);
    if (font) {
        font->setItalic(italic != 0);
    }
}

// ============================================================
// QPainter 桥接函数
// ============================================================

int64_t qPainterCreate(int64_t devicePtr) {
    QPaintDevice* device = reinterpret_cast<QPaintDevice*>(devicePtr);
    QPainter* painter = new QPainter(device);
    return reinterpret_cast<int64_t>(painter);
}

void qPainterDelete(int64_t ptr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        delete painter;
    }
}

int32_t qPainterBegin(int64_t ptr, int64_t devicePtr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    QPaintDevice* device = reinterpret_cast<QPaintDevice*>(devicePtr);
    if (painter && device) {
        return painter->begin(device) ? 1 : 0;
    }
    return 0;
}

int32_t qPainterEnd(int64_t ptr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        return painter->end() ? 1 : 0;
    }
    return 0;
}

int32_t qPainterIsActive(int64_t ptr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        return painter->isActive() ? 1 : 0;
    }
    return 0;
}

void qPainterSetPen(int64_t ptr, int64_t penPtr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    QPen* pen = reinterpret_cast<QPen*>(penPtr);
    if (painter && pen) {
        painter->setPen(*pen);
    }
}

void qPainterSetPenColor(int64_t ptr, int64_t colorPtr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    QColor* color = reinterpret_cast<QColor*>(colorPtr);
    if (painter && color) {
        painter->setPen(*color);
    }
}

void qPainterSetBrush(int64_t ptr, int64_t brushPtr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    QBrush* brush = reinterpret_cast<QBrush*>(brushPtr);
    if (painter && brush) {
        painter->setBrush(*brush);
    }
}

void qPainterSetFont(int64_t ptr, int64_t fontPtr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    QFont* font = reinterpret_cast<QFont*>(fontPtr);
    if (painter && font) {
        painter->setFont(*font);
    }
}

void qPainterSetBrushOrigin(int64_t ptr, int32_t x, int32_t y) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->setBrushOrigin(x, y);
    }
}

void qPainterSetRenderHint(int64_t ptr, int32_t hint, int32_t on) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->setRenderHint(static_cast<QPainter::RenderHint>(hint), on != 0);
    }
}

void qPainterSetBackground(int64_t ptr, int64_t brushPtr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    QBrush* brush = reinterpret_cast<QBrush*>(brushPtr);
    if (painter && brush) {
        painter->setBackground(*brush);
    }
}

void qPainterSetBackgroundMode(int64_t ptr, int32_t mode) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->setBackgroundMode(static_cast<Qt::BGMode>(mode));
    }
}

// 绘制基本图形
void qPainterDrawPoint(int64_t ptr, int32_t x, int32_t y) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->drawPoint(x, y);
    }
}

void qPainterDrawPoints(int64_t ptr, int32_t* points, int32_t count) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter && points) {
        QVector<QPoint> pointList;
        for (int i = 0; i < count * 2; i += 2) {
            pointList.append(QPoint(points[i], points[i + 1]));
        }
        painter->drawPoints(pointList);
    }
}

void qPainterDrawLine(int64_t ptr, int32_t x1, int32_t y1, int32_t x2, int32_t y2) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->drawLine(x1, y1, x2, y2);
    }
}

void qPainterDrawLines(int64_t ptr, int32_t* lines, int32_t count) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter && lines) {
        QVector<QLine> lineList;
        for (int i = 0; i < count * 4; i += 4) {
            lineList.append(QLine(lines[i], lines[i + 1], lines[i + 2], lines[i + 3]));
        }
        painter->drawLines(lineList);
    }
}

void qPainterDrawRect(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->drawRect(x, y, width, height);
    }
}

void qPainterDrawRects(int64_t ptr, int32_t* rects, int32_t count) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter && rects) {
        QVector<QRect> rectList;
        for (int i = 0; i < count * 4; i += 4) {
            rectList.append(QRect(rects[i], rects[i + 1], rects[i + 2], rects[i + 3]));
        }
        painter->drawRects(rectList);
    }
}

void qPainterDrawRoundedRect(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height, float xRadius, float yRadius) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->drawRoundedRect(x, y, width, height, xRadius, yRadius);
    }
}

void qPainterDrawEllipse(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->drawEllipse(x, y, width, height);
    }
}

void qPainterDrawEllipseCenter(int64_t ptr, int32_t cx, int32_t cy, int32_t rx, int32_t ry) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->drawEllipse(QPoint(cx, cy), rx, ry);
    }
}

void qPainterDrawArc(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height, int32_t startAngle, int32_t spanAngle) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->drawArc(x, y, width, height, startAngle, spanAngle);
    }
}

void qPainterDrawChord(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height, int32_t startAngle, int32_t spanAngle) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->drawChord(x, y, width, height, startAngle, spanAngle);
    }
}

void qPainterDrawPie(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height, int32_t startAngle, int32_t spanAngle) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->drawPie(x, y, width, height, startAngle, spanAngle);
    }
}

void qPainterDrawPolygon(int64_t ptr, int32_t* points, int32_t count, int32_t fillRule) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter && points) {
        QPolygon polygon;
        for (int i = 0; i < count * 2; i += 2) {
            polygon.append(QPoint(points[i], points[i + 1]));
        }
        painter->drawPolygon(polygon, static_cast<Qt::FillRule>(fillRule));
    }
}

void qPainterDrawPolyline(int64_t ptr, int32_t* points, int32_t count) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter && points) {
        QPolygon polygon;
        for (int i = 0; i < count * 2; i += 2) {
            polygon.append(QPoint(points[i], points[i + 1]));
        }
        painter->drawPolyline(polygon);
    }
}

void qPainterDrawConvexPolygon(int64_t ptr, int32_t* points, int32_t count) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter && points) {
        QPolygon polygon;
        for (int i = 0; i < count * 2; i += 2) {
            polygon.append(QPoint(points[i], points[i + 1]));
        }
        painter->drawConvexPolygon(polygon);
    }
}

// 绘制文字
void qPainterDrawText(int64_t ptr, int32_t x, int32_t y, const char* text) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->drawText(x, y, QString::fromUtf8(text));
    }
}

void qPainterDrawTextRect(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height, int32_t flags, const char* text) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->drawText(QRect(x, y, width, height), flags, QString::fromUtf8(text));
    }
}

void qPainterDrawTextPoint(int64_t ptr, int32_t x, int32_t y, const char* text, int32_t startPos, int32_t length) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        QString str = QString::fromUtf8(text);
        painter->drawText(QPoint(x, y), str.mid(startPos, length));
    }
}

// 绘制图像
void qPainterDrawPixmap(int64_t ptr, int32_t x, int32_t y, int64_t pixmapPtr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(pixmapPtr);
    if (painter && pixmap) {
        painter->drawPixmap(x, y, *pixmap);
    }
}

void qPainterDrawPixmapRect(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height, int64_t pixmapPtr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(pixmapPtr);
    if (painter && pixmap) {
        painter->drawPixmap(x, y, width, height, *pixmap);
    }
}

void qPainterDrawImage(int64_t ptr, int32_t x, int32_t y, int64_t imagePtr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    QImage* image = reinterpret_cast<QImage*>(imagePtr);
    if (painter && image) {
        painter->drawImage(x, y, *image);
    }
}

// 填充
void qPainterFillRect(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height, int64_t brushPtr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    QBrush* brush = reinterpret_cast<QBrush*>(brushPtr);
    if (painter && brush) {
        painter->fillRect(x, y, width, height, *brush);
    }
}

void qPainterFillRectColor(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height, int64_t colorPtr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    QColor* color = reinterpret_cast<QColor*>(colorPtr);
    if (painter && color) {
        painter->fillRect(x, y, width, height, *color);
    }
}

void qPainterEraseRect(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->eraseRect(x, y, width, height);
    }
}

// 坐标变换
void qPainterTranslate(int64_t ptr, float dx, float dy) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->translate(dx, dy);
    }
}

void qPainterScale(int64_t ptr, float sx, float sy) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->scale(sx, sy);
    }
}

void qPainterRotate(int64_t ptr, float angle) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->rotate(angle);
    }
}

void qPainterShear(int64_t ptr, float sh, float sv) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->shear(sh, sv);
    }
}

void qPainterSave(int64_t ptr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->save();
    }
}

void qPainterRestore(int64_t ptr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->restore();
    }
}

void qPainterResetTransform(int64_t ptr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->resetTransform();
    }
}

// 设置剪切区域
void qPainterSetClipRect(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->setClipRect(x, y, width, height);
    }
}

void qPainterSetClipping(int64_t ptr, int32_t enable) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->setClipping(enable != 0);
    }
}

// 设置透明度
void qPainterSetOpacity(int64_t ptr, float opacity) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        painter->setOpacity(opacity);
    }
}

float qPainterOpacity(int64_t ptr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        return painter->opacity();
    }
    return 1.0f;
}

// 获取绘图设备信息
int64_t qPainterDevice(int64_t ptr) {
    QPainter* painter = reinterpret_cast<QPainter*>(ptr);
    if (painter) {
        return reinterpret_cast<int64_t>(painter->device());
    }
    return 0;
}

// ============================================================
// QPixmap 桥接函数
// ============================================================

int64_t qPixmapCreate() {
    QPixmap* pixmap = new QPixmap();
    return reinterpret_cast<int64_t>(pixmap);
}

int64_t qPixmapCreateSize(int32_t width, int32_t height) {
    QPixmap* pixmap = new QPixmap(width, height);
    return reinterpret_cast<int64_t>(pixmap);
}

int64_t qPixmapLoad(const char* fileName) {
    QPixmap* pixmap = new QPixmap(QString::fromUtf8(fileName));
    return reinterpret_cast<int64_t>(pixmap);
}

void qPixmapDelete(int64_t ptr) {
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(ptr);
    if (pixmap) {
        delete pixmap;
    }
}

int32_t qPixmapLoadFile(int64_t ptr, const char* fileName) {
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(ptr);
    if (pixmap) {
        return pixmap->load(QString::fromUtf8(fileName)) ? 1 : 0;
    }
    return 0;
}

int32_t qPixmapSave(int64_t ptr, const char* fileName, const char* format) {
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(ptr);
    if (pixmap) {
        QString fmt = format ? QString::fromUtf8(format) : QString();
        return pixmap->save(QString::fromUtf8(fileName), fmt.toUtf8().constData()) ? 1 : 0;
    }
    return 0;
}

int64_t qPixmapScaled(int64_t ptr, int32_t width, int32_t height, int32_t aspectRatioMode, int32_t transformMode) {
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(ptr);
    if (pixmap) {
        QPixmap* scaled = new QPixmap(pixmap->scaled(width, height, 
            static_cast<Qt::AspectRatioMode>(aspectRatioMode),
            static_cast<Qt::TransformationMode>(transformMode)));
        return reinterpret_cast<int64_t>(scaled);
    }
    return 0;
}

int64_t qPixmapScaledToWidth(int64_t ptr, int32_t width, int32_t mode) {
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(ptr);
    if (pixmap) {
        QPixmap* scaled = new QPixmap(pixmap->scaledToWidth(width, static_cast<Qt::TransformationMode>(mode)));
        return reinterpret_cast<int64_t>(scaled);
    }
    return 0;
}

int64_t qPixmapScaledToHeight(int64_t ptr, int32_t height, int32_t mode) {
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(ptr);
    if (pixmap) {
        QPixmap* scaled = new QPixmap(pixmap->scaledToHeight(height, static_cast<Qt::TransformationMode>(mode)));
        return reinterpret_cast<int64_t>(scaled);
    }
    return 0;
}

int32_t qPixmapWidth(int64_t ptr) {
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(ptr);
    if (pixmap) {
        return pixmap->width();
    }
    return 0;
}

int32_t qPixmapHeight(int64_t ptr) {
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(ptr);
    if (pixmap) {
        return pixmap->height();
    }
    return 0;
}

int32_t qPixmapIsNull(int64_t ptr) {
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(ptr);
    if (pixmap) {
        return pixmap->isNull() ? 1 : 0;
    }
    return 1;
}

void qPixmapFill(int64_t ptr, int64_t colorPtr) {
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(ptr);
    QColor* color = reinterpret_cast<QColor*>(colorPtr);
    if (pixmap && color) {
        pixmap->fill(*color);
    }
}

// ============================================================
// QImage 桥接函数
// ============================================================

int64_t qImageCreate() {
    QImage* image = new QImage();
    return reinterpret_cast<int64_t>(image);
}

int64_t qImageCreateSize(int32_t width, int32_t height, int32_t format) {
    QImage* image = new QImage(width, height, static_cast<QImage::Format>(format));
    return reinterpret_cast<int64_t>(image);
}

int64_t qImageLoad(const char* fileName) {
    QImage* image = new QImage(QString::fromUtf8(fileName));
    return reinterpret_cast<int64_t>(image);
}

void qImageDelete(int64_t ptr) {
    QImage* image = reinterpret_cast<QImage*>(ptr);
    if (image) {
        delete image;
    }
}

int32_t qImageLoadFile(int64_t ptr, const char* fileName) {
    QImage* image = reinterpret_cast<QImage*>(ptr);
    if (image) {
        return image->load(QString::fromUtf8(fileName)) ? 1 : 0;
    }
    return 0;
}

int32_t qImageSave(int64_t ptr, const char* fileName, const char* format) {
    QImage* image = reinterpret_cast<QImage*>(ptr);
    if (image) {
        QString fmt = format ? QString::fromUtf8(format) : QString();
        return image->save(QString::fromUtf8(fileName), fmt.toUtf8().constData()) ? 1 : 0;
    }
    return 0;
}

int32_t qImageWidth(int64_t ptr) {
    QImage* image = reinterpret_cast<QImage*>(ptr);
    if (image) {
        return image->width();
    }
    return 0;
}

int32_t qImageHeight(int64_t ptr) {
    QImage* image = reinterpret_cast<QImage*>(ptr);
    if (image) {
        return image->height();
    }
    return 0;
}

int32_t qImageIsNull(int64_t ptr) {
    QImage* image = reinterpret_cast<QImage*>(ptr);
    if (image) {
        return image->isNull() ? 1 : 0;
    }
    return 1;
}

int64_t qImageScaled(int64_t ptr, int32_t width, int32_t height, int32_t aspectRatioMode, int32_t transformMode) {
    QImage* image = reinterpret_cast<QImage*>(ptr);
    if (image) {
        QImage* scaled = new QImage(image->scaled(width, height,
            static_cast<Qt::AspectRatioMode>(aspectRatioMode),
            static_cast<Qt::TransformationMode>(transformMode)));
        return reinterpret_cast<int64_t>(scaled);
    }
    return 0;
}

int64_t qImageMirrored(int64_t ptr, int32_t horizontal, int32_t vertical) {
    QImage* image = reinterpret_cast<QImage*>(ptr);
    if (image) {
        QImage* mirrored = new QImage(image->mirrored(horizontal != 0, vertical != 0));
        return reinterpret_cast<int64_t>(mirrored);
    }
    return 0;
}

int64_t qImageRgbSwapped(int64_t ptr) {
    QImage* image = reinterpret_cast<QImage*>(ptr);
    if (image) {
        QImage* swapped = new QImage(image->rgbSwapped());
        return reinterpret_cast<int64_t>(swapped);
    }
    return 0;
}

void qImageSetPixel(int64_t ptr, int32_t x, int32_t y, int32_t color) {
    QImage* image = reinterpret_cast<QImage*>(ptr);
    if (image) {
        image->setPixel(x, y, color);
    }
}

int32_t qImagePixel(int64_t ptr, int32_t x, int32_t y) {
    QImage* image = reinterpret_cast<QImage*>(ptr);
    if (image) {
        return image->pixel(x, y);
    }
    return 0;
}

int64_t qImageConvertToFormat(int64_t ptr, int32_t format) {
    QImage* image = reinterpret_cast<QImage*>(ptr);
    if (image) {
        QImage* converted = new QImage(image->convertToFormat(static_cast<QImage::Format>(format)));
        return reinterpret_cast<int64_t>(converted);
    }
    return 0;
}

int64_t qImageFromPixmap(int64_t pixmapPtr) {
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(pixmapPtr);
    if (pixmap) {
        QImage* image = new QImage(pixmap->toImage());
        return reinterpret_cast<int64_t>(image);
    }
    return 0;
}

int64_t qPixmapFromImage(int64_t imagePtr) {
    QImage* image = reinterpret_cast<QImage*>(imagePtr);
    if (image) {
        QPixmap* pixmap = new QPixmap(QPixmap::fromImage(*image));
        return reinterpret_cast<int64_t>(pixmap);
    }
    return 0;
}

// ============================================================
// QPainterPath 桥接函数
// ============================================================

int64_t qPainterPathCreate() {
    QPainterPath* path = new QPainterPath();
    return reinterpret_cast<int64_t>(path);
}

void qPainterPathDelete(int64_t ptr) {
    QPainterPath* path = reinterpret_cast<QPainterPath*>(ptr);
    if (path) {
        delete path;
    }
}

void qPainterPathMoveTo(int64_t ptr, float x, float y) {
    QPainterPath* path = reinterpret_cast<QPainterPath*>(ptr);
    if (path) {
        path->moveTo(x, y);
    }
}

void qPainterPathLineTo(int64_t ptr, float x, float y) {
    QPainterPath* path = reinterpret_cast<QPainterPath*>(ptr);
    if (path) {
        path->lineTo(x, y);
    }
}

void qPainterPathCubicTo(int64_t ptr, float c1x, float c1y, float c2x, float c2y, float ex, float ey) {
    QPainterPath* path = reinterpret_cast<QPainterPath*>(ptr);
    if (path) {
        path->cubicTo(c1x, c1y, c2x, c2y, ex, ey);
    }
}

void qPainterPathQuadTo(int64_t ptr, float cx, float cy, float ex, float ey) {
    QPainterPath* path = reinterpret_cast<QPainterPath*>(ptr);
    if (path) {
        path->quadTo(cx, cy, ex, ey);
    }
}

void qPainterPathArcTo(int64_t ptr, float x, float y, float width, float height, float startAngle, float sweepLength) {
    QPainterPath* path = reinterpret_cast<QPainterPath*>(ptr);
    if (path) {
        path->arcTo(x, y, width, height, startAngle, sweepLength);
    }
}

void qPainterPathAddRect(int64_t ptr, float x, float y, float width, float height) {
    QPainterPath* path = reinterpret_cast<QPainterPath*>(ptr);
    if (path) {
        path->addRect(x, y, width, height);
    }
}

void qPainterPathAddEllipse(int64_t ptr, float x, float y, float width, float height) {
    QPainterPath* path = reinterpret_cast<QPainterPath*>(ptr);
    if (path) {
        path->addEllipse(x, y, width, height);
    }
}

void qPainterPathAddPolygon(int64_t ptr, int32_t* points, int32_t count) {
    QPainterPath* path = reinterpret_cast<QPainterPath*>(ptr);
    if (path && points) {
        QPolygonF polygon;
        for (int i = 0; i < count * 2; i += 2) {
            polygon.append(QPointF(points[i], points[i + 1]));
        }
        path->addPolygon(polygon);
    }
}

void qPainterPathAddText(int64_t ptr, float x, float y, int64_t fontPtr, const char* text) {
    QPainterPath* path = reinterpret_cast<QPainterPath*>(ptr);
    QFont* font = reinterpret_cast<QFont*>(fontPtr);
    if (path && font) {
        path->addText(x, y, *font, QString::fromUtf8(text));
    }
}

void qPainterPathCloseSubpath(int64_t ptr) {
    QPainterPath* path = reinterpret_cast<QPainterPath*>(ptr);
    if (path) {
        path->closeSubpath();
    }
}

void qPainterPathTranslate(int64_t ptr, float dx, float dy) {
    QPainterPath* path = reinterpret_cast<QPainterPath*>(ptr);
    if (path) {
        path->translate(dx, dy);
    }
}

int32_t qPainterPathIsEmpty(int64_t ptr) {
    QPainterPath* path = reinterpret_cast<QPainterPath*>(ptr);
    if (path) {
        return path->isEmpty() ? 1 : 0;
    }
    return 1;
}

void qPainterDrawPath(int64_t painterPtr, int64_t pathPtr) {
    QPainter* painter = reinterpret_cast<QPainter*>(painterPtr);
    QPainterPath* path = reinterpret_cast<QPainterPath*>(pathPtr);
    if (painter && path) {
        painter->drawPath(*path);
    }
}

void qPainterFillPath(int64_t painterPtr, int64_t pathPtr, int64_t brushPtr) {
    QPainter* painter = reinterpret_cast<QPainter*>(painterPtr);
    QPainterPath* path = reinterpret_cast<QPainterPath*>(pathPtr);
    QBrush* brush = reinterpret_cast<QBrush*>(brushPtr);
    if (painter && path && brush) {
        painter->fillPath(*path, *brush);
    }
}

void qPainterStrokePath(int64_t painterPtr, int64_t pathPtr, int64_t penPtr) {
    QPainter* painter = reinterpret_cast<QPainter*>(painterPtr);
    QPainterPath* path = reinterpret_cast<QPainterPath*>(pathPtr);
    QPen* pen = reinterpret_cast<QPen*>(penPtr);
    if (painter && path && pen) {
        painter->strokePath(*path, *pen);
    }
}


// ============================================================
// QTransform 桥接函数
// ============================================================

int64_t qTransformCreate() {
    QTransform* t = new QTransform();
    return reinterpret_cast<int64_t>(t);
}

int64_t qTransformCreateWithValues(float m11, float m12, float m13, float m21, float m22, float m23, float m31, float m32, float m33) {
    QTransform* t = new QTransform(m11, m12, m13, m21, m22, m23, m31, m32, m33);
    return reinterpret_cast<int64_t>(t);
}

void qTransformSetMatrix(int64_t ptr, float m11, float m12, float m13, float m21, float m22, float m23, float m31, float m32, float m33) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) {
        t->setMatrix(m11, m12, m13, m21, m22, m23, m31, m32, m33);
    }
}

int64_t qTransformTranslate(int64_t ptr, float dx, float dy) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) {
        QTransform* result = new QTransform(*t);
        result->translate(dx, dy);
        return reinterpret_cast<int64_t>(result);
    }
    return 0;
}

int64_t qTransformScale(int64_t ptr, float sx, float sy) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) {
        QTransform* result = new QTransform(*t);
        result->scale(sx, sy);
        return reinterpret_cast<int64_t>(result);
    }
    return 0;
}

int64_t qTransformRotate(int64_t ptr, float angle) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) {
        QTransform* result = new QTransform(*t);
        result->rotate(angle);
        return reinterpret_cast<int64_t>(result);
    }
    return 0;
}

int64_t qTransformShear(int64_t ptr, float sh, float sv) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) {
        QTransform* result = new QTransform(*t);
        result->shear(sh, sv);
        return reinterpret_cast<int64_t>(result);
    }
    return 0;
}

void qTransformReset(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) {
        t->reset();
    }
}

float qTransformM11(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) return t->m11();
    return 1.0f;
}

float qTransformM12(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) return t->m12();
    return 0.0f;
}

float qTransformM13(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) return t->m13();
    return 0.0f;
}

float qTransformM21(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) return t->m21();
    return 0.0f;
}

float qTransformM22(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) return t->m22();
    return 1.0f;
}

float qTransformM23(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) return t->m23();
    return 0.0f;
}

float qTransformM31(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) return t->m31();
    return 0.0f;
}

float qTransformM32(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) return t->m32();
    return 0.0f;
}

float qTransformM33(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) return t->m33();
    return 1.0f;
}

float qTransformDx(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) return t->dx();
    return 0.0f;
}

float qTransformDy(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) return t->dy();
    return 0.0f;
}

int32_t qTransformIsIdentity(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) return t->isIdentity() ? 1 : 0;
    return 1;
}

int32_t qTransformIsInvertible(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) return t->isInvertible() ? 1 : 0;
    return 0;
}

int64_t qTransformInverted(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) {
        QTransform* result = new QTransform(t->inverted());
        return reinterpret_cast<int64_t>(result);
    }
    return 0;
}

int64_t qTransformMultiply(int64_t ptr, int64_t other) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    QTransform* o = reinterpret_cast<QTransform*>(other);
    if (t && o) {
        QTransform* result = new QTransform(*t * *o);
        return reinterpret_cast<int64_t>(result);
    }
    return 0;
}

void qTransformDelete(int64_t ptr) {
    QTransform* t = reinterpret_cast<QTransform*>(ptr);
    if (t) {
        delete t;
    }
}

} // extern "C"
