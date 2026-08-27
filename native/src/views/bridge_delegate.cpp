/**
 * @file bridge_delegate.cpp
 * @brief QStyledItemDelegate 桥接 - 基于回调的自绘委托
 *
 * 由于仓颉无法直接继承 C++ 虚类，本文件实现 CjStyledItemDelegate，
 * 它继承 QStyledItemDelegate 并将 paint / sizeHint 虚方法委托给仓颉侧注册的回调。
 *
 * 设计要点：
 * - 绘制上下文（painter / rect / state / row / col）在回调触发前暂存到 m_ctx，
 *   仓颉侧回调内通过 getter 读取（仅在回调内有效，退出回调后为脏数据）。
 * - 委托挂载到视图后（setItemDelegate），视图接管其所有权（Qt 语义：无父对象时
 *   由视图设为子对象）；仓颉侧通过 qStyledItemDelegateIsMounted 判断是否已挂载，
 *   已挂载则 close 时不主动 delete，交由视图级联析构，避免 double-free。
 */

#include <QStyledItemDelegate>
#include <QStyleOptionViewItem>
#include <QPainter>
#include <QModelIndex>
#include <QSize>
#include <QTableView>
#include <QListView>
#include <QTreeView>
#include <QWidget>
#include <QAbstractItemModel>

