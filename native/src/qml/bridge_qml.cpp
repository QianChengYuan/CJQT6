/**
 * @file bridge_qml.cpp
 * @brief QML/Qt Quick 模块桥接函数 - QQmlApplicationEngine, QQuickView, QQuickWidget
 */

#include <QQuickWindow>
#include <QQuickView>
#include <QQuickWidget>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickItem>
#include <QUrl>
#include <QVariant>
#include <QColor>
#include <QDebug>
#include <QFileInfo>
#include <QCoreApplication>
#include <QSurfaceFormat>
#include <cstdlib>
#include <cstring>
#include "bridge_string_utils.h"

extern "C" {

// ============================================================
// QQmlApplicationEngine - QML应用引擎
// ============================================================

int64_t qQmlEngineCreate() {
    QQmlApplicationEngine* engine = new QQmlApplicationEngine();
    qDebug() << "QQmlApplicationEngine created:" << (void*)engine;
    return reinterpret_cast<int64_t>(engine);
}

void qQmlEngineLoadFile(int64_t ptr, const char* filePath) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    if (engine && filePath) {
        qDebug() << "Loading QML file:" << filePath;
        // 相对路径转绝对路径（基于当前工作目录），避免 QUrl::fromLocalFile 生成相对 URL 导致加载失败
        QUrl url = QUrl::fromLocalFile(QFileInfo(QString::fromUtf8(filePath)).absoluteFilePath());
        qDebug() << "URL:" << url;
        engine->load(url);
        qDebug() << "Root objects after loadFile:" << engine->rootObjects().size();
        if (!engine->rootObjects().isEmpty()) {
            qDebug() << "First root object:" << engine->rootObjects().first();
        }
    }
}

void qQmlEngineShowRootWindow(int64_t ptr) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    qDebug() << "qQmlEngineShowRootWindow called, engine:" << (void*)engine;
    
    if (!engine) {
        qWarning() << "Engine is null";
        return;
    }
    
    qDebug() << "Root objects count:" << engine->rootObjects().size();
    
    if (engine->rootObjects().isEmpty()) {
        qWarning() << "No root objects to show";
        return;
    }
    
    QObject* root = engine->rootObjects().first();
    qDebug() << "Root object:" << root << "metaObject:" << (root ? root->metaObject()->className() : "null");
    
    QQuickWindow* window = qobject_cast<QQuickWindow*>(root);
    qDebug() << "Cast to QQuickWindow:" << window;
    
    if (window) {
        qDebug() << "Showing window...";
        window->show();
        window->raise();
        window->requestActivate();
        qDebug() << "Window shown, visible:" << window->isVisible();
    } else {
        qWarning() << "Root object is not a QQuickWindow";
    }
}

void qQmlEngineLoadUrl(int64_t ptr, const char* url) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    if (engine) {
        engine->load(QUrl(url));
    }
}

void qQmlEngineLoadData(int64_t ptr, const char* qmlData) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    if (engine && qmlData) {
        qDebug() << "Loading QML data, length:" << strlen(qmlData);
        QByteArray data(qmlData);
        // 需要提供 URL 以便正确解析 import
        QUrl url("qrc:/inline.qml");
        qDebug() << "Calling loadData...";
        engine->loadData(data, url);
        qDebug() << "loadData returned";
        qDebug() << "Root objects after loadData:" << engine->rootObjects().size();
        if (!engine->rootObjects().isEmpty()) {
            QObject* root = engine->rootObjects().first();
            qDebug() << "First root object:" << root << "type:" << (root ? root->metaObject()->className() : "null");
        }
    }
}

void qQmlEngineClearComponentCache(int64_t ptr) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    if (engine) {
        engine->clearComponentCache();
    }
}

int64_t qQmlEngineRootObjects(int64_t ptr) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    if (engine && !engine->rootObjects().isEmpty()) {
        return reinterpret_cast<int64_t>(engine->rootObjects().first());
    }
    return 0;
}

int32_t qQmlEngineRootObjectsCount(int64_t ptr) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    if (engine) {
        return engine->rootObjects().size();
    }
    return 0;
}

void qQmlEngineSetContextProperty(int64_t ptr, const char* name, int64_t valuePtr) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    if (engine) {
        QObject* obj = reinterpret_cast<QObject*>(valuePtr);
        engine->rootContext()->setContextProperty(name, QVariant::fromValue(obj));
    }
}

