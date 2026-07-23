/**
 * @file bridge_ext_views.cpp
 * @brief v1.2.0 API 补全扩展 - Model/View 批次（由子代理填充）。
 *
 * 风格与 bridge_ext_new.cpp 一致：
 *   - 入参 ptr 做空指针校验；
 *   - 字符串返回使用 static QString + toUtf8().constData()；
 *   - 信号通过 std::unordered_map 注册回调，connect 前做去重保护。
 * 注意：QModelIndex 句柄统一以 QPersistentModelIndex*（堆分配）表示，
 * 以便文件系统模型返回的索引也兼容。索引句柄在显式 getter 中由调用者负责
 * 释放（qModelIndexDelete）；信号回调中传入的索引仅在回调内有效（回调返回后即释放）。
 */

#include <QWidget>
#include <QListView>
#include <QListWidget>
#include <QListWidgetItem>
#include <QTableView>
#include <QTableWidget>
#include <QTableWidgetItem>
#include <QTreeView>
#include <QTreeWidget>
#include <QTreeWidgetItem>
#include <QFileSystemModel>
#include <QStandardItemModel>
#include <QStandardItem>
#include <QHeaderView>
#include <QAbstractItemView>
#include <QAbstractItemModel>
#include <QPersistentModelIndex>
#include <QModelIndex>
#include <QString>
#include <QStringList>
#include <QColor>
#include <QBrush>
#include <QVariant>
#include <functional>
#include <unordered_map>

extern "C" {

// ============================================================
// QModelIndex 句柄辅助（统一以 QPersistentModelIndex* 表示）
// ============================================================

int32_t qModelIndexRow(int64_t ptr) {
    QPersistentModelIndex* idx = reinterpret_cast<QPersistentModelIndex*>(ptr);
    return idx ? static_cast<int32_t>(idx->row()) : -1;
}

int32_t qModelIndexColumn(int64_t ptr) {
    QPersistentModelIndex* idx = reinterpret_cast<QPersistentModelIndex*>(ptr);
    return idx ? static_cast<int32_t>(idx->column()) : -1;
}

int32_t qModelIndexIsValid(int64_t ptr) {
    QPersistentModelIndex* idx = reinterpret_cast<QPersistentModelIndex*>(ptr);
    return idx && idx->isValid() ? 1 : 0;
}

void qModelIndexDelete(int64_t ptr) {
    QPersistentModelIndex* idx = reinterpret_cast<QPersistentModelIndex*>(ptr);
    if (idx) delete idx;
}

// ============================================================
// QListView 补充 API
// ============================================================

int32_t qListViewSelectionMode(int64_t ptr) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    return v ? static_cast<int32_t>(v->selectionMode()) : 0;
}

void qListViewSetEditTriggers(int64_t ptr, int32_t v) {
    QListView* pv = reinterpret_cast<QListView*>(ptr);
    if (pv) pv->setEditTriggers(static_cast<QAbstractItemView::EditTriggers>(v));
}

int32_t qListViewEditTriggers(int64_t ptr) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    return v ? static_cast<int32_t>(v->editTriggers()) : 0;
}

void qListViewSetViewMode(int64_t ptr, int32_t v) {
    QListView* pv = reinterpret_cast<QListView*>(ptr);
    if (pv) pv->setViewMode(static_cast<QListView::ViewMode>(v));
}

int32_t qListViewViewMode(int64_t ptr) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    return v ? static_cast<int32_t>(v->viewMode()) : 0;
}

void qListViewSetMovement(int64_t ptr, int32_t v) {
    QListView* pv = reinterpret_cast<QListView*>(ptr);
    if (pv) pv->setMovement(static_cast<QListView::Movement>(v));
}

int32_t qListViewMovement(int64_t ptr) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    return v ? static_cast<int32_t>(v->movement()) : 0;
}

void qListViewSetFlow(int64_t ptr, int32_t v) {
    QListView* pv = reinterpret_cast<QListView*>(ptr);
    if (pv) pv->setFlow(static_cast<QListView::Flow>(v));
}

int32_t qListViewFlow(int64_t ptr) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    return v ? static_cast<int32_t>(v->flow()) : 0;
}

void qListViewSetWrapping(int64_t ptr, int32_t v) {
    QListView* pv = reinterpret_cast<QListView*>(ptr);
    if (pv) pv->setWrapping(v != 0);
}

int32_t qListViewIsWrapping(int64_t ptr) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    return v ? (v->isWrapping() ? 1 : 0) : 0;
}

void qListViewSetSpacing(int64_t ptr, int32_t v) {
    QListView* pv = reinterpret_cast<QListView*>(ptr);
    if (pv) pv->setSpacing(v);
}

int32_t qListViewSpacing(int64_t ptr) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    return v ? static_cast<int32_t>(v->spacing()) : 0;
}

void qListViewSetResizeMode(int64_t ptr, int32_t v) {
    QListView* pv = reinterpret_cast<QListView*>(ptr);
    if (pv) pv->setResizeMode(static_cast<QListView::ResizeMode>(v));
}

int32_t qListViewResizeMode(int64_t ptr) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    return v ? static_cast<int32_t>(v->resizeMode()) : 0;
}

void qListViewSetWordWrap(int64_t ptr, int32_t v) {
    QListView* pv = reinterpret_cast<QListView*>(ptr);
    if (pv) pv->setWordWrap(v != 0);
}

int32_t qListViewIsWordWrap(int64_t ptr) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    return v ? (v->wordWrap() ? 1 : 0) : 0;
}

void qListViewSetUniformItemSizes(int64_t ptr, int32_t v) {
    QListView* pv = reinterpret_cast<QListView*>(ptr);
    if (pv) pv->setUniformItemSizes(v != 0);
}

int32_t qListViewUniformItemSizes(int64_t ptr) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    return v ? (v->uniformItemSizes() ? 1 : 0) : 0;
}

void qListViewSetCurrentIndex(int64_t ptr, int64_t indexPtr) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    if (v && indexPtr) v->setCurrentIndex(*reinterpret_cast<QPersistentModelIndex*>(indexPtr));
}

int64_t qListViewCurrentIndex(int64_t ptr) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    if (v) return reinterpret_cast<int64_t>(new QPersistentModelIndex(v->currentIndex()));
    return 0;
}

void qListViewSetRootIndex(int64_t ptr, int64_t indexPtr) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    if (v && indexPtr) v->setRootIndex(*reinterpret_cast<QPersistentModelIndex*>(indexPtr));
}

int64_t qListViewRootIndex(int64_t ptr) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    if (v) return reinterpret_cast<int64_t>(new QPersistentModelIndex(v->rootIndex()));
    return 0;
}

// QListView 信号回调映射
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_lvClicked;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_lvDoubleClicked;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_lvActivated;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_lvPressed;

void qListViewConnectClicked(int64_t ptr, void (*cb)(int64_t)) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    if (v && cb && g_lvClicked.find(ptr) == g_lvClicked.end()) {
        g_lvClicked[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(v, &QListView::clicked, [ptr](const QModelIndex& index) {
            auto it = g_lvClicked.find(ptr);
            if (it != g_lvClicked.end()) {
                auto* idx = new QPersistentModelIndex(index);
                it->second(reinterpret_cast<int64_t>(idx));
                delete idx;
            }
        });
    }
}

void qListViewConnectDoubleClicked(int64_t ptr, void (*cb)(int64_t)) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    if (v && cb && g_lvDoubleClicked.find(ptr) == g_lvDoubleClicked.end()) {
        g_lvDoubleClicked[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(v, &QListView::doubleClicked, [ptr](const QModelIndex& index) {
            auto it = g_lvDoubleClicked.find(ptr);
            if (it != g_lvDoubleClicked.end()) {
                auto* idx = new QPersistentModelIndex(index);
                it->second(reinterpret_cast<int64_t>(idx));
                delete idx;
            }
        });
    }
}

void qListViewConnectActivated(int64_t ptr, void (*cb)(int64_t)) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    if (v && cb && g_lvActivated.find(ptr) == g_lvActivated.end()) {
        g_lvActivated[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(v, &QListView::activated, [ptr](const QModelIndex& index) {
            auto it = g_lvActivated.find(ptr);
            if (it != g_lvActivated.end()) {
                auto* idx = new QPersistentModelIndex(index);
                it->second(reinterpret_cast<int64_t>(idx));
                delete idx;
            }
        });
    }
}

