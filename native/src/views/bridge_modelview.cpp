/**
 * @file bridge_modelview.cpp
 * @brief Model/View 架构桥接函数
 */

#include <QStandardItemModel>
#include <QStandardItem>
#include <QListView>
#include <QTableView>
#include <QTreeView>
#include <QFileSystemModel>
#include <QHeaderView>
#include <QStringList>
#include <QDir>
#include "bridge_string_utils.h"

extern "C" {

// ============================================================
// QStandardItemModel 桥接函数
// ============================================================

int64_t qStandardItemModelCreate() {
    QStandardItemModel* model = new QStandardItemModel();
    return reinterpret_cast<int64_t>(model);
}

int64_t qStandardItemModelCreateWithSize(int32_t rows, int32_t cols) {
    QStandardItemModel* model = new QStandardItemModel(rows, cols);
    return reinterpret_cast<int64_t>(model);
}

void qStandardItemModelSetRowCount(int64_t ptr, int32_t rows) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        model->setRowCount(rows);
    }
}

void qStandardItemModelSetColumnCount(int64_t ptr, int32_t cols) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        model->setColumnCount(cols);
    }
}

int32_t qStandardItemModelRowCount(int64_t ptr) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        return model->rowCount();
    }
    return 0;
}

int32_t qStandardItemModelColumnCount(int64_t ptr) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        return model->columnCount();
    }
    return 0;
}

void qStandardItemModelSetItem(int64_t ptr, int32_t row, int32_t col, const char* text) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        QStandardItem* item = new QStandardItem(QString::fromUtf8(text));
        model->setItem(row, col, item);
    }
}

const char* qStandardItemModelItemText(int64_t ptr, int32_t row, int32_t col) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        QStandardItem* item = model->item(row, col);
        if (item) {
            return cjqt6::dupUtf8(item->text());
        }
    }
    return cjqt6::emptyString();
}

void qStandardItemModelClear(int64_t ptr) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        model->clear();
    }
}

void qStandardItemModelSetHorizontalHeaderLabel(int64_t ptr, int32_t col, const char* label) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        model->setHorizontalHeaderItem(col, new QStandardItem(QString::fromUtf8(label)));
    }
}

void qStandardItemModelSetVerticalHeaderLabel(int64_t ptr, int32_t row, const char* label) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        model->setVerticalHeaderItem(row, new QStandardItem(QString::fromUtf8(label)));
    }
}

void qStandardItemModelInsertRow(int64_t ptr, int32_t row) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        model->insertRow(row);
    }
}

void qStandardItemModelRemoveRow(int64_t ptr, int32_t row) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        model->removeRow(row);
    }
}

void qStandardItemModelInsertColumn(int64_t ptr, int32_t col) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        model->insertColumn(col);
    }
}

void qStandardItemModelRemoveColumn(int64_t ptr, int32_t col) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        model->removeColumn(col);
    }
}

void qStandardItemModelSetItemEnabled(int64_t ptr, int32_t row, int32_t col, int32_t enabled) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        QStandardItem* item = model->item(row, col);
        if (item) {
            if (enabled) {
                item->setFlags(item->flags() | Qt::ItemIsEnabled);
            } else {
                item->setFlags(item->flags() & ~Qt::ItemIsEnabled);
            }
        }
    }
}

void qStandardItemModelSetItemCheckable(int64_t ptr, int32_t row, int32_t col, int32_t checkable) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        QStandardItem* item = model->item(row, col);
        if (item) {
            if (checkable) {
                item->setFlags(item->flags() | Qt::ItemIsUserCheckable);
                item->setCheckState(Qt::Unchecked);
            } else {
                item->setFlags(item->flags() & ~Qt::ItemIsUserCheckable);
            }
        }
    }
}

void qStandardItemModelSetItemChecked(int64_t ptr, int32_t row, int32_t col, int32_t checked) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        QStandardItem* item = model->item(row, col);
        if (item) {
            item->setCheckState(checked ? Qt::Checked : Qt::Unchecked);
        }
    }
}

int32_t qStandardItemModelIsItemChecked(int64_t ptr, int32_t row, int32_t col) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        QStandardItem* item = model->item(row, col);
        if (item) {
            return item->checkState() == Qt::Checked ? 1 : 0;
        }
    }
    return 0;
}

void qStandardItemModelDelete(int64_t ptr) {
    QStandardItemModel* model = reinterpret_cast<QStandardItemModel*>(ptr);
    if (model) {
        delete model;
    }
}

