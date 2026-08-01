/**
 * @file bridge_containers.cpp
 * @brief 容器部件桥接函数 - QGroupBox, QTabWidget, QScrollArea, QFrame, QSplitter
 */

#include <QGroupBox>
#include <QTabWidget>
#include <QScrollArea>
#include <QFrame>
#include <QSplitter>
#include <QStackedWidget>
#include <QVBoxLayout>
#include <QToolBox>
#include <QMdiArea>
#include <QMdiSubWindow>
#include <QDockWidget>

extern "C" {

// ============================================================
// QGroupBox 桥接函数
// ============================================================

int64_t qGroupBoxCreate() {
    QGroupBox* groupBox = new QGroupBox();
    return reinterpret_cast<int64_t>(groupBox);
}

void qGroupBoxSetTitle(int64_t ptr, const char* title) {
    QGroupBox* groupBox = reinterpret_cast<QGroupBox*>(ptr);
    if (groupBox) {
        groupBox->setTitle(QString::fromUtf8(title));
    }
}

const char* qGroupBoxTitle(int64_t ptr) {
    QGroupBox* groupBox = reinterpret_cast<QGroupBox*>(ptr);
    if (groupBox) {
        static QString title;
        title = groupBox->title();
        return title.toUtf8().constData();
    }
    return "";
}

void qGroupBoxSetCheckable(int64_t ptr, bool checkable) {
    QGroupBox* groupBox = reinterpret_cast<QGroupBox*>(ptr);
    if (groupBox) {
        groupBox->setCheckable(checkable);
    }
}

bool qGroupBoxIsCheckable(int64_t ptr) {
    QGroupBox* groupBox = reinterpret_cast<QGroupBox*>(ptr);
    if (groupBox) {
        return groupBox->isCheckable();
    }
    return false;
}

void qGroupBoxSetChecked(int64_t ptr, bool checked) {
    QGroupBox* groupBox = reinterpret_cast<QGroupBox*>(ptr);
    if (groupBox) {
        groupBox->setChecked(checked);
    }
}

bool qGroupBoxIsChecked(int64_t ptr) {
    QGroupBox* groupBox = reinterpret_cast<QGroupBox*>(ptr);
    if (groupBox) {
        return groupBox->isChecked();
    }
    return false;
}

void qGroupBoxDelete(int64_t ptr) {
    QGroupBox* groupBox = reinterpret_cast<QGroupBox*>(ptr);
    if (groupBox) {
        delete groupBox;
    }
}

// ============================================================
// QTabWidget 桥接函数
// ============================================================

int64_t qTabWidgetCreate() {
    QTabWidget* tabWidget = new QTabWidget();
    return reinterpret_cast<int64_t>(tabWidget);
}

void qTabWidgetAddTab(int64_t ptr, int64_t widgetPtr, const char* title) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (tabWidget && widget) {
        tabWidget->addTab(widget, QString::fromUtf8(title));
    }
}

void qTabWidgetRemoveTab(int64_t ptr, int32_t index) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget) {
        tabWidget->removeTab(index);
    }
}

int32_t qTabWidgetCount(int64_t ptr) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget) {
        return tabWidget->count();
    }
    return 0;
}

int32_t qTabWidgetCurrentIndex(int64_t ptr) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget) {
        return tabWidget->currentIndex();
    }
    return -1;
}

void qTabWidgetSetCurrentIndex(int64_t ptr, int32_t index) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget) {
        tabWidget->setCurrentIndex(index);
    }
}

void qTabWidgetSetTabText(int64_t ptr, int32_t index, const char* text) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget && text) {
        tabWidget->setTabText(index, QString::fromUtf8(text));
    }
}

const char* qTabWidgetTabText(int64_t ptr, int32_t index) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (!tabWidget) return "";
    static QByteArray arr;
    arr = tabWidget->tabText(index).toUtf8();
    return arr.constData();
}

void qTabWidgetSetTabToolTip(int64_t ptr, int32_t index, const char* toolTip) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget && toolTip) {
        tabWidget->setTabToolTip(index, QString::fromUtf8(toolTip));
    }
}