void qListViewConnectPressed(int64_t ptr, void (*cb)(int64_t)) {
    QListView* v = reinterpret_cast<QListView*>(ptr);
    if (v && cb && g_lvPressed.find(ptr) == g_lvPressed.end()) {
        g_lvPressed[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(v, &QListView::pressed, [ptr](const QModelIndex& index) {
            auto it = g_lvPressed.find(ptr);
            if (it != g_lvPressed.end()) {
                auto* idx = new QPersistentModelIndex(index);
                it->second(reinterpret_cast<int64_t>(idx));
                delete idx;
            }
        });
    }
}

// ============================================================
// QListWidget 补充 API
// ============================================================

void qListWidgetAddItems(int64_t ptr, const char* items) {
    QListWidget* w = reinterpret_cast<QListWidget*>(ptr);
    if (w && items) {
        QStringList list = QString::fromUtf8(items).split("\n");
        for (const QString& s : list) w->addItem(s);
    }
}

int64_t qListWidgetItem(int64_t ptr, int32_t row) {
    QListWidget* w = reinterpret_cast<QListWidget*>(ptr);
    if (w) return reinterpret_cast<int64_t>(w->item(row));
    return 0;
}

int64_t qListWidgetTakeItem(int64_t ptr, int32_t row) {
    QListWidget* w = reinterpret_cast<QListWidget*>(ptr);
    if (w) return reinterpret_cast<int64_t>(w->takeItem(row));
    return 0;
}

void qListWidgetRemoveItemWidget(int64_t ptr, int64_t itemPtr) {
    QListWidget* w = reinterpret_cast<QListWidget*>(ptr);
    if (w) w->removeItemWidget(reinterpret_cast<QListWidgetItem*>(itemPtr));
}

void qListWidgetSetCurrentItem(int64_t ptr, int64_t itemPtr) {
    QListWidget* w = reinterpret_cast<QListWidget*>(ptr);
    if (w) w->setCurrentItem(reinterpret_cast<QListWidgetItem*>(itemPtr));
}

void qListWidgetSetViewMode(int64_t ptr, int32_t v) {
    QListWidget* w = reinterpret_cast<QListWidget*>(ptr);
    if (w) w->setViewMode(static_cast<QListView::ViewMode>(v));
}

// QListWidget 信号回调映射
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_lwCurrentRowChanged;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_lwItemClicked;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_lwItemDoubleClicked;
static std::unordered_map<int64_t, std::function<void()>> g_lwItemSelectionChanged;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_lwCurrentItemChanged;

void qListWidgetConnectCurrentRowChanged(int64_t ptr, void (*cb)(int32_t)) {
    QListWidget* w = reinterpret_cast<QListWidget*>(ptr);
    if (w && cb && g_lwCurrentRowChanged.find(ptr) == g_lwCurrentRowChanged.end()) {
        g_lwCurrentRowChanged[ptr] = [cb](int32_t r) { cb(r); };
        QObject::connect(w, &QListWidget::currentRowChanged, [ptr](int row) {
            auto it = g_lwCurrentRowChanged.find(ptr);
            if (it != g_lwCurrentRowChanged.end()) it->second(static_cast<int32_t>(row));
        });
    }
}

void qListWidgetConnectItemClicked(int64_t ptr, void (*cb)(int64_t)) {
    QListWidget* w = reinterpret_cast<QListWidget*>(ptr);
    if (w && cb && g_lwItemClicked.find(ptr) == g_lwItemClicked.end()) {
        g_lwItemClicked[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(w, &QListWidget::itemClicked, [ptr](QListWidgetItem* item) {
            auto it = g_lwItemClicked.find(ptr);
            if (it != g_lwItemClicked.end()) it->second(reinterpret_cast<int64_t>(item));
        });
    }
}

void qListWidgetConnectItemDoubleClicked(int64_t ptr, void (*cb)(int64_t)) {
    QListWidget* w = reinterpret_cast<QListWidget*>(ptr);
    if (w && cb && g_lwItemDoubleClicked.find(ptr) == g_lwItemDoubleClicked.end()) {
        g_lwItemDoubleClicked[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(w, &QListWidget::itemDoubleClicked, [ptr](QListWidgetItem* item) {
            auto it = g_lwItemDoubleClicked.find(ptr);
            if (it != g_lwItemDoubleClicked.end()) it->second(reinterpret_cast<int64_t>(item));
        });
    }
}

void qListWidgetConnectItemSelectionChanged(int64_t ptr, void (*cb)()) {
    QListWidget* w = reinterpret_cast<QListWidget*>(ptr);
    if (w && cb && g_lwItemSelectionChanged.find(ptr) == g_lwItemSelectionChanged.end()) {
        g_lwItemSelectionChanged[ptr] = [cb]() { cb(); };
        QObject::connect(w, &QListWidget::itemSelectionChanged, [ptr]() {
            auto it = g_lwItemSelectionChanged.find(ptr);
            if (it != g_lwItemSelectionChanged.end()) it->second();
        });
    }
}

void qListWidgetConnectCurrentItemChanged(int64_t ptr, void (*cb)(int64_t)) {
    QListWidget* w = reinterpret_cast<QListWidget*>(ptr);
    if (w && cb && g_lwCurrentItemChanged.find(ptr) == g_lwCurrentItemChanged.end()) {
        g_lwCurrentItemChanged[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(w, &QListWidget::currentItemChanged, [ptr](QListWidgetItem* current, QListWidgetItem*) {
            auto it = g_lwCurrentItemChanged.find(ptr);
            if (it != g_lwCurrentItemChanged.end()) it->second(reinterpret_cast<int64_t>(current));
        });
    }
}

// ============================================================
// QListWidgetItem（新增最小封装）
// ============================================================

int64_t qListWidgetItemCreate() {
    return reinterpret_cast<int64_t>(new QListWidgetItem());
}

int64_t qListWidgetItemCreateWithText(const char* text) {
    return reinterpret_cast<int64_t>(new QListWidgetItem(QString::fromUtf8(text)));
}

void qListWidgetItemDelete(int64_t itemPtr) {
    QListWidgetItem* item = reinterpret_cast<QListWidgetItem*>(itemPtr);
    if (item) delete item;
}

void qListWidgetItemSetText(int64_t itemPtr, const char* text) {
    QListWidgetItem* item = reinterpret_cast<QListWidgetItem*>(itemPtr);
    if (item) item->setText(QString::fromUtf8(text));
}

const char* qListWidgetItemGetText(int64_t itemPtr) {
    QListWidgetItem* item = reinterpret_cast<QListWidgetItem*>(itemPtr);
    if (item) {
        static QString s;
        s = item->text();
        return s.toUtf8().constData();
    }
    return "";
}

void qListWidgetItemSetFlags(int64_t itemPtr, int32_t flags) {
    QListWidgetItem* item = reinterpret_cast<QListWidgetItem*>(itemPtr);
    if (item) item->setFlags(static_cast<Qt::ItemFlags>(flags));
}

int32_t qListWidgetItemFlags(int64_t itemPtr) {
    QListWidgetItem* item = reinterpret_cast<QListWidgetItem*>(itemPtr);
    return item ? static_cast<int32_t>(item->flags()) : 0;
}

void qListWidgetItemSetCheckState(int64_t itemPtr, int32_t state) {
    QListWidgetItem* item = reinterpret_cast<QListWidgetItem*>(itemPtr);
    if (item) item->setCheckState(state == 0 ? Qt::Unchecked : (state == 1 ? Qt::PartiallyChecked : Qt::Checked));
}

int32_t qListWidgetItemCheckState(int64_t itemPtr) {
    QListWidgetItem* item = reinterpret_cast<QListWidgetItem*>(itemPtr);
    if (item) {
        Qt::CheckState s = item->checkState();
        return s == Qt::Unchecked ? 0 : (s == Qt::PartiallyChecked ? 1 : 2);
    }
    return 0;
}

void qListWidgetItemSetData(int64_t itemPtr, int32_t role, int64_t value) {
    QListWidgetItem* item = reinterpret_cast<QListWidgetItem*>(itemPtr);
    if (item) item->setData(role, QVariant::fromValue(value));
}

int64_t qListWidgetItemData(int64_t itemPtr, int32_t role) {
    QListWidgetItem* item = reinterpret_cast<QListWidgetItem*>(itemPtr);
    if (item) return item->data(role).toLongLong();
    return 0;
}

// ============================================================
// QTableView 补充 API
// ============================================================

void qTableViewSetEditTriggers(int64_t ptr, int32_t v) {
    QTableView* pv = reinterpret_cast<QTableView*>(ptr);
    if (pv) pv->setEditTriggers(static_cast<QAbstractItemView::EditTriggers>(v));
}

int32_t qTableViewEditTriggers(int64_t ptr) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    return v ? static_cast<int32_t>(v->editTriggers()) : 0;
}

int32_t qTableViewIsShowGrid(int64_t ptr) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    return v ? (v->showGrid() ? 1 : 0) : 0;
}

void qTableViewSetGridStyle(int64_t ptr, int32_t v) {
    QTableView* pv = reinterpret_cast<QTableView*>(ptr);
    if (pv) pv->setGridStyle(static_cast<Qt::PenStyle>(v));
}

int32_t qTableViewGridStyle(int64_t ptr) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    return v ? static_cast<int32_t>(v->gridStyle()) : 0;
}

void qTableViewSetCornerButtonEnabled(int64_t ptr, int32_t v) {
    QTableView* pv = reinterpret_cast<QTableView*>(ptr);
    if (pv) pv->setCornerButtonEnabled(v != 0);
}

int32_t qTableViewIsCornerButtonEnabled(int64_t ptr) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    return v ? (v->isCornerButtonEnabled() ? 1 : 0) : 0;
}

