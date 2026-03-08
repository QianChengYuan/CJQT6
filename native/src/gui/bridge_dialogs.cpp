/**
 * @file bridge_dialogs.cpp
 * @brief 对话框桥接函数 - QMessageBox, QFileDialog, QInputDialog, QColorDialog
 */

#include <QMessageBox>
#include <QFileDialog>
#include <QInputDialog>
#include <QColorDialog>
#include <QColor>
#include <limits>
#include <cstring>

// 静态存储用于返回字符串（使用char数组避免悬空指针）
static char g_stringBuffer[4096];

// 安全复制QString到静态缓冲区
static const char* safeCopyString(const QString& str) {
    QByteArray utf8 = str.toUtf8();
    int len = utf8.size();
    if (len >= (int)sizeof(g_stringBuffer)) {
        len = sizeof(g_stringBuffer) - 1;
    }
    std::memcpy(g_stringBuffer, utf8.constData(), len);
    g_stringBuffer[len] = '\0';
    return g_stringBuffer;
}

extern "C" {

// ============================================================
// QMessageBox 桥接函数
// ============================================================

void qMessageBoxInformation(int64_t parentPtr, const char* title, const char* text) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QMessageBox::information(parent, QString::fromUtf8(title), QString::fromUtf8(text));
}

void qMessageBoxWarning(int64_t parentPtr, const char* title, const char* text) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QMessageBox::warning(parent, QString::fromUtf8(title), QString::fromUtf8(text));
}

void qMessageBoxCritical(int64_t parentPtr, const char* title, const char* text) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QMessageBox::critical(parent, QString::fromUtf8(title), QString::fromUtf8(text));
}

int32_t qMessageBoxQuestion(int64_t parentPtr, const char* title, const char* text) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    return QMessageBox::question(parent, QString::fromUtf8(title), QString::fromUtf8(text),
                                  QMessageBox::Yes | QMessageBox::No) == QMessageBox::Yes ? 1 : 0;
}

// ============================================================
// QFileDialog 桥接函数
// ============================================================

const char* qFileDialogGetOpenFileName(int64_t parentPtr, const char* title, const char* filter) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QString result = QFileDialog::getOpenFileName(parent, QString::fromUtf8(title), QString(), QString::fromUtf8(filter));
    return safeCopyString(result);
}

const char* qFileDialogGetSaveFileName(int64_t parentPtr, const char* title, const char* filter) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QString result = QFileDialog::getSaveFileName(parent, QString::fromUtf8(title), QString(), QString::fromUtf8(filter));
    return safeCopyString(result);
}

const char* qFileDialogGetExistingDirectory(int64_t parentPtr, const char* title) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QString result = QFileDialog::getExistingDirectory(parent, QString::fromUtf8(title));
    return safeCopyString(result);
}

// ============================================================
// QInputDialog 桥接函数 (简化版，直接返回值)
// ============================================================

const char* qInputDialogGetTextValue(int64_t parentPtr, const char* title, const char* label, const char* text) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    bool ok = false;
    QString input = QInputDialog::getText(parent, QString::fromUtf8(title), 
                                           QString::fromUtf8(label), 
                                           QLineEdit::Normal,
                                           QString::fromUtf8(text), &ok);
    if (ok) {
        return safeCopyString(input);
    }
    return safeCopyString(QString()); // 空字符串表示取消
}

int32_t qInputDialogGetIntValue(int64_t parentPtr, const char* title, const char* label, int32_t value, int32_t min, int32_t max) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    bool ok = false;
    int input = QInputDialog::getInt(parent, QString::fromUtf8(title),
                                      QString::fromUtf8(label),
                                      value, min, max, 1, &ok);
    if (ok) {
        return input;
    }
    return std::numeric_limits<int32_t>::min(); // 返回最小值表示取消
}

double qInputDialogGetDoubleValue(int64_t parentPtr, const char* title, const char* label, double value, double min, double max) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    bool ok = false;
    double input = QInputDialog::getDouble(parent, QString::fromUtf8(title),
                                            QString::fromUtf8(label),
                                            value, min, max, 4, &ok);
    if (ok) {
        return input;
    }
    return std::numeric_limits<double>::quiet_NaN(); // 返回NaN表示取消
}

// ============================================================
// QColorDialog 桥接函数 (简化版)
// ============================================================

const char* qColorDialogGetColorHex(int64_t parentPtr, const char* title) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QColor color = QColorDialog::getColor(Qt::white, parent, QString::fromUtf8(title));
    if (color.isValid()) {
        return safeCopyString(color.name(QColor::HexRgb));
    }
    return safeCopyString(QString()); // 空字符串表示取消
}

} // extern "C"