void qQmlEngineSetContextPropertyString(int64_t ptr, const char* name, const char* value) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    if (engine) {
        engine->rootContext()->setContextProperty(name, QString(value));
    }
}

void qQmlEngineSetContextPropertyInt(int64_t ptr, const char* name, int32_t value) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    if (engine) {
        engine->rootContext()->setContextProperty(name, value);
    }
}

void qQmlEngineSetContextPropertyDouble(int64_t ptr, const char* name, double value) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    if (engine) {
        engine->rootContext()->setContextProperty(name, value);
    }
}

void qQmlEngineSetContextPropertyBool(int64_t ptr, const char* name, int32_t value) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    if (engine) {
        engine->rootContext()->setContextProperty(name, value != 0);
    }
}

void qQmlEngineAddImportPath(int64_t ptr, const char* path) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    if (engine) {
        engine->addImportPath(path);
    }
}

int64_t qQmlEngineRootContext(int64_t ptr) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    if (engine) {
        return reinterpret_cast<int64_t>(engine->rootContext());
    }
    return 0;
}

void qQmlEngineDelete(int64_t ptr) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    if (engine) {
        delete engine;
    }
}

// ============================================================
// QQuickView - QML视图窗口
// ============================================================

int64_t qQuickViewCreate() {
    qDebug() << "qQuickViewCreate called";
    
    // 检查QApplication是否存在
    if (!QCoreApplication::instance()) {
        qWarning() << "QQuickView requires QApplication instance";
        return 0;
    }
    
    qDebug() << "QApplication exists, creating QQuickView...";
    
    QQuickView* view = nullptr;
    try {
        view = new QQuickView();
        qDebug() << "QQuickView new returned:" << (void*)view;
    } catch (const std::exception& e) {
        qCritical() << "Exception creating QQuickView:" << e.what();
        return 0;
    } catch (...) {
        qCritical() << "Unknown exception creating QQuickView";
        return 0;
    }
    
    if (!view) {
        qWarning() << "Failed to create QQuickView (null pointer)";
        return 0;
    }
    
    qDebug() << "QQuickView created successfully:" << (void*)view;
    return reinterpret_cast<int64_t>(view);
}

void qQuickViewSetSource(int64_t ptr, const char* source) {
    QQuickView* view = reinterpret_cast<QQuickView*>(ptr);
    if (view) {
        view->setSource(QUrl::fromLocalFile(QFileInfo(QString::fromUtf8(source)).absoluteFilePath()));
    }
}

void qQuickViewSetSourceUrl(int64_t ptr, const char* url) {
    QQuickView* view = reinterpret_cast<QQuickView*>(ptr);
    if (view) {
        view->setSource(QUrl(url));
    }
}

void qQuickViewShow(int64_t ptr) {
    QQuickView* view = reinterpret_cast<QQuickView*>(ptr);
    if (view) {
        view->show();
    }
}

void qQuickViewHide(int64_t ptr) {
    QQuickView* view = reinterpret_cast<QQuickView*>(ptr);
    if (view) {
        view->hide();
    }
}

void qQuickViewSetTitle(int64_t ptr, const char* title) {
    QQuickView* view = reinterpret_cast<QQuickView*>(ptr);
    if (view) {
        view->setTitle(title);
    }
}

void qQuickViewResize(int64_t ptr, int32_t width, int32_t height) {
    QQuickView* view = reinterpret_cast<QQuickView*>(ptr);
    if (view) {
        view->resize(width, height);
    }
}

int64_t qQuickViewRootObject(int64_t ptr) {
    QQuickView* view = reinterpret_cast<QQuickView*>(ptr);
    if (view) {
        return reinterpret_cast<int64_t>(view->rootObject());
    }
    return 0;
}

void qQuickViewSetResizeMode(int64_t ptr, int32_t mode) {
    QQuickView* view = reinterpret_cast<QQuickView*>(ptr);
    if (view) {
        view->setResizeMode(static_cast<QQuickView::ResizeMode>(mode));
    }
}

void qQuickViewDelete(int64_t ptr) {
    QQuickView* view = reinterpret_cast<QQuickView*>(ptr);
    if (view) {
        delete view;
    }
}

int32_t qQuickViewStatus(int64_t ptr) {
    QQuickView* view = reinterpret_cast<QQuickView*>(ptr);
    if (view) {
        return static_cast<int32_t>(view->status());
    }
    return 0;  // Null
}

int32_t qQuickViewErrors(int64_t ptr) {
    QQuickView* view = reinterpret_cast<QQuickView*>(ptr);
    if (view) {
        return view->errors().isEmpty() ? 0 : 1;
    }
    return 1;
}

