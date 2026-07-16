/**
 * @file bridge_core.cpp
 * @brief 核心模块桥接函数 - QApplication, QWidget, QTimer
 */

#include <QApplication>
#include <QWidget>
#include <QTimer>
#include <QDebug>
#include <QTranslator>
#include <QLocale>
#include <QDir>
#include <QLibraryInfo>
#include <functional>
#include <unordered_map>

// 全局应用程序指针
static QApplication* g_app = nullptr;

// 全局翻译器
static QTranslator* g_qtTranslator = nullptr;
static QTranslator* g_appTranslator = nullptr;

// 回调函数映射 - 非static，供其他模块使用
std::unordered_map<int64_t, std::function<void(int64_t)>> g_buttonCallbacks;
std::unordered_map<int64_t, std::function<void(int64_t)>> g_timerCallbacks;

extern "C" {

// ============================================================
// QApplication 桥接函数
// ============================================================

int64_t qApplicationCreate() {
    if (!g_app) {
        // 注释掉软件渲染，尝试使用 OpenGL
        // qputenv("QSG_RHI_BACKEND", "software");
        // qputenv("QT_QUICK_BACKEND", "software");
        
        int argc = 0;
        g_app = new QApplication(argc, nullptr);
    }
    return reinterpret_cast<int64_t>(g_app);
}

int32_t qApplicationExec() {
    if (g_app) {
        return g_app->exec();
    }
    return -1;
}

void qApplicationQuit() {
    if (g_app) {
        g_app->quit();
    }
}

void qApplicationDelete(int64_t ptr) {
    // 不删除全局 QApplication
}

// ============================================================
// QWidget 桥接函数
// ============================================================

int64_t qWidgetCreate() {
    QWidget* widget = new QWidget();
    qDebug() << "qWidgetCreate, ptr:" << (void*)widget;
    return reinterpret_cast<int64_t>(widget);
}

void qWidgetShow(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    qDebug() << "qWidgetShow called, ptr:" << (void*)widget;
    if (widget) {
        widget->show();
        widget->activateWindow();
        widget->raise();
        qDebug() << "Widget shown, visible:" << widget->isVisible();
    }
}

void qWidgetHide(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->hide();
    }
}

void qWidgetSetTitle(int64_t ptr, const char* title) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setWindowTitle(title);
    }
}

void qWidgetResize(int64_t ptr, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->resize(width, height);
    }
}

void qWidgetSetGeometry(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setGeometry(x, y, width, height);
    }
}

void qWidgetSetParent(int64_t ptr, int64_t parentPtr) {
    QWidget* child = reinterpret_cast<QWidget*>(ptr);
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    if (child && parent) {
        child->setParent(parent);
    }
}

void qWidgetSetLayout(int64_t widgetPtr, int64_t layoutPtr) {
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    QLayout* layout = reinterpret_cast<QLayout*>(layoutPtr);
    if (widget && layout) {
        widget->setLayout(layout);
    }
}

void qWidgetDelete(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        delete widget;
    }
}

// ============================================================
// QTimer 桥接函数
// ============================================================

int64_t qTimerCreate() {
    QTimer* timer = new QTimer();
    return reinterpret_cast<int64_t>(timer);
}

void qTimerSetInterval(int64_t ptr, int32_t interval) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        timer->setInterval(interval);
    }
}

void qTimerStart(int64_t ptr) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        timer->start();
    }
}

void qTimerStop(int64_t ptr) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        timer->stop();
    }
}

void qTimerSetTimeout(int64_t ptr, void (*callback)(int64_t)) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        int64_t timerPtr = ptr;
        g_timerCallbacks[ptr] = [callback, timerPtr](int64_t) { callback(timerPtr); };
        QObject::connect(timer, &QTimer::timeout, [timerPtr]() {
            auto it = g_timerCallbacks.find(timerPtr);
            if (it != g_timerCallbacks.end()) {
                it->second(timerPtr);
            }
        });
    }
}

void qTimerDelete(int64_t ptr) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        g_timerCallbacks.erase(ptr);
        delete timer;
    }
}

// ============================================================
// QWidget 样式表支持
// ============================================================

void qWidgetSetStyleSheet(int64_t ptr, const char* styleSheet) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setStyleSheet(QString::fromUtf8(styleSheet));
    }
}

const char* qWidgetStyleSheet(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        static QByteArray styleSheet;
        styleSheet = widget->styleSheet().toUtf8();
        return styleSheet.constData();
    }
    return "";
}

void qWidgetSetEnabled(int64_t ptr, int32_t enabled) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setEnabled(enabled != 0);
    }
}

int32_t qWidgetIsEnabled(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        return widget->isEnabled() ? 1 : 0;
    }
    return 0;
}

void qWidgetSetVisible(int64_t ptr, int32_t visible) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setVisible(visible != 0);
    }
}

int32_t qWidgetIsVisible(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        return widget->isVisible() ? 1 : 0;
    }
    return 0;
}

