/**
 * @file bridge_dialogs.cpp
 * @brief 对话框桥接函数 - QMessageBox, QFileDialog, QInputDialog, QColorDialog, QFontDialog, QProgressDialog
 */

#include <QMessageBox>
#include <QFileDialog>
#include <QInputDialog>
#include <QColorDialog>
#include <QFontDialog>
#include <QProgressDialog>
#include <QColor>
#include <QFont>
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

// 获取多个打开文件路径（用\n分隔）
const char* qFileDialogGetOpenFileNames(int64_t parentPtr, const char* title, const char* filter) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QStringList files = QFileDialog::getOpenFileNames(parent, QString::fromUtf8(title), QString(), QString::fromUtf8(filter));
    return safeCopyString(files.join("\n"));
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

// ============================================================
// QFontDialog 桥接函数
// ============================================================

const char* qFontDialogGetFontName(int64_t parentPtr, const char* title) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    bool ok = false;
    QFont font = QFontDialog::getFont(&ok, parent);
    if (ok) {
        return safeCopyString(font.family());
    }
    return safeCopyString(QString()); // 空字符串表示取消
}

int32_t qFontDialogGetFontSize(int64_t parentPtr, const char* title) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    bool ok = false;
    QFont font = QFontDialog::getFont(&ok, parent);
    if (ok) {
        return font.pointSize();
    }
    return -1; // -1表示取消
}

const char* qFontDialogGetFontInfo(int64_t parentPtr, const char* title) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    bool ok = false;
    QFont font = QFontDialog::getFont(&ok, parent);
    if (ok) {
        QString info = QString("%1,%2,%3,%4")
            .arg(font.family())
            .arg(font.pointSize())
            .arg(font.bold() ? 1 : 0)
            .arg(font.italic() ? 1 : 0);
        return safeCopyString(info);
    }
    return safeCopyString(QString()); // 空字符串表示取消
}

const char* qFontDialogGetFontWithDefault(int64_t parentPtr, const char* title, 
                                           const char* family, int32_t size, 
                                           int32_t bold, int32_t italic) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QFont initialFont(QString::fromUtf8(family), size);
    initialFont.setBold(bold != 0);
    initialFont.setItalic(italic != 0);
    
    bool ok = false;
    QFont font = QFontDialog::getFont(&ok, initialFont, parent, QString::fromUtf8(title));
    if (ok) {
        QString info = QString("%1,%2,%3,%4")
            .arg(font.family())
            .arg(font.pointSize())
            .arg(font.bold() ? 1 : 0)
            .arg(font.italic() ? 1 : 0);
        return safeCopyString(info);
    }
    return safeCopyString(QString()); // 空字符串表示取消
}

// ============================================================
// QProgressDialog 桥接函数
// ============================================================

int64_t qProgressDialogCreate(int64_t parentPtr, const char* labelText, const char* cancelButtonText, int32_t minimum, int32_t maximum) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QProgressDialog* progress = new QProgressDialog(
        QString::fromUtf8(labelText),
        QString::fromUtf8(cancelButtonText),
        minimum, maximum,
        parent
    );
    progress->setWindowModality(Qt::WindowModal);
    return reinterpret_cast<int64_t>(progress);
}

void qProgressDialogDelete(int64_t ptr) {
    QProgressDialog* progress = reinterpret_cast<QProgressDialog*>(ptr);
    if (progress) {
        delete progress;
    }
}

void qProgressDialogSetValue(int64_t ptr, int32_t value) {
    QProgressDialog* progress = reinterpret_cast<QProgressDialog*>(ptr);
    if (progress) {
        progress->setValue(value);
    }
}

int32_t qProgressDialogValue(int64_t ptr) {
    QProgressDialog* progress = reinterpret_cast<QProgressDialog*>(ptr);
    if (progress) {
        return progress->value();
    }
    return 0;
}

void qProgressDialogSetMinimum(int64_t ptr, int32_t minimum) {
    QProgressDialog* progress = reinterpret_cast<QProgressDialog*>(ptr);
    if (progress) {
        progress->setMinimum(minimum);
    }
}

void qProgressDialogSetMaximum(int64_t ptr, int32_t maximum) {
    QProgressDialog* progress = reinterpret_cast<QProgressDialog*>(ptr);
    if (progress) {
        progress->setMaximum(maximum);
    }
}

void qProgressDialogSetLabelText(int64_t ptr, const char* text) {
    QProgressDialog* progress = reinterpret_cast<QProgressDialog*>(ptr);
    if (progress) {
        progress->setLabelText(QString::fromUtf8(text));
    }
}

void qProgressDialogSetCancelButtonText(int64_t ptr, const char* text) {
    QProgressDialog* progress = reinterpret_cast<QProgressDialog*>(ptr);
    if (progress) {
        progress->setCancelButtonText(QString::fromUtf8(text));
    }
}

void qProgressDialogSetWindowTitle(int64_t ptr, const char* title) {
    QProgressDialog* progress = reinterpret_cast<QProgressDialog*>(ptr);
    if (progress) {
        progress->setWindowTitle(QString::fromUtf8(title));
    }
}

void qProgressDialogSetAutoClose(int64_t ptr, int32_t autoClose) {
    QProgressDialog* progress = reinterpret_cast<QProgressDialog*>(ptr);
    if (progress) {
        progress->setAutoClose(autoClose != 0);
    }
}

void qProgressDialogSetAutoReset(int64_t ptr, int32_t autoReset) {
    QProgressDialog* progress = reinterpret_cast<QProgressDialog*>(ptr);
    if (progress) {
        progress->setAutoReset(autoReset != 0);
    }
}

int32_t qProgressDialogWasCanceled(int64_t ptr) {
    QProgressDialog* progress = reinterpret_cast<QProgressDialog*>(ptr);
    if (progress) {
        return progress->wasCanceled() ? 1 : 0;
    }
    return 0;
}

void qProgressDialogShow(int64_t ptr) {
    QProgressDialog* progress = reinterpret_cast<QProgressDialog*>(ptr);
    if (progress) {
        progress->show();
    }
}

void qProgressDialogHide(int64_t ptr) {
    QProgressDialog* progress = reinterpret_cast<QProgressDialog*>(ptr);
    if (progress) {
        progress->hide();
    }
}

void qProgressDialogCancel(int64_t ptr) {
    QProgressDialog* progress = reinterpret_cast<QProgressDialog*>(ptr);
    if (progress) {
        progress->cancel();
    }
}

void qProgressDialogReset(int64_t ptr) {
    QProgressDialog* progress = reinterpret_cast<QProgressDialog*>(ptr);
    if (progress) {
        progress->reset();
    }
}

} // extern "C"