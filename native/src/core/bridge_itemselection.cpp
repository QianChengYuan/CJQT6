#include <QItemSelectionModel>
#include <QAbstractItemModel>
#include <QModelIndex>

extern "C" {

// ============================================================
// QItemSelectionModel 桥接函数
// ============================================================

int64_t qItemSelectionModelCreate(int64_t modelPtr) {
    QAbstractItemModel* model = reinterpret_cast<QAbstractItemModel*>(modelPtr);
    return reinterpret_cast<int64_t>(new QItemSelectionModel(model));
}

void qItemSelectionModelDelete(int64_t ptr) {
    delete reinterpret_cast<QItemSelectionModel*>(ptr);
}

int32_t qItemSelectionModelCurrentIndexRow(int64_t ptr) {
    QItemSelectionModel* m = reinterpret_cast<QItemSelectionModel*>(ptr);
    return m ? m->currentIndex().row() : -1;
}

int32_t qItemSelectionModelCurrentIndexCol(int64_t ptr) {
    QItemSelectionModel* m = reinterpret_cast<QItemSelectionModel*>(ptr);
    return m ? m->currentIndex().column() : -1;
}

void qItemSelectionModelSetCurrentIndex(int64_t ptr, int32_t row, int32_t col, int32_t command) {
    QItemSelectionModel* m = reinterpret_cast<QItemSelectionModel*>(ptr);
    if (m) {
        QModelIndex idx = m->model()->index(row, col);
        m->setCurrentIndex(idx, static_cast<QItemSelectionModel::SelectionFlags>(command));
    }
}

bool qItemSelectionModelIsSelected(int64_t ptr, int32_t row, int32_t col) {
    QItemSelectionModel* m = reinterpret_cast<QItemSelectionModel*>(ptr);
    if (m && m->model()) {
        QModelIndex idx = m->model()->index(row, col);
        return m->isSelected(idx);
    }
    return false;
}

bool qItemSelectionModelIsRowSelected(int64_t ptr, int32_t row) {
    QItemSelectionModel* m = reinterpret_cast<QItemSelectionModel*>(ptr);
    return m ? m->isRowSelected(row) : false;
}

bool qItemSelectionModelHasSelection(int64_t ptr) {
    QItemSelectionModel* m = reinterpret_cast<QItemSelectionModel*>(ptr);
    return m ? m->hasSelection() : false;
}

void qItemSelectionModelClearSelection(int64_t ptr) {
    QItemSelectionModel* m = reinterpret_cast<QItemSelectionModel*>(ptr);
    if (m) m->clearSelection();
}

void qItemSelectionModelClear(int64_t ptr) {
    QItemSelectionModel* m = reinterpret_cast<QItemSelectionModel*>(ptr);
    if (m) m->clear();
}

int64_t qItemSelectionModelModel(int64_t ptr) {
    QItemSelectionModel* m = reinterpret_cast<QItemSelectionModel*>(ptr);
    return m ? reinterpret_cast<int64_t>(m->model()) : 0;
}

void qItemSelectionModelSelect(int64_t ptr, int32_t row, int32_t col, int32_t command) {
    QItemSelectionModel* m = reinterpret_cast<QItemSelectionModel*>(ptr);
    if (m && m->model()) {
        QModelIndex idx = m->model()->index(row, col);
        m->select(idx, static_cast<QItemSelectionModel::SelectionFlags>(command));
    }
}

int32_t qItemSelectionModelSelectedRowsCount(int64_t ptr) {
    QItemSelectionModel* m = reinterpret_cast<QItemSelectionModel*>(ptr);
    if (m) {
        return m->selectedRows().count();
    }
    return 0;
}

int32_t qItemSelectionModelSelectedRowAt(int64_t ptr, int32_t index) {
    QItemSelectionModel* m = reinterpret_cast<QItemSelectionModel*>(ptr);
    if (m) {
        QModelIndexList list = m->selectedRows();
        if (index >= 0 && index < list.size()) {
            return list.at(index).row();
        }
    }
    return -1;
}

} // extern "C"
