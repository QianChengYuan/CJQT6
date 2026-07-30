/**
 * @file bridge_sortfilterproxymodel.cpp
 * @brief QSortFilterProxyModel 桥接函数
 */

#include <QSortFilterProxyModel>
#include <QPersistentModelIndex>

extern "C" {

// ============================================================
// QSortFilterProxyModel 桥接函数
// ============================================================

int64_t qSortFilterProxyModelCreate() {
    QSortFilterProxyModel* model = new QSortFilterProxyModel();
    return reinterpret_cast<int64_t>(model);
}

void qSortFilterProxyModelSetSourceModel(int64_t ptr, int64_t modelPtr) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    QAbstractItemModel* source = reinterpret_cast<QAbstractItemModel*>(modelPtr);
    if (proxy && source) {
        proxy->setSourceModel(source);
    }
}

void qSortFilterProxyModelSetFilterRegularExpression(int64_t ptr, const char* pattern) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        proxy->setFilterRegularExpression(QString::fromUtf8(pattern));
    }
}

void qSortFilterProxyModelSetFilterFixedString(int64_t ptr, const char* pattern) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        proxy->setFilterFixedString(QString::fromUtf8(pattern));
    }
}

void qSortFilterProxyModelSetFilterKeyColumn(int64_t ptr, int32_t col) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        proxy->setFilterKeyColumn(col);
    }
}

int32_t qSortFilterProxyModelFilterKeyColumn(int64_t ptr) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        return proxy->filterKeyColumn();
    }
    return 0;
}

void qSortFilterProxyModelSetFilterRole(int64_t ptr, int32_t role) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        proxy->setFilterRole(role);
    }
}

int32_t qSortFilterProxyModelFilterRole(int64_t ptr) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        return proxy->filterRole();
    }
    return 0;
}

void qSortFilterProxyModelSetSortRole(int64_t ptr, int32_t role) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        proxy->setSortRole(role);
    }
}

int32_t qSortFilterProxyModelSortRole(int64_t ptr) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        return proxy->sortRole();
    }
    return 0;
}

void qSortFilterProxyModelSetDynamicSortFilter(int64_t ptr, int32_t enable) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        proxy->setDynamicSortFilter(enable != 0);
    }
}

int32_t qSortFilterProxyModelDynamicSortFilter(int64_t ptr) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        return proxy->dynamicSortFilter() ? 1 : 0;
    }
    return 0;
}

void qSortFilterProxyModelSort(int64_t ptr, int32_t column, int32_t order) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        proxy->sort(column, static_cast<Qt::SortOrder>(order));
    }
}

int32_t qSortFilterProxyModelSortOrder(int64_t ptr) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        return static_cast<int32_t>(proxy->sortOrder());
    }
    return 0;
}

int64_t qSortFilterProxyModelMapToSource(int64_t ptr, int32_t proxyRow, int32_t proxyCol) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        QModelIndex proxyIndex = proxy->index(proxyRow, proxyCol);
        QModelIndex sourceIndex = proxy->mapToSource(proxyIndex);
        return reinterpret_cast<int64_t>(new QPersistentModelIndex(sourceIndex));
    }
    return 0;
}

int64_t qSortFilterProxyModelMapFromSource(int64_t ptr, int32_t sourceRow, int32_t sourceCol, int64_t sourceModelPtr) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    QAbstractItemModel* sourceModel = reinterpret_cast<QAbstractItemModel*>(sourceModelPtr);
    if (proxy && sourceModel) {
        QModelIndex sourceIndex = sourceModel->index(sourceRow, sourceCol);
        QModelIndex proxyIndex = proxy->mapFromSource(sourceIndex);
        return reinterpret_cast<int64_t>(new QPersistentModelIndex(proxyIndex));
    }
    return 0;
}

void qSortFilterProxyModelSetFilterCaseSensitivity(int64_t ptr, int32_t cs) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        proxy->setFilterCaseSensitivity(static_cast<Qt::CaseSensitivity>(cs));
    }
}

int32_t qSortFilterProxyModelFilterCaseSensitivity(int64_t ptr) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        return static_cast<int32_t>(proxy->filterCaseSensitivity());
    }
    return 0;
}

void qSortFilterProxyModelInvalidate(int64_t ptr) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        proxy->invalidate();
    }
}

void qSortFilterProxyModelSetFilterWildcard(int64_t ptr, const char* pattern) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        proxy->setFilterWildcard(QString::fromUtf8(pattern));
    }
}

int32_t qSortFilterProxyModelRowCount(int64_t ptr) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        return proxy->rowCount();
    }
    return 0;
}

int32_t qSortFilterProxyModelColumnCount(int64_t ptr) {
    QSortFilterProxyModel* proxy = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (proxy) {
        return proxy->columnCount();
    }
    return 0;
}

void qSortFilterProxyModelDelete(int64_t ptr) {
    QSortFilterProxyModel* model = reinterpret_cast<QSortFilterProxyModel*>(ptr);
    if (model) {
        delete model;
    }
}

} // extern "C"