extern "C" {

// 回调函数指针类型：均以 delegate 自身指针为唯一入参，上下文经 getter 读取
typedef void (*PaintFunc)(int64_t delegatePtr);
typedef int64_t (*SizeHintFunc)(int64_t delegatePtr);
typedef int64_t (*CreateEditorFunc)(int64_t delegatePtr);   // 返回 editor widget 指针，0 表示不编辑
typedef void (*SetEditorDataFunc)(int64_t delegatePtr);
typedef void (*SetModelDataFunc)(int64_t delegatePtr);

// ============================================================
// CjStyledItemDelegate - QStyledItemDelegate 适配器
// ============================================================

class CjStyledItemDelegate : public QStyledItemDelegate {
public:
    explicit CjStyledItemDelegate(QObject* parent = nullptr)
        : QStyledItemDelegate(parent), m_paintCb(nullptr), m_sizeHintCb(nullptr),
          m_createEditorCb(nullptr), m_setEditorDataCb(nullptr), m_setModelDataCb(nullptr),
          m_parentPtr(0), m_editorPtr(0), m_modelPtr(0) {
        m_ctx.valid = false;
        m_ctx.painterPtr = 0;
        m_ctx.rectX = 0;
        m_ctx.rectY = 0;
        m_ctx.rectW = 0;
        m_ctx.rectH = 0;
        m_ctx.state = 0;
        m_ctx.row = 0;
        m_ctx.col = 0;
    }

    // 注册回调
    void setPaintCallback(PaintFunc cb) { m_paintCb = cb; }
    void setSizeHintCallback(SizeHintFunc cb) { m_sizeHintCb = cb; }
    void setCreateEditorCallback(CreateEditorFunc cb) { m_createEditorCb = cb; }
    void setSetEditorDataCallback(SetEditorDataFunc cb) { m_setEditorDataCb = cb; }
    void setSetModelDataCallback(SetModelDataFunc cb) { m_setModelDataCb = cb; }

    // 绘制：注册了 paint 回调则完全由仓颉侧接管，否则走默认绘制
    void paint(QPainter* painter, const QStyleOptionViewItem& option,
               const QModelIndex& index) const override {
        if (m_paintCb) {
            fillContext(painter, option, index);
            m_paintCb(reinterpret_cast<int64_t>(const_cast<CjStyledItemDelegate*>(this)));
            m_ctx.valid = false;
            return;
        }
        QStyledItemDelegate::paint(painter, option, index);
    }

    // 尺寸：注册了 sizeHint 回调则取回调返回的打包值（(高<<32)|宽），否则默认
    QSize sizeHint(const QStyleOptionViewItem& option, const QModelIndex& index) const override {
        if (m_sizeHintCb) {
            fillContext(nullptr, option, index);
            int64_t packed = m_sizeHintCb(reinterpret_cast<int64_t>(const_cast<CjStyledItemDelegate*>(this)));
            m_ctx.valid = false;
            if (packed != 0) {
                int32_t w = static_cast<int32_t>(packed & 0xFFFFFFFFLL);
                int32_t h = static_cast<int32_t>((packed >> 32) & 0xFFFFFFFFLL);
                return QSize(w, h);
            }
        }
        return QStyledItemDelegate::sizeHint(option, index);
    }

    // 创建编辑器：注册了回调则由仓颉侧创建并返回 editor 指针，否则走默认（QLineEdit）
    QWidget* createEditor(QWidget* parent, const QStyleOptionViewItem& option,
                          const QModelIndex& index) const override {
        if (m_createEditorCb) {
            m_parentPtr = reinterpret_cast<int64_t>(parent);
            m_ctx.row = index.row();
            m_ctx.col = index.column();
            int64_t editorPtr = m_createEditorCb(
                reinterpret_cast<int64_t>(const_cast<CjStyledItemDelegate*>(this)));
            m_parentPtr = 0;
            return reinterpret_cast<QWidget*>(editorPtr);
        }
        return QStyledItemDelegate::createEditor(parent, option, index);
    }

    // 从 model 取数据填入编辑器：注册了回调则交仓颉侧处理，否则走默认
    void setEditorData(QWidget* editor, const QModelIndex& index) const override {
        if (m_setEditorDataCb) {
            m_editorPtr = reinterpret_cast<int64_t>(editor);
            m_ctx.row = index.row();
            m_ctx.col = index.column();
            m_setEditorDataCb(
                reinterpret_cast<int64_t>(const_cast<CjStyledItemDelegate*>(this)));
            m_editorPtr = 0;
            return;
        }
        QStyledItemDelegate::setEditorData(editor, index);
    }

    // 从编辑器取数据写回 model：注册了回调则交仓颉侧处理，否则走默认
    void setModelData(QWidget* editor, QAbstractItemModel* model,
                      const QModelIndex& index) const override {
        if (m_setModelDataCb) {
            m_editorPtr = reinterpret_cast<int64_t>(editor);
            m_modelPtr = reinterpret_cast<int64_t>(model);
            m_ctx.row = index.row();
            m_ctx.col = index.column();
            m_setModelDataCb(
                reinterpret_cast<int64_t>(const_cast<CjStyledItemDelegate*>(this)));
            m_editorPtr = 0;
            m_modelPtr = 0;
            return;
        }
        QStyledItemDelegate::setModelData(editor, model, index);
    }

    // 是否已被视图接管（Qt 会为无父委托设置父对象为视图）
    bool isMounted() const { return parent() != nullptr; }

    // ---- 上下文 getter（仅回调内有效） ----
    int64_t getPainterPtr() const { return m_ctx.painterPtr; }
    int32_t getRectX() const { return m_ctx.rectX; }
    int32_t getRectY() const { return m_ctx.rectY; }
    int32_t getRectW() const { return m_ctx.rectW; }
    int32_t getRectH() const { return m_ctx.rectH; }
    int32_t getState() const { return m_ctx.state; }
    int32_t getRow() const { return m_ctx.row; }
    int32_t getCol() const { return m_ctx.col; }

    // ---- 编辑上下文 getter（仅编辑回调内有效） ----
    int64_t getParentPtr() const { return m_parentPtr; }
    int64_t getEditorPtr() const { return m_editorPtr; }
    int64_t getModelPtr() const { return m_modelPtr; }

private:
    // 把本次绘制/尺寸请求的上下文写入 m_ctx
    void fillContext(QPainter* painter, const QStyleOptionViewItem& option,
                     const QModelIndex& index) const {
        m_ctx.valid = true;
        m_ctx.painterPtr = reinterpret_cast<int64_t>(painter);
        m_ctx.rectX = option.rect.x();
        m_ctx.rectY = option.rect.y();
        m_ctx.rectW = option.rect.width();
        m_ctx.rectH = option.rect.height();
        m_ctx.state = static_cast<int32_t>(option.state.toInt());
        m_ctx.row = index.row();
        m_ctx.col = index.column();
    }

    PaintFunc m_paintCb;
    SizeHintFunc m_sizeHintCb;

    struct PaintContext {
        bool valid;
        int64_t painterPtr;
        int32_t rectX;
        int32_t rectY;
        int32_t rectW;
        int32_t rectH;
        int32_t state;
        int32_t row;
        int32_t col;
    };
    mutable PaintContext m_ctx;

    // 编辑回调与上下文
    CreateEditorFunc m_createEditorCb;
    SetEditorDataFunc m_setEditorDataCb;
    SetModelDataFunc m_setModelDataCb;
    mutable int64_t m_parentPtr;   // createEditor 的父 widget 指针
    mutable int64_t m_editorPtr;   // 当前编辑器指针
    mutable int64_t m_modelPtr;    // setModelData 的 model 指针
};

// ============================================================
// 委托桥接函数
// ============================================================

int64_t qStyledItemDelegateCreate() {
    return reinterpret_cast<int64_t>(new CjStyledItemDelegate(nullptr));
}

void qStyledItemDelegateDelete(int64_t ptr) {
    delete reinterpret_cast<CjStyledItemDelegate*>(ptr);
}

void qStyledItemDelegateSetPaintCallback(int64_t ptr, PaintFunc cb) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    if (d) d->setPaintCallback(cb);
}