int64_t qQuickViewEngine(int64_t ptr) {
    QQuickView* view = reinterpret_cast<QQuickView*>(ptr);
    if (view && view->engine()) {
        return reinterpret_cast<int64_t>(view->engine());
    }
    return 0;
}

// ============================================================
// QQuickWidget - QML嵌入Widget
// ============================================================

int64_t qQuickWidgetCreate() {
    try {
        // 检查QApplication是否存在
        if (!QCoreApplication::instance()) {
            qWarning() << "QQuickWidget requires QApplication instance";
            return 0;
        }
        
        QQuickWidget* widget = new QQuickWidget();
        if (!widget) {
            qWarning() << "Failed to create QQuickWidget";
            return 0;
        }
        
        qDebug() << "QQuickWidget created successfully:" << (void*)widget;
        return reinterpret_cast<int64_t>(widget);
    } catch (const std::exception& e) {
        qCritical() << "Exception creating QQuickWidget:" << e.what();
        return 0;
    } catch (...) {
        qCritical() << "Unknown exception creating QQuickWidget";
        return 0;
    }
}

void qQuickWidgetSetSource(int64_t ptr, const char* source) {
    QQuickWidget* widget = reinterpret_cast<QQuickWidget*>(ptr);
    if (widget) {
        widget->setSource(QUrl::fromLocalFile(QFileInfo(QString::fromUtf8(source)).absoluteFilePath()));
    }
}

void qQuickWidgetSetSourceUrl(int64_t ptr, const char* url) {
    QQuickWidget* widget = reinterpret_cast<QQuickWidget*>(ptr);
    if (widget) {
        widget->setSource(QUrl(url));
    }
}

void qQuickWidgetShow(int64_t ptr) {
    QQuickWidget* widget = reinterpret_cast<QQuickWidget*>(ptr);
    if (widget) {
        widget->show();
    }
}

void qQuickWidgetResize(int64_t ptr, int32_t width, int32_t height) {
    QQuickWidget* widget = reinterpret_cast<QQuickWidget*>(ptr);
    if (widget) {
        widget->resize(width, height);
    }
}

int64_t qQuickWidgetRootObject(int64_t ptr) {
    QQuickWidget* widget = reinterpret_cast<QQuickWidget*>(ptr);
    if (widget) {
        return reinterpret_cast<int64_t>(widget->rootObject());
    }
    return 0;
}

void qQuickWidgetSetResizeMode(int64_t ptr, int32_t mode) {
    QQuickWidget* widget = reinterpret_cast<QQuickWidget*>(ptr);
    if (widget) {
        widget->setResizeMode(static_cast<QQuickWidget::ResizeMode>(mode));
    }
}

int64_t qQuickWidgetGetPtr(int64_t ptr) {
    return ptr;  // 用于布局
}

void qQuickWidgetDelete(int64_t ptr) {
    QQuickWidget* widget = reinterpret_cast<QQuickWidget*>(ptr);
    if (widget) {
        delete widget;
    }
}

int64_t qQuickWidgetEngine(int64_t ptr) {
    QQuickWidget* widget = reinterpret_cast<QQuickWidget*>(ptr);
    if (widget && widget->engine()) {
        return reinterpret_cast<int64_t>(widget->engine());
    }
    return 0;
}

// ============================================================
// QQuickItem - QML项操作
// ============================================================

void qQuickItemSetVisible(int64_t ptr, int32_t visible) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        item->setVisible(visible != 0);
    }
}

int32_t qQuickItemIsVisible(int64_t ptr) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        return item->isVisible() ? 1 : 0;
    }
    return 0;
}

void qQuickItemSetEnabled(int64_t ptr, int32_t enabled) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        item->setEnabled(enabled != 0);
    }
}

int32_t qQuickItemIsEnabled(int64_t ptr) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        return item->isEnabled() ? 1 : 0;
    }
    return 0;
}

void qQuickItemSetX(int64_t ptr, float x) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        item->setX(x);
    }
}

void qQuickItemSetY(int64_t ptr, float y) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        item->setY(y);
    }
}

void qQuickItemSetWidth(int64_t ptr, float width) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        item->setWidth(width);
    }
}

void qQuickItemSetHeight(int64_t ptr, float height) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        item->setHeight(height);
    }
}

float qQuickItemX(int64_t ptr) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        return item->x();
    }
    return 0;
}

float qQuickItemY(int64_t ptr) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        return item->y();
    }
    return 0;
}