int32_t qTableViewIsSortingEnabled(int64_t ptr) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    return v ? (v->isSortingEnabled() ? 1 : 0) : 0;
}

void qTableViewResizeColumnToContents(int64_t ptr, int32_t col) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    if (v) v->resizeColumnToContents(col);
}

void qTableViewSetHorizontalHeader(int64_t ptr, int64_t headerPtr) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    if (v && headerPtr) v->setHorizontalHeader(reinterpret_cast<QHeaderView*>(headerPtr));
}

void qTableViewSetVerticalHeader(int64_t ptr, int64_t headerPtr) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    if (v && headerPtr) v->setVerticalHeader(reinterpret_cast<QHeaderView*>(headerPtr));
}

void qTableViewSetWordWrap(int64_t ptr, int32_t v) {
    QTableView* pv = reinterpret_cast<QTableView*>(ptr);
    if (pv) pv->setWordWrap(v != 0);
}

int32_t qTableViewIsWordWrap(int64_t ptr) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    return v ? (v->wordWrap() ? 1 : 0) : 0;
}

int32_t qTableViewRowAt(int64_t ptr, int32_t y) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    return v ? static_cast<int32_t>(v->rowAt(y)) : -1;
}

int32_t qTableViewColumnAt(int64_t ptr, int32_t x) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    return v ? static_cast<int32_t>(v->columnAt(x)) : -1;
}

void qTableViewSetCurrentIndex(int64_t ptr, int64_t indexPtr) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    if (v && indexPtr) v->setCurrentIndex(*reinterpret_cast<QPersistentModelIndex*>(indexPtr));
}

int64_t qTableViewCurrentIndex(int64_t ptr) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    if (v) return reinterpret_cast<int64_t>(new QPersistentModelIndex(v->currentIndex()));
    return 0;
}

// QTableView 信号回调映射
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_tvClicked;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_tvDoubleClicked;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_tvActivated;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_tvPressed;

void qTableViewConnectClicked(int64_t ptr, void (*cb)(int64_t)) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    if (v && cb && g_tvClicked.find(ptr) == g_tvClicked.end()) {
        g_tvClicked[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(v, &QTableView::clicked, [ptr](const QModelIndex& index) {
            auto it = g_tvClicked.find(ptr);
            if (it != g_tvClicked.end()) {
                auto* idx = new QPersistentModelIndex(index);
                it->second(reinterpret_cast<int64_t>(idx));
                delete idx;
            }
        });
    }
}

void qTableViewConnectDoubleClicked(int64_t ptr, void (*cb)(int64_t)) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    if (v && cb && g_tvDoubleClicked.find(ptr) == g_tvDoubleClicked.end()) {
        g_tvDoubleClicked[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(v, &QTableView::doubleClicked, [ptr](const QModelIndex& index) {
            auto it = g_tvDoubleClicked.find(ptr);
            if (it != g_tvDoubleClicked.end()) {
                auto* idx = new QPersistentModelIndex(index);
                it->second(reinterpret_cast<int64_t>(idx));
                delete idx;
            }
        });
    }
}

void qTableViewConnectActivated(int64_t ptr, void (*cb)(int64_t)) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    if (v && cb && g_tvActivated.find(ptr) == g_tvActivated.end()) {
        g_tvActivated[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(v, &QTableView::activated, [ptr](const QModelIndex& index) {
            auto it = g_tvActivated.find(ptr);
            if (it != g_tvActivated.end()) {
                auto* idx = new QPersistentModelIndex(index);
                it->second(reinterpret_cast<int64_t>(idx));
                delete idx;
            }
        });
    }
}

void qTableViewConnectPressed(int64_t ptr, void (*cb)(int64_t)) {
    QTableView* v = reinterpret_cast<QTableView*>(ptr);
    if (v && cb && g_tvPressed.find(ptr) == g_tvPressed.end()) {
        g_tvPressed[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(v, &QTableView::pressed, [ptr](const QModelIndex& index) {
            auto it = g_tvPressed.find(ptr);
            if (it != g_tvPressed.end()) {
                auto* idx = new QPersistentModelIndex(index);
                it->second(reinterpret_cast<int64_t>(idx));
                delete idx;
            }
        });
    }
}

// ============================================================
// QTableWidget 补充 API
// ============================================================

int64_t qTableWidgetItem(int64_t ptr, int32_t row, int32_t col) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w) return reinterpret_cast<int64_t>(w->item(row, col));
    return 0;
}

int64_t qTableWidgetTakeItem(int64_t ptr, int32_t row, int32_t col) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w) return reinterpret_cast<int64_t>(w->takeItem(row, col));
    return 0;
}

void qTableWidgetSetItemPtr(int64_t ptr, int32_t row, int32_t col, int64_t itemPtr) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w && itemPtr) w->setItem(row, col, reinterpret_cast<QTableWidgetItem*>(itemPtr));
}

void qTableWidgetSetHorizontalHeaderItem(int64_t ptr, int32_t col, int64_t itemPtr) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w && itemPtr) w->setHorizontalHeaderItem(col, reinterpret_cast<QTableWidgetItem*>(itemPtr));
}

void qTableWidgetSetVerticalHeaderItem(int64_t ptr, int32_t row, int64_t itemPtr) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w && itemPtr) w->setVerticalHeaderItem(row, reinterpret_cast<QTableWidgetItem*>(itemPtr));
}

void qTableWidgetSetHorizontalHeaderLabels(int64_t ptr, const char* labels) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w && labels) {
        QStringList list = QString::fromUtf8(labels).split("\n");
        w->setHorizontalHeaderLabels(list);
    }
}

int32_t qTableWidgetSelectedRanges(int64_t ptr) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    return w ? static_cast<int32_t>(w->selectedRanges().size()) : 0;
}

int32_t qTableWidgetFindItems(int64_t ptr, const char* text, int32_t flags) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w) return static_cast<int32_t>(w->findItems(QString::fromUtf8(text), static_cast<Qt::MatchFlags>(flags)).size());
    return 0;
}

void qTableWidgetSetEditTriggers(int64_t ptr, int32_t v) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w) w->setEditTriggers(static_cast<QAbstractItemView::EditTriggers>(v));
}

int32_t qTableWidgetEditTriggers(int64_t ptr) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    return w ? static_cast<int32_t>(w->editTriggers()) : 0;
}

void qTableWidgetSetGridStyle(int64_t ptr, int32_t v) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w) w->setGridStyle(static_cast<Qt::PenStyle>(v));
}

int32_t qTableWidgetGridStyle(int64_t ptr) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    return w ? static_cast<int32_t>(w->gridStyle()) : 0;
}

void qTableWidgetSetCornerButtonEnabled(int64_t ptr, int32_t v) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w) w->setCornerButtonEnabled(v != 0);
}

int32_t qTableWidgetIsCornerButtonEnabled(int64_t ptr) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    return w ? (w->isCornerButtonEnabled() ? 1 : 0) : 0;
}