int32_t qTabWidgetInsertTab(int64_t ptr, int32_t index, int64_t widgetPtr, const char* title) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (tabWidget && widget && title) {
        return static_cast<int32_t>(tabWidget->insertTab(index, widget, QString::fromUtf8(title)));
    }
    return -1;
}

void qTabWidgetSetTabsClosable(int64_t ptr, bool closable) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget) {
        tabWidget->setTabsClosable(closable);
    }
}

void qTabWidgetSetMovable(int64_t ptr, bool movable) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget) {
        tabWidget->setMovable(movable);
    }
}

void qTabWidgetClear(int64_t ptr) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget) {
        tabWidget->clear();
    }
}

// QTabWidget 回调映射
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_tabChangedCallbacks;

void qTabWidgetConnectCurrentChanged(int64_t ptr, void (*callback)(int32_t)) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget && callback && g_tabChangedCallbacks.find(ptr) == g_tabChangedCallbacks.end()) {
        g_tabChangedCallbacks[ptr] = [callback](int32_t v) { callback(v); };
        QObject::connect(tabWidget, &QTabWidget::currentChanged, [ptr](int index) {
            auto it = g_tabChangedCallbacks.find(ptr);
            if (it != g_tabChangedCallbacks.end()) it->second(static_cast<int32_t>(index));
        });
    }
}

void qTabWidgetDisconnectCurrentChanged(int64_t ptr) {
    g_tabChangedCallbacks.erase(ptr);
}

void qTabWidgetDelete(int64_t ptr) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget) {
        g_tabChangedCallbacks.erase(ptr);
        delete tabWidget;
    }
}

// ============================================================
// QScrollArea 桥接函数
// ============================================================

int64_t qScrollAreaCreate() {
    QScrollArea* scrollArea = new QScrollArea();
    return reinterpret_cast<int64_t>(scrollArea);
}

void qScrollAreaSetWidget(int64_t ptr, int64_t widgetPtr) {
    QScrollArea* scrollArea = reinterpret_cast<QScrollArea*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (scrollArea && widget) {
        scrollArea->setWidget(widget);
    }
}

void qScrollAreaSetWidgetResizable(int64_t ptr, bool resizable) {
    QScrollArea* scrollArea = reinterpret_cast<QScrollArea*>(ptr);
    if (scrollArea) {
        scrollArea->setWidgetResizable(resizable);
    }
}

int64_t qScrollAreaWidget(int64_t ptr) {
    QScrollArea* scrollArea = reinterpret_cast<QScrollArea*>(ptr);
    if (scrollArea) {
        return reinterpret_cast<int64_t>(scrollArea->widget());
    }
    return 0;
}

void qScrollAreaDelete(int64_t ptr) {
    QScrollArea* scrollArea = reinterpret_cast<QScrollArea*>(ptr);
    if (scrollArea) {
        delete scrollArea;
    }
}

// ============================================================
// QFrame 桥接函数
// ============================================================

int64_t qFrameCreate() {
    QFrame* frame = new QFrame();
    return reinterpret_cast<int64_t>(frame);
}

void qFrameSetFrameShape(int64_t ptr, int32_t shape) {
    QFrame* frame = reinterpret_cast<QFrame*>(ptr);
    if (frame) {
        frame->setFrameShape(static_cast<QFrame::Shape>(shape));
    }
}

void qFrameSetFrameShadow(int64_t ptr, int32_t shadow) {
    QFrame* frame = reinterpret_cast<QFrame*>(ptr);
    if (frame) {
        frame->setFrameShadow(static_cast<QFrame::Shadow>(shadow));
    }
}

void qFrameSetLineWidth(int64_t ptr, int32_t width) {
    QFrame* frame = reinterpret_cast<QFrame*>(ptr);
    if (frame) {
        frame->setLineWidth(width);
    }
}

void qFrameDelete(int64_t ptr) {
    QFrame* frame = reinterpret_cast<QFrame*>(ptr);
    if (frame) {
        delete frame;
    }
}