float qQuickItemWidth(int64_t ptr) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        return item->width();
    }
    return 0;
}

float qQuickItemHeight(int64_t ptr) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        return item->height();
    }
    return 0;
}

// 递归在 QObject 子对象树中按 objectName 查找 QQuickItem。
// 不使用 QObject::findChild，以避免对 Qt 内部符号 qt_qFindChild_helper 的依赖
// （该符号在 Qt 6.10+ 运行时中已不再导出，会导致 bridge 加载失败）。
static QQuickItem* findQuickChildByName(QObject* obj, const QString& name) {
    if (!obj) return nullptr;
    const QObjectList& children = obj->children();
    for (QObject* child : children) {
        if (child->objectName() == name) {
            QQuickItem* qi = qobject_cast<QQuickItem*>(child);
            if (qi) return qi;
        }
    }
    for (QObject* child : children) {
        QQuickItem* qi = qobject_cast<QQuickItem*>(child);
        if (qi) {
            QQuickItem* found = findQuickChildByName(qi, name);
            if (found) return found;
        }
    }
    return nullptr;
}

int64_t qQuickItemFindChild(int64_t ptr, const char* name) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        QQuickItem* child = findQuickChildByName(item, QString::fromUtf8(name));
        return reinterpret_cast<int64_t>(child);
    }
    return 0;
}

// ============================================================
// QML属性操作
// ============================================================

void qQuickItemSetPropertyString(int64_t ptr, const char* name, const char* value) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        item->setProperty(name, value);
    }
}

void qQuickItemSetPropertyInt(int64_t ptr, const char* name, int32_t value) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        item->setProperty(name, value);
    }
}

void qQuickItemSetPropertyDouble(int64_t ptr, const char* name, double value) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        item->setProperty(name, value);
    }
}

void qQuickItemSetPropertyBool(int64_t ptr, const char* name, int32_t value) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        item->setProperty(name, value != 0);
    }
}

// 获取属性值（返回字符串表示）
char* qQuickItemGetPropertyString(int64_t ptr, const char* name) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        QVariant value = item->property(name);
        QString str = value.toString();
        return cjqt6::dupUtf8(str);
    }
    return cjqt6::emptyString();
}

int32_t qQuickItemGetPropertyInt(int64_t ptr, const char* name) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        return item->property(name).toInt();
    }
    return 0;
}

double qQuickItemGetPropertyDouble(int64_t ptr, const char* name) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        return item->property(name).toDouble();
    }
    return 0.0;
}

int32_t qQuickItemGetPropertyBool(int64_t ptr, const char* name) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        return item->property(name).toBool() ? 1 : 0;
    }
    return 0;
}

void qQuickItemFreeString(char* str) {
    if (str) {
        std::free(str);
    }
}

// ============================================================
// QQuickItem 属性扩展 - opacity / rotation / scale / z / objectName / focus / parentItem
// ============================================================

void qQuickItemSetOpacity(int64_t ptr, float opacity) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        item->setOpacity(opacity);
    }
}

float qQuickItemOpacity(int64_t ptr) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        return static_cast<float>(item->opacity());
    }
    return 1.0f;
}

void qQuickItemSetRotation(int64_t ptr, float rotation) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        item->setRotation(rotation);
    }
}

float qQuickItemRotation(int64_t ptr) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        return static_cast<float>(item->rotation());
    }
    return 0.0f;
}

void qQuickItemSetScale(int64_t ptr, float scale) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        item->setScale(scale);
    }
}

float qQuickItemScale(int64_t ptr) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        return static_cast<float>(item->scale());
    }
    return 1.0f;
}

void qQuickItemSetZ(int64_t ptr, float z) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        item->setZ(z);
    }
}

float qQuickItemZ(int64_t ptr) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        return static_cast<float>(item->z());
    }
    return 0.0f;
}

void qQuickItemSetObjectName(int64_t ptr, const char* name) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item && name) {
        item->setObjectName(QString::fromUtf8(name));
    }
}

char* qQuickItemObjectName(int64_t ptr) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        QByteArray ba = item->objectName().toUtf8();
        return cjqt6::dupUtf8(ba);
    }
    return cjqt6::emptyString();
}

void qQuickItemSetFocus(int64_t ptr, int32_t focus) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        item->setFocus(focus != 0);
    }
}

int32_t qQuickItemHasFocus(int64_t ptr) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        return item->hasFocus() ? 1 : 0;
    }
    return 0;
}

