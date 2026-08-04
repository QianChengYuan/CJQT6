/**
 * @file bridge_core.cpp
 * @brief 核心模块桥接函数 - QApplication, QWidget, QTimer
 */

#include <QApplication>
#include <QClipboard>
#include <QDebug>
#include <QDesktopServices>
#include <QDir>
#include <QFileSystemWatcher>
#include <QGuiApplication>
#include <functional>
#include <QLibraryInfo>
#include <QLocale>
#include <QPropertyAnimation>
#include <QScreen>
#include <QSettings>
#include <QShortcut>
#include <QStandardPaths>
#include <QTimer>
#include <QTranslator>
#include <QUrl>
#include <QWidget>
#include <unordered_map>
#include <exception>
#include <cstdio>

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

        // 注意：QApplication(int&, char**) 不能传 argv=nullptr，否则 Qt 在解析
        // 命令行/初始化平台插件时可能越界访问 argv[0]，触发 /GS 栈保护
        // (__fastfail STATUS_FAIL_FAST_FATAL_STACK_BUFFER_OVERRUN = 0xC0000409)。
        // 必须给出合法的 argv[0]。
        static int s_argc = 1;
        static char s_arg0[] = "cjqt6";
        static char* s_argv[] = { s_arg0, nullptr };

        try {
            g_app = new QApplication(s_argc, s_argv);
        } catch (const std::exception& e) {
            fprintf(stderr, "[cjqt6_bridge] qApplicationCreate failed: %s\n", e.what());
            g_app = nullptr;
        } catch (...) {
            fprintf(stderr, "[cjqt6_bridge] qApplicationCreate failed: unknown C++ exception\n");
            g_app = nullptr;
        }
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

void qApplicationDelete(int64_t) {
    // 不删除全局 QApplication
}

// ============================================================
// QWidget 桥接函数
// ============================================================

int64_t qWidgetCreate() {
    QWidget* widget = new QWidget();
    return reinterpret_cast<int64_t>(widget);
}

void qWidgetShow(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->show();
        widget->activateWindow();
        widget->raise();
    } else {
        fprintf(stderr, "[cjqt6_bridge] qWidgetShow ERROR: widget is NULL\n");
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


void qWidgetMove(int64_t ptr, int32_t x, int32_t y) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) widget->move(x, y);
}
int32_t qWidgetX(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    return widget ? widget->x() : 0;
}
int32_t qWidgetY(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    return widget ? widget->y() : 0;
}
void qWidgetSetFixedSize(int64_t ptr, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) widget->setFixedSize(width, height);
}
void qWidgetSetWindowIcon(int64_t ptr, const char* iconPath) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget && iconPath) widget->setWindowIcon(QIcon(iconPath));
}

__declspec(dllexport) void qWidgetSetWindowFlags(int64_t ptr, int32_t flags) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setWindowFlags(Qt::WindowFlags(QFlag(flags)));
    }
}

// ============================================================
// QClipboard 桥接函数
// ============================================================

const char* qClipboardText() {
    QClipboard* clipboard = QApplication::clipboard();
    if (clipboard) {
        static QByteArray text;
        text = clipboard->text().toUtf8();
        return text.constData();
    }
    return "";
}

void qClipboardSetText(const char* text) {
    QClipboard* clipboard = QApplication::clipboard();
    if (clipboard) {
        clipboard->setText(QString::fromUtf8(text));
    }
}

bool qClipboardHasText() {
    QClipboard* clipboard = QApplication::clipboard();
    if (clipboard) {
        return !clipboard->text().isEmpty();
    }
    return false;
}

void qClipboardClear() {
    QClipboard* clipboard = QApplication::clipboard();
    if (clipboard) {
        clipboard->clear();
    }
}

// ============================================================
// QDesktopServices 桥接函数
// ============================================================

bool qDesktopServicesOpenUrl(const char* url) {
    return QDesktopServices::openUrl(QUrl(QString::fromUtf8(url)));
}