// ============================================================
// QListView 桥接函数
// ============================================================

int64_t qListViewCreate() {
    QListView* view = new QListView();
    return reinterpret_cast<int64_t>(view);
}

void qListViewSetModel(int64_t ptr, int64_t modelPtr) {
    QListView* view = reinterpret_cast<QListView*>(ptr);
    QAbstractItemModel* model = reinterpret_cast<QAbstractItemModel*>(modelPtr);
    if (view && model) {
        view->setModel(model);
    }
}

int64_t qListViewModel(int64_t ptr) {
    QListView* view = reinterpret_cast<QListView*>(ptr);
    if (view) {
        return reinterpret_cast<int64_t>(view->model());
    }
    return 0;
}

void qListViewSetSelectionMode(int64_t ptr, int32_t mode) {
    QListView* view = reinterpret_cast<QListView*>(ptr);
    if (view) {
        view->setSelectionMode(static_cast<QAbstractItemView::SelectionMode>(mode));
    }
}

void qListViewDelete(int64_t ptr) {
    QListView* view = reinterpret_cast<QListView*>(ptr);
    if (view) {
        delete view;
    }
}

// ============================================================
// QTableView 桥接函数
// ============================================================

int64_t qTableViewCreate() {
    QTableView* view = new QTableView();
    return reinterpret_cast<int64_t>(view);
}

void qTableViewSetModel(int64_t ptr, int64_t modelPtr) {
    QTableView* view = reinterpret_cast<QTableView*>(ptr);
    QAbstractItemModel* model = reinterpret_cast<QAbstractItemModel*>(modelPtr);
    if (view && model) {
        view->setModel(model);
    }
}

void qTableViewSetColumnWidth(int64_t ptr, int32_t col, int32_t width) {
    QTableView* view = reinterpret_cast<QTableView*>(ptr);
    if (view) {
        view->setColumnWidth(col, width);
    }
}

void qTableViewSetRowHeight(int64_t ptr, int32_t row, int32_t height) {
    QTableView* view = reinterpret_cast<QTableView*>(ptr);
    if (view) {
        view->setRowHeight(row, height);
    }
}

void qTableViewSetShowGrid(int64_t ptr, int32_t show) {
    QTableView* view = reinterpret_cast<QTableView*>(ptr);
    if (view) {
        view->setShowGrid(show != 0);
    }
}

void qTableViewSetSelectionMode(int64_t ptr, int32_t mode) {
    QTableView* view = reinterpret_cast<QTableView*>(ptr);
    if (view) {
        view->setSelectionMode(static_cast<QAbstractItemView::SelectionMode>(mode));
    }
}

void qTableViewSetSelectionBehavior(int64_t ptr, int32_t behavior) {
    QTableView* view = reinterpret_cast<QTableView*>(ptr);
    if (view) {
        view->setSelectionBehavior(static_cast<QAbstractItemView::SelectionBehavior>(behavior));
    }
}

void qTableViewSetSortingEnabled(int64_t ptr, int32_t enabled) {
    QTableView* view = reinterpret_cast<QTableView*>(ptr);
    if (view) {
        view->setSortingEnabled(enabled != 0);
    }
}

void qTableViewResizeColumnsToContents(int64_t ptr) {
    QTableView* view = reinterpret_cast<QTableView*>(ptr);
    if (view) {
        view->resizeColumnsToContents();
    }
}

void qTableViewResizeRowsToContents(int64_t ptr) {
    QTableView* view = reinterpret_cast<QTableView*>(ptr);
    if (view) {
        view->resizeRowsToContents();
    }
}

void qTableViewHorizontalHeaderSetStretchLastSection(int64_t ptr, int32_t stretch) {
    QTableView* view = reinterpret_cast<QTableView*>(ptr);
    if (view) {
        view->horizontalHeader()->setStretchLastSection(stretch != 0);
    }
}

void qTableViewDelete(int64_t ptr) {
    QTableView* view = reinterpret_cast<QTableView*>(ptr);
    if (view) {
        delete view;
    }
}

// ============================================================
// QTreeView 桥接函数
// ============================================================

int64_t qTreeViewCreate() {
    QTreeView* view = new QTreeView();
    return reinterpret_cast<int64_t>(view);
}

