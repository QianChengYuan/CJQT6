
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
#include <QStyle>
#include <QLineEdit>
#include <QTextEdit>
#include <QPrinter>
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

// 设置按钮图标（从文件路径）
void qButtonSetIcon(int64_t ptr, const char* iconPath) {
    QPushButton* button = reinterpret_cast<QPushButton*>(ptr);
    if (button && iconPath) {
        QIcon icon(QString::fromUtf8(iconPath));
        button->setIcon(icon);
    }
}

// 设置按钮图标大小
void qButtonSetIconSize(int64_t ptr, int32_t width, int32_t height) {
    QPushButton* button = reinterpret_cast<QPushButton*>(ptr);
    if (button) {
        button->setIconSize(QSize(width, height));
    }
}

// 设置按钮使用 Qt 标准图标
void qButtonSetStandardIcon(int64_t ptr, int32_t iconType) {
    QPushButton* button = reinterpret_cast<QPushButton*>(ptr);
    if (button) {
        QStyle::StandardPixmap standardIcon;
        switch (iconType) {
            case 0: standardIcon = QStyle::SP_DialogOpenButton; break;
            case 1: standardIcon = QStyle::SP_DialogSaveButton; break;
            case 2: standardIcon = QStyle::SP_DialogCloseButton; break;
            case 3: standardIcon = QStyle::SP_DialogApplyButton; break;
            case 4: standardIcon = QStyle::SP_DialogCancelButton; break;
            case 5: standardIcon = QStyle::SP_DialogHelpButton; break;
            case 6: standardIcon = QStyle::SP_FileIcon; break;
            case 7: standardIcon = QStyle::SP_DirIcon; break;
            case 8: standardIcon = QStyle::SP_FileDialogNewFolder; break;
            case 9: standardIcon = QStyle::SP_CommandLink; break;
            case 10: standardIcon = QStyle::SP_BrowserReload; break;
            case 11: standardIcon = QStyle::SP_BrowserStop; break;
            case 12: standardIcon = QStyle::SP_MediaPlay; break;
            case 13: standardIcon = QStyle::SP_MediaPause; break;
            case 14: standardIcon = QStyle::SP_MediaStop; break;
            case 15: standardIcon = QStyle::SP_MediaSeekForward; break;
            case 16: standardIcon = QStyle::SP_MediaSeekBackward; break;
            case 17: standardIcon = QStyle::SP_MediaSkipForward; break;
            case 18: standardIcon = QStyle::SP_MediaSkipBackward; break;
            case 19: standardIcon = QStyle::SP_ArrowUp; break;
            case 20: standardIcon = QStyle::SP_ArrowDown; break;
            case 21: standardIcon = QStyle::SP_ArrowLeft; break;
            case 22: standardIcon = QStyle::SP_ArrowRight; break;
            case 23: standardIcon = QStyle::SP_DialogYesButton; break;
            case 24: standardIcon = QStyle::SP_DialogNoButton; break;
            default: standardIcon = QStyle::SP_DialogApplyButton; break;
        }
        QIcon icon = button->style()->standardIcon(standardIcon);
        button->setIcon(icon);
    }
}

void qButtonSetCheckable(int64_t ptr, bool checkable) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn) btn->setCheckable(checkable);
}
void qButtonSetChecked(int64_t ptr, bool checked) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn) btn->setChecked(checked);
}
bool qButtonIsChecked(int64_t ptr) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    return btn ? btn->isChecked() : false;
}
void qButtonSetDefault(int64_t ptr, bool isDefault) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn) btn->setDefault(isDefault);
}
void qButtonSetFlat(int64_t ptr, bool flat) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn) btn->setFlat(flat);
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

// 密码可见性切换按钮存储
static std::unordered_map<int64_t, std::function<void()>> g_passwordToggleCallbacks;
static std::unordered_map<int64_t, QToolButton*> g_passwordToggleButtons;