int32_t qTableWidgetIsSortingEnabled(int64_t ptr) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    return w ? (w->isSortingEnabled() ? 1 : 0) : 0;
}

void qTableWidgetResizeColumnToContents(int64_t ptr, int32_t col) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w) w->resizeColumnToContents(col);
}

void qTableWidgetSetHorizontalHeader(int64_t ptr, int64_t headerPtr) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w && headerPtr) w->setHorizontalHeader(reinterpret_cast<QHeaderView*>(headerPtr));
}

void qTableWidgetSetVerticalHeader(int64_t ptr, int64_t headerPtr) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w && headerPtr) w->setVerticalHeader(reinterpret_cast<QHeaderView*>(headerPtr));
}

void qTableWidgetSetWordWrap(int64_t ptr, int32_t v) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w) w->setWordWrap(v != 0);
}

int32_t qTableWidgetIsWordWrap(int64_t ptr) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    return w ? (w->wordWrap() ? 1 : 0) : 0;
}

int32_t qTableWidgetRowAt(int64_t ptr, int32_t y) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    return w ? static_cast<int32_t>(w->rowAt(y)) : -1;
}

int32_t qTableWidgetColumnAt(int64_t ptr, int32_t x) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    return w ? static_cast<int32_t>(w->columnAt(x)) : -1;
}

void qTableWidgetSetCurrentIndex(int64_t ptr, int64_t indexPtr) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w && indexPtr) w->setCurrentIndex(*reinterpret_cast<QPersistentModelIndex*>(indexPtr));
}

int64_t qTableWidgetCurrentIndex(int64_t ptr) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w) return reinterpret_cast<int64_t>(new QPersistentModelIndex(w->currentIndex()));
    return 0;
}

// QTableWidget 信号回调映射
static std::unordered_map<int64_t, std::function<void(int32_t, int32_t)>> g_twCellClicked;
static std::unordered_map<int64_t, std::function<void(int32_t, int32_t)>> g_twCellChanged;
static std::unordered_map<int64_t, std::function<void(int32_t, int32_t)>> g_twCellDoubleClicked;
static std::unordered_map<int64_t, std::function<void(int32_t, int32_t)>> g_twCurrentCellChanged;
static std::unordered_map<int64_t, std::function<void()>> g_twItemSelectionChanged;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_twItemClicked;

void qTableWidgetConnectCellClicked(int64_t ptr, void (*cb)(int32_t, int32_t)) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w && cb && g_twCellClicked.find(ptr) == g_twCellClicked.end()) {
        g_twCellClicked[ptr] = [cb](int32_t r, int32_t c) { cb(r, c); };
        QObject::connect(w, &QTableWidget::cellClicked, [ptr](int row, int column) {
            auto it = g_twCellClicked.find(ptr);
            if (it != g_twCellClicked.end()) it->second(static_cast<int32_t>(row), static_cast<int32_t>(column));
        });
    }
}

void qTableWidgetConnectCellChanged(int64_t ptr, void (*cb)(int32_t, int32_t)) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w && cb && g_twCellChanged.find(ptr) == g_twCellChanged.end()) {
        g_twCellChanged[ptr] = [cb](int32_t r, int32_t c) { cb(r, c); };
        QObject::connect(w, &QTableWidget::cellChanged, [ptr](int row, int column) {
            auto it = g_twCellChanged.find(ptr);
            if (it != g_twCellChanged.end()) it->second(static_cast<int32_t>(row), static_cast<int32_t>(column));
        });
    }
}

void qTableWidgetConnectCellDoubleClicked(int64_t ptr, void (*cb)(int32_t, int32_t)) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w && cb && g_twCellDoubleClicked.find(ptr) == g_twCellDoubleClicked.end()) {
        g_twCellDoubleClicked[ptr] = [cb](int32_t r, int32_t c) { cb(r, c); };
        QObject::connect(w, &QTableWidget::cellDoubleClicked, [ptr](int row, int column) {
            auto it = g_twCellDoubleClicked.find(ptr);
            if (it != g_twCellDoubleClicked.end()) it->second(static_cast<int32_t>(row), static_cast<int32_t>(column));
        });
    }
}

void qTableWidgetConnectCurrentCellChanged(int64_t ptr, void (*cb)(int32_t, int32_t)) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w && cb && g_twCurrentCellChanged.find(ptr) == g_twCurrentCellChanged.end()) {
        g_twCurrentCellChanged[ptr] = [cb](int32_t r, int32_t c) { cb(r, c); };
        QObject::connect(w, &QTableWidget::currentCellChanged, [ptr](int row, int column, int, int) {
            auto it = g_twCurrentCellChanged.find(ptr);
            if (it != g_twCurrentCellChanged.end()) it->second(static_cast<int32_t>(row), static_cast<int32_t>(column));
        });
    }
}

void qTableWidgetConnectItemSelectionChanged(int64_t ptr, void (*cb)()) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w && cb && g_twItemSelectionChanged.find(ptr) == g_twItemSelectionChanged.end()) {
        g_twItemSelectionChanged[ptr] = [cb]() { cb(); };
        QObject::connect(w, &QTableWidget::itemSelectionChanged, [ptr]() {
            auto it = g_twItemSelectionChanged.find(ptr);
            if (it != g_twItemSelectionChanged.end()) it->second();
        });
    }
}