// ============================================================
// QSplitter 桥接函数
// ============================================================

int64_t qSplitterCreate(int64_t parentPtr) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QSplitter* splitter = new QSplitter(parent);
    return reinterpret_cast<int64_t>(splitter);
}

int64_t qSplitterCreateHorizontal(int64_t parentPtr) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QSplitter* splitter = new QSplitter(Qt::Horizontal, parent);
    return reinterpret_cast<int64_t>(splitter);
}

int64_t qSplitterCreateVertical(int64_t parentPtr) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QSplitter* splitter = new QSplitter(Qt::Vertical, parent);
    return reinterpret_cast<int64_t>(splitter);
}

void qSplitterDelete(int64_t ptr) {
    QSplitter* splitter = reinterpret_cast<QSplitter*>(ptr);
    if (splitter) {
        delete splitter;
    }
}

void qSplitterAddWidget(int64_t ptr, int64_t widgetPtr) {
    QSplitter* splitter = reinterpret_cast<QSplitter*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (splitter && widget) {
        splitter->addWidget(widget);
    }
}

int32_t qSplitterCount(int64_t ptr) {
    QSplitter* splitter = reinterpret_cast<QSplitter*>(ptr);
    if (splitter) {
        return splitter->count();
    }
    return 0;
}

int64_t qSplitterWidget(int64_t ptr, int32_t index) {
    QSplitter* splitter = reinterpret_cast<QSplitter*>(ptr);
    if (splitter) {
        QWidget* widget = splitter->widget(index);
        return reinterpret_cast<int64_t>(widget);
    }
    return 0;
}

void qSplitterSetSizes(int64_t ptr, int32_t* sizes, int32_t count) {
    QSplitter* splitter = reinterpret_cast<QSplitter*>(ptr);
    if (splitter && sizes) {
        QList<int> sizeList;
        for (int i = 0; i < count; ++i) {
            sizeList.append(sizes[i]);
        }
        splitter->setSizes(sizeList);
    }
}

void qSplitterSetStretchFactor(int64_t ptr, int32_t index, int32_t stretch) {
    QSplitter* splitter = reinterpret_cast<QSplitter*>(ptr);
    if (splitter) {
        splitter->setStretchFactor(index, stretch);
    }
}

void qSplitterSetHandleWidth(int64_t ptr, int32_t width) {
    QSplitter* splitter = reinterpret_cast<QSplitter*>(ptr);
    if (splitter) {
        splitter->setHandleWidth(width);
    }
}

int32_t qSplitterHandleWidth(int64_t ptr) {
    QSplitter* splitter = reinterpret_cast<QSplitter*>(ptr);
    if (splitter) {
        return splitter->handleWidth();
    }
    return 0;
}

void qSplitterSetChildrenCollapsible(int64_t ptr, int32_t collapsible) {
    QSplitter* splitter = reinterpret_cast<QSplitter*>(ptr);
    if (splitter) {
        splitter->setChildrenCollapsible(collapsible != 0);
    }
}

int32_t qSplitterChildrenCollapsible(int64_t ptr) {
    QSplitter* splitter = reinterpret_cast<QSplitter*>(ptr);
    if (splitter) {
        return splitter->childrenCollapsible() ? 1 : 0;
    }
    return 0;
}

void qSplitterSetOrientation(int64_t ptr, int32_t orientation) {
    QSplitter* splitter = reinterpret_cast<QSplitter*>(ptr);
    if (splitter) {
        splitter->setOrientation(static_cast<Qt::Orientation>(orientation));
    }
}

int32_t qSplitterOrientation(int64_t ptr) {
    QSplitter* splitter = reinterpret_cast<QSplitter*>(ptr);
    if (splitter) {
        return static_cast<int32_t>(splitter->orientation());
    }
    return 1; // Qt::Horizontal
}

