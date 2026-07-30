
/**
 * @file bridge_widgets.cpp
 * @brief ���������ŽӺ��� - QLabel, QPushButton, QToolButton, QLineEdit, QTextEdit
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
#include <QPlainTextEdit>
#include <QCompleter>
#include <QStringListModel>
#include <QPrinter>
#include <QGraphicsView>
#include <QGraphicsScene>
#include <QGraphicsItem>
#include <QGraphicsProxyWidget>
#include <QPen>
#include <QBrush>
#include <QTextBrowser>
#include <QKeySequenceEdit>
#include <QSystemTrayIcon>
#include <QGraphicsOpacityEffect>
#include <QGraphicsDropShadowEffect>
#include <QFontComboBox>
#include <QDialogButtonBox>
#include <QCommandLinkButton>
#include <QScrollBar>
#include <QIntValidator>
#include <QDoubleValidator>
#include <QSplashScreen>
#include <QSizeGrip>
#include <QRubberBand>
#include <functional>
#include <unordered_map>

// �ⲿ�ص�ӳ������
extern std::unordered_map<int64_t, std::function<void(int64_t)>> g_buttonCallbacks;
extern std::unordered_map<int64_t, std::function<void(int64_t)>> g_lineEditCallbacks;

// �ı��仯�ص�ӳ��
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_textChangedCallbacks;

extern "C" {

// ============================================================
// QLabel �ŽӺ���
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

const char* qLabelText(int64_t ptr) {
    QLabel* label = reinterpret_cast<QLabel*>(ptr);
    if (!label) return nullptr;
    QByteArray arr = label->text().toUtf8();
    char* result = (char*)malloc(arr.size() + 1);
    if (result) memcpy(result, arr.constData(), arr.size() + 1);
    return result;
}
void qLabelSetWordWrap(int64_t ptr, bool wrap) {
    QLabel* label = reinterpret_cast<QLabel*>(ptr);
    if (label) label->setWordWrap(wrap);
}
bool qLabelWordWrap(int64_t ptr) {
    QLabel* label = reinterpret_cast<QLabel*>(ptr);
    return label ? label->wordWrap() : false;
}

void qLabelDelete(int64_t ptr) {
    QLabel* label = reinterpret_cast<QLabel*>(ptr);
    if (label) {
        delete label;
    }
}

// ============================================================
// QPushButton �ŽӺ���
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

const char* qButtonText(int64_t ptr) {
    QPushButton* button = reinterpret_cast<QPushButton*>(ptr);
    if (!button) return "";
    QByteArray arr = button->text().toUtf8();
    char* result = (char*)malloc(arr.size() + 1);
    if (result) memcpy(result, arr.constData(), arr.size() + 1);
    return result;
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

// ���ð�ťͼ�꣨���ļ�·����
void qButtonSetIcon(int64_t ptr, const char* iconPath) {
    QPushButton* button = reinterpret_cast<QPushButton*>(ptr);
    if (button && iconPath) {
        QIcon icon(QString::fromUtf8(iconPath));
        button->setIcon(icon);
    }
}

// ���ð�ťͼ���С
void qButtonSetIconSize(int64_t ptr, int32_t width, int32_t height) {
    QPushButton* button = reinterpret_cast<QPushButton*>(ptr);
    if (button) {
        button->setIconSize(QSize(width, height));
    }
}

// ���ð�ťʹ�� Qt ��׼ͼ��
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
// QToolButton �ŽӺ���
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
// QLineEdit �ŽӺ���
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
    if (!lineEdit) return nullptr;
    QByteArray arr = lineEdit->text().toUtf8();
    char* result = (char*)malloc(arr.size() + 1);
    if (result) memcpy(result, arr.constData(), arr.size() + 1);
    return result;
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

// ����ɼ����л���ť�洢
static std::unordered_map<int64_t, std::function<void()>> g_passwordToggleCallbacks;
static std::unordered_map<int64_t, QToolButton*> g_passwordToggleButtons;

// ��������ɼ����л���ť��������Ҳ�
void qLineEditAddPasswordToggleAction(int64_t ptr, void (*callback)()) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit && callback) {
        // ����һ�� QToolButton ��Ϊ�л���ť
        QToolButton* toggleBtn = new QToolButton(lineEdit);
        
        // ʹ���ı����ţ��� ��ʾ����״̬���� ��ʾ��ʾ״̬
        toggleBtn->setText(QString::fromUtf8("\u25CF"));  // �� ʵ��Բ��
        toggleBtn->setCursor(Qt::PointingHandCursor);
        toggleBtn->setFixedSize(20, 20);  // ��С�İ�ť
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
        
        // �洢�ص��Ͱ�ť
        g_passwordToggleCallbacks[ptr] = callback;
        g_passwordToggleButtons[ptr] = toggleBtn;
        
        // ���ӵ���ź�
        int64_t widgetPtr = ptr;
        QObject::connect(toggleBtn, &QToolButton::clicked, [widgetPtr]() {
            auto it = g_passwordToggleCallbacks.find(widgetPtr);
            if (it != g_passwordToggleCallbacks.end()) {
                it->second();
            }
        });
        
        // ����������Ҳ��ڱ߾�
        int frameWidth = lineEdit->style()->pixelMetric(QStyle::PM_DefaultFrameWidth);
        lineEdit->setStyleSheet(
            QString("QLineEdit { padding-right: %1px; }").arg(20 + frameWidth + 1)
        );
        
        // ��λ��ť - ��ֱ���У�����΢��
        int editHeight = lineEdit->height();
        int yPos = (editHeight - 20) / 2 - 1;  // ����ƫ��1����
        int xPos = lineEdit->width() - 20 - frameWidth - 1;  // �����ұ߿�϶
        toggleBtn->move(xPos, yPos);
        toggleBtn->show();
        
        // �����ı��仯���¶�λ
        QObject::connect(lineEdit, &QLineEdit::textChanged, [lineEdit, toggleBtn]() {
            int frameWidth = lineEdit->style()->pixelMetric(QStyle::PM_DefaultFrameWidth);
            int editHeight = lineEdit->height();
            int yPos = (editHeight - 20) / 2 - 1;
            int xPos = lineEdit->width() - 20 - frameWidth - 1;
            toggleBtn->move(xPos, yPos);
        });
    }
}

// ���������л���ťͼ�꣨true=�ɼ���false=���أ�
void qLineEditSetPasswordToggleIcon(int64_t ptr, bool visible) {
    auto it = g_passwordToggleButtons.find(ptr);
    if (it != g_passwordToggleButtons.end()) {
        QToolButton* btn = it->second;
        if (btn) {
            if (visible) {
                // ����ɼ�ʱ��ʾ����Բ�㣨��ʾ�������أ�
                btn->setText(QString::fromUtf8("\u25CB"));  // �� ����Բ��
            } else {
                // ��������ʱ��ʾʵ��Բ�㣨��ʾ������ʾ��
                btn->setText(QString::fromUtf8("\u25CF"));  // �� ʵ��Բ��
            }
        }
    }
}

// �����������루��ʽ�����룩
// �����ַ���
// 0 - ���֣����
// 9 - ���֣���ѡ��
// # - ���ֻ������ţ���ѡ��
// D - �������֣����
// d - �������֣���ѡ��
// A - ��ĸ�����
// a - ��ĸ����ѡ��
// N - ��ĸ�����֣����
// n - ��ĸ�����֣���ѡ��
// H - ʮ�������ַ������
// h - ʮ�������ַ�����ѡ��
// X - �����ַ������
// x - �����ַ�����ѡ��
// > - ת��Ϊ��д
// < - ת��ΪСд
// ! - �رմ�Сдת��
// ;c - ����ռλ�ַ�Ϊ c
void qLineEditSetInputMask(int64_t ptr, const char* mask) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit && mask) {
        lineEdit->setInputMask(QString::fromUtf8(mask));
    }
}

// �����Ƿ���ʾ�߿�
void qLineEditSetFrame(int64_t ptr, bool enabled) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->setFrame(enabled);
    }
}

// �����ı����뷽ʽ
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

// ��ȡ�ı�����
int32_t qLineEditLength(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        return lineEdit->text().length();
    }
    return 0;
}

// ��ȡ��󳤶�
int32_t qLineEditMaxLength(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        return lineEdit->maxLength();
    }
    return 32767;
}

// �Ƿ���ѡ���ı�
bool qLineEditHasSelectedText(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        return lineEdit->hasSelectedText();
    }
    return false;
}

// ��ȡѡ�е��ı�
const char* qLineEditSelectedText(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (!lineEdit) return nullptr;
    QByteArray arr = lineEdit->selectedText().toUtf8();
    char* result = (char*)malloc(arr.size() + 1);
    if (result) memcpy(result, arr.constData(), arr.size() + 1);
    return result;
}

// ѡ�������ı�
void qLineEditSelectAll(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->selectAll();
    }
}

// ���ý���
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
// QTextEdit �ŽӺ���
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
    if (!textEdit) return nullptr;
    QByteArray arr = textEdit->toPlainText().toUtf8();
    char* result = (char*)malloc(arr.size() + 1);
    if (result) memcpy(result, arr.constData(), arr.size() + 1);
    return result;
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
// QTextEdit ��չ����
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

// ���ҹ���
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

// �滻����
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
    
    // �ƶ����ĵ���ͷ
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

// ���λ��
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
        return cursor.blockNumber() + 1;  // ����1-based�к�
    }
    return 1;
}

int qTextEditCurrentColumn(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        QTextCursor cursor = textEdit->textCursor();
        return cursor.columnNumber() + 1;  // ����1-based�к�
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

// ��ӡ����
void qTextEditPrint(int64_t ptr, int64_t printerPtr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    QPrinter* printer = reinterpret_cast<QPrinter*>(printerPtr);
    if (textEdit && printer) {
        textEdit->print(printer);
    }
}

// ��ת��ָ����
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

// ============================================================
// QPlainTextEdit �ŽӺ���
// ============================================================

int64_t qPlainTextEditCreate() {
    QPlainTextEdit* editor = new QPlainTextEdit();
    return reinterpret_cast<int64_t>(editor);
}

void qPlainTextEditSetPlainText(int64_t ptr, const char* text) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (editor) {
        editor->setPlainText(QString::fromUtf8(text));
    }
}

const char* qPlainTextEditToPlainText(int64_t ptr) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (!editor) return nullptr;
    QByteArray arr = editor->toPlainText().toUtf8();
    char* result = (char*)malloc(arr.size() + 1);
    if (result) memcpy(result, arr.constData(), arr.size() + 1);
    return result;
}

void qPlainTextEditSetReadOnly(int64_t ptr, bool readonly) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (editor) {
        editor->setReadOnly(readonly);
    }
}

bool qPlainTextEditIsReadOnly(int64_t ptr) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    return editor ? editor->isReadOnly() : false;
}

void qPlainTextEditClear(int64_t ptr) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (editor) {
        editor->clear();
    }
}

void qPlainTextEditCut(int64_t ptr) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (editor) editor->cut();
}

void qPlainTextEditCopy(int64_t ptr) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (editor) editor->copy();
}

void qPlainTextEditPaste(int64_t ptr) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (editor) editor->paste();
}

void qPlainTextEditSelectAll(int64_t ptr) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (editor) editor->selectAll();
}

void qPlainTextEditUndo(int64_t ptr) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (editor) editor->undo();
}

void qPlainTextEditRedo(int64_t ptr) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (editor) editor->redo();
}

bool qPlainTextEditCanUndo(int64_t ptr) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    return editor ? editor->document()->isUndoAvailable() : false;
}

bool qPlainTextEditCanRedo(int64_t ptr) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    return editor ? editor->document()->isRedoAvailable() : false;
}

bool qPlainTextEditIsModified(int64_t ptr) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    return editor ? editor->document()->isModified() : false;
}

void qPlainTextEditSetModified(int64_t ptr, bool modified) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (editor) editor->document()->setModified(modified);
}

void qPlainTextEditSetLineWrapMode(int64_t ptr, int32_t mode) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (editor) {
        editor->setLineWrapMode(static_cast<QPlainTextEdit::LineWrapMode>(mode));
    }
}

int32_t qPlainTextEditLineWrapMode(int64_t ptr) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    return editor ? static_cast<int32_t>(editor->lineWrapMode()) : 0;
}

void qPlainTextEditSetTabStopDistance(int64_t ptr, double distance) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (editor) {
        editor->setTabStopDistance(distance);
    }
}

int64_t qPlainTextEditLineCount(int64_t ptr) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    return editor ? editor->blockCount() : 0;
}

void qPlainTextEditAppendPlainText(int64_t ptr, const char* text) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (editor) {
        editor->appendPlainText(QString::fromUtf8(text));
    }
}

void qPlainTextEditSetMaximumBlockCount(int64_t ptr, int32_t maxBlocks) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (editor) {
        editor->setMaximumBlockCount(maxBlocks);
    }
}

void qPlainTextEditDelete(int64_t ptr) {
    QPlainTextEdit* editor = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (editor) {
        delete editor;
    }
}

// ============================================================
// QCompleter �ŽӺ���
// ============================================================

int64_t qCompleterCreate() {
    QCompleter* completer = new QCompleter();
    return reinterpret_cast<int64_t>(completer);
}

int64_t qCompleterCreateWithStrings(const char* items) {
    QStringList list = QString::fromUtf8(items).split('\n', Qt::SkipEmptyParts);
    QStringListModel* model = new QStringListModel(list);
    QCompleter* completer = new QCompleter(model);
    // completer ӵ�� model ������Ȩ
    return reinterpret_cast<int64_t>(completer);
}

void qCompleterSetModel(int64_t ptr, const char* items) {
    QCompleter* completer = reinterpret_cast<QCompleter*>(ptr);
    if (completer) {
        QStringList list = QString::fromUtf8(items).split('\n', Qt::SkipEmptyParts);
        QStringListModel* model = new QStringListModel(list, completer);
        completer->setModel(model);
    }
}

void qCompleterSetCaseSensitivity(int64_t ptr, bool caseSensitive) {
    QCompleter* completer = reinterpret_cast<QCompleter*>(ptr);
    if (completer) {
        completer->setCaseSensitivity(caseSensitive ? Qt::CaseSensitive : Qt::CaseInsensitive);
    }
}

void qCompleterSetFilterMode(int64_t ptr, int32_t mode) {
    QCompleter* completer = reinterpret_cast<QCompleter*>(ptr);
    if (completer) {
        completer->setFilterMode(static_cast<Qt::MatchFlag>(mode));
    }
}

void qCompleterSetCompletionMode(int64_t ptr, int32_t mode) {
    QCompleter* completer = reinterpret_cast<QCompleter*>(ptr);
    if (completer) {
        completer->setCompletionMode(static_cast<QCompleter::CompletionMode>(mode));
    }
}

void qCompleterSetMaxVisibleItems(int64_t ptr, int32_t maxItems) {
    QCompleter* completer = reinterpret_cast<QCompleter*>(ptr);
    if (completer) {
        completer->setMaxVisibleItems(maxItems);
    }
}

int32_t qCompleterMaxVisibleItems(int64_t ptr) {
    QCompleter* completer = reinterpret_cast<QCompleter*>(ptr);
    return completer ? completer->maxVisibleItems() : 7;
}

void qCompleterSetCompletionPrefix(int64_t ptr, const char* prefix) {
    QCompleter* completer = reinterpret_cast<QCompleter*>(ptr);
    if (completer) {
        completer->setCompletionPrefix(QString::fromUtf8(prefix));
    }
}

const char* qCompleterCompletionPrefix(int64_t ptr) {
    QCompleter* completer = reinterpret_cast<QCompleter*>(ptr);
    if (!completer) return nullptr;
    QByteArray arr = completer->completionPrefix().toUtf8();
    char* result = (char*)malloc(arr.size() + 1);
    if (result) memcpy(result, arr.constData(), arr.size() + 1);
    return result;
}

int32_t qCompleterCompletionCount(int64_t ptr) {
    QCompleter* completer = reinterpret_cast<QCompleter*>(ptr);
    return completer ? completer->completionCount() : 0;
}

void qCompleterComplete(int64_t ptr) {
    QCompleter* completer = reinterpret_cast<QCompleter*>(ptr);
    if (completer) {
        completer->complete();
    }
}

void qCompleterDelete(int64_t ptr) {
    QCompleter* completer = reinterpret_cast<QCompleter*>(ptr);
    if (completer) {
        delete completer;
    }
}

// ============================================================
// QTextBrowser �ŽӺ���
// ============================================================

int64_t qTextBrowserCreate() {
    QTextBrowser* browser = new QTextBrowser();
    return reinterpret_cast<int64_t>(browser);
}

void qTextBrowserSetText(int64_t ptr, const char* text) {
    QTextBrowser* browser = reinterpret_cast<QTextBrowser*>(ptr);
    if (browser) {
        browser->setText(QString::fromUtf8(text));
    }
}

const char* qTextBrowserToPlainText(int64_t ptr) {
    QTextBrowser* browser = reinterpret_cast<QTextBrowser*>(ptr);
    if (!browser) return nullptr;
    QByteArray arr = browser->toPlainText().toUtf8();
    char* result = (char*)malloc(arr.size() + 1);
    if (result) memcpy(result, arr.constData(), arr.size() + 1);
    return result;
}

void qTextBrowserSetHtml(int64_t ptr, const char* html) {
    QTextBrowser* browser = reinterpret_cast<QTextBrowser*>(ptr);
    if (browser) {
        browser->setHtml(QString::fromUtf8(html));
    }
}

const char* qTextBrowserToHtml(int64_t ptr) {
    QTextBrowser* browser = reinterpret_cast<QTextBrowser*>(ptr);
    if (!browser) return nullptr;
    QByteArray arr = browser->toHtml().toUtf8();
    char* result = (char*)malloc(arr.size() + 1);
    if (result) memcpy(result, arr.constData(), arr.size() + 1);
    return result;
}

void qTextBrowserSetSource(int64_t ptr, const char* url) {
    QTextBrowser* browser = reinterpret_cast<QTextBrowser*>(ptr);
    if (browser) {
        browser->setSource(QUrl(QString::fromUtf8(url)));
    }
}

void qTextBrowserBackward(int64_t ptr) {
    QTextBrowser* browser = reinterpret_cast<QTextBrowser*>(ptr);
    if (browser) browser->backward();
}

void qTextBrowserForward(int64_t ptr) {
    QTextBrowser* browser = reinterpret_cast<QTextBrowser*>(ptr);
    if (browser) browser->forward();
}

void qTextBrowserHome(int64_t ptr) {
    QTextBrowser* browser = reinterpret_cast<QTextBrowser*>(ptr);
    if (browser) browser->home();
}

void qTextBrowserReload(int64_t ptr) {
    QTextBrowser* browser = reinterpret_cast<QTextBrowser*>(ptr);
    if (browser) browser->reload();
}

void qTextBrowserSetOpenLinks(int64_t ptr, bool open) {
    QTextBrowser* browser = reinterpret_cast<QTextBrowser*>(ptr);
    if (browser) browser->setOpenLinks(open);
}

void qTextBrowserSetOpenExternalLinks(int64_t ptr, bool open) {
    QTextBrowser* browser = reinterpret_cast<QTextBrowser*>(ptr);
    if (browser) browser->setOpenExternalLinks(open);
}

void qTextBrowserClear(int64_t ptr) {
    QTextBrowser* browser = reinterpret_cast<QTextBrowser*>(ptr);
    if (browser) browser->clear();
}

void qTextBrowserSetPlainText(int64_t ptr, const char* text) {
    QTextBrowser* browser = reinterpret_cast<QTextBrowser*>(ptr);
    if (browser) {
        browser->setPlainText(QString::fromUtf8(text));
    }
}

void qTextBrowserDelete(int64_t ptr) {
    QTextBrowser* browser = reinterpret_cast<QTextBrowser*>(ptr);
    if (browser) {
        delete browser;
    }
}

// ============================================================
// QKeySequenceEdit �ŽӺ���
// ============================================================

int64_t qKeySequenceEditCreate(int64_t parentPtr) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QKeySequenceEdit* edit = new QKeySequenceEdit(parent);
    return reinterpret_cast<int64_t>(edit);
}

const char* qKeySequenceEditKeySequence(int64_t ptr) {
    QKeySequenceEdit* edit = reinterpret_cast<QKeySequenceEdit*>(ptr);
    if (!edit) return nullptr;
    QByteArray arr = edit->keySequence().toString(QKeySequence::NativeText).toUtf8();
    char* result = (char*)malloc(arr.size() + 1);
    if (result) memcpy(result, arr.constData(), arr.size() + 1);
    return result;
}

void qKeySequenceEditSetKeySequence(int64_t ptr, const char* text) {
    QKeySequenceEdit* edit = reinterpret_cast<QKeySequenceEdit*>(ptr);
    if (edit) {
        edit->setKeySequence(QKeySequence(QString::fromUtf8(text)));
    }
}

void qKeySequenceEditClear(int64_t ptr) {
    QKeySequenceEdit* edit = reinterpret_cast<QKeySequenceEdit*>(ptr);
    if (edit) edit->clear();
}

void qKeySequenceEditDelete(int64_t ptr) {
    QKeySequenceEdit* edit = reinterpret_cast<QKeySequenceEdit*>(ptr);
    if (edit) {
        delete edit;
    }
}

// ============================================================
// QSystemTrayIcon �ŽӺ���
// ============================================================

int64_t qSystemTrayIconCreate(int64_t parentPtr) {
    QObject* parent = reinterpret_cast<QObject*>(parentPtr);
    QSystemTrayIcon* icon = new QSystemTrayIcon(parent);
    return reinterpret_cast<int64_t>(icon);
}

void qSystemTrayIconDelete(int64_t ptr) {
    QSystemTrayIcon* icon = reinterpret_cast<QSystemTrayIcon*>(ptr);
    if (icon) {
        delete icon;
    }
}

void qSystemTrayIconSetIcon(int64_t ptr, const char* iconPath) {
    QSystemTrayIcon* icon = reinterpret_cast<QSystemTrayIcon*>(ptr);
    if (icon && iconPath) {
        icon->setIcon(QIcon(QString::fromUtf8(iconPath)));
    }
}

void qSystemTrayIconSetToolTip(int64_t ptr, const char* tip) {
    QSystemTrayIcon* icon = reinterpret_cast<QSystemTrayIcon*>(ptr);
    if (icon) {
        icon->setToolTip(QString::fromUtf8(tip));
    }
}

void qSystemTrayIconShow(int64_t ptr) {
    QSystemTrayIcon* icon = reinterpret_cast<QSystemTrayIcon*>(ptr);
    if (icon) icon->show();
}

void qSystemTrayIconHide(int64_t ptr) {
    QSystemTrayIcon* icon = reinterpret_cast<QSystemTrayIcon*>(ptr);
    if (icon) icon->hide();
}

bool qSystemTrayIconIsVisible(int64_t ptr) {
    QSystemTrayIcon* icon = reinterpret_cast<QSystemTrayIcon*>(ptr);
    return icon ? icon->isVisible() : false;
}

void qSystemTrayIconShowMessage(int64_t ptr, const char* title, const char* message, int32_t iconType, int32_t duration) {
    QSystemTrayIcon* icon = reinterpret_cast<QSystemTrayIcon*>(ptr);
    if (icon) {
        icon->showMessage(
            QString::fromUtf8(title),
            QString::fromUtf8(message),
            static_cast<QSystemTrayIcon::MessageIcon>(iconType),
            duration
        );
    }
}

void qSystemTrayIconSetContextMenu(int64_t ptr, int64_t menuPtr) {
    QSystemTrayIcon* icon = reinterpret_cast<QSystemTrayIcon*>(ptr);
    QMenu* menu = reinterpret_cast<QMenu*>(menuPtr);
    if (icon && menu) {
        icon->setContextMenu(menu);
    }
}

// ============================================================
// QGraphicsView �ŽӺ���
// ============================================================

int64_t qGraphicsViewCreate(int64_t parentPtr) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QGraphicsView* view = new QGraphicsView(parent);
    return reinterpret_cast<int64_t>(view);
}

void qGraphicsViewDelete(int64_t ptr) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    if (view) delete view;
}

void qGraphicsViewSetScene(int64_t ptr, int64_t scenePtr) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(scenePtr);
    if (view) view->setScene(scene);
}

int64_t qGraphicsViewScene(int64_t ptr) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    return view ? reinterpret_cast<int64_t>(view->scene()) : 0;
}

void qGraphicsViewSetRenderHint(int64_t ptr, int32_t hint, bool enabled) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    if (view) view->setRenderHint(static_cast<QPainter::RenderHint>(hint), enabled);
}

void qGraphicsViewSetDragMode(int64_t ptr, int32_t mode) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    if (view) view->setDragMode(static_cast<QGraphicsView::DragMode>(mode));
}

int32_t qGraphicsViewDragMode(int64_t ptr) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    return view ? static_cast<int32_t>(view->dragMode()) : 0;
}

void qGraphicsViewCenterOn(int64_t ptr, double x, double y) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    if (view) view->centerOn(x, y);
}

void qGraphicsViewFitInView(int64_t ptr, double x, double y, double w, double h) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    if (view) view->fitInView(x, y, w, h, Qt::KeepAspectRatio);
}

void qGraphicsViewScale(int64_t ptr, double fx, double fy) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    if (view) view->scale(fx, fy);
}

void qGraphicsViewRotate(int64_t ptr, double angle) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    if (view) view->rotate(angle);
}

void qGraphicsViewTranslate(int64_t ptr, double dx, double dy) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    if (view) view->translate(dx, dy);
}

void qGraphicsViewResetTransform(int64_t ptr) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    if (view) view->resetTransform();
}

void qGraphicsViewSetInteractive(int64_t ptr, bool interactive) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    if (view) view->setInteractive(interactive);
}

bool qGraphicsViewIsInteractive(int64_t ptr) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    return view ? view->isInteractive() : false;
}

void qGraphicsViewSetSceneRect(int64_t ptr, double x, double y, double w, double h) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    if (view) view->setSceneRect(x, y, w, h);
}

void qGraphicsViewSetBackgroundBrush(int64_t ptr, int32_t r, int32_t g, int32_t b) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    if (view) view->setBackgroundBrush(QBrush(QColor(r, g, b)));
}

void qGraphicsViewSetForegroundBrush(int64_t ptr, int32_t r, int32_t g, int32_t b) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    if (view) view->setForegroundBrush(QBrush(QColor(r, g, b)));
}

const char* qGraphicsViewMapToScene(int64_t ptr, double x, double y) {
    QGraphicsView* view = reinterpret_cast<QGraphicsView*>(ptr);
    if (!view) return "0,0";
    QPointF pt = view->mapToScene(static_cast<int>(x), static_cast<int>(y));
    static thread_local std::string buf;
    buf = QString("%1,%2").arg(pt.x(), 0, 'f', 4).arg(pt.y(), 0, 'f', 4).toStdString();
    return buf.c_str();
}

// ============================================================
// QGraphicsScene �ŽӺ���
// ============================================================

int64_t qGraphicsSceneCreate() {
    QGraphicsScene* scene = new QGraphicsScene();
    return reinterpret_cast<int64_t>(scene);
}

void qGraphicsSceneDelete(int64_t ptr) {
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(ptr);
    if (scene) delete scene;
}

void qGraphicsSceneAddItem(int64_t ptr, int64_t itemPtr) {
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(ptr);
    QGraphicsItem* item = reinterpret_cast<QGraphicsItem*>(itemPtr);
    if (scene && item) scene->addItem(item);
}

void qGraphicsSceneRemoveItem(int64_t ptr, int64_t itemPtr) {
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(ptr);
    QGraphicsItem* item = reinterpret_cast<QGraphicsItem*>(itemPtr);
    if (scene && item) scene->removeItem(item);
}

void qGraphicsSceneClear(int64_t ptr) {
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(ptr);
    if (scene) scene->clear();
}

const char* qGraphicsSceneItems(int64_t ptr) {
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(ptr);
    if (!scene) return "";
    QList<QGraphicsItem*> items = scene->items();
    static thread_local std::string buf;
    buf.clear();
    for (int i = 0; i < items.size(); ++i) {
        if (i > 0) buf += ",";
        buf += std::to_string(reinterpret_cast<int64_t>(items[i]));
    }
    return buf.c_str();
}

int64_t qGraphicsSceneItemAt(int64_t ptr, double x, double y) {
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(ptr);
    if (!scene) return 0;
    QGraphicsItem* item = scene->itemAt(QPointF(x, y), QTransform());
    return reinterpret_cast<int64_t>(item);
}

int64_t qGraphicsSceneAddRect(int64_t ptr, double x, double y, double w, double h,
                               int32_t penR, int32_t penG, int32_t penB, double penW,
                               int32_t brushR, int32_t brushG, int32_t brushB) {
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(ptr);
    if (!scene) return 0;
    QPen pen(QColor(penR, penG, penB), penW);
    QBrush brush(QColor(brushR, brushG, brushB));
    QGraphicsRectItem* item = scene->addRect(x, y, w, h, pen, brush);
    return reinterpret_cast<int64_t>(item);
}

int64_t qGraphicsSceneAddEllipse(int64_t ptr, double x, double y, double w, double h,
                                  int32_t penR, int32_t penG, int32_t penB, double penW,
                                  int32_t brushR, int32_t brushG, int32_t brushB) {
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(ptr);
    if (!scene) return 0;
    QPen pen(QColor(penR, penG, penB), penW);
    QBrush brush(QColor(brushR, brushG, brushB));
    QGraphicsEllipseItem* item = scene->addEllipse(x, y, w, h, pen, brush);
    return reinterpret_cast<int64_t>(item);
}

int64_t qGraphicsSceneAddLine(int64_t ptr, double x1, double y1, double x2, double y2,
                               int32_t penR, int32_t penG, int32_t penB, double penW) {
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(ptr);
    if (!scene) return 0;
    QPen pen(QColor(penR, penG, penB), penW);
    QGraphicsLineItem* item = scene->addLine(x1, y1, x2, y2, pen);
    return reinterpret_cast<int64_t>(item);
}

int64_t qGraphicsSceneAddText(int64_t ptr, const char* text) {
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(ptr);
    if (!scene || !text) return 0;
    QGraphicsTextItem* item = scene->addText(QString::fromUtf8(text));
    return reinterpret_cast<int64_t>(item);
}

void qGraphicsSceneSetSceneRect(int64_t ptr, double x, double y, double w, double h) {
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(ptr);
    if (scene) scene->setSceneRect(x, y, w, h);
}

const char* qGraphicsSceneSceneRect(int64_t ptr) {
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(ptr);
    if (!scene) return "0,0,0,0";
    QRectF r = scene->sceneRect();
    static thread_local std::string buf;
    buf = QString("%1,%2,%3,%4").arg(r.x(), 0, 'f', 4).arg(r.y(), 0, 'f', 4)
                                .arg(r.width(), 0, 'f', 4).arg(r.height(), 0, 'f', 4).toStdString();
    return buf.c_str();
}

void qGraphicsSceneUpdate(int64_t ptr) {
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(ptr);
    if (scene) scene->update();
}

void qGraphicsSceneSetBackgroundBrush(int64_t ptr, int32_t r, int32_t g, int32_t b) {
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(ptr);
    if (scene) scene->setBackgroundBrush(QBrush(QColor(r, g, b)));
}

int64_t qGraphicsSceneAddWidget(int64_t ptr, int64_t widgetPtr) {
    QGraphicsScene* scene = reinterpret_cast<QGraphicsScene*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (scene && widget) {
        QGraphicsProxyWidget* proxy = scene->addWidget(widget);
        return reinterpret_cast<int64_t>(proxy);
    }
    return 0;
}

// ============================================================
// QGraphicsItem �ŽӺ��� (��С��)
// ============================================================

void qGraphicsItemSetPos(int64_t ptr, double x, double y) {
    QGraphicsItem* item = reinterpret_cast<QGraphicsItem*>(ptr);
    if (item) item->setPos(x, y);
}

const char* qGraphicsItemPos(int64_t ptr) {
    QGraphicsItem* item = reinterpret_cast<QGraphicsItem*>(ptr);
    if (!item) return "0,0";
    QPointF p = item->pos();
    static thread_local std::string buf;
    buf = QString("%1,%2").arg(p.x(), 0, 'f', 4).arg(p.y(), 0, 'f', 4).toStdString();
    return buf.c_str();
}

void qGraphicsItemSetZValue(int64_t ptr, double z) {
    QGraphicsItem* item = reinterpret_cast<QGraphicsItem*>(ptr);
    if (item) item->setZValue(z);
}

void qGraphicsItemSetRotation(int64_t ptr, double angle) {
    QGraphicsItem* item = reinterpret_cast<QGraphicsItem*>(ptr);
    if (item) item->setRotation(angle);
}

void qGraphicsItemSetVisible(int64_t ptr, bool visible) {
    QGraphicsItem* item = reinterpret_cast<QGraphicsItem*>(ptr);
    if (item) item->setVisible(visible);
}

bool qGraphicsItemIsVisible(int64_t ptr) {
    QGraphicsItem* item = reinterpret_cast<QGraphicsItem*>(ptr);
    return item ? item->isVisible() : false;
}

void qGraphicsItemSetSelected(int64_t ptr, bool selected) {
    QGraphicsItem* item = reinterpret_cast<QGraphicsItem*>(ptr);
    if (item) item->setSelected(selected);
}

bool qGraphicsItemIsSelected(int64_t ptr) {
    QGraphicsItem* item = reinterpret_cast<QGraphicsItem*>(ptr);
    return item ? item->isSelected() : false;
}

void qGraphicsItemUpdate(int64_t ptr) {
    QGraphicsItem* item = reinterpret_cast<QGraphicsItem*>(ptr);
    if (item) item->update();
}

// ============================================================
// QGraphicsOpacityEffect �ŽӺ���
// ============================================================

int64_t qGraphicsOpacityEffectCreate() {
    QGraphicsOpacityEffect* effect = new QGraphicsOpacityEffect();
    return reinterpret_cast<int64_t>(effect);
}

void qGraphicsOpacityEffectSetOpacity(int64_t ptr, double opacity) {
    QGraphicsOpacityEffect* effect = reinterpret_cast<QGraphicsOpacityEffect*>(ptr);
    if (effect) effect->setOpacity(opacity);
}

double qGraphicsOpacityEffectOpacity(int64_t ptr) {
    QGraphicsOpacityEffect* effect = reinterpret_cast<QGraphicsOpacityEffect*>(ptr);
    return effect ? effect->opacity() : 1.0;
}

void qGraphicsOpacityEffectSetEnabled(int64_t ptr, bool enabled) {
    QGraphicsOpacityEffect* effect = reinterpret_cast<QGraphicsOpacityEffect*>(ptr);
    if (effect) effect->setEnabled(enabled);
}

void qGraphicsOpacityEffectDelete(int64_t ptr) {
    QGraphicsOpacityEffect* effect = reinterpret_cast<QGraphicsOpacityEffect*>(ptr);
    if (effect) delete effect;
}

// ============================================================
// QGraphicsDropShadowEffect �ŽӺ���
// ============================================================

int64_t qGraphicsDropShadowEffectCreate() {
    QGraphicsDropShadowEffect* effect = new QGraphicsDropShadowEffect();
    return reinterpret_cast<int64_t>(effect);
}

void qGraphicsDropShadowEffectSetOffset(int64_t ptr, double dx, double dy) {
    QGraphicsDropShadowEffect* effect = reinterpret_cast<QGraphicsDropShadowEffect*>(ptr);
    if (effect) effect->setOffset(dx, dy);
}

void qGraphicsDropShadowEffectSetBlurRadius(int64_t ptr, double radius) {
    QGraphicsDropShadowEffect* effect = reinterpret_cast<QGraphicsDropShadowEffect*>(ptr);
    if (effect) effect->setBlurRadius(radius);
}

double qGraphicsDropShadowEffectBlurRadius(int64_t ptr) {
    QGraphicsDropShadowEffect* effect = reinterpret_cast<QGraphicsDropShadowEffect*>(ptr);
    return effect ? effect->blurRadius() : 0.0;
}

void qGraphicsDropShadowEffectSetColor(int64_t ptr, int32_t r, int32_t g, int32_t b, int32_t a) {
    QGraphicsDropShadowEffect* effect = reinterpret_cast<QGraphicsDropShadowEffect*>(ptr);
    if (effect) effect->setColor(QColor(r, g, b, a));
}

void qGraphicsDropShadowEffectSetEnabled(int64_t ptr, bool enabled) {
    QGraphicsDropShadowEffect* effect = reinterpret_cast<QGraphicsDropShadowEffect*>(ptr);
    if (effect) effect->setEnabled(enabled);
}

void qGraphicsDropShadowEffectDelete(int64_t ptr) {
    QGraphicsDropShadowEffect* effect = reinterpret_cast<QGraphicsDropShadowEffect*>(ptr);
    if (effect) delete effect;
}

// ============================================================
// QFontComboBox �ŽӺ���
// ============================================================

int64_t qFontComboBoxCreate() {
    QFontComboBox* combo = new QFontComboBox();
    return reinterpret_cast<int64_t>(combo);
}

int64_t qFontComboBoxCreateWithParent(int64_t parentPtr) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QFontComboBox* combo = new QFontComboBox(parent);
    return reinterpret_cast<int64_t>(combo);
}

void qFontComboBoxSetCurrentFont(int64_t ptr, const char* family) {
    QFontComboBox* combo = reinterpret_cast<QFontComboBox*>(ptr);
    if (combo) {
        combo->setCurrentFont(QFont(QString::fromUtf8(family)));
    }
}

const char* qFontComboBoxCurrentFont(int64_t ptr) {
    QFontComboBox* combo = reinterpret_cast<QFontComboBox*>(ptr);
    if (!combo) return "";
    static QByteArray arr;
    arr = combo->currentFont().family().toUtf8();
    return arr.constData();
}

void qFontComboBoxSetWritingSystem(int64_t ptr, int32_t ws) {
    QFontComboBox* combo = reinterpret_cast<QFontComboBox*>(ptr);
    if (combo) {
        combo->setWritingSystem(static_cast<QFontDatabase::WritingSystem>(ws));
    }
}

void qFontComboBoxSetFontFilters(int64_t ptr, int32_t filters) {
    QFontComboBox* combo = reinterpret_cast<QFontComboBox*>(ptr);
    if (combo) {
        combo->setFontFilters(static_cast<QFontComboBox::FontFilter>(filters));
    }
}

void qFontComboBoxDelete(int64_t ptr) {
    QFontComboBox* combo = reinterpret_cast<QFontComboBox*>(ptr);
    if (combo) delete combo;
}



// ============================================================
// QDialogButtonBox 桥接函数
// ============================================================

int64_t qDialogButtonBoxCreate() {
    QDialogButtonBox* box = new QDialogButtonBox();
    return reinterpret_cast<int64_t>(box);
}

void qDialogButtonBoxAddButton(int64_t ptr, const char* text, int32_t role) {
    QDialogButtonBox* box = reinterpret_cast<QDialogButtonBox*>(ptr);
    if (box && text) {
        box->addButton(QString::fromUtf8(text), static_cast<QDialogButtonBox::ButtonRole>(role));
    }
}

void qDialogButtonBoxSetStandardButtons(int64_t ptr, int32_t buttons) {
    QDialogButtonBox* box = reinterpret_cast<QDialogButtonBox*>(ptr);
    if (box) {
        box->setStandardButtons(static_cast<QDialogButtonBox::StandardButtons>(buttons));
    }
}

// QDialogButtonBox 回调映射
static std::unordered_map<int64_t, std::function<void()>> g_dialogBtnAcceptedCallbacks;
static std::unordered_map<int64_t, std::function<void()>> g_dialogBtnRejectedCallbacks;

void qDialogButtonBoxConnectAccepted(int64_t ptr, void (*callback)(void)) {
    QDialogButtonBox* box = reinterpret_cast<QDialogButtonBox*>(ptr);
    if (box && callback) {
        int64_t widgetPtr = ptr;
        g_dialogBtnAcceptedCallbacks[ptr] = [callback, widgetPtr]() { callback(); };
        QObject::connect(box, &QDialogButtonBox::accepted, [widgetPtr]() {
            auto it = g_dialogBtnAcceptedCallbacks.find(widgetPtr);
            if (it != g_dialogBtnAcceptedCallbacks.end()) {
                it->second();
            }
        });
    }
}

void qDialogButtonBoxConnectRejected(int64_t ptr, void (*callback)(void)) {
    QDialogButtonBox* box = reinterpret_cast<QDialogButtonBox*>(ptr);
    if (box && callback) {
        int64_t widgetPtr = ptr;
        g_dialogBtnRejectedCallbacks[ptr] = [callback, widgetPtr]() { callback(); };
        QObject::connect(box, &QDialogButtonBox::rejected, [widgetPtr]() {
            auto it = g_dialogBtnRejectedCallbacks.find(widgetPtr);
            if (it != g_dialogBtnRejectedCallbacks.end()) {
                it->second();
            }
        });
    }
}

void qDialogButtonBoxDelete(int64_t ptr) {
    QDialogButtonBox* box = reinterpret_cast<QDialogButtonBox*>(ptr);
    if (box) {
        g_dialogBtnAcceptedCallbacks.erase(ptr);
        g_dialogBtnRejectedCallbacks.erase(ptr);
        delete box;
    }
}

// ============================================================
// QCommandLinkButton 桥接函数
// ============================================================

int64_t qCommandLinkButtonCreate() {
    QCommandLinkButton* btn = new QCommandLinkButton();
    return reinterpret_cast<int64_t>(btn);
}

int64_t qCommandLinkButtonCreateWithParent(int64_t parentPtr) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QCommandLinkButton* btn = new QCommandLinkButton(parent);
    return reinterpret_cast<int64_t>(btn);
}

void qCommandLinkButtonSetText(int64_t ptr, const char* text) {
    QCommandLinkButton* btn = reinterpret_cast<QCommandLinkButton*>(ptr);
    if (btn && text) {
        btn->setText(QString::fromUtf8(text));
    }
}

void qCommandLinkButtonSetDescription(int64_t ptr, const char* description) {
    QCommandLinkButton* btn = reinterpret_cast<QCommandLinkButton*>(ptr);
    if (btn && description) {
        btn->setDescription(QString::fromUtf8(description));
    }
}

void qCommandLinkButtonDelete(int64_t ptr) {
    QCommandLinkButton* btn = reinterpret_cast<QCommandLinkButton*>(ptr);
    if (btn) delete btn;
}

// ============================================================
// QScrollBar 桥接函数
// ============================================================

int64_t qScrollBarCreate(int32_t orientation) {
    QScrollBar* bar = new QScrollBar(static_cast<Qt::Orientation>(orientation));
    return reinterpret_cast<int64_t>(bar);
}

void qScrollBarSetRange(int64_t ptr, int32_t min, int32_t max) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar) bar->setRange(min, max);
}

void qScrollBarSetValue(int64_t ptr, int32_t value) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar) bar->setValue(value);
}

int32_t qScrollBarValue(int64_t ptr) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    return bar ? bar->value() : 0;
}

void qScrollBarSetSingleStep(int64_t ptr, int32_t step) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar) bar->setSingleStep(step);
}

void qScrollBarSetPageStep(int64_t ptr, int32_t step) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar) bar->setPageStep(step);
}

void qScrollBarSetOrientation(int64_t ptr, int32_t orientation) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar) bar->setOrientation(static_cast<Qt::Orientation>(orientation));
}

// QScrollBar 回调映射
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_scrollBarCallbacks;

void qScrollBarConnectValueChanged(int64_t ptr, void (*callback)(int32_t)) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar && callback) {
        int64_t widgetPtr = ptr;
        g_scrollBarCallbacks[ptr] = [callback, widgetPtr](int32_t v) { callback(v); };
        QObject::connect(bar, &QScrollBar::valueChanged, [widgetPtr](int v) {
            auto it = g_scrollBarCallbacks.find(widgetPtr);
            if (it != g_scrollBarCallbacks.end()) {
                it->second(static_cast<int32_t>(v));
            }
        });
    }
}

void qScrollBarDelete(int64_t ptr) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar) {
        g_scrollBarCallbacks.erase(ptr);
        delete bar;
    }
}

// ============================================================
// QValidator 桥接函数 (QIntValidator, QDoubleValidator)
// ============================================================

int64_t qIntValidatorCreate(int32_t min, int32_t max) {
    QIntValidator* validator = new QIntValidator(min, max);
    return reinterpret_cast<int64_t>(validator);
}

void qIntValidatorSetRange(int64_t ptr, int32_t min, int32_t max) {
    QIntValidator* v = reinterpret_cast<QIntValidator*>(ptr);
    if (v) v->setRange(min, max);
}

int64_t qDoubleValidatorCreate(double min, double max, int32_t decimals) {
    QDoubleValidator* validator = new QDoubleValidator(min, max, decimals);
    return reinterpret_cast<int64_t>(validator);
}

void qDoubleValidatorSetRange(int64_t ptr, double min, double max, int32_t decimals) {
    QDoubleValidator* v = reinterpret_cast<QDoubleValidator*>(ptr);
    if (v) v->setRange(min, max, decimals);
}

void qLineEditSetValidator(int64_t lineEditPtr, int64_t validatorPtr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(lineEditPtr);
    QValidator* validator = reinterpret_cast<QValidator*>(validatorPtr);
    if (lineEdit && validator) {
        lineEdit->setValidator(validator);
    }
}

void qValidatorDelete(int64_t ptr) {
    QValidator* v = reinterpret_cast<QValidator*>(ptr);
    if (v) delete v;
}



// ============================================================
// QSplashScreen �ŽӺ���
// ============================================================

int64_t qSplashScreenCreate() {
    QSplashScreen* splash = new QSplashScreen();
    return reinterpret_cast<int64_t>(splash);
}

int64_t qSplashScreenCreateWithPixmap(int64_t pixmapPtr) {
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(pixmapPtr);
    if (!pixmap) return 0;
    QSplashScreen* splash = new QSplashScreen(*pixmap);
    return reinterpret_cast<int64_t>(splash);
}

void qSplashScreenShow(int64_t ptr) {
    QSplashScreen* splash = reinterpret_cast<QSplashScreen*>(ptr);
    if (splash) splash->show();
}

void qSplashScreenFinish(int64_t ptr, int64_t windowPtr) {
    QSplashScreen* splash = reinterpret_cast<QSplashScreen*>(ptr);
    QWidget* window = reinterpret_cast<QWidget*>(windowPtr);
    if (splash && window) splash->finish(window);
}

void qSplashScreenShowMessage(int64_t ptr, const char* message) {
    QSplashScreen* splash = reinterpret_cast<QSplashScreen*>(ptr);
    if (splash && message) {
        splash->showMessage(QString::fromUtf8(message), Qt::AlignBottom | Qt::AlignHCenter, Qt::white);
    }
}

void qSplashScreenSetPixmap(int64_t ptr, int64_t pixmapPtr) {
    QSplashScreen* splash = reinterpret_cast<QSplashScreen*>(ptr);
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(pixmapPtr);
    if (splash && pixmap) splash->setPixmap(*pixmap);
}

void qSplashScreenDelete(int64_t ptr) {
    QSplashScreen* splash = reinterpret_cast<QSplashScreen*>(ptr);
    if (splash) delete splash;
}

// ============================================================
// QSizeGrip �ŽӺ���
// ============================================================

int64_t qSizeGripCreate(int64_t parentPtr) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QSizeGrip* grip = new QSizeGrip(parent);
    return reinterpret_cast<int64_t>(grip);
}

void qSizeGripSetVisible(int64_t ptr, bool visible) {
    QSizeGrip* grip = reinterpret_cast<QSizeGrip*>(ptr);
    if (grip) grip->setVisible(visible);
}

void qSizeGripDelete(int64_t ptr) {
    QSizeGrip* grip = reinterpret_cast<QSizeGrip*>(ptr);
    if (grip) delete grip;
}

// ============================================================
// QRubberBand �ŽӺ���
// ============================================================

int64_t qRubberBandCreate(int32_t shape, int64_t parentPtr) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QRubberBand* band = new QRubberBand(static_cast<QRubberBand::Shape>(shape), parent);
    return reinterpret_cast<int64_t>(band);
}

void qRubberBandSetGeometry(int64_t ptr, int32_t x, int32_t y, int32_t w, int32_t h) {
    QRubberBand* band = reinterpret_cast<QRubberBand*>(ptr);
    if (band) band->setGeometry(x, y, w, h);
}

void qRubberBandMove(int64_t ptr, int32_t x, int32_t y) {
    QRubberBand* band = reinterpret_cast<QRubberBand*>(ptr);
    if (band) band->move(x, y);
}

void qRubberBandResize(int64_t ptr, int32_t w, int32_t h) {
    QRubberBand* band = reinterpret_cast<QRubberBand*>(ptr);
    if (band) band->resize(w, h);
}

void qRubberBandShow(int64_t ptr) {
    QRubberBand* band = reinterpret_cast<QRubberBand*>(ptr);
    if (band) band->show();
}

void qRubberBandHide(int64_t ptr) {
    QRubberBand* band = reinterpret_cast<QRubberBand*>(ptr);
    if (band) band->hide();
}

int64_t qRubberBandGeometryX(int64_t ptr) {
    QRubberBand* band = reinterpret_cast<QRubberBand*>(ptr);
    return band ? static_cast<int64_t>(band->geometry().x()) : 0;
}

int64_t qRubberBandGeometryY(int64_t ptr) {
    QRubberBand* band = reinterpret_cast<QRubberBand*>(ptr);
    return band ? static_cast<int64_t>(band->geometry().y()) : 0;
}

int64_t qRubberBandGeometryWidth(int64_t ptr) {
    QRubberBand* band = reinterpret_cast<QRubberBand*>(ptr);
    return band ? static_cast<int64_t>(band->geometry().width()) : 0;
}

int64_t qRubberBandGeometryHeight(int64_t ptr) {
    QRubberBand* band = reinterpret_cast<QRubberBand*>(ptr);
    return band ? static_cast<int64_t>(band->geometry().height()) : 0;
}

void qRubberBandDelete(int64_t ptr) {
    QRubberBand* band = reinterpret_cast<QRubberBand*>(ptr);
    if (band) delete band;
}


} // extern "C"