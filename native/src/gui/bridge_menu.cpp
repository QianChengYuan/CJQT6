/**
 * @file bridge_menu.cpp
 * @brief 菜单模块桥接函数 - QMenuBar, QMenu, QAction, QToolBar, QStatusBar
 */

#include <QMenuBar>
#include <QMenu>
#include <QAction>
#include <QToolBar>
#include <QStatusBar>
#include <QMainWindow>
#include <functional>
#include <unordered_map>

// 动作触发回调映射
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_actionCallbacks;

extern "C" {

// ============================================================
// QMenuBar 桥接函数
// ============================================================

int64_t qMenuBarCreate() {
    QMenuBar* menuBar = new QMenuBar();
    return reinterpret_cast<int64_t>(menuBar);
}

int64_t qMenuBarAddMenu(int64_t ptr, const char* title) {
    QMenuBar* menuBar = reinterpret_cast<QMenuBar*>(ptr);
    if (menuBar) {
        QMenu* menu = menuBar->addMenu(QString::fromUtf8(title));
        return reinterpret_cast<int64_t>(menu);
    }
    return 0;
}

void qMenuBarDelete(int64_t ptr) {
    QMenuBar* menuBar = reinterpret_cast<QMenuBar*>(ptr);
    if (menuBar) {
        delete menuBar;
    }
}

// ============================================================
// QMenu 桥接函数
// ============================================================

int64_t qMenuCreate(const char* title) {
    QMenu* menu = new QMenu(QString::fromUtf8(title));
    return reinterpret_cast<int64_t>(menu);
}

int64_t qMenuAddAction(int64_t ptr, const char* text) {
    QMenu* menu = reinterpret_cast<QMenu*>(ptr);
    if (menu) {
        QAction* action = menu->addAction(QString::fromUtf8(text));
        return reinterpret_cast<int64_t>(action);
    }
    return 0;
}

void qMenuAddActionByPtr(int64_t ptr, int64_t actionPtr) {
    QMenu* menu = reinterpret_cast<QMenu*>(ptr);
    QAction* action = reinterpret_cast<QAction*>(actionPtr);
    if (menu && action) {
        menu->addAction(action);
    }
}

int64_t qMenuAddSeparator(int64_t ptr) {
    QMenu* menu = reinterpret_cast<QMenu*>(ptr);
    if (menu) {
        QAction* action = menu->addSeparator();
        return reinterpret_cast<int64_t>(action);
    }
    return 0;
}

int64_t qMenuAddMenu(int64_t ptr, const char* title) {
    QMenu* menu = reinterpret_cast<QMenu*>(ptr);
    if (menu) {
        QMenu* subMenu = menu->addMenu(QString::fromUtf8(title));
        return reinterpret_cast<int64_t>(subMenu);
    }
    return 0;
}

void qMenuSetTitle(int64_t ptr, const char* title) {
    QMenu* menu = reinterpret_cast<QMenu*>(ptr);
    if (menu) {
        menu->setTitle(QString::fromUtf8(title));
    }
}

void qMenuDelete(int64_t ptr) {
    QMenu* menu = reinterpret_cast<QMenu*>(ptr);
    if (menu) {
        delete menu;
    }
}

// ============================================================
// QAction 桥接函数
// ============================================================

int64_t qActionCreate(const char* text) {
    QAction* action = new QAction(QString::fromUtf8(text));
    return reinterpret_cast<int64_t>(action);
}

void qActionSetText(int64_t ptr, const char* text) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action) {
        action->setText(QString::fromUtf8(text));
    }
}

const char* qActionText(int64_t ptr) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action) {
        static QString text;
        text = action->text();
        return text.toUtf8().constData();
    }
    return "";
}

void qActionSetShortcut(int64_t ptr, const char* shortcut) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action) {
        action->setShortcut(QKeySequence(QString::fromUtf8(shortcut)));
    }
}

void qActionSetCheckable(int64_t ptr, bool checkable) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action) {
        action->setCheckable(checkable);
    }
}

bool qActionIsCheckable(int64_t ptr) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action) {
        return action->isCheckable();
    }
    return false;
}

void qActionSetChecked(int64_t ptr, bool checked) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action) {
        action->setChecked(checked);
    }
}

bool qActionIsChecked(int64_t ptr) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action) {
        return action->isChecked();
    }
    return false;
}

void qActionSetEnabled(int64_t ptr, bool enabled) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action) {
        action->setEnabled(enabled);
    }
}

bool qActionIsEnabled(int64_t ptr) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action) {
        return action->isEnabled();
    }
    return false;
}

void qActionSetVisible(int64_t ptr, bool visible) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action) {
        action->setVisible(visible);
    }
}

bool qActionIsVisible(int64_t ptr) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action) {
        return action->isVisible();
    }
    return false;
}

void qActionSetOnTriggered(int64_t ptr, void (*callback)(int64_t)) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action) {
        int64_t actionPtr = ptr;
        g_actionCallbacks[ptr] = [callback, actionPtr](int64_t) { callback(actionPtr); };
        QObject::connect(action, &QAction::triggered, [actionPtr]() {
            auto it = g_actionCallbacks.find(actionPtr);
            if (it != g_actionCallbacks.end()) {
                it->second(actionPtr);
            }
        });
    }
}