void qTableWidgetConnectItemClicked(int64_t ptr, void (*cb)(int64_t)) {
    QTableWidget* w = reinterpret_cast<QTableWidget*>(ptr);
    if (w && cb && g_twItemClicked.find(ptr) == g_twItemClicked.end()) {
        g_twItemClicked[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(w, &QTableWidget::itemClicked, [ptr](QTableWidgetItem* item) {
            auto it = g_twItemClicked.find(ptr);
            if (it != g_twItemClicked.end()) it->second(reinterpret_cast<int64_t>(item));
        });
    }
}

// ============================================================
// QTableWidgetItem（新增最小封装）
// ============================================================

int64_t qTableWidgetItemCreate() {
    return reinterpret_cast<int64_t>(new QTableWidgetItem());
}

int64_t qTableWidgetItemCreateWithText(const char* text) {
    return reinterpret_cast<int64_t>(new QTableWidgetItem(QString::fromUtf8(text)));
}

void qTableWidgetItemDelete(int64_t itemPtr) {
    QTableWidgetItem* item = reinterpret_cast<QTableWidgetItem*>(itemPtr);
    if (item) delete item;
}

void qTableWidgetItemSetText(int64_t itemPtr, const char* text) {
    QTableWidgetItem* item = reinterpret_cast<QTableWidgetItem*>(itemPtr);
    if (item) item->setText(QString::fromUtf8(text));
}

const char* qTableWidgetItemGetText(int64_t itemPtr) {
    QTableWidgetItem* item = reinterpret_cast<QTableWidgetItem*>(itemPtr);
    if (item) {
        static QString s;
        s = item->text();
        return s.toUtf8().constData();
    }
    return "";
}

void qTableWidgetItemSetFlags(int64_t itemPtr, int32_t flags) {
    QTableWidgetItem* item = reinterpret_cast<QTableWidgetItem*>(itemPtr);
    if (item) item->setFlags(static_cast<Qt::ItemFlags>(flags));
}

int32_t qTableWidgetItemFlags(int64_t itemPtr) {
    QTableWidgetItem* item = reinterpret_cast<QTableWidgetItem*>(itemPtr);
    return item ? static_cast<int32_t>(item->flags()) : 0;
}

void qTableWidgetItemSetCheckState(int64_t itemPtr, int32_t state) {
    QTableWidgetItem* item = reinterpret_cast<QTableWidgetItem*>(itemPtr);
    if (item) item->setCheckState(state == 0 ? Qt::Unchecked : (state == 1 ? Qt::PartiallyChecked : Qt::Checked));
}

int32_t qTableWidgetItemCheckState(int64_t itemPtr) {
    QTableWidgetItem* item = reinterpret_cast<QTableWidgetItem*>(itemPtr);
    if (item) {
        Qt::CheckState s = item->checkState();
        return s == Qt::Unchecked ? 0 : (s == Qt::PartiallyChecked ? 1 : 2);
    }
    return 0;
}

void qTableWidgetItemSetData(int64_t itemPtr, int32_t role, int64_t value) {
    QTableWidgetItem* item = reinterpret_cast<QTableWidgetItem*>(itemPtr);
    if (item) item->setData(role, QVariant::fromValue(value));
}

int64_t qTableWidgetItemData(int64_t itemPtr, int32_t role) {
    QTableWidgetItem* item = reinterpret_cast<QTableWidgetItem*>(itemPtr);
    if (item) return item->data(role).toLongLong();
    return 0;
}

void qTableWidgetItemSetBackground(int64_t itemPtr, int32_t r, int32_t g, int32_t b) {
    QTableWidgetItem* item = reinterpret_cast<QTableWidgetItem*>(itemPtr);
    if (item) item->setBackground(QBrush(QColor(r, g, b)));
}

// ============================================================
// QTreeView 补充 API
// ============================================================

void qTreeViewSetEditTriggers(int64_t ptr, int32_t v) {
    QTreeView* pv = reinterpret_cast<QTreeView*>(ptr);
    if (pv) pv->setEditTriggers(static_cast<QAbstractItemView::EditTriggers>(v));
}

int32_t qTreeViewEditTriggers(int64_t ptr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    return v ? static_cast<int32_t>(v->editTriggers()) : 0;
}

void qTreeViewSetSortingEnabled(int64_t ptr, int32_t v) {
    QTreeView* pv = reinterpret_cast<QTreeView*>(ptr);
    if (pv) pv->setSortingEnabled(v != 0);
}

int32_t qTreeViewIsSortingEnabled(int64_t ptr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    return v ? (v->isSortingEnabled() ? 1 : 0) : 0;
}

void qTreeViewSetAnimated(int64_t ptr, int32_t v) {
    QTreeView* pv = reinterpret_cast<QTreeView*>(ptr);
    if (pv) pv->setAnimated(v != 0);
}

int32_t qTreeViewIsAnimated(int64_t ptr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    return v ? (v->isAnimated() ? 1 : 0) : 0;
}

int32_t qTreeViewIsHeaderHidden(int64_t ptr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    return v ? (v->isHeaderHidden() ? 1 : 0) : 0;
}

void qTreeViewSetUniformRowHeights(int64_t ptr, int32_t v) {
    QTreeView* pv = reinterpret_cast<QTreeView*>(ptr);
    if (pv) pv->setUniformRowHeights(v != 0);
}

int32_t qTreeViewUniformRowHeights(int64_t ptr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    return v ? (v->uniformRowHeights() ? 1 : 0) : 0;
}

void qTreeViewSetItemsExpandable(int64_t ptr, int32_t v) {
    QTreeView* pv = reinterpret_cast<QTreeView*>(ptr);
    if (pv) pv->setItemsExpandable(v != 0);
}

int32_t qTreeViewItemsExpandable(int64_t ptr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    return v ? (v->itemsExpandable() ? 1 : 0) : 0;
}

void qTreeViewSetRootIsDecorated(int64_t ptr, int32_t v) {
    QTreeView* pv = reinterpret_cast<QTreeView*>(ptr);
    if (pv) pv->setRootIsDecorated(v != 0);
}

int32_t qTreeViewRootIsDecorated(int64_t ptr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    return v ? (v->rootIsDecorated() ? 1 : 0) : 0;
}

void qTreeViewSetExpandsOnDoubleClick(int64_t ptr, int32_t v) {
    QTreeView* pv = reinterpret_cast<QTreeView*>(ptr);
    if (pv) pv->setExpandsOnDoubleClick(v != 0);
}

int32_t qTreeViewExpandsOnDoubleClick(int64_t ptr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    return v ? (v->expandsOnDoubleClick() ? 1 : 0) : 0;
}

void qTreeViewExpand(int64_t ptr, int64_t indexPtr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    if (v && indexPtr) v->expand(*reinterpret_cast<QPersistentModelIndex*>(indexPtr));
}

void qTreeViewCollapse(int64_t ptr, int64_t indexPtr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    if (v && indexPtr) v->collapse(*reinterpret_cast<QPersistentModelIndex*>(indexPtr));
}

int32_t qTreeViewIsExpanded(int64_t ptr, int64_t indexPtr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    if (v && indexPtr) return v->isExpanded(*reinterpret_cast<QPersistentModelIndex*>(indexPtr)) ? 1 : 0;
    return 0;
}

void qTreeViewSetColumnWidth(int64_t ptr, int32_t col, int32_t width) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    if (v) v->setColumnWidth(col, width);
}

void qTreeViewSetHeader(int64_t ptr, int64_t headerPtr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    if (v && headerPtr) v->setHeader(reinterpret_cast<QHeaderView*>(headerPtr));
}

void qTreeViewSetCurrentIndex(int64_t ptr, int64_t indexPtr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    if (v && indexPtr) v->setCurrentIndex(*reinterpret_cast<QPersistentModelIndex*>(indexPtr));
}

int64_t qTreeViewCurrentIndex(int64_t ptr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    if (v) return reinterpret_cast<int64_t>(new QPersistentModelIndex(v->currentIndex()));
    return 0;
}

void qTreeViewSetRootIndex(int64_t ptr, int64_t indexPtr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    if (v && indexPtr) v->setRootIndex(*reinterpret_cast<QPersistentModelIndex*>(indexPtr));
}

int64_t qTreeViewRootIndex(int64_t ptr) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    if (v) return reinterpret_cast<int64_t>(new QPersistentModelIndex(v->rootIndex()));
    return 0;
}

// QTreeView 信号回调映射
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_trvClicked;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_trvDoubleClicked;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_trvExpanded;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_trvCollapsed;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_trvActivated;

void qTreeViewConnectClicked(int64_t ptr, void (*cb)(int64_t)) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    if (v && cb && g_trvClicked.find(ptr) == g_trvClicked.end()) {
        g_trvClicked[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(v, &QTreeView::clicked, [ptr](const QModelIndex& index) {
            auto it = g_trvClicked.find(ptr);
            if (it != g_trvClicked.end()) {
                auto* idx = new QPersistentModelIndex(index);
                it->second(reinterpret_cast<int64_t>(idx));
                delete idx;
            }
        });
    }
}

void qTreeViewConnectDoubleClicked(int64_t ptr, void (*cb)(int64_t)) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    if (v && cb && g_trvDoubleClicked.find(ptr) == g_trvDoubleClicked.end()) {
        g_trvDoubleClicked[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(v, &QTreeView::doubleClicked, [ptr](const QModelIndex& index) {
            auto it = g_trvDoubleClicked.find(ptr);
            if (it != g_trvDoubleClicked.end()) {
                auto* idx = new QPersistentModelIndex(index);
                it->second(reinterpret_cast<int64_t>(idx));
                delete idx;
            }
        });
    }
}

void qTreeViewConnectExpanded(int64_t ptr, void (*cb)(int64_t)) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    if (v && cb && g_trvExpanded.find(ptr) == g_trvExpanded.end()) {
        g_trvExpanded[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(v, &QTreeView::expanded, [ptr](const QModelIndex& index) {
            auto it = g_trvExpanded.find(ptr);
            if (it != g_trvExpanded.end()) {
                auto* idx = new QPersistentModelIndex(index);
                it->second(reinterpret_cast<int64_t>(idx));
                delete idx;
            }
        });
    }
}

void qTreeViewConnectCollapsed(int64_t ptr, void (*cb)(int64_t)) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    if (v && cb && g_trvCollapsed.find(ptr) == g_trvCollapsed.end()) {
        g_trvCollapsed[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(v, &QTreeView::collapsed, [ptr](const QModelIndex& index) {
            auto it = g_trvCollapsed.find(ptr);
            if (it != g_trvCollapsed.end()) {
                auto* idx = new QPersistentModelIndex(index);
                it->second(reinterpret_cast<int64_t>(idx));
                delete idx;
            }
        });
    }
}

