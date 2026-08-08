/**
 * @file bridge_tree.cpp
 * @brief QTreeWidget 桥接函数
 */

#include <QTreeWidget>
#include <QTreeWidgetItem>
#include <QHeaderView>
#include <cstring>
#include <functional>
#include <unordered_map>
#include "bridge_string_utils.h"

// 树形事件回调映射
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_treeItemClickedCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_treeItemDoubleClickedCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_treeItemExpandedCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_treeItemCollapsedCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_treeCurrentItemChangedCallbacks;

static const char* safeCopyString(const QString& str) {
    return cjqt6::dupUtf8(str);
}

extern "C" {

// ============================================================
// QTreeWidget 桥接函数
// ============================================================

int64_t qTreeWidgetCreate() {
    QTreeWidget* tree = new QTreeWidget();
    return reinterpret_cast<int64_t>(tree);
}

void qTreeWidgetDelete(int64_t ptr) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree) {
        delete tree;
    }
}

// 设置列数
void qTreeWidgetSetColumnCount(int64_t ptr, int32_t columns) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree) {
        tree->setColumnCount(columns);
    }
}

// 设置表头标签
void qTreeWidgetSetHeaderLabels(int64_t ptr, const char** labels, int32_t count) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree) {
        QStringList headers;
        for (int i = 0; i < count; i++) {
            headers << QString::fromUtf8(labels[i]);
        }
        tree->setHeaderLabels(headers);
    }
}

void qTreeWidgetSetHeaderLabel(int64_t ptr, int32_t column, const char* label) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree) {
        QTreeWidgetItem* header = tree->headerItem();
        if (header) {
            header->setText(column, QString::fromUtf8(label));
        }
    }
}

// 隐藏/显示表头
void qTreeWidgetSetHeaderHidden(int64_t ptr, bool hidden) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree) {
        tree->setHeaderHidden(hidden);
    }
}

// 顶级项操作
int64_t qTreeWidgetAddTopLevelItem(int64_t ptr, const char* text) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree) {
        QTreeWidgetItem* item = new QTreeWidgetItem(QStringList() << QString::fromUtf8(text));
        tree->addTopLevelItem(item);
        return reinterpret_cast<int64_t>(item);
    }
    return 0;
}

void qTreeWidgetInsertTopLevelItem(int64_t ptr, int32_t index, int64_t itemPtr) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (tree && item) {
        tree->insertTopLevelItem(index, item);
    }
}

void qTreeWidgetTakeTopLevelItem(int64_t ptr, int32_t index) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree) {
        delete tree->takeTopLevelItem(index);
    }
}

int32_t qTreeWidgetTopLevelItemCount(int64_t ptr) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree) {
        return tree->topLevelItemCount();
    }
    return 0;
}

int64_t qTreeWidgetTopLevelItem(int64_t ptr, int32_t index) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree) {
        return reinterpret_cast<int64_t>(tree->topLevelItem(index));
    }
    return 0;
}

void qTreeWidgetClear(int64_t ptr) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree) {
        tree->clear();
    }
}

// 当前选中
int64_t qTreeWidgetCurrentItem(int64_t ptr) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree) {
        return reinterpret_cast<int64_t>(tree->currentItem());
    }
    return 0;
}

void qTreeWidgetSetCurrentItem(int64_t ptr, int64_t itemPtr) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (tree && item) {
        tree->setCurrentItem(item);
    }
}

// 展开折叠
void qTreeWidgetExpandItem(int64_t ptr, int64_t itemPtr) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (tree && item) {
        tree->expandItem(item);
    }
}

void qTreeWidgetCollapseItem(int64_t ptr, int64_t itemPtr) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (tree && item) {
        tree->collapseItem(item);
    }
}

void qTreeWidgetExpandAll(int64_t ptr) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree) {
        tree->expandAll();
    }
}

