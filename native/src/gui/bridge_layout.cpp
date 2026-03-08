/**
 * @file bridge_layout.cpp
 * @brief 布局管理桥接函数 - QVBoxLayout, QHBoxLayout, QGridLayout
 */

#include <QLayout>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QGridLayout>

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

} // extern "C"