void qTreeViewConnectActivated(int64_t ptr, void (*cb)(int64_t)) {
    QTreeView* v = reinterpret_cast<QTreeView*>(ptr);
    if (v && cb && g_trvActivated.find(ptr) == g_trvActivated.end()) {
        g_trvActivated[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(v, &QTreeView::activated, [ptr](const QModelIndex& index) {
            auto it = g_trvActivated.find(ptr);
            if (it != g_trvActivated.end()) {
                auto* idx = new QPersistentModelIndex(index);
                it->second(reinterpret_cast<int64_t>(idx));
                delete idx;
            }
        });
    }
}

// ============================================================
// QTreeWidget 补充 API
// ============================================================

int32_t qTreeWidgetColumnCount(int64_t ptr) {
    QTreeWidget* w = reinterpret_cast<QTreeWidget*>(ptr);
    return w ? static_cast<int32_t>(w->columnCount()) : 0;
}

void qTreeWidgetSetHeaderItem(int64_t ptr, int64_t itemPtr) {
    QTreeWidget* w = reinterpret_cast<QTreeWidget*>(ptr);
    if (w && itemPtr) w->setHeaderItem(reinterpret_cast<QTreeWidgetItem*>(itemPtr));
}

int32_t qTreeWidgetIndexOfTopLevelItem(int64_t ptr, int64_t itemPtr) {
    QTreeWidget* w = reinterpret_cast<QTreeWidget*>(ptr);
    if (w && itemPtr) return static_cast<int32_t>(w->indexOfTopLevelItem(reinterpret_cast<QTreeWidgetItem*>(itemPtr)));
    return -1;
}

int32_t qTreeWidgetSelectedItems(int64_t ptr) {
    QTreeWidget* w = reinterpret_cast<QTreeWidget*>(ptr);
    return w ? static_cast<int32_t>(w->selectedItems().size()) : 0;
}

void qTreeWidgetSetSelectionMode(int64_t ptr, int32_t mode) {
    QTreeWidget* w = reinterpret_cast<QTreeWidget*>(ptr);
    if (w) w->setSelectionMode(static_cast<QAbstractItemView::SelectionMode>(mode));
}

// QTreeWidget 信号回调映射（带列号）
static std::unordered_map<int64_t, std::function<void(int64_t, int32_t)>> g_twItemClicked2;
static std::unordered_map<int64_t, std::function<void(int64_t, int32_t)>> g_twItemDoubleClicked2;
static std::unordered_map<int64_t, std::function<void(int64_t, int32_t)>> g_twItemChanged2;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_twCurrentItemChanged2;

void qTreeWidgetConnectItemClicked(int64_t ptr, void (*cb)(int64_t, int32_t)) {
    QTreeWidget* w = reinterpret_cast<QTreeWidget*>(ptr);
    if (w && cb && g_twItemClicked2.find(ptr) == g_twItemClicked2.end()) {
        g_twItemClicked2[ptr] = [cb](int64_t i, int32_t c) { cb(i, c); };
        QObject::connect(w, &QTreeWidget::itemClicked, [ptr](QTreeWidgetItem* item, int column) {
            auto it = g_twItemClicked2.find(ptr);
            if (it != g_twItemClicked2.end()) it->second(reinterpret_cast<int64_t>(item), static_cast<int32_t>(column));
        });
    }
}

void qTreeWidgetConnectItemDoubleClicked(int64_t ptr, void (*cb)(int64_t, int32_t)) {
    QTreeWidget* w = reinterpret_cast<QTreeWidget*>(ptr);
    if (w && cb && g_twItemDoubleClicked2.find(ptr) == g_twItemDoubleClicked2.end()) {
        g_twItemDoubleClicked2[ptr] = [cb](int64_t i, int32_t c) { cb(i, c); };
        QObject::connect(w, &QTreeWidget::itemDoubleClicked, [ptr](QTreeWidgetItem* item, int column) {
            auto it = g_twItemDoubleClicked2.find(ptr);
            if (it != g_twItemDoubleClicked2.end()) it->second(reinterpret_cast<int64_t>(item), static_cast<int32_t>(column));
        });
    }
}

void qTreeWidgetConnectItemChanged(int64_t ptr, void (*cb)(int64_t, int32_t)) {
    QTreeWidget* w = reinterpret_cast<QTreeWidget*>(ptr);
    if (w && cb && g_twItemChanged2.find(ptr) == g_twItemChanged2.end()) {
        g_twItemChanged2[ptr] = [cb](int64_t i, int32_t c) { cb(i, c); };
        QObject::connect(w, &QTreeWidget::itemChanged, [ptr](QTreeWidgetItem* item, int column) {
            auto it = g_twItemChanged2.find(ptr);
            if (it != g_twItemChanged2.end()) it->second(reinterpret_cast<int64_t>(item), static_cast<int32_t>(column));
        });
    }
}

void qTreeWidgetConnectCurrentItemChanged(int64_t ptr, void (*cb)(int64_t)) {
    QTreeWidget* w = reinterpret_cast<QTreeWidget*>(ptr);
    if (w && cb && g_twCurrentItemChanged2.find(ptr) == g_twCurrentItemChanged2.end()) {
        g_twCurrentItemChanged2[ptr] = [cb](int64_t i) { cb(i); };
        QObject::connect(w, &QTreeWidget::currentItemChanged, [ptr](QTreeWidgetItem* current, QTreeWidgetItem*) {
            auto it = g_twCurrentItemChanged2.find(ptr);
            if (it != g_twCurrentItemChanged2.end()) it->second(reinterpret_cast<int64_t>(current));
        });
    }
}

// ============================================================
// QFileSystemModel 补充 API
// ============================================================

void qFileSystemModelSetReadOnly(int64_t ptr, int32_t v) {
    QFileSystemModel* m = reinterpret_cast<QFileSystemModel*>(ptr);
    if (m) m->setReadOnly(v != 0);
}

int32_t qFileSystemModelIsReadOnly(int64_t ptr) {
    QFileSystemModel* m = reinterpret_cast<QFileSystemModel*>(ptr);
    return m ? (m->isReadOnly() ? 1 : 0) : 0;
}

void qFileSystemModelSetNameFilterDisables(int64_t ptr, int32_t v) {
    QFileSystemModel* m = reinterpret_cast<QFileSystemModel*>(ptr);
    if (m) m->setNameFilterDisables(v != 0);
}

void qFileSystemModelSetResolveSymlinks(int64_t ptr, int32_t v) {
    QFileSystemModel* m = reinterpret_cast<QFileSystemModel*>(ptr);
    if (m) m->setResolveSymlinks(v != 0);
}

int32_t qFileSystemModelIsResolveSymlinks(int64_t ptr) {
    QFileSystemModel* m = reinterpret_cast<QFileSystemModel*>(ptr);
    return m ? (m->resolveSymlinks() ? 1 : 0) : 0;
}

const char* qFileSystemModelFilePath(int64_t ptr, int64_t indexPtr) {
    QFileSystemModel* m = reinterpret_cast<QFileSystemModel*>(ptr);
    if (m && indexPtr) {
        static QString s;
        s = m->filePath(*reinterpret_cast<QPersistentModelIndex*>(indexPtr));
        return s.toUtf8().constData();
    }
    return "";
}

const char* qFileSystemModelFileName(int64_t ptr, int64_t indexPtr) {
    QFileSystemModel* m = reinterpret_cast<QFileSystemModel*>(ptr);
    if (m && indexPtr) {
        static QString s;
        s = m->fileName(*reinterpret_cast<QPersistentModelIndex*>(indexPtr));
        return s.toUtf8().constData();
    }
    return "";
}

int32_t qFileSystemModelIsDir(int64_t ptr, int64_t indexPtr) {
    QFileSystemModel* m = reinterpret_cast<QFileSystemModel*>(ptr);
    if (m && indexPtr) return m->isDir(*reinterpret_cast<QPersistentModelIndex*>(indexPtr)) ? 1 : 0;
    return 0;
}

// QFileSystemModel 信号回调映射
static std::unordered_map<int64_t, std::function<void(const char*)>> g_fsmDirectoryLoaded;
static std::unordered_map<int64_t, std::function<void(const char*)>> g_fsmRootPathChanged;

void qFileSystemModelConnectDirectoryLoaded(int64_t ptr, void (*cb)(const char*)) {
    QFileSystemModel* m = reinterpret_cast<QFileSystemModel*>(ptr);
    if (m && cb && g_fsmDirectoryLoaded.find(ptr) == g_fsmDirectoryLoaded.end()) {
        g_fsmDirectoryLoaded[ptr] = [cb](const char* p) { cb(p); };
        QObject::connect(m, &QFileSystemModel::directoryLoaded, [ptr](const QString& path) {
            auto it = g_fsmDirectoryLoaded.find(ptr);
            if (it != g_fsmDirectoryLoaded.end()) {
                static QString s;
                s = path;
                it->second(s.toUtf8().constData());
            }
        });
    }
}

void qFileSystemModelConnectRootPathChanged(int64_t ptr, void (*cb)(const char*)) {
    QFileSystemModel* m = reinterpret_cast<QFileSystemModel*>(ptr);
    if (m && cb && g_fsmRootPathChanged.find(ptr) == g_fsmRootPathChanged.end()) {
        g_fsmRootPathChanged[ptr] = [cb](const char* p) { cb(p); };
        QObject::connect(m, &QFileSystemModel::rootPathChanged, [ptr](const QString& path) {
            auto it = g_fsmRootPathChanged.find(ptr);
            if (it != g_fsmRootPathChanged.end()) {
                static QString s;
                s = path;
                it->second(s.toUtf8().constData());
            }
        });
    }
}

// ============================================================
// QStandardItemModel 补充 API
// ============================================================

int32_t qStandardItemModelSetHeaderData(int64_t ptr, int32_t section, int32_t orientation, int64_t value, int32_t role) {
    QStandardItemModel* m = reinterpret_cast<QStandardItemModel*>(ptr);
    if (m) return m->setHeaderData(section, static_cast<Qt::Orientation>(orientation), QVariant::fromValue(value), role) ? 1 : 0;
    return 0;
}

void qStandardItemModelSetItemPtr(int64_t ptr, int32_t row, int32_t col, int64_t itemPtr) {
    QStandardItemModel* m = reinterpret_cast<QStandardItemModel*>(ptr);
    if (m && itemPtr) m->setItem(row, col, reinterpret_cast<QStandardItem*>(itemPtr));
}

int64_t qStandardItemModelItem(int64_t ptr, int32_t row, int32_t col) {
    QStandardItemModel* m = reinterpret_cast<QStandardItemModel*>(ptr);
    if (m) return reinterpret_cast<int64_t>(m->item(row, col));
    return 0;
}

void qStandardItemModelSetHorizontalHeaderItem(int64_t ptr, int32_t col, int64_t itemPtr) {
    QStandardItemModel* m = reinterpret_cast<QStandardItemModel*>(ptr);
    if (m && itemPtr) m->setHorizontalHeaderItem(col, reinterpret_cast<QStandardItem*>(itemPtr));
}

void qStandardItemModelSetVerticalHeaderItem(int64_t ptr, int32_t row, int64_t itemPtr) {
    QStandardItemModel* m = reinterpret_cast<QStandardItemModel*>(ptr);
    if (m && itemPtr) m->setVerticalHeaderItem(row, reinterpret_cast<QStandardItem*>(itemPtr));
}

void qStandardItemModelAppendRow(int64_t ptr, int64_t itemPtr) {
    QStandardItemModel* m = reinterpret_cast<QStandardItemModel*>(ptr);
    if (m && itemPtr) m->appendRow(reinterpret_cast<QStandardItem*>(itemPtr));
}

void qStandardItemModelInsertRowItem(int64_t ptr, int32_t row, int64_t itemPtr) {
    QStandardItemModel* m = reinterpret_cast<QStandardItemModel*>(ptr);
    if (m && itemPtr) m->insertRow(row, reinterpret_cast<QStandardItem*>(itemPtr));
}

int32_t qStandardItemModelFindItems(int64_t ptr, const char* text, int32_t flags) {
    QStandardItemModel* m = reinterpret_cast<QStandardItemModel*>(ptr);
    if (m) return static_cast<int32_t>(m->findItems(QString::fromUtf8(text), static_cast<Qt::MatchFlags>(flags)).size());
    return 0;
}

int64_t qStandardItemModelItemFromIndex(int64_t ptr, int64_t indexPtr) {
    QStandardItemModel* m = reinterpret_cast<QStandardItemModel*>(ptr);
    if (m && indexPtr) return reinterpret_cast<int64_t>(m->itemFromIndex(*reinterpret_cast<QPersistentModelIndex*>(indexPtr)));
    return 0;
}

int64_t qStandardItemModelIndexFromItem(int64_t ptr, int64_t itemPtr) {
    QStandardItemModel* m = reinterpret_cast<QStandardItemModel*>(ptr);
    if (m && itemPtr) return reinterpret_cast<int64_t>(new QPersistentModelIndex(m->indexFromItem(reinterpret_cast<QStandardItem*>(itemPtr))));
    return 0;
}

// ============================================================
// QStandardItem（新增最小封装）
// ============================================================

int64_t qStandardItemCreate() {
    return reinterpret_cast<int64_t>(new QStandardItem());
}

int64_t qStandardItemCreateWithText(const char* text) {
    return reinterpret_cast<int64_t>(new QStandardItem(QString::fromUtf8(text)));
}

void qStandardItemDelete(int64_t itemPtr) {
    QStandardItem* item = reinterpret_cast<QStandardItem*>(itemPtr);
    if (item) delete item;
}

void qStandardItemSetText(int64_t itemPtr, const char* text) {
    QStandardItem* item = reinterpret_cast<QStandardItem*>(itemPtr);
    if (item) item->setText(QString::fromUtf8(text));
}

const char* qStandardItemGetText(int64_t itemPtr) {
    QStandardItem* item = reinterpret_cast<QStandardItem*>(itemPtr);
    if (item) {
        static QString s;
        s = item->text();
        return s.toUtf8().constData();
    }
    return "";
}

void qStandardItemSetFlags(int64_t itemPtr, int32_t flags) {
    QStandardItem* item = reinterpret_cast<QStandardItem*>(itemPtr);
    if (item) item->setFlags(static_cast<Qt::ItemFlags>(flags));
}

int32_t qStandardItemFlags(int64_t itemPtr) {
    QStandardItem* item = reinterpret_cast<QStandardItem*>(itemPtr);
    return item ? static_cast<int32_t>(item->flags()) : 0;
}

void qStandardItemSetCheckState(int64_t itemPtr, int32_t state) {
    QStandardItem* item = reinterpret_cast<QStandardItem*>(itemPtr);
    if (item) item->setCheckState(state == 0 ? Qt::Unchecked : (state == 1 ? Qt::PartiallyChecked : Qt::Checked));
}

int32_t qStandardItemCheckState(int64_t itemPtr) {
    QStandardItem* item = reinterpret_cast<QStandardItem*>(itemPtr);
    if (item) {
        Qt::CheckState s = item->checkState();
        return s == Qt::Unchecked ? 0 : (s == Qt::PartiallyChecked ? 1 : 2);
    }
    return 0;
}

void qStandardItemSetData(int64_t itemPtr, int32_t role, int64_t value) {
    QStandardItem* item = reinterpret_cast<QStandardItem*>(itemPtr);
    if (item) item->setData(QVariant::fromValue(value), role);
}

int64_t qStandardItemData(int64_t itemPtr, int32_t role) {
    QStandardItem* item = reinterpret_cast<QStandardItem*>(itemPtr);
    if (item) return item->data(role).toLongLong();
    return 0;
}

void qStandardItemSetEditable(int64_t itemPtr, int32_t v) {
    QStandardItem* item = reinterpret_cast<QStandardItem*>(itemPtr);
    if (item) item->setEditable(v != 0);
}

int32_t qStandardItemIsEditable(int64_t itemPtr) {
    QStandardItem* item = reinterpret_cast<QStandardItem*>(itemPtr);
    return item ? (item->isEditable() ? 1 : 0) : 0;
}

void qStandardItemAppendRow(int64_t itemPtr, int64_t childPtr) {
    QStandardItem* item = reinterpret_cast<QStandardItem*>(itemPtr);
    if (item && childPtr) item->appendRow(reinterpret_cast<QStandardItem*>(childPtr));
}

void qStandardItemSetForeground(int64_t itemPtr, int32_t r, int32_t g, int32_t b) {
    QStandardItem* item = reinterpret_cast<QStandardItem*>(itemPtr);
    if (item) item->setForeground(QBrush(QColor(r, g, b)));
}

// ============================================================
// QHeaderView 补充 API
// ============================================================

void qHeaderViewSetVisible(int64_t ptr, int32_t v) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->setVisible(v != 0);
}