void qStyledItemDelegateSetSizeHintCallback(int64_t ptr, SizeHintFunc cb) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    if (d) d->setSizeHintCallback(cb);
}

int32_t qStyledItemDelegateIsMounted(int64_t ptr) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    return (d && d->isMounted()) ? 1 : 0;
}

int64_t qStyledItemDelegateGetPainterPtr(int64_t ptr) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    return d ? d->getPainterPtr() : 0;
}

int32_t qStyledItemDelegateGetRectX(int64_t ptr) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    return d ? d->getRectX() : 0;
}

int32_t qStyledItemDelegateGetRectY(int64_t ptr) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    return d ? d->getRectY() : 0;
}

int32_t qStyledItemDelegateGetRectW(int64_t ptr) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    return d ? d->getRectW() : 0;
}

int32_t qStyledItemDelegateGetRectH(int64_t ptr) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    return d ? d->getRectH() : 0;
}

int32_t qStyledItemDelegateGetState(int64_t ptr) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    return d ? d->getState() : 0;
}

int32_t qStyledItemDelegateGetRow(int64_t ptr) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    return d ? d->getRow() : 0;
}

int32_t qStyledItemDelegateGetCol(int64_t ptr) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    return d ? d->getCol() : 0;
}

// ---- 编辑回调注册 ----

void qStyledItemDelegateSetCreateEditorCallback(int64_t ptr, CreateEditorFunc cb) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    if (d) d->setCreateEditorCallback(cb);
}

void qStyledItemDelegateSetSetEditorDataCallback(int64_t ptr, SetEditorDataFunc cb) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    if (d) d->setSetEditorDataCallback(cb);
}

void qStyledItemDelegateSetSetModelDataCallback(int64_t ptr, SetModelDataFunc cb) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    if (d) d->setSetModelDataCallback(cb);
}

// ---- 编辑上下文 getter ----

int64_t qStyledItemDelegateGetParentPtr(int64_t ptr) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    return d ? d->getParentPtr() : 0;
}

int64_t qStyledItemDelegateGetEditorPtr(int64_t ptr) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    return d ? d->getEditorPtr() : 0;
}

int64_t qStyledItemDelegateGetModelPtr(int64_t ptr) {
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(ptr);
    return d ? d->getModelPtr() : 0;
}

// ============================================================
// 视图挂载桥接函数
// ============================================================

void qTableViewSetItemDelegate(int64_t ptr, int64_t delegatePtr) {
    QTableView* view = reinterpret_cast<QTableView*>(ptr);
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(delegatePtr);
    if (view && d) view->setItemDelegate(d);
}

void qListViewSetItemDelegate(int64_t ptr, int64_t delegatePtr) {
    QListView* view = reinterpret_cast<QListView*>(ptr);
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(delegatePtr);
    if (view && d) view->setItemDelegate(d);
}

void qTreeViewSetItemDelegate(int64_t ptr, int64_t delegatePtr) {
    QTreeView* view = reinterpret_cast<QTreeView*>(ptr);
    CjStyledItemDelegate* d = reinterpret_cast<CjStyledItemDelegate*>(delegatePtr);
    if (view && d) view->setItemDelegate(d);
}

} // extern "C"