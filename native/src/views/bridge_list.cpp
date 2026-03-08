/**
 * @file bridge_list.cpp
 * @brief QListWidget 桥接函数
 */

#include <QListWidget>
#include <QListWidgetItem>
#include <cstring>
#include <functional>
#include <unordered_map>

// 静态缓冲区用于返回字符串
static char g_listBuffer[4096];

// 列表事件回调映射
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_listItemClickedCallbacks;
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_listItemDoubleClickedCallbacks;
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_listCurrentRowChangedCallbacks;

static const char* safeCopyString(const QString& str) {
    QByteArray utf8 = str.toUtf8();
    int len = utf8.size();
    if (len >= (int)sizeof(g_listBuffer)) {
        len = sizeof(g_listBuffer) - 1;
    }
    std::memcpy(g_listBuffer, utf8.constData(), len);
    g_listBuffer[len] = '\0';
    return g_listBuffer;
}

extern "C" {

// ============================================================
// QListWidget 桥接函数
// ============================================================

int64_t qListWidgetCreate() {
    QListWidget* list = new QListWidget();
    return reinterpret_cast<int64_t>(list);
}

void qListWidgetDelete(int64_t ptr) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        delete list;
    }
}

// 添加项
int64_t qListWidgetAddItem(int64_t ptr, const char* text) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        QListWidgetItem* item = new QListWidgetItem(QString::fromUtf8(text));
        list->addItem(item);
        return reinterpret_cast<int64_t>(item);
    }
    return 0;
}

void qListWidgetInsertItem(int64_t ptr, int32_t row, const char* text) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        list->insertItem(row, QString::fromUtf8(text));
    }
}

void qListWidgetRemoveItem(int64_t ptr, int32_t row) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        delete list->takeItem(row);
    }
}

void qListWidgetClear(int64_t ptr) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        list->clear();
    }
}

int32_t qListWidgetCount(int64_t ptr) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        return list->count();
    }
    return 0;
}

// 当前选中
int32_t qListWidgetCurrentRow(int64_t ptr) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        return list->currentRow();
    }
    return -1;
}

void qListWidgetSetCurrentRow(int64_t ptr, int32_t row) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        list->setCurrentRow(row);
    }
}

const char* qListWidgetCurrentItemText(int64_t ptr) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        QListWidgetItem* item = list->currentItem();
        if (item) {
            return safeCopyString(item->text());
        }
    }
    return "";
}

// 获取指定行文本
const char* qListWidgetItemText(int64_t ptr, int32_t row) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        QListWidgetItem* item = list->item(row);
        if (item) {
            return safeCopyString(item->text());
        }
    }
    return "";
}

void qListWidgetSetItemText(int64_t ptr, int32_t row, const char* text) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        QListWidgetItem* item = list->item(row);
        if (item) {
            item->setText(QString::fromUtf8(text));
        }
    }
}

// 项数据 (用户数据)
void qListWidgetSetItemData(int64_t ptr, int32_t row, int64_t data) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        QListWidgetItem* item = list->item(row);
        if (item) {
            item->setData(Qt::UserRole, QVariant::fromValue(data));
        }
    }
}

int64_t qListWidgetGetItemData(int64_t ptr, int32_t row) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        QListWidgetItem* item = list->item(row);
        if (item) {
            return item->data(Qt::UserRole).toLongLong();
        }
    }
    return 0;
}

// 选择模式
void qListWidgetSetSelectionMode(int64_t ptr, int32_t mode) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        list->setSelectionMode(static_cast<QAbstractItemView::SelectionMode>(mode));
    }
}

// 外观
void qListWidgetSetAlternatingRowColors(int64_t ptr, bool enable) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        list->setAlternatingRowColors(enable);
    }
}

void qListWidgetSetSortingEnabled(int64_t ptr, bool enable) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        list->setSortingEnabled(enable);
    }
}

// 图标 (简化，使用标准图标)
void qListWidgetSetItemIcon(int64_t ptr, int32_t row, int32_t iconType) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        QListWidgetItem* item = list->item(row);
        if (item) {
            // iconType: 0=无, 1=文件夹, 2=文件, 3=警告, 4=信息, 5=错误
            QStyle::StandardPixmap stdIcon = QStyle::SP_FileIcon;
            switch (iconType) {
                case 1: stdIcon = QStyle::SP_DirIcon; break;
                case 2: stdIcon = QStyle::SP_FileIcon; break;
                case 3: stdIcon = QStyle::SP_MessageBoxWarning; break;
                case 4: stdIcon = QStyle::SP_MessageBoxInformation; break;
                case 5: stdIcon = QStyle::SP_MessageBoxCritical; break;
                default: return;
            }
            item->setIcon(list->style()->standardIcon(stdIcon));
        }
    }
}

// 勾选
void qListWidgetSetCheckable(int64_t ptr, int32_t row, bool checkable) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        QListWidgetItem* item = list->item(row);
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

int32_t qListWidgetIsChecked(int64_t ptr, int32_t row) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        QListWidgetItem* item = list->item(row);
        if (item) {
            return item->checkState() == Qt::Checked ? 1 : 0;
        }
    }
    return 0;
}

void qListWidgetSetChecked(int64_t ptr, int32_t row, bool checked) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list) {
        QListWidgetItem* item = list->item(row);
        if (item) {
            item->setCheckState(checked ? Qt::Checked : Qt::Unchecked);
        }
    }
}

// ============================================================
// QListWidget 事件回调
// ============================================================

void qListWidgetSetOnItemClicked(int64_t ptr, void (*callback)(int32_t)) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list && callback) {
        g_listItemClickedCallbacks[ptr] = callback;
        QObject::connect(list, &QListWidget::itemClicked, [ptr](QListWidgetItem* item) {
            auto it = g_listItemClickedCallbacks.find(ptr);
            if (it != g_listItemClickedCallbacks.end()) {
                QListWidget* l = reinterpret_cast<QListWidget*>(ptr);
                it->second(l->row(item));
            }
        });
    }
}

void qListWidgetSetOnItemDoubleClicked(int64_t ptr, void (*callback)(int32_t)) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list && callback) {
        g_listItemDoubleClickedCallbacks[ptr] = callback;
        QObject::connect(list, &QListWidget::itemDoubleClicked, [ptr](QListWidgetItem* item) {
            auto it = g_listItemDoubleClickedCallbacks.find(ptr);
            if (it != g_listItemDoubleClickedCallbacks.end()) {
                QListWidget* l = reinterpret_cast<QListWidget*>(ptr);
                it->second(l->row(item));
            }
        });
    }
}

void qListWidgetSetOnCurrentRowChanged(int64_t ptr, void (*callback)(int32_t)) {
    QListWidget* list = reinterpret_cast<QListWidget*>(ptr);
    if (list && callback) {
        g_listCurrentRowChangedCallbacks[ptr] = callback;
        QObject::connect(list, &QListWidget::currentRowChanged, [ptr](int row) {
            auto it = g_listCurrentRowChangedCallbacks.find(ptr);
            if (it != g_listCurrentRowChangedCallbacks.end()) {
                it->second(row);
            }
        });
    }
}

} // extern "C"
