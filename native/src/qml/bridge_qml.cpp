/**
 * @file bridge_qml.cpp
 * @brief QML/Qt Quick 模块桥接函数 - QQmlApplicationEngine, QQuickView, QQuickWidget
 */

#include <QQuickWindow>
#include <QQuickView>
#include <QQuickWidget>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickItem>
#include <QUrl>
#include <QVariant>
#include <QDebug>

extern "C" {

// ============================================================
// QQmlApplicationEngine - QML应用引擎
// ============================================================

int64_t qQmlEngineCreate() {
    QQmlApplicationEngine* engine = new QQmlApplicationEngine();
    return reinterpret_cast<int64_t>(engine);
}

void qQmlEngineLoadFile(int64_t ptr, const char* filePath) {
    QQmlApplicationEngine* engine = reinterpret_cast<QQmlApplicationEngine*>(ptr);
    if (engine && filePath) {
        engine->load(QString::fromUtf8(filePath));
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
        QByteArray data(qmlData);
        engine->loadData(data);
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
    QQuickView* view = new QQuickView();
    return reinterpret_cast<int64_t>(view);
}

void qQuickViewSetSource(int64_t ptr, const char* source) {
    QQuickView* view = reinterpret_cast<QQuickView*>(ptr);
    if (view) {
        view->setSource(QUrl::fromLocalFile(source));
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

// ============================================================
// QQuickWidget - QML嵌入Widget
// ============================================================

int64_t qQuickWidgetCreate() {
    QQuickWidget* widget = new QQuickWidget();
    return reinterpret_cast<int64_t>(widget);
}

void qQuickWidgetSetSource(int64_t ptr, const char* source) {
    QQuickWidget* widget = reinterpret_cast<QQuickWidget*>(ptr);
    if (widget) {
        widget->setSource(QUrl::fromLocalFile(source));
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

int64_t qQuickItemFindChild(int64_t ptr, const char* name) {
    QQuickItem* item = reinterpret_cast<QQuickItem*>(ptr);
    if (item) {
        QQuickItem* child = item->findChild<QQuickItem*>(name);
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
        char* result = new char[str.size() + 1];
        strcpy(result, str.toUtf8().constData());
        return result;
    }
    char* empty = new char[1];
    empty[0] = '\0';
    return empty;
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
        delete[] str;
    }
}

} // extern "C"