void qSplitterSaveState(int64_t ptr, char* buffer, int32_t* bufferSize) {
    QSplitter* splitter = reinterpret_cast<QSplitter*>(ptr);
    if (splitter && buffer && bufferSize) {
        QByteArray state = splitter->saveState();
        int len = state.size();
        if (len < *bufferSize) {
            std::memcpy(buffer, state.constData(), len);
            *bufferSize = len;
        }
    }
}

int32_t qSplitterRestoreState(int64_t ptr, const char* buffer, int32_t size) {
    QSplitter* splitter = reinterpret_cast<QSplitter*>(ptr);
    if (splitter && buffer) {
        QByteArray state(buffer, size);
        return splitter->restoreState(state) ? 1 : 0;
    }
    return 0;
}

// ============================================================
// QStackedWidget 桥接函数
// ============================================================

int64_t qStackedWidgetCreate() {
    QStackedWidget* stacked = new QStackedWidget();
    return reinterpret_cast<int64_t>(stacked);
}

int32_t qStackedWidgetAddWidget(int64_t ptr, int64_t widgetPtr) {
    QStackedWidget* stacked = reinterpret_cast<QStackedWidget*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (stacked && widget) {
        return static_cast<int32_t>(stacked->addWidget(widget));
    }
    return -1;
}

int32_t qStackedWidgetInsertWidget(int64_t ptr, int32_t index, int64_t widgetPtr) {
    QStackedWidget* stacked = reinterpret_cast<QStackedWidget*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (stacked && widget) {
        return static_cast<int32_t>(stacked->insertWidget(index, widget));
    }
    return -1;
}

void qStackedWidgetRemoveWidget(int64_t ptr, int64_t widgetPtr) {
    QStackedWidget* stacked = reinterpret_cast<QStackedWidget*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (stacked && widget) {
        stacked->removeWidget(widget);
    }
}

void qStackedWidgetSetCurrentIndex(int64_t ptr, int32_t index) {
    QStackedWidget* stacked = reinterpret_cast<QStackedWidget*>(ptr);
    if (stacked) {
        stacked->setCurrentIndex(index);
    }
}

int32_t qStackedWidgetCurrentIndex(int64_t ptr) {
    QStackedWidget* stacked = reinterpret_cast<QStackedWidget*>(ptr);
    return stacked ? stacked->currentIndex() : -1;
}

int64_t qStackedWidgetCurrentWidget(int64_t ptr) {
    QStackedWidget* stacked = reinterpret_cast<QStackedWidget*>(ptr);
    if (stacked) {
        return reinterpret_cast<int64_t>(stacked->currentWidget());
    }
    return 0;
}

int32_t qStackedWidgetCount(int64_t ptr) {
    QStackedWidget* stacked = reinterpret_cast<QStackedWidget*>(ptr);
    return stacked ? stacked->count() : 0;
}

void qStackedWidgetDelete(int64_t ptr) {
    QStackedWidget* stacked = reinterpret_cast<QStackedWidget*>(ptr);
    if (stacked) {
        delete stacked;
    }
}

// ============================================================
// QToolBox 桥接函数
// ============================================================

int64_t qToolBoxCreate() {
    QToolBox* toolbox = new QToolBox();
    return reinterpret_cast<int64_t>(toolbox);
}

void qToolBoxDelete(int64_t ptr) {
    QToolBox* toolbox = reinterpret_cast<QToolBox*>(ptr);
    if (toolbox) {
        delete toolbox;
    }
}

int32_t qToolBoxAddItem(int64_t ptr, int64_t widgetPtr, const char* title) {
    QToolBox* toolbox = reinterpret_cast<QToolBox*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (toolbox && widget) {
        return static_cast<int32_t>(toolbox->addItem(widget, QString::fromUtf8(title)));
    }
    return -1;
}

int32_t qToolBoxInsertItem(int64_t ptr, int32_t index, int64_t widgetPtr, const char* title) {
    QToolBox* toolbox = reinterpret_cast<QToolBox*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (toolbox && widget) {
        return static_cast<int32_t>(toolbox->insertItem(index, widget, QString::fromUtf8(title)));
    }
    return -1;
}