void qQuickItemSetParentItem(int64_t ptr, int64_t parentPtr) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    QQuickItem* parent = reinterpret_cast<QQuickItem*>(parentPtr);
    if (item) {
        item->setParentItem(parent);
    }
}

int64_t qQuickItemParentItem(int64_t ptr) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        return reinterpret_cast<int64_t>(item->parentItem());
    }
    return 0;
}

int64_t qQuickItemCreate() {
    QQuickItem* item = new QQuickItem();
    return reinterpret_cast<int64_t>(item);
}

void qQuickItemDelete(int64_t ptr) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        delete item;
    }
}

// ============================================================
// QQmlComponent - QML组件
// ============================================================

int64_t qQmlComponentCreate(int64_t enginePtr) {
    QQmlEngine* engine = reinterpret_cast<QQmlEngine*>(enginePtr);
    QQmlComponent* comp = new QQmlComponent(engine);
    return reinterpret_cast<int64_t>(comp);
}

void qQmlComponentLoadUrl(int64_t ptr, const char* url) {
    QQmlComponent* comp = reinterpret_cast<QQmlComponent*>(ptr);
    if (comp && url) {
        comp->loadUrl(QUrl(url));
    }
}

void qQmlComponentSetData(int64_t ptr, const char* data, const char* url) {
    QQmlComponent* comp = reinterpret_cast<QQmlComponent*>(ptr);
    if (comp && data) {
        QUrl baseUrl = (url && url[0] != '\0') ? QUrl(url) : QUrl("qrc:/inline.qml");
        comp->setData(QByteArray(data), baseUrl);
    }
}

int32_t qQmlComponentStatus(int64_t ptr) {
    QQmlComponent* comp = reinterpret_cast<QQmlComponent*>(ptr);
    if (comp) {
        return static_cast<int32_t>(comp->status());
    }
    return 0;
}

int32_t qQmlComponentIsReady(int64_t ptr) {
    QQmlComponent* comp = reinterpret_cast<QQmlComponent*>(ptr);
    if (comp) {
        return comp->isReady() ? 1 : 0;
    }
    return 0;
}

int32_t qQmlComponentIsError(int64_t ptr) {
    QQmlComponent* comp = reinterpret_cast<QQmlComponent*>(ptr);
    if (comp) {
        return comp->isError() ? 1 : 0;
    }
    return 0;
}

char* qQmlComponentErrorString(int64_t ptr) {
    QQmlComponent* comp = reinterpret_cast<QQmlComponent*>(ptr);
    if (comp) {
        QByteArray ba = comp->errorString().toUtf8();
        return cjqt6::dupUtf8(ba);
    }
    return cjqt6::emptyString();
}

int64_t qQmlComponentCreateObject(int64_t ptr, int64_t contextPtr, int64_t parentPtr) {
    QQmlComponent* comp = reinterpret_cast<QQmlComponent*>(ptr);
    if (comp) {
        QQmlContext* context = reinterpret_cast<QQmlContext*>(contextPtr);
        QObject* parent = reinterpret_cast<QObject*>(parentPtr);
        QObject* obj = comp->create(context);
        if (obj && parent) {
            obj->setParent(parent);
        }
        return reinterpret_cast<int64_t>(obj);
    }
    return 0;
}

void qQmlComponentDelete(int64_t ptr) {
    QQmlComponent* comp = reinterpret_cast<QQmlComponent*>(ptr);
    if (comp) {
        delete comp;
    }
}

// ============================================================
// QQmlContext - QML上下文
// ============================================================

int64_t qQmlContextCreate(int64_t parentContextPtr) {
    QQmlContext* parent = reinterpret_cast<QQmlContext*>(parentContextPtr);
    QQmlContext* ctx = new QQmlContext(parent);
    return reinterpret_cast<int64_t>(ctx);
}

void qQmlContextSetContextProperty(int64_t ptr, const char* name, int64_t valuePtr) {
    QQmlContext* ctx = reinterpret_cast<QQmlContext*>(ptr);
    if (ctx && name) {
        QObject* obj = reinterpret_cast<QObject*>(valuePtr);
        ctx->setContextProperty(name, QVariant::fromValue(obj));
    }
}

void qQmlContextSetContextPropertyString(int64_t ptr, const char* name, const char* value) {
    QQmlContext* ctx = reinterpret_cast<QQmlContext*>(ptr);
    if (ctx && name) {
        ctx->setContextProperty(name, QString(value));
    }
}

