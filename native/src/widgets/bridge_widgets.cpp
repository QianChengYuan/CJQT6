/**
 * @file bridge_widgets.cpp
 * @brief 基础部件桥接函数 - QLabel, QPushButton, QToolButton, QLineEdit, QTextEdit
 */

#include <QLabel>
#include <QPushButton>
#include <QToolButton>
#include <QMenu>
#include <QIcon>
#include <QSize>
#include <QLineEdit>
#include <QTextEdit>
#include <functional>
#include <unordered_map>

// 外部回调映射声明
extern std::unordered_map<int64_t, std::function<void(int64_t)>> g_buttonCallbacks;
extern std::unordered_map<int64_t, std::function<void(int64_t)>> g_lineEditCallbacks;

// 文本变化回调映射
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_textChangedCallbacks;

extern "C" {

// ============================================================
// QLabel 桥接函数
// ============================================================

int64_t qLabelCreate() {
    QLabel* label = new QLabel();
    return reinterpret_cast<int64_t>(label);
}

void qLabelSetText(int64_t ptr, const char* text) {
    QLabel* label = reinterpret_cast<QLabel*>(ptr);
    if (label) {
        label->setText(text);
    }
}

void qLabelSetAlignment(int64_t ptr, int32_t alignment) {
    QLabel* label = reinterpret_cast<QLabel*>(ptr);
    if (label) {
        label->setAlignment(static_cast<Qt::AlignmentFlag>(alignment));
    }
}

void qLabelSetPixmap(int64_t ptr, int64_t pixmapPtr) {
    QLabel* label = reinterpret_cast<QLabel*>(ptr);
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(pixmapPtr);
    if (label && pixmap) {
        label->setPixmap(*pixmap);
    }
}

void qLabelDelete(int64_t ptr) {
    QLabel* label = reinterpret_cast<QLabel*>(ptr);
    if (label) {
        delete label;
    }
}

// ============================================================
// QPushButton 桥接函数
// ============================================================

int64_t qButtonCreate() {
    QPushButton* button = new QPushButton();
    return reinterpret_cast<int64_t>(button);
}

void qButtonSetText(int64_t ptr, const char* text) {
    QPushButton* button = reinterpret_cast<QPushButton*>(ptr);
    if (button) {
        button->setText(text);
    }
}

void qButtonSetOnClick(int64_t ptr, void (*callback)(int64_t)) {
    QPushButton* button = reinterpret_cast<QPushButton*>(ptr);
    if (button) {
        int64_t widgetPtr = ptr;
        g_buttonCallbacks[ptr] = [callback, widgetPtr](int64_t) { callback(widgetPtr); };
        QObject::connect(button, &QPushButton::clicked, [widgetPtr]() {
            auto it = g_buttonCallbacks.find(widgetPtr);
            if (it != g_buttonCallbacks.end()) {
                it->second(widgetPtr);
            }
        });
    }
}

void qButtonDelete(int64_t ptr) {
    QPushButton* button = reinterpret_cast<QPushButton*>(ptr);
    if (button) {
        g_buttonCallbacks.erase(ptr);
        delete button;
    }
}

// ============================================================
// QToolButton 桥接函数
// ============================================================

int64_t qToolButtonCreate() {
    QToolButton* button = new QToolButton();
    return reinterpret_cast<int64_t>(button);
}

void qToolButtonSetText(int64_t ptr, const char* text) {
    QToolButton* button = reinterpret_cast<QToolButton*>(ptr);
    if (button) {
        button->setText(text);
    }
}

void qToolButtonSetIcon(int64_t ptr, int64_t iconPtr) {
    QToolButton* button = reinterpret_cast<QToolButton*>(ptr);
    QIcon* icon = reinterpret_cast<QIcon*>(iconPtr);
    if (button && icon) {
        button->setIcon(*icon);
    }
}

void qToolButtonSetIconSize(int64_t ptr, int32_t width, int32_t height) {
    QToolButton* button = reinterpret_cast<QToolButton*>(ptr);
    if (button) {
        button->setIconSize(QSize(width, height));
    }
}

void qToolButtonSetToolButtonStyle(int64_t ptr, int32_t style) {
    QToolButton* button = reinterpret_cast<QToolButton*>(ptr);
    if (button) {
        button->setToolButtonStyle(static_cast<Qt::ToolButtonStyle>(style));
    }
}

void qToolButtonSetPopupMode(int64_t ptr, int32_t mode) {
    QToolButton* button = reinterpret_cast<QToolButton*>(ptr);
    if (button) {
        button->setPopupMode(static_cast<QToolButton::ToolButtonPopupMode>(mode));
    }
}

void qToolButtonSetAutoRaise(int64_t ptr, bool enabled) {
    QToolButton* button = reinterpret_cast<QToolButton*>(ptr);
    if (button) {
        button->setAutoRaise(enabled);
    }
}

bool qToolButtonAutoRaise(int64_t ptr) {
    QToolButton* button = reinterpret_cast<QToolButton*>(ptr);
    if (button) {
        return button->autoRaise();
    }
    return false;
}

void qToolButtonSetArrowType(int64_t ptr, int32_t type) {
    QToolButton* button = reinterpret_cast<QToolButton*>(ptr);
    if (button) {
        button->setArrowType(static_cast<Qt::ArrowType>(type));
    }
}

void qToolButtonSetMenu(int64_t ptr, int64_t menuPtr) {
    QToolButton* button = reinterpret_cast<QToolButton*>(ptr);
    QMenu* menu = reinterpret_cast<QMenu*>(menuPtr);
    if (button && menu) {
        button->setMenu(menu);
    }
}

void qToolButtonShowMenu(int64_t ptr) {
    QToolButton* button = reinterpret_cast<QToolButton*>(ptr);
    if (button) {
        button->showMenu();
    }
}

void qToolButtonDelete(int64_t ptr) {
    QToolButton* button = reinterpret_cast<QToolButton*>(ptr);
    if (button) {
        delete button;
    }
}

// ============================================================
// QLineEdit 桥接函数
// ============================================================

int64_t qLineEditCreate() {
    QLineEdit* lineEdit = new QLineEdit();
    return reinterpret_cast<int64_t>(lineEdit);
}

void qLineEditSetText(int64_t ptr, const char* text) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->setText(QString::fromUtf8(text));
    }
}