void qToolBoxRemoveItem(int64_t ptr, int32_t index) {
    QToolBox* toolbox = reinterpret_cast<QToolBox*>(ptr);
    if (toolbox) {
        toolbox->removeItem(index);
    }
}

int32_t qToolBoxCount(int64_t ptr) {
    QToolBox* toolbox = reinterpret_cast<QToolBox*>(ptr);
    return toolbox ? toolbox->count() : 0;
}

int32_t qToolBoxCurrentIndex(int64_t ptr) {
    QToolBox* toolbox = reinterpret_cast<QToolBox*>(ptr);
    return toolbox ? toolbox->currentIndex() : -1;
}

void qToolBoxSetCurrentIndex(int64_t ptr, int32_t index) {
    QToolBox* toolbox = reinterpret_cast<QToolBox*>(ptr);
    if (toolbox) {
        toolbox->setCurrentIndex(index);
    }
}

void qToolBoxSetItemText(int64_t ptr, int32_t index, const char* text) {
    QToolBox* toolbox = reinterpret_cast<QToolBox*>(ptr);
    if (toolbox) {
        toolbox->setItemText(index, QString::fromUtf8(text));
    }
}

const char* qToolBoxItemText(int64_t ptr, int32_t index) {
    QToolBox* toolbox = reinterpret_cast<QToolBox*>(ptr);
    if (toolbox) {
        static QString text;
        text = toolbox->itemText(index);
        return text.toUtf8().constData();
    }
    return "";
}

void qToolBoxSetItemToolTip(int64_t ptr, int32_t index, const char* toolTip) {
    QToolBox* toolbox = reinterpret_cast<QToolBox*>(ptr);
    if (toolbox) {
        toolbox->setItemToolTip(index, QString::fromUtf8(toolTip));
    }
}

void qToolBoxSetItemEnabled(int64_t ptr, int32_t index, int32_t enabled) {
    QToolBox* toolbox = reinterpret_cast<QToolBox*>(ptr);
    if (toolbox) {
        toolbox->setItemEnabled(index, enabled != 0);
    }
}

int32_t qToolBoxIsItemEnabled(int64_t ptr, int32_t index) {
    QToolBox* toolbox = reinterpret_cast<QToolBox*>(ptr);
    if (toolbox) {
        return toolbox->isItemEnabled(index) ? 1 : 0;
    }
    return 0;
}

// ============================================================
// QMdiArea 桥接函数
// ============================================================

int64_t qMdiAreaCreate() {
    QMdiArea* mdiArea = new QMdiArea();
    return reinterpret_cast<int64_t>(mdiArea);
}

void qMdiAreaDelete(int64_t ptr) {
    QMdiArea* mdiArea = reinterpret_cast<QMdiArea*>(ptr);
    if (mdiArea) {
        delete mdiArea;
    }
}

int64_t qMdiAreaAddSubWindow(int64_t ptr, int64_t widgetPtr) {
    QMdiArea* mdiArea = reinterpret_cast<QMdiArea*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (mdiArea && widget) {
        QMdiSubWindow* subWin = mdiArea->addSubWindow(widget);
        return reinterpret_cast<int64_t>(subWin);
    }
    return 0;
}

void qMdiAreaRemoveSubWindow(int64_t ptr, int64_t subWinPtr) {
    QMdiArea* mdiArea = reinterpret_cast<QMdiArea*>(ptr);
    QMdiSubWindow* subWin = reinterpret_cast<QMdiSubWindow*>(subWinPtr);
    if (mdiArea && subWin) {
        mdiArea->removeSubWindow(subWin);
    }
}

int64_t qMdiAreaCurrentSubWindow(int64_t ptr) {
    QMdiArea* mdiArea = reinterpret_cast<QMdiArea*>(ptr);
    if (mdiArea) {
        return reinterpret_cast<int64_t>(mdiArea->currentSubWindow());
    }
    return 0;
}

void qMdiAreaCascadeSubWindows(int64_t ptr) {
    QMdiArea* mdiArea = reinterpret_cast<QMdiArea*>(ptr);
    if (mdiArea) {
        mdiArea->cascadeSubWindows();
    }
}