void qQmlContextSetContextPropertyInt(int64_t ptr, const char* name, int32_t value) {
    QQmlContext* ctx = reinterpret_cast<QQmlContext*>(ptr);
    if (ctx && name) {
        ctx->setContextProperty(name, value);
    }
}

void qQmlContextSetContextPropertyDouble(int64_t ptr, const char* name, double value) {
    QQmlContext* ctx = reinterpret_cast<QQmlContext*>(ptr);
    if (ctx && name) {
        ctx->setContextProperty(name, value);
    }
}

void qQmlContextSetContextPropertyBool(int64_t ptr, const char* name, int32_t value) {
    QQmlContext* ctx = reinterpret_cast<QQmlContext*>(ptr);
    if (ctx && name) {
        ctx->setContextProperty(name, value != 0);
    }
}

void qQmlContextSetContextObject(int64_t ptr, int64_t objPtr) {
    QQmlContext* ctx = reinterpret_cast<QQmlContext*>(ptr);
    if (ctx) {
        QObject* obj = reinterpret_cast<QObject*>(objPtr);
        ctx->setContextObject(obj);
    }
}

int64_t qQmlContextContextObject(int64_t ptr) {
    QQmlContext* ctx = reinterpret_cast<QQmlContext*>(ptr);
    if (ctx) {
        return reinterpret_cast<int64_t>(ctx->contextObject());
    }
    return 0;
}

int64_t qQmlContextParentContext(int64_t ptr) {
    QQmlContext* ctx = reinterpret_cast<QQmlContext*>(ptr);
    if (ctx) {
        return reinterpret_cast<int64_t>(ctx->parentContext());
    }
    return 0;
}

void qQmlContextDelete(int64_t ptr) {
    QQmlContext* ctx = reinterpret_cast<QQmlContext*>(ptr);
    if (ctx) {
        delete ctx;
    }
}

// ============================================================
// QQuickWindow - QML窗口
// ============================================================

int64_t qQuickWindowCreate() {
    if (!QCoreApplication::instance()) {
        qWarning() << "QQuickWindow requires QApplication instance";
        return 0;
    }
    QQuickWindow* win = new QQuickWindow();
    return reinterpret_cast<int64_t>(win);
}

void qQuickWindowShow(int64_t ptr) {
    QQuickWindow* win = reinterpret_cast<QQuickWindow*>(ptr);
    if (win) {
        win->show();
    }
}

void qQuickWindowHide(int64_t ptr) {
    QQuickWindow* win = reinterpret_cast<QQuickWindow*>(ptr);
    if (win) {
        win->hide();
    }
}

void qQuickWindowSetTitle(int64_t ptr, const char* title) {
    QQuickWindow* win = reinterpret_cast<QQuickWindow*>(ptr);
    if (win && title) {
        win->setTitle(QString::fromUtf8(title));
    }
}

void qQuickWindowResize(int64_t ptr, int32_t width, int32_t height) {
    QQuickWindow* win = reinterpret_cast<QQuickWindow*>(ptr);
    if (win) {
        win->resize(width, height);
    }
}

int32_t qQuickWindowWidth(int64_t ptr) {
    QQuickWindow* win = reinterpret_cast<QQuickWindow*>(ptr);
    if (win) {
        return win->width();
    }
    return 0;
}

int32_t qQuickWindowHeight(int64_t ptr) {
    QQuickWindow* win = reinterpret_cast<QQuickWindow*>(ptr);
    if (win) {
        return win->height();
    }
    return 0;
}

void qQuickWindowSetColor(int64_t ptr, int32_t r, int32_t g, int32_t b, int32_t a) {
    QQuickWindow* win = reinterpret_cast<QQuickWindow*>(ptr);
    if (win) {
        win->setColor(QColor(r, g, b, a));
    }
}

int32_t qQuickWindowIsVisible(int64_t ptr) {
    QQuickWindow* win = reinterpret_cast<QQuickWindow*>(ptr);
    if (win) {
        return win->isVisible() ? 1 : 0;
    }
    return 0;
}

int64_t qQuickWindowContentItem(int64_t ptr) {
    QQuickWindow* win = reinterpret_cast<QQuickWindow*>(ptr);
    if (win) {
        return reinterpret_cast<int64_t>(win->contentItem());
    }
    return 0;
}

void qQuickWindowDelete(int64_t ptr) {
    QQuickWindow* win = reinterpret_cast<QQuickWindow*>(ptr);
    if (win) {
        delete win;
    }
}

} // extern "C"