void qWidgetSetToolTip(int64_t ptr, const char* toolTip) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setToolTip(QString::fromUtf8(toolTip));
    }
}

void qWidgetSetMinimumSize(int64_t ptr, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setMinimumSize(width, height);
    }
}

void qWidgetSetMaximumSize(int64_t ptr, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setMaximumSize(width, height);
    }
}

int32_t qWidgetWidth(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        return widget->width();
    }
    return 0;
}

int32_t qWidgetHeight(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        return widget->height();
    }
    return 0;
}

void qWidgetUpdate(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->update();
    }
}

void qWidgetRepaint(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->repaint();
    }
}

// ============================================================
// 翻译/语言相关函数
// ============================================================

// 加载Qt内置翻译（用于对话框等）
bool qApplicationLoadQtTranslation(const char* locale) {
    if (!g_app) return false;
    
    // 删除旧的翻译器
    if (g_qtTranslator) {
        g_app->removeTranslator(g_qtTranslator);
        delete g_qtTranslator;
    }
    
    g_qtTranslator = new QTranslator();
    
    QString localeStr = QString::fromUtf8(locale);
    if (localeStr.isEmpty()) {
        localeStr = QLocale::system().name();  // 例如 "zh_CN"
    }
    
    // 尝试从多个路径加载Qt翻译文件
    QStringList searchPaths;
    
    // 常见的Qt翻译文件路径
    searchPaths << "/usr/share/qt6/translations"
                << "/usr/share/qt/translations"
                << "/usr/lib/qt6/translations"
                << "/usr/lib/qt/translations"
                << "/opt/qt6/translations"
                << QLibraryInfo::path(QLibraryInfo::TranslationsPath);
    
    // 尝试多种文件名格式
    QStringList filePatterns;
    filePatterns << QString("qtbase_%1").arg(localeStr)           // qtbase_zh_CN
                 << QString("qtbase_%1").arg(localeStr.left(2))   // qtbase_zh
                 << QString("qt_%1").arg(localeStr)               // qt_zh_CN
                 << QString("qt_%1").arg(localeStr.left(2));      // qt_zh
    
    for (const QString& path : searchPaths) {
        for (const QString& pattern : filePatterns) {
            QString qmFile = QString("%1.qm").arg(pattern);
            QString fullPath = QString("%1/%2").arg(path).arg(qmFile);
            if (QFile::exists(fullPath)) {
                if (g_qtTranslator->load(qmFile, path)) {
                    g_app->installTranslator(g_qtTranslator);
                    return true;
                }
            }
        }
    }
    
    // 尝试直接加载（从系统路径）
    for (const QString& pattern : filePatterns) {
        QString qmFile = QString("%1.qm").arg(pattern);
        if (g_qtTranslator->load(qmFile)) {
            g_app->installTranslator(g_qtTranslator);
            return true;
        }
    }
    
    delete g_qtTranslator;
    g_qtTranslator = nullptr;
    return false;
}

// 加载应用程序翻译
bool qApplicationLoadAppTranslation(const char* qmFile, const char* directory) {
    if (!g_app) return false;
    
    // 删除旧的翻译器
    if (g_appTranslator) {
        g_app->removeTranslator(g_appTranslator);
        delete g_appTranslator;
    }
    
    g_appTranslator = new QTranslator();
    
    QString qmPath = QString::fromUtf8(qmFile);
    QString dir = QString::fromUtf8(directory);
    
    if (g_appTranslator->load(qmPath, dir.isEmpty() ? QString() : dir)) {
        g_app->installTranslator(g_appTranslator);
        return true;
    }
    
    delete g_appTranslator;
    g_appTranslator = nullptr;
    return false;
}

// 设置应用程序语言环境
void qApplicationSetLocale(const char* locale) {
    QString localeStr = QString::fromUtf8(locale);
    if (localeStr.isEmpty()) {
        QLocale::setDefault(QLocale::system());
    } else {
        QLocale::setDefault(QLocale(localeStr));
    }
}

// 获取当前语言环境
const char* qApplicationLocale() {
    static QByteArray buffer;
    buffer = QLocale().name().toUtf8();  // 例如 "zh_CN"
    return buffer.constData();
}

// 获取系统语言环境
const char* qApplicationSystemLocale() {
    static QByteArray buffer;
    buffer = QLocale::system().name().toUtf8();
    return buffer.constData();
}

// 切换语言（同时加载Qt翻译）
bool qApplicationSwitchLanguage(const char* locale) {
    QString localeStr = QString::fromUtf8(locale);
    
    if (localeStr.isEmpty()) {
        // 恢复系统默认
        QLocale::setDefault(QLocale::system());
    } else {
        QLocale::setDefault(QLocale(localeStr));
    }
    
    // 加载Qt翻译
    return qApplicationLoadQtTranslation(locale);
}

} // extern "C"

