/**
 * @file bridge_table.cpp
 * @brief 表格部件桥接函数 - QTableWidget
 */

#include <QTableWidget>
#include <QTableWidgetItem>
#include <QHeaderView>
#include "bridge_string_utils.h"

extern "C" {

// ============================================================
// QTableWidget 桥接函数
// ============================================================

int64_t qTableWidgetCreate() {
    QTableWidget* table = new QTableWidget();
    return reinterpret_cast<int64_t>(table);
}

int64_t qTableWidgetCreateWithSize(int32_t rows, int32_t cols) {
    QTableWidget* table = new QTableWidget(rows, cols);
    return reinterpret_cast<int64_t>(table);
}

void qTableWidgetSetRowCount(int64_t ptr, int32_t rows) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setRowCount(rows);
    }
}

void qTableWidgetSetColumnCount(int64_t ptr, int32_t cols) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setColumnCount(cols);
    }
}

int32_t qTableWidgetRowCount(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        return table->rowCount();
    }
    return 0;
}

int32_t qTableWidgetColumnCount(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        return table->columnCount();
    }
    return 0;
}

void qTableWidgetSetHorizontalHeaderLabel(int64_t ptr, int32_t col, const char* label) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        QTableWidgetItem* item = table->horizontalHeaderItem(col);
        if (!item) {
            item = new QTableWidgetItem(QString::fromUtf8(label));
            table->setHorizontalHeaderItem(col, item);
        } else {
            item->setText(QString::fromUtf8(label));
        }
    }
}

void qTableWidgetSetVerticalHeaderLabel(int64_t ptr, int32_t row, const char* label) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        QTableWidgetItem* item = table->verticalHeaderItem(row);
        if (!item) {
            item = new QTableWidgetItem(QString::fromUtf8(label));
            table->setVerticalHeaderItem(row, item);
        } else {
            item->setText(QString::fromUtf8(label));
        }
    }
}

void qTableWidgetSetItem(int64_t ptr, int32_t row, int32_t col, const char* text) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        QTableWidgetItem* item = new QTableWidgetItem(QString::fromUtf8(text));
        table->setItem(row, col, item);
    }
}

const char* qTableWidgetItemText(int64_t ptr, int32_t row, int32_t col) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        QTableWidgetItem* item = table->item(row, col);
        if (item) {
            return cjqt6::dupUtf8(item->text());
        }
    }
    return cjqt6::emptyString();
}

void qTableWidgetClear(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->clear();
    }
}

void qTableWidgetClearContents(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->clearContents();
    }
}

void qTableWidgetInsertRow(int64_t ptr, int32_t row) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->insertRow(row);
    }
}

void qTableWidgetInsertColumn(int64_t ptr, int32_t col) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->insertColumn(col);
    }
}

void qTableWidgetRemoveRow(int64_t ptr, int32_t row) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->removeRow(row);
    }
}

void qTableWidgetRemoveColumn(int64_t ptr, int32_t col) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->removeColumn(col);
    }
}

int32_t qTableWidgetCurrentRow(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        return table->currentRow();
    }
    return -1;
}

int32_t qTableWidgetCurrentColumn(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        return table->currentColumn();
    }
    return -1;
}

void qTableWidgetSetCurrentCell(int64_t ptr, int32_t row, int32_t col) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setCurrentCell(row, col);
    }
}

void qTableWidgetSetSelectionBehavior(int64_t ptr, int32_t behavior) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setSelectionBehavior(static_cast<QAbstractItemView::SelectionBehavior>(behavior));
    }
}

void qTableWidgetSetSelectionMode(int64_t ptr, int32_t mode) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setSelectionMode(static_cast<QAbstractItemView::SelectionMode>(mode));
    }
}

void qTableWidgetSetShowGrid(int64_t ptr, bool show) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setShowGrid(show);
    }
}

void qTableWidgetSetSortingEnabled(int64_t ptr, bool enabled) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setSortingEnabled(enabled);
    }
}

void qTableWidgetSetAlternatingRowColors(int64_t ptr, bool enabled) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setAlternatingRowColors(enabled);
    }
}

void qTableWidgetResizeColumnsToContents(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->resizeColumnsToContents();
    }
}

void qTableWidgetResizeRowsToContents(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->resizeRowsToContents();
    }
}

void qTableWidgetSetColumnWidth(int64_t ptr, int32_t col, int32_t width) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setColumnWidth(col, width);
    }
}

void qTableWidgetSetRowHeight(int64_t ptr, int32_t row, int32_t height) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setRowHeight(row, height);
    }
}

// 水平表头设置
void qTableWidgetHorizontalHeaderSetStretchLastSection(int64_t ptr, bool stretch) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->horizontalHeader()->setStretchLastSection(stretch);
    }
}

void qTableWidgetHorizontalHeaderSetSectionResizeMode(int64_t ptr, int32_t mode) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->horizontalHeader()->setSectionResizeMode(static_cast<QHeaderView::ResizeMode>(mode));
    }
}

void qTableWidgetHorizontalHeaderSetSectionResizeModeColumn(int64_t ptr, int32_t col, int32_t mode) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->horizontalHeader()->setSectionResizeMode(col, static_cast<QHeaderView::ResizeMode>(mode));
    }
}

// 垂直表头设置
void qTableWidgetVerticalHeaderSetStretchLastSection(int64_t ptr, bool stretch) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->verticalHeader()->setStretchLastSection(stretch);
    }
}

void qTableWidgetVerticalHeaderSetDefaultSectionSize(int64_t ptr, int32_t size) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->verticalHeader()->setDefaultSectionSize(size);
    }
}

void qTableWidgetDelete(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        delete table;
    }
}

} // extern "C"