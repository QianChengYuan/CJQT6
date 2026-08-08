/**
 * @file bridge_graphicsitem.cpp
 * @brief QGraphicsItem 子类桥接函数 - QGraphicsRectItem, QGraphicsEllipseItem, QGraphicsTextItem 等
 *
 * 注意：qGraphicsItemSetPos/Pos/SetZValue/SetRotation/SetVisible/IsVisible/SetSelected/IsSelected/Update
 * 已在 bridge_widgets.cpp 中定义，此处不再重复定义。
 */

#include <QGraphicsItem>
#include <QGraphicsRectItem>
#include <QGraphicsEllipseItem>
#include <QGraphicsLineItem>
#include <QGraphicsTextItem>
#include <QGraphicsPixmapItem>
#include <QGraphicsPathItem>
#include <QGraphicsItemGroup>
#include <QPen>
#include <QBrush>
#include <QFont>
#include <QPixmap>
#include <QPainterPath>
#include <QGraphicsScene>
#include <QCursor>
#include <QByteArray>
#include "bridge_string_utils.h"

extern "C" {

// ============================================================
// QGraphicsItem 通用操作（仅新增的 getter/setter，避免与 bridge_widgets.cpp 重复）
// ============================================================

double qGraphicsItemPosX(int64_t ptr) {
    return reinterpret_cast<QGraphicsItem*>(ptr)->pos().x();
}

double qGraphicsItemPosY(int64_t ptr) {
    return reinterpret_cast<QGraphicsItem*>(ptr)->pos().y();
}

double qGraphicsItemZValue(int64_t ptr) {
    return reinterpret_cast<QGraphicsItem*>(ptr)->zValue();
}

double qGraphicsItemRotation(int64_t ptr) {
    return reinterpret_cast<QGraphicsItem*>(ptr)->rotation();
}

void qGraphicsItemSetScale(int64_t ptr, double scale) {
    reinterpret_cast<QGraphicsItem*>(ptr)->setScale(scale);
}

double qGraphicsItemScale(int64_t ptr) {
    return reinterpret_cast<QGraphicsItem*>(ptr)->scale();
}

void qGraphicsItemSetEnabled(int64_t ptr, bool enabled) {
    reinterpret_cast<QGraphicsItem*>(ptr)->setEnabled(enabled);
}

bool qGraphicsItemIsEnabled(int64_t ptr) {
    return reinterpret_cast<QGraphicsItem*>(ptr)->isEnabled();
}

void qGraphicsItemSetOpacity(int64_t ptr, double opacity) {
    reinterpret_cast<QGraphicsItem*>(ptr)->setOpacity(opacity);
}

double qGraphicsItemOpacity(int64_t ptr) {
    return reinterpret_cast<QGraphicsItem*>(ptr)->opacity();
}

double qGraphicsItemSceneBoundingRectX(int64_t ptr) {
    return reinterpret_cast<QGraphicsItem*>(ptr)->sceneBoundingRect().x();
}

double qGraphicsItemSceneBoundingRectY(int64_t ptr) {
    return reinterpret_cast<QGraphicsItem*>(ptr)->sceneBoundingRect().y();
}

double qGraphicsItemSceneBoundingRectW(int64_t ptr) {
    return reinterpret_cast<QGraphicsItem*>(ptr)->sceneBoundingRect().width();
}

double qGraphicsItemSceneBoundingRectH(int64_t ptr) {
    return reinterpret_cast<QGraphicsItem*>(ptr)->sceneBoundingRect().height();
}

int64_t qGraphicsItemScene(int64_t ptr) {
    return reinterpret_cast<int64_t>(reinterpret_cast<QGraphicsItem*>(ptr)->scene());
}

void qGraphicsItemSetParentItem(int64_t ptr, int64_t parentPtr) {
    reinterpret_cast<QGraphicsItem*>(ptr)->setParentItem(reinterpret_cast<QGraphicsItem*>(parentPtr));
}

void qGraphicsItemSetToolTip(int64_t ptr, const char* tip) {
    reinterpret_cast<QGraphicsItem*>(ptr)->setToolTip(QString::fromUtf8(tip));
}

void qGraphicsItemSetCursor(int64_t ptr, int32_t shape) {
    reinterpret_cast<QGraphicsItem*>(ptr)->setCursor(QCursor(static_cast<Qt::CursorShape>(shape)));
}

int32_t qGraphicsItemType(int64_t ptr) {
    return reinterpret_cast<QGraphicsItem*>(ptr)->type();
}

// ============================================================
// QGraphicsRectItem
// ============================================================

int64_t qGraphicsRectItemCreate() {
    return reinterpret_cast<int64_t>(new QGraphicsRectItem());
}

int64_t qGraphicsRectItemCreateXYWH(double x, double y, double w, double h) {
    return reinterpret_cast<int64_t>(new QGraphicsRectItem(x, y, w, h));
}

void qGraphicsRectItemDelete(int64_t ptr) {
    delete reinterpret_cast<QGraphicsRectItem*>(ptr);
}

void qGraphicsRectItemSetRect(int64_t ptr, double x, double y, double w, double h) {
    reinterpret_cast<QGraphicsRectItem*>(ptr)->setRect(x, y, w, h);
}

const char* qGraphicsRectItemRect(int64_t ptr) {
    QRectF r = reinterpret_cast<QGraphicsRectItem*>(ptr)->rect();
    return cjqt6::dupUtf8(QString("(%1,%2,%3,%4)").arg(r.x()).arg(r.y()).arg(r.width()).arg(r.height()));
}

void qGraphicsRectItemSetPen(int64_t ptr, int32_t colorR, int32_t colorG, int32_t colorB, int32_t width) {
    reinterpret_cast<QGraphicsRectItem*>(ptr)->setPen(QPen(QColor(colorR, colorG, colorB), width));
}

void qGraphicsRectItemSetBrush(int64_t ptr, int32_t colorR, int32_t colorG, int32_t colorB) {
    reinterpret_cast<QGraphicsRectItem*>(ptr)->setBrush(QBrush(QColor(colorR, colorG, colorB)));
}

// ============================================================
// QGraphicsEllipseItem
// ============================================================

int64_t qGraphicsEllipseItemCreate() {
    return reinterpret_cast<int64_t>(new QGraphicsEllipseItem());
}

int64_t qGraphicsEllipseItemCreateXYWH(double x, double y, double w, double h) {
    return reinterpret_cast<int64_t>(new QGraphicsEllipseItem(x, y, w, h));
}

void qGraphicsEllipseItemDelete(int64_t ptr) {
    delete reinterpret_cast<QGraphicsEllipseItem*>(ptr);
}

void qGraphicsEllipseItemSetRect(int64_t ptr, double x, double y, double w, double h) {
    reinterpret_cast<QGraphicsEllipseItem*>(ptr)->setRect(x, y, w, h);
}

const char* qGraphicsEllipseItemRect(int64_t ptr) {
    QRectF r = reinterpret_cast<QGraphicsEllipseItem*>(ptr)->rect();
    return cjqt6::dupUtf8(QString("(%1,%2,%3,%4)").arg(r.x()).arg(r.y()).arg(r.width()).arg(r.height()));
}

void qGraphicsEllipseItemSetStartAngle(int64_t ptr, int32_t angle) {
    reinterpret_cast<QGraphicsEllipseItem*>(ptr)->setStartAngle(angle);
}

void qGraphicsEllipseItemSetSpanAngle(int64_t ptr, int32_t angle) {
    reinterpret_cast<QGraphicsEllipseItem*>(ptr)->setSpanAngle(angle);
}

void qGraphicsEllipseItemSetPen(int64_t ptr, int32_t colorR, int32_t colorG, int32_t colorB, int32_t width) {
    reinterpret_cast<QGraphicsEllipseItem*>(ptr)->setPen(QPen(QColor(colorR, colorG, colorB), width));
}

void qGraphicsEllipseItemSetBrush(int64_t ptr, int32_t colorR, int32_t colorG, int32_t colorB) {
    reinterpret_cast<QGraphicsEllipseItem*>(ptr)->setBrush(QBrush(QColor(colorR, colorG, colorB)));
}

// ============================================================
// QGraphicsLineItem
// ============================================================

int64_t qGraphicsLineItemCreate() {
    return reinterpret_cast<int64_t>(new QGraphicsLineItem());
}

int64_t qGraphicsLineItemCreateLine(double x1, double y1, double x2, double y2) {
    return reinterpret_cast<int64_t>(new QGraphicsLineItem(x1, y1, x2, y2));
}

void qGraphicsLineItemDelete(int64_t ptr) {
    delete reinterpret_cast<QGraphicsLineItem*>(ptr);
}

void qGraphicsLineItemSetLine(int64_t ptr, double x1, double y1, double x2, double y2) {
    reinterpret_cast<QGraphicsLineItem*>(ptr)->setLine(x1, y1, x2, y2);
}

const char* qGraphicsLineItemLine(int64_t ptr) {
    QLineF l = reinterpret_cast<QGraphicsLineItem*>(ptr)->line();
    return cjqt6::dupUtf8(QString("(%1,%2,%3,%4)").arg(l.x1()).arg(l.y1()).arg(l.x2()).arg(l.y2()));
}

void qGraphicsLineItemSetPen(int64_t ptr, int32_t colorR, int32_t colorG, int32_t colorB, int32_t width) {
    reinterpret_cast<QGraphicsLineItem*>(ptr)->setPen(QPen(QColor(colorR, colorG, colorB), width));
}

// ============================================================
// QGraphicsTextItem
// ============================================================

int64_t qGraphicsTextItemCreate() {
    return reinterpret_cast<int64_t>(new QGraphicsTextItem());
}

int64_t qGraphicsTextItemCreateText(const char* text) {
    return reinterpret_cast<int64_t>(new QGraphicsTextItem(QString::fromUtf8(text)));
}

void qGraphicsTextItemDelete(int64_t ptr) {
    delete reinterpret_cast<QGraphicsTextItem*>(ptr);
}

void qGraphicsTextItemSetText(int64_t ptr, const char* text) {
    reinterpret_cast<QGraphicsTextItem*>(ptr)->setPlainText(QString::fromUtf8(text));
}

const char* qGraphicsTextItemText(int64_t ptr) {
    return cjqt6::dupUtf8(reinterpret_cast<QGraphicsTextItem*>(ptr)->toPlainText());
}

void qGraphicsTextItemSetHtml(int64_t ptr, const char* html) {
    reinterpret_cast<QGraphicsTextItem*>(ptr)->setHtml(QString::fromUtf8(html));
}

void qGraphicsTextItemSetFont(int64_t ptr, const char* family, double pointSize, bool bold) {
    QFont font(QString::fromUtf8(family), pointSize);
    font.setBold(bold);
    reinterpret_cast<QGraphicsTextItem*>(ptr)->setFont(font);
}

void qGraphicsTextItemSetTextWidth(int64_t ptr, double width) {
    reinterpret_cast<QGraphicsTextItem*>(ptr)->setTextWidth(width);
}

void qGraphicsTextItemSetDefaultTextColor(int64_t ptr, int32_t colorR, int32_t colorG, int32_t colorB) {
    reinterpret_cast<QGraphicsTextItem*>(ptr)->setDefaultTextColor(QColor(colorR, colorG, colorB));
}

// ============================================================
// QGraphicsPixmapItem
// ============================================================

int64_t qGraphicsPixmapItemCreate() {
    return reinterpret_cast<int64_t>(new QGraphicsPixmapItem());
}

int64_t qGraphicsPixmapItemCreatePixmap(int64_t pixmapPtr) {
    return reinterpret_cast<int64_t>(new QGraphicsPixmapItem(*reinterpret_cast<QPixmap*>(pixmapPtr)));
}

void qGraphicsPixmapItemDelete(int64_t ptr) {
    delete reinterpret_cast<QGraphicsPixmapItem*>(ptr);
}

void qGraphicsPixmapItemSetPixmap(int64_t ptr, int64_t pixmapPtr) {
    reinterpret_cast<QGraphicsPixmapItem*>(ptr)->setPixmap(*reinterpret_cast<QPixmap*>(pixmapPtr));
}

void qGraphicsPixmapItemSetOffset(int64_t ptr, double x, double y) {
    reinterpret_cast<QGraphicsPixmapItem*>(ptr)->setOffset(x, y);
}

// ============================================================
// QGraphicsPathItem
// ============================================================

int64_t qGraphicsPathItemCreate() {
    return reinterpret_cast<int64_t>(new QGraphicsPathItem());
}

void qGraphicsPathItemDelete(int64_t ptr) {
    delete reinterpret_cast<QGraphicsPathItem*>(ptr);
}

void qGraphicsPathItemSetPen(int64_t ptr, int32_t colorR, int32_t colorG, int32_t colorB, int32_t width) {
    reinterpret_cast<QGraphicsPathItem*>(ptr)->setPen(QPen(QColor(colorR, colorG, colorB), width));
}

void qGraphicsPathItemSetBrush(int64_t ptr, int32_t colorR, int32_t colorG, int32_t colorB) {
    reinterpret_cast<QGraphicsPathItem*>(ptr)->setBrush(QBrush(QColor(colorR, colorG, colorB)));
}

// ============================================================
// QGraphicsItemGroup
// ============================================================

int64_t qGraphicsItemGroupCreate() {
    return reinterpret_cast<int64_t>(new QGraphicsItemGroup());
}

void qGraphicsItemGroupDelete(int64_t ptr) {
    delete reinterpret_cast<QGraphicsItemGroup*>(ptr);
}

void qGraphicsItemGroupAddToGroup(int64_t ptr, int64_t itemPtr) {
    reinterpret_cast<QGraphicsItemGroup*>(ptr)->addToGroup(reinterpret_cast<QGraphicsItem*>(itemPtr));
}

void qGraphicsItemGroupRemoveFromGroup(int64_t ptr, int64_t itemPtr) {
    reinterpret_cast<QGraphicsItemGroup*>(ptr)->removeFromGroup(reinterpret_cast<QGraphicsItem*>(itemPtr));
}

} // extern "C"
