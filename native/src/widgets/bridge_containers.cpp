/**
 * @file bridge_containers.cpp
 * @brief 容器部件桥接函数 - QGroupBox, QTabWidget, QScrollArea, QFrame
 */

#include <QGroupBox>
#include <QTabWidget>
#include <QScrollArea>
#include <QFrame>
#include <QVBoxLayout>

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

void qTabWidgetDelete(int64_t ptr) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget) {
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

} // extern "C"
// ============================================================
// QSplitter 桥接函数
// ============================================================

#include <QSplitter>

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