void qActionDelete(int64_t ptr) {
    QAction* action = reinterpret_cast<QAction*>(ptr);
    if (action) {
        g_actionCallbacks.erase(ptr);
        delete action;
    }
}

// ============================================================
// QToolBar 桥接函数
// ============================================================

int64_t qToolBarCreate(const char* title) {
    QToolBar* toolBar = new QToolBar(QString::fromUtf8(title));
    return reinterpret_cast<int64_t>(toolBar);
}

void qToolBarAddAction(int64_t ptr, int64_t actionPtr) {
    QToolBar* toolBar = reinterpret_cast<QToolBar*>(ptr);
    QAction* action = reinterpret_cast<QAction*>(actionPtr);
    if (toolBar && action) {
        toolBar->addAction(action);
    }
}

void qToolBarAddSeparator(int64_t ptr) {
    QToolBar* toolBar = reinterpret_cast<QToolBar*>(ptr);
    if (toolBar) {
        toolBar->addSeparator();
    }
}

void qToolBarAddWidget(int64_t ptr, int64_t widgetPtr) {
    QToolBar* toolBar = reinterpret_cast<QToolBar*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (toolBar && widget) {
        toolBar->addWidget(widget);
    }
}

void qToolBarSetMovable(int64_t ptr, bool movable) {
    QToolBar* toolBar = reinterpret_cast<QToolBar*>(ptr);
    if (toolBar) {
        toolBar->setMovable(movable);
    }
}

void qToolBarDelete(int64_t ptr) {
    QToolBar* toolBar = reinterpret_cast<QToolBar*>(ptr);
    if (toolBar) {
        delete toolBar;
    }
}

// ============================================================
// QStatusBar 桥接函数
// ============================================================

int64_t qStatusBarCreate() {
    QStatusBar* statusBar = new QStatusBar();
    return reinterpret_cast<int64_t>(statusBar);
}

void qStatusBarShowMessage(int64_t ptr, const char* message, int32_t timeout) {
    QStatusBar* statusBar = reinterpret_cast<QStatusBar*>(ptr);
    if (statusBar) {
        statusBar->showMessage(QString::fromUtf8(message), timeout);
    }
}

void qStatusBarClearMessage(int64_t ptr) {
    QStatusBar* statusBar = reinterpret_cast<QStatusBar*>(ptr);
    if (statusBar) {
        statusBar->clearMessage();
    }
}

void qStatusBarAddWidget(int64_t ptr, int64_t widgetPtr, int32_t stretch) {
    QStatusBar* statusBar = reinterpret_cast<QStatusBar*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (statusBar && widget) {
        statusBar->addWidget(widget, stretch);
    }
}

void qStatusBarDelete(int64_t ptr) {
    QStatusBar* statusBar = reinterpret_cast<QStatusBar*>(ptr);
    if (statusBar) {
        delete statusBar;
    }
}

// ============================================================
// QMainWindow 桥接函数
// ============================================================

int64_t qMainWindowCreate() {
    QMainWindow* mainWindow = new QMainWindow();
    return reinterpret_cast<int64_t>(mainWindow);
}

void qMainWindowSetMenuBar(int64_t ptr, int64_t menuBarPtr) {
    QMainWindow* mainWindow = reinterpret_cast<QMainWindow*>(ptr);
    QMenuBar* menuBar = reinterpret_cast<QMenuBar*>(menuBarPtr);
    if (mainWindow && menuBar) {
        mainWindow->setMenuBar(menuBar);
    }
}

void qMainWindowAddToolBar(int64_t ptr, int64_t toolBarPtr) {
    QMainWindow* mainWindow = reinterpret_cast<QMainWindow*>(ptr);
    QToolBar* toolBar = reinterpret_cast<QToolBar*>(toolBarPtr);
    if (mainWindow && toolBar) {
        mainWindow->addToolBar(toolBar);
    }
}

void qMainWindowSetStatusBar(int64_t ptr, int64_t statusBarPtr) {
    QMainWindow* mainWindow = reinterpret_cast<QMainWindow*>(ptr);
    QStatusBar* statusBar = reinterpret_cast<QStatusBar*>(statusBarPtr);
    if (mainWindow && statusBar) {
        mainWindow->setStatusBar(statusBar);
    }
}

void qMainWindowSetCentralWidget(int64_t ptr, int64_t widgetPtr) {
    QMainWindow* mainWindow = reinterpret_cast<QMainWindow*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (mainWindow && widget) {
        mainWindow->setCentralWidget(widget);
    }
}

void qMainWindowSetWindowTitle(int64_t ptr, const char* title) {
    QMainWindow* mainWindow = reinterpret_cast<QMainWindow*>(ptr);
    if (mainWindow) {
        mainWindow->setWindowTitle(QString::fromUtf8(title));
    }
}

void qMainWindowDelete(int64_t ptr) {
    QMainWindow* mainWindow = reinterpret_cast<QMainWindow*>(ptr);
    if (mainWindow) {
        delete mainWindow;
    }
}

} // extern "C"