void qHeaderViewShow(int64_t ptr) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->show();
}

void qHeaderViewHide(int64_t ptr) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->hide();
}

int32_t qHeaderViewIsStretchLastSection(int64_t ptr) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    return h ? (h->stretchLastSection() ? 1 : 0) : 0;
}

void qHeaderViewSetDefaultSectionSize(int64_t ptr, int32_t v) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->setDefaultSectionSize(v);
}

int32_t qHeaderViewDefaultSectionSize(int64_t ptr) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    return h ? static_cast<int32_t>(h->defaultSectionSize()) : 0;
}

void qHeaderViewSetMinimumSectionSize(int64_t ptr, int32_t v) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->setMinimumSectionSize(v);
}

int32_t qHeaderViewMinimumSectionSize(int64_t ptr) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    return h ? static_cast<int32_t>(h->minimumSectionSize()) : 0;
}

void qHeaderViewSetSectionResizeModeIndex(int64_t ptr, int32_t index, int32_t mode) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->setSectionResizeMode(index, static_cast<QHeaderView::ResizeMode>(mode));
}

void qHeaderViewSetSortIndicatorShown(int64_t ptr, int32_t v) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->setSortIndicatorShown(v != 0);
}

int32_t qHeaderViewIsSortIndicatorShown(int64_t ptr) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    return h ? (h->isSortIndicatorShown() ? 1 : 0) : 0;
}