// 添加密码可见性切换按钮到输入框右侧
void qLineEditAddPasswordToggleAction(int64_t ptr, void (*callback)()) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit && callback) {
        // 创建一个 QToolButton 作为切换按钮
        QToolButton* toggleBtn = new QToolButton(lineEdit);
        
        // 使用文本符号：● 表示隐藏状态，○ 表示显示状态
        toggleBtn->setText(QString::fromUtf8("\u25CF"));  // ● 实心圆点
        toggleBtn->setCursor(Qt::PointingHandCursor);
        toggleBtn->setFixedSize(20, 20);  // 更小的按钮
        toggleBtn->setStyleSheet(
            "QToolButton {"
            "  border: none;"
            "  background: transparent;"
            "  font-size: 12px;"
            "  color: #666;"
            "  padding: 0px;"
            "}"
            "QToolButton:hover {"
            "  color: #333;"
            "  background: rgba(0,0,0,0.1);"
            "  border-radius: 2px;"
            "}"
        );
        
        // 存储回调和按钮
        g_passwordToggleCallbacks[ptr] = callback;
        g_passwordToggleButtons[ptr] = toggleBtn;
        
        // 连接点击信号
        int64_t widgetPtr = ptr;
        QObject::connect(toggleBtn, &QToolButton::clicked, [widgetPtr]() {
            auto it = g_passwordToggleCallbacks.find(widgetPtr);
            if (it != g_passwordToggleCallbacks.end()) {
                it->second();
            }
        });
        
        // 设置输入框右侧内边距
        int frameWidth = lineEdit->style()->pixelMetric(QStyle::PM_DefaultFrameWidth);
        lineEdit->setStyleSheet(
            QString("QLineEdit { padding-right: %1px; }").arg(20 + frameWidth + 1)
        );
        
        // 定位按钮 - 垂直居中，向上微调
        int editHeight = lineEdit->height();
        int yPos = (editHeight - 20) / 2 - 1;  // 向上偏移1像素
        int xPos = lineEdit->width() - 20 - frameWidth - 1;  // 减少右边空隙
        toggleBtn->move(xPos, yPos);
        toggleBtn->show();
        
        // 监听文本变化重新定位
        QObject::connect(lineEdit, &QLineEdit::textChanged, [lineEdit, toggleBtn]() {
            int frameWidth = lineEdit->style()->pixelMetric(QStyle::PM_DefaultFrameWidth);
            int editHeight = lineEdit->height();
            int yPos = (editHeight - 20) / 2 - 1;
            int xPos = lineEdit->width() - 20 - frameWidth - 1;
            toggleBtn->move(xPos, yPos);
        });
    }
}

// 设置密码切换按钮图标（true=可见，false=隐藏）
void qLineEditSetPasswordToggleIcon(int64_t ptr, bool visible) {
    auto it = g_passwordToggleButtons.find(ptr);
    if (it != g_passwordToggleButtons.end()) {
        QToolButton* btn = it->second;
        if (btn) {
            if (visible) {
                // 密码可见时显示空心圆点（表示可以隐藏）
                btn->setText(QString::fromUtf8("\u25CB"));  // ○ 空心圆点
            } else {
                // 密码隐藏时显示实心圆点（表示可以显示）
                btn->setText(QString::fromUtf8("\u25CF"));  // ● 实心圆点
            }
        }
    }
}

// 设置输入掩码（格式化输入）
// 掩码字符：
// 0 - 数字（必填）
// 9 - 数字（可选）
// # - 数字或正负号（可选）
// D - 非零数字（必填）
// d - 非零数字（可选）
// A - 字母（必填）
// a - 字母（可选）
// N - 字母或数字（必填）
// n - 字母或数字（可选）
// H - 十六进制字符（必填）
// h - 十六进制字符（可选）
// X - 任意字符（必填）
// x - 任意字符（可选）
// > - 转换为大写
// < - 转换为小写
// ! - 关闭大小写转换
// ;c - 设置占位字符为 c
void qLineEditSetInputMask(int64_t ptr, const char* mask) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit && mask) {
        lineEdit->setInputMask(QString::fromUtf8(mask));
    }
}

// 设置是否显示边框
void qLineEditSetFrame(int64_t ptr, bool enabled) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->setFrame(enabled);
    }
}

// 设置文本对齐方式
// 0x01 = AlignLeft
// 0x02 = AlignRight
// 0x04 = AlignHCenter
// 0x20 = AlignTop
// 0x40 = AlignBottom
// 0x80 = AlignVCenter
// 0x84 = AlignCenter
void qLineEditSetAlignment(int64_t ptr, int32_t alignment) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->setAlignment(static_cast<Qt::Alignment>(alignment));
    }
}

// 获取文本长度
int32_t qLineEditLength(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        return lineEdit->text().length();
    }
    return 0;
}

// 获取最大长度
int32_t qLineEditMaxLength(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        return lineEdit->maxLength();
    }
    return 32767;
}

// 是否有选中文本
bool qLineEditHasSelectedText(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        return lineEdit->hasSelectedText();
    }
    return false;
}

// 获取选中的文本
const char* qLineEditSelectedText(int64_t ptr) {
    static thread_local std::string selectedTextStr;
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        selectedTextStr = lineEdit->selectedText().toStdString();
        return selectedTextStr.c_str();
    }
    return "";
}

// 选中所有文本
void qLineEditSelectAll(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->selectAll();
    }
}

// 设置焦点
void qLineEditSetFocus(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->setFocus();
    }
}

void qLineEditDelete(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        g_textChangedCallbacks.erase(ptr);
        g_passwordToggleCallbacks.erase(ptr);
        g_passwordToggleButtons.erase(ptr);
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

void qTextEditUndo(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        textEdit->undo();
    }
}

