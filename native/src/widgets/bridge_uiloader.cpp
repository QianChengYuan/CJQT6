/**
 * @file bridge_uiloader.cpp
 * @brief Qt Designer .ui 文件加载桥接函数 - QUiLoader (QtUiTools 模块)
 */

#include <QUiLoader>
#include <QFile>
#include <QDir>
#include <QIODevice>
#include <QWidget>
#include <QDebug>
#include <cstring>
#include "bridge_string_utils.h"

extern "C" {

// ============================================================
// QUiLoader - Qt Designer .ui 文件加载器
// ============================================================

int64_t qUiLoaderCreate() {
    QUiLoader* loader = new QUiLoader();
    return reinterpret_cast<int64_t>(loader);
}

void qUiLoaderDelete(int64_t ptr) {
    QUiLoader* loader = reinterpret_cast<QUiLoader*>(ptr);
    if (loader) {
        delete loader;
    }
}

/**
 * @brief 加载 .ui 文件，返回根控件指针
 * @param ptr QUiLoader 指针
 * @param filePath .ui 文件路径（UTF-8）
 * @param parentPtr 父控件指针（0 表示无父，返回的控件作为独立顶层窗口）
 * @return 根控件指针，失败返回 0
 */
int64_t qUiLoaderLoadFile(int64_t ptr, const char* filePath, int64_t parentPtr) {
    QUiLoader* loader = reinterpret_cast<QUiLoader*>(ptr);
    if (!loader || !filePath) {
        return 0;
    }
    QFile file(QString::fromUtf8(filePath));
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "qUiLoaderLoadFile: cannot open file:" << filePath;
        return 0;
    }
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QWidget* widget = loader->load(&file, parent);
    if (!widget) {
        qWarning() << "qUiLoaderLoadFile: load failed:" << loader->errorString();
        return 0;
    }
    return reinterpret_cast<int64_t>(widget);
}

/**
 * @brief 设置工作目录（.ui 内相对路径资源基于此目录解析）
 */
void qUiLoaderSetWorkingDirectory(int64_t ptr, const char* dir) {
    QUiLoader* loader = reinterpret_cast<QUiLoader*>(ptr);
    if (loader && dir) {
        loader->setWorkingDirectory(QDir(QString::fromUtf8(dir)));
    }
}

/**
 * @brief 获取最近一次加载的错误信息
 */
const char* qUiLoaderErrorString(int64_t ptr) {
    QUiLoader* loader = reinterpret_cast<QUiLoader*>(ptr);
    if (!loader) {
        return cjqt6::emptyString();
    }
    return cjqt6::dupUtf8(loader->errorString());
}

// ============================================================
// QWidget::findChild - 按 objectName 递归查找子控件
// 说明：不直接使用 QObject::findChild（Qt 6.10+ 存在模板实例化链接问题），
// 与 qml 模块一致，改用 children() 递归遍历
// ============================================================

static QWidget* findWidgetChildByName(QObject* obj, const QString& name) {
    if (!obj) return nullptr;
    const QObjectList& children = obj->children();
    for (QObject* child : children) {
        QWidget* w = qobject_cast<QWidget*>(child);
        if (w) {
            if (w->objectName() == name) {
                return w;
            }
            QWidget* found = findWidgetChildByName(w, name);
            if (found) {
                return found;
            }
        }
    }
    return nullptr;
}

int64_t qWidgetFindChild(int64_t ptr, const char* name) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (!widget || !name) {
        return 0;
    }
    QWidget* child = findWidgetChildByName(widget, QString::fromUtf8(name));
    return reinterpret_cast<int64_t>(child);
}

} // extern "C"
