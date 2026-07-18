/**
 * @file bridge_layout.cpp
 * @brief 布局管理桥接函数 - QVBoxLayout, QHBoxLayout, QGridLayout
 */

#include <QLayout>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QGridLayout>
#include <QFormLayout>

extern "C" {

// ============================================================
// QVBoxLayout 桥接函数
// ============================================================

int64_t qVBoxLayoutCreate() {
    QVBoxLayout* layout = new QVBoxLayout();
    return reinterpret_cast<int64_t>(layout);
}

void qVBoxLayoutAddWidget(int64_t layoutPtr, int64_t widgetPtr) {
    QVBoxLayout* layout = reinterpret_cast<QVBoxLayout*>(layoutPtr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (layout && widget) {
        layout->addWidget(widget);
    }
}

void qVBoxLayoutAddWidgetStretch(int64_t layoutPtr, int64_t widgetPtr, int32_t stretch) {
    QVBoxLayout* layout = reinterpret_cast<QVBoxLayout*>(layoutPtr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (layout && widget) {
        layout->addWidget(widget, stretch);
    }
}

void qVBoxLayoutAddLayout(int64_t layoutPtr, int64_t childLayoutPtr) {
    QVBoxLayout* layout = reinterpret_cast<QVBoxLayout*>(layoutPtr);
    QLayout* childLayout = reinterpret_cast<QLayout*>(childLayoutPtr);
    if (layout && childLayout) {
        layout->addLayout(childLayout);
    }
}

void qVBoxLayoutAddStretch(int64_t ptr) {
    QVBoxLayout* layout = reinterpret_cast<QVBoxLayout*>(ptr);
    if (layout) {
        layout->addStretch();
    }
}

void qVBoxLayoutSetSpacing(int64_t ptr, int32_t spacing) {
    QVBoxLayout* layout = reinterpret_cast<QVBoxLayout*>(ptr);
    if (layout) {
        layout->setSpacing(spacing);
    }
}

void qVBoxLayoutSetMargin(int64_t ptr, int32_t margin) {
    QVBoxLayout* layout = reinterpret_cast<QVBoxLayout*>(ptr);
    if (layout) {
        layout->setContentsMargins(margin, margin, margin, margin);
    }
}

void qVBoxLayoutDelete(int64_t ptr) {
    QVBoxLayout* layout = reinterpret_cast<QVBoxLayout*>(ptr);
    if (layout) {
        delete layout;
    }
}

// ============================================================
// QHBoxLayout 桥接函数
// ============================================================

int64_t qHBoxLayoutCreate() {
    QHBoxLayout* layout = new QHBoxLayout();
    return reinterpret_cast<int64_t>(layout);
}

void qHBoxLayoutAddWidget(int64_t layoutPtr, int64_t widgetPtr) {
    QHBoxLayout* layout = reinterpret_cast<QHBoxLayout*>(layoutPtr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (layout && widget) {
        layout->addWidget(widget);
    }
}

void qHBoxLayoutAddWidgetStretch(int64_t layoutPtr, int64_t widgetPtr, int32_t stretch) {
    QHBoxLayout* layout = reinterpret_cast<QHBoxLayout*>(layoutPtr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (layout && widget) {
        layout->addWidget(widget, stretch);
    }
}

void qHBoxLayoutAddLayout(int64_t layoutPtr, int64_t childLayoutPtr) {
    QHBoxLayout* layout = reinterpret_cast<QHBoxLayout*>(layoutPtr);
    QLayout* childLayout = reinterpret_cast<QLayout*>(childLayoutPtr);
    if (layout && childLayout) {
        layout->addLayout(childLayout);
    }
}

void qHBoxLayoutAddStretch(int64_t ptr) {
    QHBoxLayout* layout = reinterpret_cast<QHBoxLayout*>(ptr);
    if (layout) {
        layout->addStretch();
    }
}

void qHBoxLayoutSetSpacing(int64_t ptr, int32_t spacing) {
    QHBoxLayout* layout = reinterpret_cast<QHBoxLayout*>(ptr);
    if (layout) {
        layout->setSpacing(spacing);
    }
}

void qHBoxLayoutSetMargin(int64_t ptr, int32_t margin) {
    QHBoxLayout* layout = reinterpret_cast<QHBoxLayout*>(ptr);
    if (layout) {
        layout->setContentsMargins(margin, margin, margin, margin);
    }
}

void qHBoxLayoutDelete(int64_t ptr) {
    QHBoxLayout* layout = reinterpret_cast<QHBoxLayout*>(ptr);
    if (layout) {
        delete layout;
    }
}

// ============================================================
// QGridLayout 桥接函数
// ============================================================

int64_t qGridLayoutCreate() {
    QGridLayout* layout = new QGridLayout();
    return reinterpret_cast<int64_t>(layout);
}

void qGridLayoutAddWidget(int64_t layoutPtr, int64_t widgetPtr, int32_t row, int32_t col) {
    QGridLayout* layout = reinterpret_cast<QGridLayout*>(layoutPtr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (layout && widget) {
        layout->addWidget(widget, row, col);
    }
}

void qGridLayoutAddWidgetSpan(int64_t layoutPtr, int64_t widgetPtr, int32_t row, int32_t col, int32_t rowSpan, int32_t colSpan) {
    QGridLayout* layout = reinterpret_cast<QGridLayout*>(layoutPtr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (layout && widget) {
        layout->addWidget(widget, row, col, rowSpan, colSpan);
    }
}

void qGridLayoutSetSpacing(int64_t ptr, int32_t spacing) {
    QGridLayout* layout = reinterpret_cast<QGridLayout*>(ptr);
    if (layout) {
        layout->setSpacing(spacing);
    }
}

void qGridLayoutSetMargin(int64_t ptr, int32_t margin) {
    QGridLayout* layout = reinterpret_cast<QGridLayout*>(ptr);
    if (layout) {
        layout->setContentsMargins(margin, margin, margin, margin);
    }
}

void qGridLayoutDelete(int64_t ptr) {
    QGridLayout* layout = reinterpret_cast<QGridLayout*>(ptr);
    if (layout) {
        delete layout;
    }
}

// ============================================================
// QFormLayout 桥接函数
// ============================================================

int64_t qFormLayoutCreate() {
    QFormLayout* layout = new QFormLayout();
    return reinterpret_cast<int64_t>(layout);
}

void qFormLayoutAddRow(int64_t ptr, const char* label, int64_t widgetPtr) {
    QFormLayout* layout = reinterpret_cast<QFormLayout*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (layout && widget) {
        layout->addRow(QString::fromUtf8(label), widget);
    }
}

void qFormLayoutAddRowWidget(int64_t ptr, int64_t labelWidgetPtr, int64_t fieldWidgetPtr) {
    QFormLayout* layout = reinterpret_cast<QFormLayout*>(ptr);
    QWidget* labelWidget = reinterpret_cast<QWidget*>(labelWidgetPtr);
    QWidget* fieldWidget = reinterpret_cast<QWidget*>(fieldWidgetPtr);
    if (layout && labelWidget && fieldWidget) {
        layout->addRow(labelWidget, fieldWidget);
    }
}

void qFormLayoutAddRowLayout(int64_t ptr, const char* label, int64_t layoutPtr) {
    QFormLayout* layout = reinterpret_cast<QFormLayout*>(ptr);
    QLayout* childLayout = reinterpret_cast<QLayout*>(layoutPtr);
    if (layout && childLayout) {
        layout->addRow(QString::fromUtf8(label), childLayout);
    }
}

void qFormLayoutInsertRow(int64_t ptr, int32_t row, const char* label, int64_t widgetPtr) {
    QFormLayout* layout = reinterpret_cast<QFormLayout*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (layout && widget) {
        layout->insertRow(row, QString::fromUtf8(label), widget);
    }
}

void qFormLayoutRemoveRow(int64_t ptr, int32_t row) {
    QFormLayout* layout = reinterpret_cast<QFormLayout*>(ptr);
    if (layout) {
        layout->removeRow(row);
    }
}

int32_t qFormLayoutRowCount(int64_t ptr) {
    QFormLayout* layout = reinterpret_cast<QFormLayout*>(ptr);
    return layout ? layout->rowCount() : 0;
}

void qFormLayoutSetSpacing(int64_t ptr, int32_t spacing) {
    QFormLayout* layout = reinterpret_cast<QFormLayout*>(ptr);
    if (layout) {
        layout->setSpacing(spacing);
    }
}

void qFormLayoutSetMargin(int64_t ptr, int32_t margin) {
    QFormLayout* layout = reinterpret_cast<QFormLayout*>(ptr);
    if (layout) {
        layout->setContentsMargins(margin, margin, margin, margin);
    }
}

void qFormLayoutSetLabelAlignment(int64_t ptr, int32_t alignment) {
    QFormLayout* layout = reinterpret_cast<QFormLayout*>(ptr);
    if (layout) {
        layout->setLabelAlignment(static_cast<Qt::Alignment>(alignment));
    }
}

void qFormLayoutSetFormAlignment(int64_t ptr, int32_t alignment) {
    QFormLayout* layout = reinterpret_cast<QFormLayout*>(ptr);
    if (layout) {
        layout->setFormAlignment(static_cast<Qt::Alignment>(alignment));
    }
}

void qFormLayoutSetFieldGrowthPolicy(int64_t ptr, int32_t policy) {
    QFormLayout* layout = reinterpret_cast<QFormLayout*>(ptr);
    if (layout) {
        layout->setFieldGrowthPolicy(static_cast<QFormLayout::FieldGrowthPolicy>(policy));
    }
}

void qFormLayoutSetRowWrapPolicy(int64_t ptr, int32_t policy) {
    QFormLayout* layout = reinterpret_cast<QFormLayout*>(ptr);
    if (layout) {
        layout->setRowWrapPolicy(static_cast<QFormLayout::RowWrapPolicy>(policy));
    }
}

void qFormLayoutDelete(int64_t ptr) {
    QFormLayout* layout = reinterpret_cast<QFormLayout*>(ptr);
    if (layout) {
        delete layout;
    }
}

} // extern "C"