bool qDesktopServicesOpenFile(const char* filePath) {
    return QDesktopServices::openUrl(QUrl::fromLocalFile(QString::fromUtf8(filePath)));
}

// ============================================================
// QShortcut 桥接函数
// ============================================================

int64_t qShortcutCreate(int64_t parentPtr) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    if (parent) {
        QShortcut* shortcut = new QShortcut(parent);
        return reinterpret_cast<int64_t>(shortcut);
    }
    return 0;
}

void qShortcutSetKey(int64_t ptr, const char* keySequence) {
    QShortcut* shortcut = reinterpret_cast<QShortcut*>(ptr);
    if (shortcut) {
        shortcut->setKey(QKeySequence(QString::fromUtf8(keySequence)));
    }
}

void qShortcutSetEnabled(int64_t ptr, bool enabled) {
    QShortcut* shortcut = reinterpret_cast<QShortcut*>(ptr);
    if (shortcut) {
        shortcut->setEnabled(enabled);
    }
}

void qShortcutSetAutoRepeat(int64_t ptr, bool repeat) {
    QShortcut* shortcut = reinterpret_cast<QShortcut*>(ptr);
    if (shortcut) {
        shortcut->setAutoRepeat(repeat);
    }
}

void qShortcutDelete(int64_t ptr) {
    QShortcut* shortcut = reinterpret_cast<QShortcut*>(ptr);
    if (shortcut) {
        delete shortcut;
    }
}

// ============================================================
// QStandardPaths 桥接函数
// ============================================================

const char* qStandardPathWritableLocation(int32_t type) {
    static QByteArray path;
    path = QStandardPaths::writableLocation(static_cast<QStandardPaths::StandardLocation>(type)).toUtf8();
    return path.constData();
}

const char* qStandardPathLocate(int32_t type, const char* fileName) {
    static QByteArray path;
    path = QStandardPaths::locate(static_cast<QStandardPaths::StandardLocation>(type), QString::fromUtf8(fileName)).toUtf8();
    return path.constData();
}

const char* qStandardPathDisplayName(int32_t type) {
    static QByteArray name;
    name = QStandardPaths::displayName(static_cast<QStandardPaths::StandardLocation>(type)).toUtf8();
    return name.constData();
}

const char* qStandardPathTempDir() {
    static QByteArray path;
    path = QStandardPaths::writableLocation(QStandardPaths::TempLocation).toUtf8();
    return path.constData();
}

// ============================================================
// QFileSystemWatcher 桥接函数
// ============================================================

int64_t qFileSystemWatcherCreate() {
    QFileSystemWatcher* watcher = new QFileSystemWatcher();
    return reinterpret_cast<int64_t>(watcher);
}

void qFileSystemWatcherAddPath(int64_t ptr, const char* path) {
    QFileSystemWatcher* watcher = reinterpret_cast<QFileSystemWatcher*>(ptr);
    if (watcher) {
        watcher->addPath(QString::fromUtf8(path));
    }
}

void qFileSystemWatcherRemovePath(int64_t ptr, const char* path) {
    QFileSystemWatcher* watcher = reinterpret_cast<QFileSystemWatcher*>(ptr);
    if (watcher) {
        watcher->removePath(QString::fromUtf8(path));
    }
}

void qFileSystemWatcherDelete(int64_t ptr) {
    QFileSystemWatcher* watcher = reinterpret_cast<QFileSystemWatcher*>(ptr);
    if (watcher) {
        delete watcher;
    }
}

// ============================================================
// QSettings 桥接函数
// ============================================================

int64_t qSettingsCreate(const char* appName) {
    QSettings* settings = new QSettings(QString::fromUtf8(appName));
    return reinterpret_cast<int64_t>(settings);
}

int64_t qSettingsCreateWithFile(const char* fileName) {
    QSettings* settings = new QSettings(QString::fromUtf8(fileName), QSettings::IniFormat);
    return reinterpret_cast<int64_t>(settings);
}

void qSettingsSetValue(int64_t ptr, const char* key, const char* value) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        settings->setValue(QString::fromUtf8(key), QString::fromUtf8(value));
    }
}