void qMdiAreaTileSubWindows(int64_t ptr) {
    QMdiArea* mdiArea = reinterpret_cast<QMdiArea*>(ptr);
    if (mdiArea) {
        mdiArea->tileSubWindows();
    }
}

void qMdiAreaCloseAllSubWindows(int64_t ptr) {
    QMdiArea* mdiArea = reinterpret_cast<QMdiArea*>(ptr);
    if (mdiArea) {
        mdiArea->closeAllSubWindows();
    }
}

void qMdiAreaSetViewMode(int64_t ptr, int32_t mode) {
    QMdiArea* mdiArea = reinterpret_cast<QMdiArea*>(ptr);
    if (mdiArea) {
        mdiArea->setViewMode(static_cast<QMdiArea::ViewMode>(mode));
    }
}

// ============================================================
// QMdiSubWindow 桥接函数
// ============================================================

void qMdiSubWindowSetWidget(int64_t ptr, int64_t widgetPtr) {
    QMdiSubWindow* subWin = reinterpret_cast<QMdiSubWindow*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (subWin && widget) {
        subWin->setWidget(widget);
    }
}

int64_t qMdiSubWindowWidget(int64_t ptr) {
    QMdiSubWindow* subWin = reinterpret_cast<QMdiSubWindow*>(ptr);
    if (subWin) {
        return reinterpret_cast<int64_t>(subWin->widget());
    }
    return 0;
}

void qMdiSubWindowDelete(int64_t ptr) {
    QMdiSubWindow* subWin = reinterpret_cast<QMdiSubWindow*>(ptr);
    if (subWin) {
        delete subWin;
    }
}

// ============================================================
// QDockWidget 桥接函数
// ============================================================

int64_t qDockWidgetCreate(const char* title) {
    QDockWidget* dock = new QDockWidget(QString::fromUtf8(title));
    return reinterpret_cast<int64_t>(dock);
}

void qDockWidgetDelete(int64_t ptr) {
    QDockWidget* dock = reinterpret_cast<QDockWidget*>(ptr);
    if (dock) {
        delete dock;
    }
}

void qDockWidgetSetWidget(int64_t ptr, int64_t widgetPtr) {
    QDockWidget* dock = reinterpret_cast<QDockWidget*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (dock && widget) {
        dock->setWidget(widget);
    }
}

int64_t qDockWidgetWidget(int64_t ptr) {
    QDockWidget* dock = reinterpret_cast<QDockWidget*>(ptr);
    if (dock) {
        return reinterpret_cast<int64_t>(dock->widget());
    }
    return 0;
}

void qDockWidgetSetWindowTitle(int64_t ptr, const char* title) {
    QDockWidget* dock = reinterpret_cast<QDockWidget*>(ptr);
    if (dock) {
        dock->setWindowTitle(QString::fromUtf8(title));
    }
}

void qDockWidgetSetAllowedAreas(int64_t ptr, int32_t areas) {
    QDockWidget* dock = reinterpret_cast<QDockWidget*>(ptr);
    if (dock) {
        dock->setAllowedAreas(static_cast<Qt::DockWidgetAreas>(areas));
    }
}

void qDockWidgetSetFeatures(int64_t ptr, int32_t features) {
    QDockWidget* dock = reinterpret_cast<QDockWidget*>(ptr);
    if (dock) {
        dock->setFeatures(static_cast<QDockWidget::DockWidgetFeatures>(features));
    }
}

void qDockWidgetSetFloating(int64_t ptr, int32_t floating) {
    QDockWidget* dock = reinterpret_cast<QDockWidget*>(ptr);
    if (dock) {
        dock->setFloating(floating != 0);
    }
}

int32_t qDockWidgetIsFloating(int64_t ptr) {
    QDockWidget* dock = reinterpret_cast<QDockWidget*>(ptr);
    if (dock) {
        return dock->isFloating() ? 1 : 0;
    }
    return 0;
}

} // extern "C"