void qTreeWidgetCollapseAll(int64_t ptr) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree) {
        tree->collapseAll();
    }
}

// ============================================================
// QTreeWidgetItem 桥接函数
// ============================================================

int64_t qTreeWidgetItemCreate() {
    QTreeWidgetItem* item = new QTreeWidgetItem();
    return reinterpret_cast<int64_t>(item);
}

int64_t qTreeWidgetItemCreateWithText(const char* text) {
    QTreeWidgetItem* item = new QTreeWidgetItem(QStringList() << QString::fromUtf8(text));
    return reinterpret_cast<int64_t>(item);
}

void qTreeWidgetItemDelete(int64_t itemPtr) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        delete item;
    }
}

// 文本
void qTreeWidgetItemSetText(int64_t itemPtr, int32_t column, const char* text) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        item->setText(column, QString::fromUtf8(text));
    }
}

const char* qTreeWidgetItemText(int64_t itemPtr, int32_t column) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        return safeCopyString(item->text(column));
    }
    return cjqt6::emptyString();
}

// 子项
int64_t qTreeWidgetItemAddChild(int64_t itemPtr, const char* text) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        QTreeWidgetItem* child = new QTreeWidgetItem(QStringList() << QString::fromUtf8(text));
        item->addChild(child);
        return reinterpret_cast<int64_t>(child);
    }
    return 0;
}

void qTreeWidgetItemAddChildItem(int64_t itemPtr, int64_t childPtr) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    QTreeWidgetItem* child = reinterpret_cast<QTreeWidgetItem*>(childPtr);
    if (item && child) {
        item->addChild(child);
    }
}

int32_t qTreeWidgetItemChildCount(int64_t itemPtr) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        return item->childCount();
    }
    return 0;
}

int64_t qTreeWidgetItemChild(int64_t itemPtr, int32_t index) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        return reinterpret_cast<int64_t>(item->child(index));
    }
    return 0;
}

void qTreeWidgetItemTakeChild(int64_t itemPtr, int32_t index) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        delete item->takeChild(index);
    }
}

// 父项
int64_t qTreeWidgetItemParent(int64_t itemPtr) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        return reinterpret_cast<int64_t>(item->parent());
    }
    return 0;
}

// 用户数据
void qTreeWidgetItemSetData(int64_t itemPtr, int32_t column, int64_t data) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        item->setData(column, Qt::UserRole, QVariant::fromValue(data));
    }
}

int64_t qTreeWidgetItemGetData(int64_t itemPtr, int32_t column) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        return item->data(column, Qt::UserRole).toLongLong();
    }
    return 0;
}

// 展开/折叠
void qTreeWidgetItemSetExpanded(int64_t itemPtr, bool expanded) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        item->setExpanded(expanded);
    }
}

bool qTreeWidgetItemIsExpanded(int64_t itemPtr) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        return item->isExpanded();
    }
    return false;
}

// 勾选
void qTreeWidgetItemSetCheckState(int64_t itemPtr, int32_t column, int32_t state) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        item->setCheckState(column, state == 0 ? Qt::Unchecked : (state == 1 ? Qt::PartiallyChecked : Qt::Checked));
    }
}

int32_t qTreeWidgetItemCheckState(int64_t itemPtr, int32_t column) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        Qt::CheckState state = item->checkState(column);
        return state == Qt::Unchecked ? 0 : (state == Qt::PartiallyChecked ? 1 : 2);
    }
    return 0;
}

// 图标
void qTreeWidgetItemSetIcon(int64_t itemPtr, int32_t column, int32_t iconType) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        QStyle::StandardPixmap stdIcon = QStyle::SP_FileIcon;
        switch (iconType) {
            case 1: stdIcon = QStyle::SP_DirIcon; break;
            case 2: stdIcon = QStyle::SP_FileIcon; break;
            case 3: stdIcon = QStyle::SP_MessageBoxWarning; break;
            case 4: stdIcon = QStyle::SP_MessageBoxInformation; break;
            case 5: stdIcon = QStyle::SP_MessageBoxCritical; break;
            default: return;
        }
        // 需要获取tree widget来获取style
        // 这里简化处理，不设置图标
    }
}

