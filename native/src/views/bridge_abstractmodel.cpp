/**
 * @file bridge_abstractmodel.cpp
 * @brief QAbstractItemModel 桥接 - 基于回调的自定义模型
 *
 * 由于仓颉无法直接继承 C++ 虚类，本文件实现了一个 C++ 适配器
 * CjAbstractItemModel，它继承 QAbstractItemModel 并将虚方法调用
 * 委托给仓颉侧注册的回调函数。
 */

#include <QAbstractItemModel>
#include <QModelIndex>
#include <QVariant>

extern "C" {

// 回调函数指针类型
typedef int32_t (*RowCountFunc)(int64_t modelPtr, int64_t parentPtr);
typedef int32_t (*ColumnCountFunc)(int64_t modelPtr, int64_t parentPtr);
typedef int64_t (*IndexFunc)(int64_t modelPtr, int32_t row, int32_t column, int64_t parentPtr);
typedef int64_t (*ParentFunc)(int64_t modelPtr, int64_t childPtr);
typedef int64_t (*DataFunc)(int64_t modelPtr, int64_t indexPtr, int32_t role);
typedef int64_t (*HeaderDataFunc)(int64_t modelPtr, int32_t section, int32_t orientation, int32_t role);
typedef int32_t (*FlagsFunc)(int64_t modelPtr, int64_t indexPtr);

// ============================================================
// CjAbstractItemModel - QAbstractItemModel 适配器
// ============================================================

class CjAbstractItemModel : public QAbstractItemModel {
public:
    explicit CjAbstractItemModel()
        : QAbstractItemModel(nullptr)
        , m_rowCountCb(nullptr)
        , m_columnCountCb(nullptr)
        , m_indexCb(nullptr)
        , m_parentCb(nullptr)
        , m_dataCb(nullptr)
        , m_headerDataCb(nullptr)
        , m_flagsCb(nullptr)
    {}

    // 注册回调
    void setRowCountCallback(RowCountFunc cb) { m_rowCountCb = cb; }
    void setColumnCountCallback(ColumnCountFunc cb) { m_columnCountCb = cb; }
    void setIndexCallback(IndexFunc cb) { m_indexCb = cb; }
    void setParentCallback(ParentFunc cb) { m_parentCb = cb; }
    void setDataCallback(DataFunc cb) { m_dataCb = cb; }
    void setHeaderDataCallback(HeaderDataFunc cb) { m_headerDataCb = cb; }
    void setFlagsCallback(FlagsFunc cb) { m_flagsCb = cb; }

    // ---- QAbstractItemModel 接口实现 ----

    QModelIndex index(int row, int column, const QModelIndex& parent = QModelIndex()) const override {
        if (m_indexCb) {
            int64_t parentPtr = parent.isValid() ? reinterpret_cast<int64_t>(parent.internalPointer()) : 0;
            int64_t id = m_indexCb(reinterpret_cast<int64_t>(this), row, column, parentPtr);
            if (id != 0) {
                return createIndex(row, column, reinterpret_cast<void*>(id));
            }
        }
        return QModelIndex();
    }

    QModelIndex parent(const QModelIndex& child) const override {
        if (m_parentCb && child.isValid()) {
            int64_t childPtr = reinterpret_cast<int64_t>(child.internalPointer());
            int64_t parentId = m_parentCb(reinterpret_cast<int64_t>(this), childPtr);
            if (parentId != 0) {
                return createIndex(0, 0, reinterpret_cast<void*>(parentId));
            }
        }
        return QModelIndex();
    }

    int rowCount(const QModelIndex& parent = QModelIndex()) const override {
        if (m_rowCountCb) {
            int64_t parentPtr = parent.isValid() ? reinterpret_cast<int64_t>(parent.internalPointer()) : 0;
            return m_rowCountCb(reinterpret_cast<int64_t>(this), parentPtr);
        }
        return 0;
    }

    int columnCount(const QModelIndex& parent = QModelIndex()) const override {
        if (m_columnCountCb) {
            int64_t parentPtr = parent.isValid() ? reinterpret_cast<int64_t>(parent.internalPointer()) : 0;
            return m_columnCountCb(reinterpret_cast<int64_t>(this), parentPtr);
        }
        return 0;
    }

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override {
        if (m_dataCb && index.isValid()) {
            int64_t indexPtr = reinterpret_cast<int64_t>(index.internalPointer());
            int64_t result = m_dataCb(reinterpret_cast<int64_t>(this), indexPtr, role);
            // 简单场景：将 Int64 视为字符串指针
            if (result != 0) {
                const char* str = reinterpret_cast<const char*>(result);
                return QVariant(QString::fromUtf8(str));
            }
        }
        return QVariant();
    }

    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override {
        if (m_headerDataCb) {
            int64_t result = m_headerDataCb(reinterpret_cast<int64_t>(this), section,
                                             static_cast<int32_t>(orientation), role);
            if (result != 0) {
                const char* str = reinterpret_cast<const char*>(result);
                return QVariant(QString::fromUtf8(str));
            }
        }
        return QVariant();
    }

    Qt::ItemFlags flags(const QModelIndex& index) const override {
        if (m_flagsCb && index.isValid()) {
            int64_t indexPtr = reinterpret_cast<int64_t>(index.internalPointer());
            return static_cast<Qt::ItemFlags>(m_flagsCb(reinterpret_cast<int64_t>(this), indexPtr));
        }
        return Qt::ItemIsEnabled | Qt::ItemIsSelectable;
    }

    // ---- 公开的 notify 方法（供桥接函数调用 protected 方法） ----
    void notifyBeginResetModel() { beginResetModel(); }
    void notifyEndResetModel() { endResetModel(); }
    void notifyBeginInsertRows(int32_t first, int32_t last) { beginInsertRows(QModelIndex(), first, last); }
    void notifyEndInsertRows() { endInsertRows(); }
    void notifyBeginRemoveRows(int32_t first, int32_t last) { beginRemoveRows(QModelIndex(), first, last); }
    void notifyEndRemoveRows() { endRemoveRows(); }

    // dataChanged/layoutChanged（P1）：数据与结构局部更新通知。
    // 索引通过回调 m_indexCb 拿到与 index() 一致的内部 ID，保证视图刷新时
    // 重新取数的 internalPointer 与初次 index() 一致。
    void notifyDataChanged(int32_t topLeftRow, int32_t topLeftCol,
                           int32_t bottomRightRow, int32_t bottomRightCol) {
        if (!m_indexCb) return;
        int64_t tlId = m_indexCb(reinterpret_cast<int64_t>(this), topLeftRow, topLeftCol, 0);
        int64_t brId = m_indexCb(reinterpret_cast<int64_t>(this), bottomRightRow, bottomRightCol, 0);
        if (tlId == 0 || brId == 0) return;
        QModelIndex tl = createIndex(topLeftRow, topLeftCol, reinterpret_cast<void*>(tlId));
        QModelIndex br = createIndex(bottomRightRow, bottomRightCol, reinterpret_cast<void*>(brId));
        emit dataChanged(tl, br);
    }

    void notifyLayoutChanged() {
        emit layoutChanged(QList<QPersistentModelIndex>(), QAbstractItemModel::NoLayoutChangeHint);
    }

private:
    RowCountFunc m_rowCountCb;
    ColumnCountFunc m_columnCountCb;
    IndexFunc m_indexCb;
    ParentFunc m_parentCb;
    DataFunc m_dataCb;
    HeaderDataFunc m_headerDataCb;
    FlagsFunc m_flagsCb;
};

// ============================================================
// 桥接函数
// ============================================================

int64_t qAbstractItemModelCreate() {
    return reinterpret_cast<int64_t>(new CjAbstractItemModel());
}

void qAbstractItemModelDelete(int64_t ptr) {
    delete reinterpret_cast<CjAbstractItemModel*>(ptr);
}

void qAbstractItemModelSetRowCountCallback(int64_t ptr, RowCountFunc cb) {
    CjAbstractItemModel* model = reinterpret_cast<CjAbstractItemModel*>(ptr);
    if (model) model->setRowCountCallback(cb);
}

void qAbstractItemModelSetColumnCountCallback(int64_t ptr, ColumnCountFunc cb) {
    CjAbstractItemModel* model = reinterpret_cast<CjAbstractItemModel*>(ptr);
    if (model) model->setColumnCountCallback(cb);
}

void qAbstractItemModelSetIndexCallback(int64_t ptr, IndexFunc cb) {
    CjAbstractItemModel* model = reinterpret_cast<CjAbstractItemModel*>(ptr);
    if (model) model->setIndexCallback(cb);
}

void qAbstractItemModelSetParentCallback(int64_t ptr, ParentFunc cb) {
    CjAbstractItemModel* model = reinterpret_cast<CjAbstractItemModel*>(ptr);
    if (model) model->setParentCallback(cb);
}

void qAbstractItemModelSetDataCallback(int64_t ptr, DataFunc cb) {
    CjAbstractItemModel* model = reinterpret_cast<CjAbstractItemModel*>(ptr);
    if (model) model->setDataCallback(cb);
}

void qAbstractItemModelSetHeaderDataCallback(int64_t ptr, HeaderDataFunc cb) {
    CjAbstractItemModel* model = reinterpret_cast<CjAbstractItemModel*>(ptr);
    if (model) model->setHeaderDataCallback(cb);
}

void qAbstractItemModelSetFlagsCallback(int64_t ptr, FlagsFunc cb) {
    CjAbstractItemModel* model = reinterpret_cast<CjAbstractItemModel*>(ptr);
    if (model) model->setFlagsCallback(cb);
}

// Model 通知方法
void qAbstractItemModelBeginResetModel(int64_t ptr) {
    CjAbstractItemModel* model = reinterpret_cast<CjAbstractItemModel*>(ptr);
    if (model) model->notifyBeginResetModel();
}

void qAbstractItemModelEndResetModel(int64_t ptr) {
    CjAbstractItemModel* model = reinterpret_cast<CjAbstractItemModel*>(ptr);
    if (model) model->notifyEndResetModel();
}

void qAbstractItemModelBeginInsertRows(int64_t ptr, int32_t first, int32_t last) {
    CjAbstractItemModel* model = reinterpret_cast<CjAbstractItemModel*>(ptr);
    if (model) model->notifyBeginInsertRows(first, last);
}

void qAbstractItemModelEndInsertRows(int64_t ptr) {
    CjAbstractItemModel* model = reinterpret_cast<CjAbstractItemModel*>(ptr);
    if (model) model->notifyEndInsertRows();
}

void qAbstractItemModelBeginRemoveRows(int64_t ptr, int32_t first, int32_t last) {
    CjAbstractItemModel* model = reinterpret_cast<CjAbstractItemModel*>(ptr);
    if (model) model->notifyBeginRemoveRows(first, last);
}

void qAbstractItemModelEndRemoveRows(int64_t ptr) {
    CjAbstractItemModel* model = reinterpret_cast<CjAbstractItemModel*>(ptr);
    if (model) model->notifyEndRemoveRows();
}

// P1：局部数据更新通知（dataChanged）—— 视图只刷新指定矩形区域，避免整表 reset
void qAbstractItemModelDataChanged(int64_t ptr, int32_t topLeftRow, int32_t topLeftCol,
                                   int32_t bottomRightRow, int32_t bottomRightCol) {
    CjAbstractItemModel* model = reinterpret_cast<CjAbstractItemModel*>(ptr);
    if (model) model->notifyDataChanged(topLeftRow, topLeftCol, bottomRightRow, bottomRightCol);
}

// P1：布局变化通知（layoutChanged）—— 行/列顺序或结构调整后通知视图重排
void qAbstractItemModelLayoutChanged(int64_t ptr) {
    CjAbstractItemModel* model = reinterpret_cast<CjAbstractItemModel*>(ptr);
    if (model) model->notifyLayoutChanged();
}

} // extern "C"