void qTextEditRedo(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        textEdit->redo();
    }
}

bool qTextEditCanUndo(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        return textEdit->document()->isUndoAvailable();
    }
    return false;
}

bool qTextEditCanRedo(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        return textEdit->document()->isRedoAvailable();
    }
    return false;
}

bool qTextEditIsModified(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        return textEdit->document()->isModified();
    }
    return false;
}

void qTextEditSetModified(int64_t ptr, bool modified) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        textEdit->document()->setModified(modified);
    }
}

void qTextEditSetLineWrapMode(int64_t ptr, int mode) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        textEdit->setLineWrapMode(static_cast<QTextEdit::LineWrapMode>(mode));
    }
}

int qTextEditLineWrapMode(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        return static_cast<int>(textEdit->lineWrapMode());
    }
    return 0;
}

void qTextEditSetFontFamily(int64_t ptr, const char* family) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        QFont font = textEdit->font();
        font.setFamily(QString::fromUtf8(family));
        textEdit->setFont(font);
    }
}

void qTextEditSetFontSize(int64_t ptr, int size) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        QFont font = textEdit->font();
        font.setPointSize(size);
        textEdit->setFont(font);
    }
}

void qTextEditSetFontBold(int64_t ptr, bool bold) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        QFont font = textEdit->font();
        font.setBold(bold);
        textEdit->setFont(font);
    }
}

void qTextEditSetFontItalic(int64_t ptr, bool italic) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        QFont font = textEdit->font();
        font.setItalic(italic);
        textEdit->setFont(font);
    }
}

// 查找功能
bool qTextEditFind(int64_t ptr, const char* text, bool caseSensitive) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        QTextDocument::FindFlags flags;
        if (caseSensitive) {
            flags |= QTextDocument::FindCaseSensitively;
        }
        return textEdit->find(QString::fromUtf8(text), flags);
    }
    return false;
}

void qTextEditFindNext(int64_t ptr, const char* text, bool caseSensitive) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        QTextDocument::FindFlags flags;
        if (caseSensitive) {
            flags |= QTextDocument::FindCaseSensitively;
        }
        textEdit->find(QString::fromUtf8(text), flags);
    }
}

void qTextEditFindPrev(int64_t ptr, const char* text, bool caseSensitive) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        QTextDocument::FindFlags flags = QTextDocument::FindBackward;
        if (caseSensitive) {
            flags |= QTextDocument::FindCaseSensitively;
        }
        textEdit->find(QString::fromUtf8(text), flags);
    }
}

// 替换功能
void qTextEditReplace(int64_t ptr, const char* newText) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        QTextCursor cursor = textEdit->textCursor();
        if (cursor.hasSelection()) {
            cursor.insertText(QString::fromUtf8(newText));
        }
    }
}

int qTextEditReplaceAll(int64_t ptr, const char* oldText, const char* newText, bool caseSensitive) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (!textEdit) return 0;
    
    int count = 0;
    QTextDocument::FindFlags flags;
    if (caseSensitive) {
        flags |= QTextDocument::FindCaseSensitively;
    }
    
    // 移动到文档开头
    QTextCursor cursor = textEdit->textCursor();
    cursor.movePosition(QTextCursor::Start);
    textEdit->setTextCursor(cursor);
    
    QString oldStr = QString::fromUtf8(oldText);
    QString newStr = QString::fromUtf8(newText);
    
    while (textEdit->find(oldStr, flags)) {
        QTextCursor cur = textEdit->textCursor();
        if (cur.hasSelection()) {
            cur.insertText(newStr);
            count++;
        }
    }
    
    return count;
}

// 光标位置
int qTextEditLineCount(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        return textEdit->document()->lineCount();
    }
    return 0;
}

int qTextEditCurrentLine(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        QTextCursor cursor = textEdit->textCursor();
        return cursor.blockNumber() + 1;  // 返回1-based行号
    }
    return 1;
}

int qTextEditCurrentColumn(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        QTextCursor cursor = textEdit->textCursor();
        return cursor.columnNumber() + 1;  // 返回1-based列号
    }
    return 1;
}

int qTextEditCharacterCount(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        return textEdit->document()->characterCount();
    }
    return 0;
}

// 打印功能
void qTextEditPrint(int64_t ptr, int64_t printerPtr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    QPrinter* printer = reinterpret_cast<QPrinter*>(printerPtr);
    if (textEdit && printer) {
        textEdit->print(printer);
    }
}

// 跳转到指定行
void qTextEditGoToLine(int64_t ptr, int line) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        QTextCursor cursor = textEdit->textCursor();
        cursor.movePosition(QTextCursor::Start);
        for (int i = 1; i < line && !cursor.atEnd(); ++i) {
            cursor.movePosition(QTextCursor::Down);
        }
        textEdit->setTextCursor(cursor);
        textEdit->setFocus();
    }
}

} // extern "C"