void qHeaderViewSetSectionsClickable(int64_t ptr, int32_t v) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->setSectionsClickable(v != 0);
}

int32_t qHeaderViewIsSectionsClickable(int64_t ptr) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    return h ? (h->sectionsClickable() ? 1 : 0) : 0;
}

void qHeaderViewSetHighlightSections(int64_t ptr, int32_t v) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->setHighlightSections(v != 0);
}

int32_t qHeaderViewIsHighlightSections(int64_t ptr) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    return h ? (h->highlightSections() ? 1 : 0) : 0;
}

void qHeaderViewSetCascadingSectionResizes(int64_t ptr, int32_t v) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->setCascadingSectionResizes(v != 0);
}

int32_t qHeaderViewIsCascadingSectionResizes(int64_t ptr) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    return h ? (h->cascadingSectionResizes() ? 1 : 0) : 0;
}

void qHeaderViewResizeSection(int64_t ptr, int32_t index, int32_t size) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->resizeSection(index, size);
}

int32_t qHeaderViewSectionSize(int64_t ptr, int32_t index) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    return h ? static_cast<int32_t>(h->sectionSize(index)) : 0;
}

void qHeaderViewSetSectionHidden(int64_t ptr, int32_t index, int32_t v) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->setSectionHidden(index, v != 0);
}

int32_t qHeaderViewIsSectionHidden(int64_t ptr, int32_t index) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    return h ? (h->isSectionHidden(index) ? 1 : 0) : 0;
}

int32_t qHeaderViewCount(int64_t ptr) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    return h ? static_cast<int32_t>(h->count()) : 0;
}

int32_t qHeaderViewLength(int64_t ptr) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    return h ? static_cast<int32_t>(h->length()) : 0;
}

int32_t qHeaderViewLogicalIndex(int64_t ptr, int32_t visual) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    return h ? static_cast<int32_t>(h->logicalIndex(visual)) : -1;
}

int32_t qHeaderViewVisualIndex(int64_t ptr, int32_t logical) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    return h ? static_cast<int32_t>(h->visualIndex(logical)) : -1;
}

void qHeaderViewSetOffset(int64_t ptr, int32_t offset) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->setOffset(offset);
}

int32_t qHeaderViewOffset(int64_t ptr) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    return h ? static_cast<int32_t>(h->offset()) : 0;
}

void qHeaderViewMoveSection(int64_t ptr, int32_t from, int32_t to) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->moveSection(from, to);
}

void qHeaderViewSwapSections(int64_t ptr, int32_t one, int32_t two) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->swapSections(one, two);
}

void qHeaderViewSetDefaultAlignment(int64_t ptr, int32_t alignment) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h) h->setDefaultAlignment(static_cast<Qt::Alignment>(alignment));
}

// QHeaderView 信号回调映射
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_hvSectionClicked;
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_hvSectionDoubleClicked;
static std::unordered_map<int64_t, std::function<void(int32_t, int32_t, int32_t)>> g_hvSectionResized;
static std::unordered_map<int64_t, std::function<void(int32_t, int32_t, int32_t)>> g_hvSectionMoved;
static std::unordered_map<int64_t, std::function<void(int32_t, int32_t)>> g_hvSortIndicatorChanged;
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_hvSectionHandleDoubleClicked;

void qHeaderViewConnectSectionClicked(int64_t ptr, void (*cb)(int32_t)) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h && cb && g_hvSectionClicked.find(ptr) == g_hvSectionClicked.end()) {
        g_hvSectionClicked[ptr] = [cb](int32_t i) { cb(i); };
        QObject::connect(h, &QHeaderView::sectionClicked, [ptr](int logicalIndex) {
            auto it = g_hvSectionClicked.find(ptr);
            if (it != g_hvSectionClicked.end()) it->second(static_cast<int32_t>(logicalIndex));
        });
    }
}

void qHeaderViewConnectSectionDoubleClicked(int64_t ptr, void (*cb)(int32_t)) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h && cb && g_hvSectionDoubleClicked.find(ptr) == g_hvSectionDoubleClicked.end()) {
        g_hvSectionDoubleClicked[ptr] = [cb](int32_t i) { cb(i); };
        QObject::connect(h, &QHeaderView::sectionDoubleClicked, [ptr](int logicalIndex) {
            auto it = g_hvSectionDoubleClicked.find(ptr);
            if (it != g_hvSectionDoubleClicked.end()) it->second(static_cast<int32_t>(logicalIndex));
        });
    }
}

void qHeaderViewConnectSectionResized(int64_t ptr, void (*cb)(int32_t, int32_t, int32_t)) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h && cb && g_hvSectionResized.find(ptr) == g_hvSectionResized.end()) {
        g_hvSectionResized[ptr] = [cb](int32_t a, int32_t b, int32_t c) { cb(a, b, c); };
        QObject::connect(h, &QHeaderView::sectionResized, [ptr](int logicalIndex, int oldSize, int newSize) {
            auto it = g_hvSectionResized.find(ptr);
            if (it != g_hvSectionResized.end()) it->second(static_cast<int32_t>(logicalIndex), static_cast<int32_t>(oldSize), static_cast<int32_t>(newSize));
        });
    }
}

void qHeaderViewConnectSectionMoved(int64_t ptr, void (*cb)(int32_t, int32_t, int32_t)) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h && cb && g_hvSectionMoved.find(ptr) == g_hvSectionMoved.end()) {
        g_hvSectionMoved[ptr] = [cb](int32_t a, int32_t b, int32_t c) { cb(a, b, c); };
        QObject::connect(h, &QHeaderView::sectionMoved, [ptr](int logicalIndex, int oldVisualIndex, int newVisualIndex) {
            auto it = g_hvSectionMoved.find(ptr);
            if (it != g_hvSectionMoved.end()) it->second(static_cast<int32_t>(logicalIndex), static_cast<int32_t>(oldVisualIndex), static_cast<int32_t>(newVisualIndex));
        });
    }
}

void qHeaderViewConnectSortIndicatorChanged(int64_t ptr, void (*cb)(int32_t, int32_t)) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h && cb && g_hvSortIndicatorChanged.find(ptr) == g_hvSortIndicatorChanged.end()) {
        g_hvSortIndicatorChanged[ptr] = [cb](int32_t a, int32_t b) { cb(a, b); };
        QObject::connect(h, &QHeaderView::sortIndicatorChanged, [ptr](int logicalIndex, int order) {
            auto it = g_hvSortIndicatorChanged.find(ptr);
            if (it != g_hvSortIndicatorChanged.end()) it->second(static_cast<int32_t>(logicalIndex), static_cast<int32_t>(order));
        });
    }
}

void qHeaderViewConnectSectionHandleDoubleClicked(int64_t ptr, void (*cb)(int32_t)) {
    QHeaderView* h = reinterpret_cast<QHeaderView*>(ptr);
    if (h && cb && g_hvSectionHandleDoubleClicked.find(ptr) == g_hvSectionHandleDoubleClicked.end()) {
        g_hvSectionHandleDoubleClicked[ptr] = [cb](int32_t i) { cb(i); };
        QObject::connect(h, &QHeaderView::sectionHandleDoubleClicked, [ptr](int logicalIndex) {
            auto it = g_hvSectionHandleDoubleClicked.find(ptr);
            if (it != g_hvSectionHandleDoubleClicked.end()) it->second(static_cast<int32_t>(logicalIndex));
        });
    }
}

} // extern "C"