void qTreeViewSetModel(int64_t ptr, int64_t modelPtr) {
    QTreeView* view = reinterpret_cast<QTreeView*>(ptr);
    QAbstractItemModel* model = reinterpret_cast<QAbstractItemModel*>(modelPtr);
    if (view && model) {
        view->setModel(model);
    }
}

void qTreeViewExpandAll(int64_t ptr) {
    QTreeView* view = reinterpret_cast<QTreeView*>(ptr);
    if (view) {
        view->expandAll();
    }
}

void qTreeViewCollapseAll(int64_t ptr) {
    QTreeView* view = reinterpret_cast<QTreeView*>(ptr);
    if (view) {
        view->collapseAll();
    }
}

void qTreeViewSetSelectionMode(int64_t ptr, int32_t mode) {
    QTreeView* view = reinterpret_cast<QTreeView*>(ptr);
    if (view) {
        view->setSelectionMode(static_cast<QAbstractItemView::SelectionMode>(mode));
    }
}

void qTreeViewSetHeaderHidden(int64_t ptr, int32_t hidden) {
    QTreeView* view = reinterpret_cast<QTreeView*>(ptr);
    if (view) {
        view->setHeaderHidden(hidden != 0);
    }
}

void qTreeViewDelete(int64_t ptr) {
    QTreeView* view = reinterpret_cast<QTreeView*>(ptr);
    if (view) {
        delete view;
    }
}

// ============================================================
// QFileSystemModel 桥接函数
// ============================================================

int64_t qFileSystemModelCreate() {
    QFileSystemModel* model = new QFileSystemModel();
    return reinterpret_cast<int64_t>(model);
}

void qFileSystemModelSetRootPath(int64_t ptr, const char* path) {
    QFileSystemModel* model = reinterpret_cast<QFileSystemModel*>(ptr);
    if (model) {
        model->setRootPath(QString::fromUtf8(path));
    }
}

const char* qFileSystemModelRootPath(int64_t ptr) {
    QFileSystemModel* model = reinterpret_cast<QFileSystemModel*>(ptr);
    if (model) {
        return cjqt6::dupUtf8(model->rootPath());
    }
    return cjqt6::emptyString();
}

int64_t qFileSystemModelIndex(int64_t ptr, const char* path) {
    QFileSystemModel* model = reinterpret_cast<QFileSystemModel*>(ptr);
    if (model) {
        QModelIndex index = model->index(QString::fromUtf8(path));
        return reinterpret_cast<int64_t>(new QPersistentModelIndex(index));
    }
    return 0;
}

void qFileSystemModelSetNameFilters(int64_t ptr, const char** filters, int32_t count) {
    QFileSystemModel* model = reinterpret_cast<QFileSystemModel*>(ptr);
    if (model) {
        QStringList nameFilters;
        for (int32_t i = 0; i < count; i++) {
            nameFilters << QString::fromUtf8(filters[i]);
        }
        model->setNameFilters(nameFilters);
    }
}

void qFileSystemModelSetFilter(int64_t ptr, int32_t filter) {
    QFileSystemModel* model = reinterpret_cast<QFileSystemModel*>(ptr);
    if (model) {
        model->setFilter(static_cast<QDir::Filters>(filter));
    }
}

void qFileSystemModelDelete(int64_t ptr) {
    QFileSystemModel* model = reinterpret_cast<QFileSystemModel*>(ptr);
    if (model) {
        delete model;
    }
}

// ============================================================
// QHeaderView 桥接函数
// ============================================================

int64_t qHeaderViewCreate(int32_t orientation) {
    QHeaderView* header = new QHeaderView(static_cast<Qt::Orientation>(orientation));
    return reinterpret_cast<int64_t>(header);
}

void qHeaderViewSetStretchLastSection(int64_t ptr, int32_t stretch) {
    QHeaderView* header = reinterpret_cast<QHeaderView*>(ptr);
    if (header) {
        header->setStretchLastSection(stretch != 0);
    }
}

void qHeaderViewSetSectionResizeMode(int64_t ptr, int32_t mode) {
    QHeaderView* header = reinterpret_cast<QHeaderView*>(ptr);
    if (header) {
        header->setSectionResizeMode(static_cast<QHeaderView::ResizeMode>(mode));
    }
}

void qHeaderViewDelete(int64_t ptr) {
    QHeaderView* header = reinterpret_cast<QHeaderView*>(ptr);
    if (header) {
        delete header;
    }
}

} // extern "C"