// 选中
void qTreeWidgetItemSetSelected(int64_t itemPtr, bool selected) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        item->setSelected(selected);
    }
}

bool qTreeWidgetItemIsSelected(int64_t itemPtr) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        return item->isSelected();
    }
    return false;
}

// 隐藏
void qTreeWidgetItemSetHidden(int64_t itemPtr, bool hidden) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        item->setHidden(hidden);
    }
}

bool qTreeWidgetItemIsHidden(int64_t itemPtr) {
    QTreeWidgetItem* item = reinterpret_cast<QTreeWidgetItem*>(itemPtr);
    if (item) {
        return item->isHidden();
    }
    return false;
}

// ============================================================
// QTreeWidget 事件回调
// ============================================================

void qTreeWidgetSetOnItemClicked(int64_t ptr, void (*callback)(int64_t)) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree && callback) {
        g_treeItemClickedCallbacks[ptr] = callback;
        QObject::connect(tree, &QTreeWidget::itemClicked, [ptr](QTreeWidgetItem* item, int) {
            auto it = g_treeItemClickedCallbacks.find(ptr);
            if (it != g_treeItemClickedCallbacks.end()) {
                it->second(reinterpret_cast<int64_t>(item));
            }
        });
    }
}

void qTreeWidgetSetOnItemDoubleClicked(int64_t ptr, void (*callback)(int64_t)) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree && callback) {
        g_treeItemDoubleClickedCallbacks[ptr] = callback;
        QObject::connect(tree, &QTreeWidget::itemDoubleClicked, [ptr](QTreeWidgetItem* item, int) {
            auto it = g_treeItemDoubleClickedCallbacks.find(ptr);
            if (it != g_treeItemDoubleClickedCallbacks.end()) {
                it->second(reinterpret_cast<int64_t>(item));
            }
        });
    }
}

void qTreeWidgetSetOnItemExpanded(int64_t ptr, void (*callback)(int64_t)) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree && callback) {
        g_treeItemExpandedCallbacks[ptr] = callback;
        QObject::connect(tree, &QTreeWidget::itemExpanded, [ptr](QTreeWidgetItem* item) {
            auto it = g_treeItemExpandedCallbacks.find(ptr);
            if (it != g_treeItemExpandedCallbacks.end()) {
                it->second(reinterpret_cast<int64_t>(item));
            }
        });
    }
}

void qTreeWidgetSetOnItemCollapsed(int64_t ptr, void (*callback)(int64_t)) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree && callback) {
        g_treeItemCollapsedCallbacks[ptr] = callback;
        QObject::connect(tree, &QTreeWidget::itemCollapsed, [ptr](QTreeWidgetItem* item) {
            auto it = g_treeItemCollapsedCallbacks.find(ptr);
            if (it != g_treeItemCollapsedCallbacks.end()) {
                it->second(reinterpret_cast<int64_t>(item));
            }
        });
    }
}

void qTreeWidgetSetOnCurrentItemChanged(int64_t ptr, void (*callback)(int64_t)) {
    QTreeWidget* tree = reinterpret_cast<QTreeWidget*>(ptr);
    if (tree && callback) {
        g_treeCurrentItemChangedCallbacks[ptr] = callback;
        QObject::connect(tree, &QTreeWidget::currentItemChanged, [ptr](QTreeWidgetItem* current, QTreeWidgetItem*) {
            auto it = g_treeCurrentItemChangedCallbacks.find(ptr);
            if (it != g_treeCurrentItemChangedCallbacks.end()) {
                it->second(reinterpret_cast<int64_t>(current));
            }
        });
    }
}

} // extern "C"
