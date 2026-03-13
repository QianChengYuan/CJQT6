/**
 * @file bridge_print.cpp
 * @brief 打印模块桥接函数 - QPrinter, QPrintDialog, QPrintPreviewDialog
 */

#include <QPrinter>
#include <QPrintDialog>
#include <QPrintPreviewDialog>
#include <QPainter>
#include <QPageSize>
#include <QPageLayout>

extern "C" {

// ============================================================
// QPrinter 桥接函数
// ============================================================

int64_t qPrinterCreate() {
    QPrinter* printer = new QPrinter();
    return reinterpret_cast<int64_t>(printer);
}

int64_t qPrinterCreateWithMode(int32_t mode) {
    QPrinter* printer = new QPrinter(static_cast<QPrinter::PrinterMode>(mode));
    return reinterpret_cast<int64_t>(printer);
}

void qPrinterSetOutputFormat(int64_t ptr, int32_t format) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        printer->setOutputFormat(static_cast<QPrinter::OutputFormat>(format));
    }
}

int32_t qPrinterOutputFormat(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        return static_cast<int32_t>(printer->outputFormat());
    }
    return 0;
}

void qPrinterSetOutputFileName(int64_t ptr, const char* name) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        printer->setOutputFileName(QString::fromUtf8(name));
    }
}

const char* qPrinterOutputFileName(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    static QByteArray buffer;
    if (printer) {
        buffer = printer->outputFileName().toUtf8();
        return buffer.constData();
    }
    return "";
}

void qPrinterSetPageSize(int64_t ptr, int32_t pageSize) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        printer->setPageSize(QPageSize(static_cast<QPageSize::PageSizeId>(pageSize)));
    }
}

int32_t qPrinterPageSize(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        return static_cast<int32_t>(printer->pageLayout().pageSize().id());
    }
    return 0;
}

void qPrinterSetOrientation(int64_t ptr, int32_t orientation) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        printer->setPageOrientation(static_cast<QPageLayout::Orientation>(orientation));
    }
}

int32_t qPrinterOrientation(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        return static_cast<int32_t>(printer->pageLayout().orientation());
    }
    return 0;
}

void qPrinterSetPageMargins(int64_t ptr, float left, float top, float right, float bottom) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        printer->setPageMargins(QMarginsF(left, top, right, bottom), QPageLayout::Millimeter);
    }
}

void qPrinterSetFullPage(int64_t ptr, bool fullPage) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        printer->setFullPage(fullPage);
    }
}

bool qPrinterFullPage(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        return printer->fullPage();
    }
    return false;
}

void qPrinterSetNumCopies(int64_t ptr, int32_t copies) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        printer->setCopyCount(copies);
    }
}

int32_t qPrinterNumCopies(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        return printer->copyCount();
    }
    return 1;
}

void qPrinterSetCopyCollate(int64_t ptr, bool collate) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        printer->setCollateCopies(collate);
    }
}

bool qPrinterCopyCollate(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        return printer->collateCopies();
    }
    return false;
}

void qPrinterSetColorMode(int64_t ptr, int32_t mode) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        printer->setColorMode(static_cast<QPrinter::ColorMode>(mode));
    }
}

int32_t qPrinterColorMode(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        return static_cast<int32_t>(printer->colorMode());
    }
    return 0;
}

void qPrinterSetDoubleSidedPrinting(int64_t ptr, bool enable) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        printer->setDuplex(enable ? QPrinter::DuplexAuto : QPrinter::DuplexNone);
    }
}

bool qPrinterDoubleSidedPrinting(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        return printer->duplex() != QPrinter::DuplexNone;
    }
    return false;
}

int32_t qPrinterWidth(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        return static_cast<int32_t>(printer->width());
    }
    return 0;
}

int32_t qPrinterHeight(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        return static_cast<int32_t>(printer->height());
    }
    return 0;
}

int32_t qPrinterResolution(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        return printer->resolution();
    }
    return 0;
}

void qPrinterSetResolution(int64_t ptr, int32_t dpi) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        printer->setResolution(dpi);
    }
}

const char* qPrinterPrinterName(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    static QByteArray buffer;
    if (printer) {
        buffer = printer->printerName().toUtf8();
        return buffer.constData();
    }
    return "";
}

void qPrinterSetPrinterName(int64_t ptr, const char* name) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        printer->setPrinterName(QString::fromUtf8(name));
    }
}

const char* qPrinterDocName(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    static QByteArray buffer;
    if (printer) {
        buffer = printer->docName().toUtf8();
        return buffer.constData();
    }
    return "";
}

void qPrinterSetDocName(int64_t ptr, const char* name) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        printer->setDocName(QString::fromUtf8(name));
    }
}

int64_t qPrinterNewPage(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        return printer->newPage() ? 1 : 0;
    }
    return 0;
}

int32_t qPrinterFromPage(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        return printer->fromPage();
    }
    return 0;
}

int32_t qPrinterToPage(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        return printer->toPage();
    }
    return 0;
}

void qPrinterSetFromTo(int64_t ptr, int32_t from, int32_t to) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        printer->setFromTo(from, to);
    }
}

void qPrinterDelete(int64_t ptr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(ptr);
    if (printer) {
        delete printer;
    }
}

// ============================================================
// QPrintDialog 桥接函数
// ============================================================

int64_t qPrintDialogCreate(int64_t printerPtr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(printerPtr);
    QPrintDialog* dialog = new QPrintDialog(printer);
    return reinterpret_cast<int64_t>(dialog);
}

int32_t qPrintDialogExec(int64_t ptr) {
    QPrintDialog* dialog = reinterpret_cast<QPrintDialog*>(ptr);
    if (dialog) {
        return static_cast<int32_t>(dialog->exec());
    }
    return 0;
}

int64_t qPrintDialogPrinter(int64_t ptr) {
    QPrintDialog* dialog = reinterpret_cast<QPrintDialog*>(ptr);
    if (dialog) {
        return reinterpret_cast<int64_t>(dialog->printer());
    }
    return 0;
}

void qPrintDialogDelete(int64_t ptr) {
    QPrintDialog* dialog = reinterpret_cast<QPrintDialog*>(ptr);
    if (dialog) {
        delete dialog;
    }
}

// ============================================================
// QPrintPreviewDialog 桥接函数
// ============================================================

int64_t qPrintPreviewDialogCreate(int64_t printerPtr) {
    QPrinter* printer = reinterpret_cast<QPrinter*>(printerPtr);
    QPrintPreviewDialog* dialog = new QPrintPreviewDialog(printer);
    return reinterpret_cast<int64_t>(dialog);
}

int32_t qPrintPreviewDialogExec(int64_t ptr) {
    QPrintPreviewDialog* dialog = reinterpret_cast<QPrintPreviewDialog*>(ptr);
    if (dialog) {
        return static_cast<int32_t>(dialog->exec());
    }
    return 0;
}

int64_t qPrintPreviewDialogPrinter(int64_t ptr) {
    QPrintPreviewDialog* dialog = reinterpret_cast<QPrintPreviewDialog*>(ptr);
    if (dialog) {
        return reinterpret_cast<int64_t>(dialog->printer());
    }
    return 0;
}

void qPrintPreviewDialogDelete(int64_t ptr) {
    QPrintPreviewDialog* dialog = reinterpret_cast<QPrintPreviewDialog*>(ptr);
    if (dialog) {
        delete dialog;
    }
}

} // extern "C"