const char* qLineEditText(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        static QString text;
        text = lineEdit->text();
        return text.toUtf8().constData();
    }
    return "";
}

void qLineEditSetPlaceholder(int64_t ptr, const char* text) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->setPlaceholderText(QString::fromUtf8(text));
    }
}

void qLineEditSetMaxLength(int64_t ptr, int32_t length) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->setMaxLength(length);
    }
}

void qLineEditSetReadOnly(int64_t ptr, bool readonly) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->setReadOnly(readonly);
    }
}

void qLineEditSetEchoMode(int64_t ptr, int32_t mode) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->setEchoMode(static_cast<QLineEdit::EchoMode>(mode));
    }
}

void qLineEditClear(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->clear();
    }
}

void qLineEditSetOnTextChanged(int64_t ptr, void (*callback)(int64_t)) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        int64_t widgetPtr = ptr;
        g_textChangedCallbacks[ptr] = [callback, widgetPtr](int64_t) { callback(widgetPtr); };
        QObject::connect(lineEdit, &QLineEdit::textChanged, [widgetPtr](const QString&) {
            auto it = g_textChangedCallbacks.find(widgetPtr);
            if (it != g_textChangedCallbacks.end()) {
                it->second(widgetPtr);
            }
        });
    }
}

void qLineEditDelete(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        g_textChangedCallbacks.erase(ptr);
        delete lineEdit;
    }
}

// ============================================================
// QTextEdit 桥接函数
// ============================================================

int64_t qTextEditCreate() {
    QTextEdit* textEdit = new QTextEdit();
    return reinterpret_cast<int64_t>(textEdit);
}

void qTextEditSetText(int64_t ptr, const char* text) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        textEdit->setText(QString::fromUtf8(text));
    }
}

const char* qTextEditText(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        // 使用独立的静态缓冲区，大小足够大
        static QByteArray buffer;
        buffer = textEdit->toPlainText().toUtf8();
        return buffer.constData();
    }
    return "";
}

void qTextEditSetReadOnly(int64_t ptr, bool readonly) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        textEdit->setReadOnly(readonly);
    }
}

void qTextEditClear(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        textEdit->clear();
    }
}

void qTextEditDelete(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        delete textEdit;
    }
}

} // extern "C"

// ============================================================
// QTextEdit 扩展方法
// ============================================================

extern "C" {

void qTextEditCut(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        textEdit->cut();
    }
}

void qTextEditCopy(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        textEdit->copy();
    }
}

void qTextEditPaste(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        textEdit->paste();
    }
}

void qTextEditSelectAll(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        textEdit->selectAll();
    }
}

bool qTextEditCanPaste(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        return textEdit->canPaste();
    }
    return false;
}

} // extern "C"