const char* qSettingsValue(int64_t ptr, const char* key, const char* defaultValue) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        static QByteArray value;
        value = settings->value(QString::fromUtf8(key), QString::fromUtf8(defaultValue)).toString().toUtf8();
        return value.constData();
    }
    return defaultValue;
}

int32_t qSettingsValueInt(int64_t ptr, const char* key, int32_t defaultValue) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        return settings->value(QString::fromUtf8(key), defaultValue).toInt();
    }
    return defaultValue;
}

bool qSettingsValueBool(int64_t ptr, const char* key, bool defaultValue) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        return settings->value(QString::fromUtf8(key), defaultValue).toBool();
    }
    return defaultValue;
}

void qSettingsBeginGroup(int64_t ptr, const char* prefix) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        settings->beginGroup(QString::fromUtf8(prefix));
    }
}

void qSettingsEndGroup(int64_t ptr) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        settings->endGroup();
    }
}

void qSettingsSync(int64_t ptr) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        settings->sync();
    }
}

bool qSettingsContains(int64_t ptr, const char* key) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        return settings->contains(QString::fromUtf8(key));
    }
    return false;
}

void qSettingsRemove(int64_t ptr, const char* key) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        settings->remove(QString::fromUtf8(key));
    }
}

void qSettingsDelete(int64_t ptr) {
    QSettings* settings = reinterpret_cast<QSettings*>(ptr);
    if (settings) {
        delete settings;
    }
}

// ============================================================
// QPropertyAnimation 桥接函数
// ============================================================

int64_t qPropertyAnimationCreate(int64_t targetPtr, const char* propertyName) {
    QPropertyAnimation* anim = new QPropertyAnimation(
        reinterpret_cast<QObject*>(targetPtr),
        QByteArray(propertyName),
        nullptr
    );
    return reinterpret_cast<int64_t>(anim);
}

void qPropertyAnimationSetDuration(int64_t ptr, int32_t duration) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) anim->setDuration(duration);
}

int32_t qPropertyAnimationDuration(int64_t ptr) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    return anim ? anim->duration() : 0;
}

void qPropertyAnimationSetStartValue(int64_t ptr, double value) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) anim->setStartValue(QVariant(value));
}

void qPropertyAnimationSetEndValue(int64_t ptr, double value) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) anim->setEndValue(QVariant(value));
}

void qPropertyAnimationStart(int64_t ptr) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) anim->start();
}

void qPropertyAnimationStop(int64_t ptr) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) anim->stop();
}

void qPropertyAnimationSetLoopCount(int64_t ptr, int32_t count) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) anim->setLoopCount(count);
}

int32_t qPropertyAnimationLoopCount(int64_t ptr) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    return anim ? anim->loopCount() : 1;
}

void qPropertyAnimationSetEasingCurve(int64_t ptr, int32_t curveType) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) anim->setEasingCurve(static_cast<QEasingCurve::Type>(curveType));
}

void qPropertyAnimationDelete(int64_t ptr) {
    QPropertyAnimation* anim = reinterpret_cast<QPropertyAnimation*>(ptr);
    if (anim) delete anim;
}

// ============================================================
// QScreen 桥接函数
// ============================================================

double qScreenPrimaryDpiX() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->logicalDotsPerInchX() : 0.0;
}

double qScreenPrimaryDpiY() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->logicalDotsPerInchY() : 0.0;
}

double qScreenPrimaryPhysicalDpiX() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->physicalDotsPerInchX() : 0.0;
}

double qScreenPrimaryPhysicalDpiY() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->physicalDotsPerInchY() : 0.0;
}

double qScreenPrimaryDevicePixelRatio() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->devicePixelRatio() : 1.0;
}

int32_t qScreenPrimaryWidth() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->size().width() : 0;
}

int32_t qScreenPrimaryHeight() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->size().height() : 0;
}

double qScreenPrimaryRefreshRate() {
    QScreen* screen = QGuiApplication::primaryScreen();
    return screen ? screen->refreshRate() : 0.0;
}

} // extern "C"

