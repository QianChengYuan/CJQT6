/**
 * @file bridge_ext_wlayout.cpp
 * @brief v1.2.0 API 补全扩展 - wlayout 批次控件桥接函数。
 * 该文件补充 wlayout 批次控件的桥接函数，遵循 bridge_ext_new.cpp 的既有风格：
 *   - 入参 ptr 做空指针校验；
 *   - 字符串返回使用 static 缓冲区 + toUtf8().constData()；
 *   - 信号通过 std::unordered_map 注册回调，connect 前做去重保护；
 *   - 布尔参数/返回值统一使用 int32_t（bool 信号回调使用 bool 以匹配 BoolCallback）。
 */
#include <QWidget>
#include <QString>
#include <QGroupBox>
#include <QFrame>
#include <QScrollArea>
#include <QStackedWidget>
#include <QToolBox>
#include <QDockWidget>
#include <QMdiArea>
#include <QMdiSubWindow>
#include <QAction>
#include <QIcon>
#include <QBrush>
#include <QPixmap>
#include <QRect>
#include <functional>
#include <unordered_map>

extern "C" {

// ============================================================
// QGroupBox 补充 API
// ============================================================
void qGroupBoxSetAlignment(int64_t ptr, int32_t alignment) {
    QGroupBox* w = reinterpret_cast<QGroupBox*>(ptr);
    if (w) w->setAlignment(static_cast<Qt::Alignment>(alignment));
}

int32_t qGroupBoxAlignment(int64_t ptr) {
    QGroupBox* w = reinterpret_cast<QGroupBox*>(ptr);
    return w ? static_cast<int32_t>(w->alignment()) : 0;
}

static std::unordered_map<int64_t, std::function<void(bool)>> g_gbClicked;
static std::unordered_map<int64_t, std::function<void(bool)>> g_gbToggled;

void qGroupBoxConnectClicked(int64_t ptr, void (*cb)(bool)) {
    QGroupBox* w = reinterpret_cast<QGroupBox*>(ptr);
    if (w && cb && g_gbClicked.find(ptr) == g_gbClicked.end()) {
        g_gbClicked[ptr] = [cb](bool v) { cb(v); };
        QObject::connect(w, &QGroupBox::clicked, [ptr](bool checked) {
            auto it = g_gbClicked.find(ptr);
            if (it != g_gbClicked.end()) it->second(checked);
        });
    }
}

void qGroupBoxConnectToggled(int64_t ptr, void (*cb)(bool)) {
    QGroupBox* w = reinterpret_cast<QGroupBox*>(ptr);
    if (w && cb && g_gbToggled.find(ptr) == g_gbToggled.end()) {
        g_gbToggled[ptr] = [cb](bool v) { cb(v); };
        QObject::connect(w, &QGroupBox::toggled, [ptr](bool on) {
            auto it = g_gbToggled.find(ptr);
            if (it != g_gbToggled.end()) it->second(on);
        });
    }
}

// ============================================================
// QFrame 补充 API
// ============================================================
int32_t qFrameFrameShape(int64_t ptr) {
    QFrame* w = reinterpret_cast<QFrame*>(ptr);
    return w ? static_cast<int32_t>(w->frameShape()) : 0;
}

int32_t qFrameFrameShadow(int64_t ptr) {
    QFrame* w = reinterpret_cast<QFrame*>(ptr);
    return w ? static_cast<int32_t>(w->frameShadow()) : 0;
}

void qFrameSetMidLineWidth(int64_t ptr, int32_t width) {
    QFrame* w = reinterpret_cast<QFrame*>(ptr);
    if (w) w->setMidLineWidth(width);
}

int32_t qFrameMidLineWidth(int64_t ptr) {
    QFrame* w = reinterpret_cast<QFrame*>(ptr);
    return w ? static_cast<int32_t>(w->midLineWidth()) : 0;
}

void qFrameSetFrameStyle(int64_t ptr, int32_t style) {
    QFrame* w = reinterpret_cast<QFrame*>(ptr);
    if (w) w->setFrameStyle(style);
}

int32_t qFrameFrameStyle(int64_t ptr) {
    QFrame* w = reinterpret_cast<QFrame*>(ptr);
    return w ? static_cast<int32_t>(w->frameStyle()) : 0;
}

void qFrameSetFrameRect(int64_t ptr, int32_t x, int32_t y, int32_t w, int32_t h) {
    QFrame* f = reinterpret_cast<QFrame*>(ptr);
    if (f) f->setFrameRect(QRect(x, y, w, h));
}

// ============================================================
// QScrollArea 补充 API
// ============================================================
int64_t qScrollAreaTakeWidget(int64_t ptr) {
    QScrollArea* w = reinterpret_cast<QScrollArea*>(ptr);
    if (w) return reinterpret_cast<int64_t>(w->takeWidget());
    return 0;
}

int32_t qScrollAreaWidgetResizable(int64_t ptr) {
    QScrollArea* w = reinterpret_cast<QScrollArea*>(ptr);
    return w ? (w->widgetResizable() ? 1 : 0) : 0;
}

void qScrollAreaSetHorizontalScrollBarPolicy(int64_t ptr, int32_t policy) {
    QScrollArea* w = reinterpret_cast<QScrollArea*>(ptr);
    if (w) w->setHorizontalScrollBarPolicy(static_cast<Qt::ScrollBarPolicy>(policy));
}

void qScrollAreaSetVerticalScrollBarPolicy(int64_t ptr, int32_t policy) {
    QScrollArea* w = reinterpret_cast<QScrollArea*>(ptr);
    if (w) w->setVerticalScrollBarPolicy(static_cast<Qt::ScrollBarPolicy>(policy));
}

void qScrollAreaEnsureVisible(int64_t ptr, int32_t x, int32_t y, int32_t w, int32_t h) {
    QScrollArea* sa = reinterpret_cast<QScrollArea*>(ptr);
    if (sa) sa->ensureVisible(x, y, w, h);
}

void qScrollAreaSetAlignment(int64_t ptr, int32_t alignment) {
    QScrollArea* w = reinterpret_cast<QScrollArea*>(ptr);
    if (w) w->setAlignment(static_cast<Qt::Alignment>(alignment));
}

int32_t qScrollAreaAlignment(int64_t ptr) {
    QScrollArea* w = reinterpret_cast<QScrollArea*>(ptr);
    return w ? static_cast<int32_t>(w->alignment()) : 0;
}

// ============================================================
// QStackedWidget 补充 API
// ============================================================
void qStackedWidgetSetCurrentWidget(int64_t ptr, int64_t widgetPtr) {
    QStackedWidget* w = reinterpret_cast<QStackedWidget*>(ptr);
    QWidget* cw = reinterpret_cast<QWidget*>(widgetPtr);
    if (w) w->setCurrentWidget(cw);
}

int64_t qStackedWidgetWidget(int64_t ptr, int32_t index) {
    QStackedWidget* w = reinterpret_cast<QStackedWidget*>(ptr);
    if (w) return reinterpret_cast<int64_t>(w->widget(index));
    return 0;
}

static std::unordered_map<int64_t, std::function<void(int32_t)>> g_swCurrentChanged;
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_swWidgetRemoved;

void qStackedWidgetConnectCurrentChanged(int64_t ptr, void (*cb)(int32_t)) {
    QStackedWidget* w = reinterpret_cast<QStackedWidget*>(ptr);
    if (w && cb && g_swCurrentChanged.find(ptr) == g_swCurrentChanged.end()) {
        g_swCurrentChanged[ptr] = [cb](int32_t v) { cb(v); };
        QObject::connect(w, &QStackedWidget::currentChanged, [ptr](int index) {
            auto it = g_swCurrentChanged.find(ptr);
            if (it != g_swCurrentChanged.end()) it->second(static_cast<int32_t>(index));
        });
    }
}

void qStackedWidgetConnectWidgetRemoved(int64_t ptr, void (*cb)(int32_t)) {
    QStackedWidget* w = reinterpret_cast<QStackedWidget*>(ptr);
    if (w && cb && g_swWidgetRemoved.find(ptr) == g_swWidgetRemoved.end()) {
        g_swWidgetRemoved[ptr] = [cb](int32_t v) { cb(v); };
        QObject::connect(w, &QStackedWidget::widgetRemoved, [ptr](int index) {
            auto it = g_swWidgetRemoved.find(ptr);
            if (it != g_swWidgetRemoved.end()) it->second(static_cast<int32_t>(index));
        });
    }
}

// ============================================================
// QToolBox 补充 API
// ============================================================
void qToolBoxSetItemIcon(int64_t ptr, int32_t index, const char* path) {
    QToolBox* w = reinterpret_cast<QToolBox*>(ptr);
    if (w) w->setItemIcon(index, QIcon(QString::fromUtf8(path)));
}

void qToolBoxSetCurrentWidget(int64_t ptr, int64_t widgetPtr) {
    QToolBox* w = reinterpret_cast<QToolBox*>(ptr);
    QWidget* cw = reinterpret_cast<QWidget*>(widgetPtr);
    if (w) w->setCurrentWidget(cw);
}

int32_t qToolBoxIndexOf(int64_t ptr, int64_t widgetPtr) {
    QToolBox* w = reinterpret_cast<QToolBox*>(ptr);
    QWidget* cw = reinterpret_cast<QWidget*>(widgetPtr);
    return w ? static_cast<int32_t>(w->indexOf(cw)) : -1;
}

static std::unordered_map<int64_t, std::function<void(int32_t)>> g_tbCurrentChanged;

void qToolBoxConnectCurrentChanged(int64_t ptr, void (*cb)(int32_t)) {
    QToolBox* w = reinterpret_cast<QToolBox*>(ptr);
    if (w && cb && g_tbCurrentChanged.find(ptr) == g_tbCurrentChanged.end()) {
        g_tbCurrentChanged[ptr] = [cb](int32_t v) { cb(v); };
        QObject::connect(w, &QToolBox::currentChanged, [ptr](int index) {
            auto it = g_tbCurrentChanged.find(ptr);
            if (it != g_tbCurrentChanged.end()) it->second(static_cast<int32_t>(index));
        });
    }
}

// ============================================================
// QDockWidget 补充 API
// ============================================================
int32_t qDockWidgetFeatures(int64_t ptr) {
    QDockWidget* w = reinterpret_cast<QDockWidget*>(ptr);
    return w ? static_cast<int32_t>(w->features()) : 0;
}

int32_t qDockWidgetAllowedAreas(int64_t ptr) {
    QDockWidget* w = reinterpret_cast<QDockWidget*>(ptr);
    return w ? static_cast<int32_t>(w->allowedAreas()) : 0;
}

void qDockWidgetSetVisible(int64_t ptr, int32_t visible) {
    QDockWidget* w = reinterpret_cast<QDockWidget*>(ptr);
    if (w) w->setVisible(visible != 0);
}

int64_t qDockWidgetToggleViewAction(int64_t ptr) {
    QDockWidget* w = reinterpret_cast<QDockWidget*>(ptr);
    if (w) return reinterpret_cast<int64_t>(w->toggleViewAction());
    return 0;
}

static std::unordered_map<int64_t, std::function<void(bool)>> g_dwTopLevel;
static std::unordered_map<int64_t, std::function<void(bool)>> g_dwVisibility;
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_dwDockLoc;

void qDockWidgetConnectTopLevelChanged(int64_t ptr, void (*cb)(bool)) {
    QDockWidget* w = reinterpret_cast<QDockWidget*>(ptr);
    if (w && cb && g_dwTopLevel.find(ptr) == g_dwTopLevel.end()) {
        g_dwTopLevel[ptr] = [cb](bool v) { cb(v); };
        QObject::connect(w, &QDockWidget::topLevelChanged, [ptr](bool topLevel) {
            auto it = g_dwTopLevel.find(ptr);
            if (it != g_dwTopLevel.end()) it->second(topLevel);
        });
    }
}

void qDockWidgetConnectVisibilityChanged(int64_t ptr, void (*cb)(bool)) {
    QDockWidget* w = reinterpret_cast<QDockWidget*>(ptr);
    if (w && cb && g_dwVisibility.find(ptr) == g_dwVisibility.end()) {
        g_dwVisibility[ptr] = [cb](bool v) { cb(v); };
        QObject::connect(w, &QDockWidget::visibilityChanged, [ptr](bool visible) {
            auto it = g_dwVisibility.find(ptr);
            if (it != g_dwVisibility.end()) it->second(visible);
        });
    }
}

void qDockWidgetConnectDockLocationChanged(int64_t ptr, void (*cb)(int32_t)) {
    QDockWidget* w = reinterpret_cast<QDockWidget*>(ptr);
    if (w && cb && g_dwDockLoc.find(ptr) == g_dwDockLoc.end()) {
        g_dwDockLoc[ptr] = [cb](int32_t v) { cb(v); };
        QObject::connect(w, &QDockWidget::dockLocationChanged, [ptr](Qt::DockWidgetArea area) {
            auto it = g_dwDockLoc.find(ptr);
            if (it != g_dwDockLoc.end()) it->second(static_cast<int32_t>(area));
        });
    }
}

// ============================================================
// QMdiArea / QMdiSubWindow 补充 API
// ============================================================
int32_t qMdiAreaSubWindowCount(int64_t ptr) {
    QMdiArea* w = reinterpret_cast<QMdiArea*>(ptr);
    return w ? static_cast<int32_t>(w->subWindowList().size()) : 0;
}

void qMdiAreaSetActiveSubWindow(int64_t ptr, int64_t subWinPtr) {
    QMdiArea* w = reinterpret_cast<QMdiArea*>(ptr);
    QMdiSubWindow* sw = reinterpret_cast<QMdiSubWindow*>(subWinPtr);
    if (w) w->setActiveSubWindow(sw);
}

int32_t qMdiAreaViewMode(int64_t ptr) {
    QMdiArea* w = reinterpret_cast<QMdiArea*>(ptr);
    return w ? static_cast<int32_t>(w->viewMode()) : 0;
}

void qMdiAreaSetActivationOrder(int64_t ptr, int32_t order) {
    QMdiArea* w = reinterpret_cast<QMdiArea*>(ptr);
    if (w) w->setActivationOrder(static_cast<QMdiArea::WindowOrder>(order));
}

int32_t qMdiAreaActivationOrder(int64_t ptr) {
    QMdiArea* w = reinterpret_cast<QMdiArea*>(ptr);
    return w ? static_cast<int32_t>(w->activationOrder()) : 0;
}

void qMdiAreaSetBackground(int64_t ptr, const char* path) {
    QMdiArea* w = reinterpret_cast<QMdiArea*>(ptr);
    if (w) w->setBackground(QBrush(QPixmap(QString::fromUtf8(path))));
}

static std::unordered_map<int64_t, std::function<void(int64_t)>> g_maSubWinActivated;

void qMdiAreaConnectSubWindowActivated(int64_t ptr, void (*cb)(int64_t)) {
    QMdiArea* w = reinterpret_cast<QMdiArea*>(ptr);
    if (w && cb && g_maSubWinActivated.find(ptr) == g_maSubWinActivated.end()) {
        g_maSubWinActivated[ptr] = [cb](int64_t v) { cb(v); };
        QObject::connect(w, &QMdiArea::subWindowActivated, [ptr](QMdiSubWindow* sw) {
            auto it = g_maSubWinActivated.find(ptr);
            if (it != g_maSubWinActivated.end()) it->second(reinterpret_cast<int64_t>(sw));
        });
    }
}

void qMdiSubWindowShowShaded(int64_t ptr) {
    QMdiSubWindow* w = reinterpret_cast<QMdiSubWindow*>(ptr);
    if (w) w->showShaded();
}

int32_t qMdiSubWindowIsShaded(int64_t ptr) {
    QMdiSubWindow* w = reinterpret_cast<QMdiSubWindow*>(ptr);
    return w ? (w->isShaded() ? 1 : 0) : 0;
}

} // extern "C"
