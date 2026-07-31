/**
 * @file bridge_textdoc.cpp
 * @brief QTextDocument / QTextCursor 桥接函数
 */

#include <QTextDocument>
#include <QTextCursor>
#include <QFont>

extern "C" {

// ============================================================
// QTextDocument 桥接函数
// ============================================================

int64_t qTextDocumentCreate() {
    return reinterpret_cast<int64_t>(new QTextDocument());
}

int64_t qTextDocumentCreateWithText(const char* text) {
    return reinterpret_cast<int64_t>(new QTextDocument(QString::fromUtf8(text)));
}

void qTextDocumentDelete(int64_t ptr) {
    delete reinterpret_cast<QTextDocument*>(ptr);
}

void qTextDocumentSetPlainText(int64_t ptr, const char* text) {
    QTextDocument* doc = reinterpret_cast<QTextDocument*>(ptr);
    if (doc) doc->setPlainText(QString::fromUtf8(text));
}

const char* qTextDocumentToPlainText(int64_t ptr) {
    QTextDocument* doc = reinterpret_cast<QTextDocument*>(ptr);
    static QByteArray buffer;
    if (doc) {
        buffer = doc->toPlainText().toUtf8();
        return buffer.constData();
    }
    return "";
}

void qTextDocumentSetHtml(int64_t ptr, const char* html) {
    QTextDocument* doc = reinterpret_cast<QTextDocument*>(ptr);
    if (doc) doc->setHtml(QString::fromUtf8(html));
}

const char* qTextDocumentToHtml(int64_t ptr) {
    QTextDocument* doc = reinterpret_cast<QTextDocument*>(ptr);
    static QByteArray buffer;
    if (doc) {
        buffer = doc->toHtml().toUtf8();
        return buffer.constData();
    }
    return "";
}

int32_t qTextDocumentBlockCount(int64_t ptr) {
    QTextDocument* doc = reinterpret_cast<QTextDocument*>(ptr);
    return doc ? doc->blockCount() : 0;
}

int32_t qTextDocumentLineCount(int64_t ptr) {
    QTextDocument* doc = reinterpret_cast<QTextDocument*>(ptr);
    return doc ? doc->lineCount() : 0;
}

int32_t qTextDocumentCharacterCount(int64_t ptr) {
    QTextDocument* doc = reinterpret_cast<QTextDocument*>(ptr);
    return doc ? doc->characterCount() : 0;
}

int32_t qTextDocumentPageCount(int64_t ptr) {
    QTextDocument* doc = reinterpret_cast<QTextDocument*>(ptr);
    return doc ? doc->pageCount() : 0;
}

bool qTextDocumentIsEmpty(int64_t ptr) {
    QTextDocument* doc = reinterpret_cast<QTextDocument*>(ptr);
    return doc ? doc->isEmpty() : true;
}

bool qTextDocumentIsModified(int64_t ptr) {
    QTextDocument* doc = reinterpret_cast<QTextDocument*>(ptr);
    return doc ? doc->isModified() : false;
}

void qTextDocumentSetModified(int64_t ptr, bool modified) {
    QTextDocument* doc = reinterpret_cast<QTextDocument*>(ptr);
    if (doc) doc->setModified(modified);
}

void qTextDocumentSetDefaultFont(int64_t ptr, const char* family, int32_t pointSize) {
    QTextDocument* doc = reinterpret_cast<QTextDocument*>(ptr);
    if (doc) {
        QFont font(QString::fromUtf8(family));
        if (pointSize > 0) font.setPointSize(pointSize);
        doc->setDefaultFont(font);
    }
}

void qTextDocumentClear(int64_t ptr) {
    QTextDocument* doc = reinterpret_cast<QTextDocument*>(ptr);
    if (doc) doc->clear();
}

// ============================================================
// QTextCursor 桥接函数
// ============================================================

int64_t qTextCursorCreate(int64_t docPtr) {
    QTextDocument* doc = reinterpret_cast<QTextDocument*>(docPtr);
    if (doc) {
        return reinterpret_cast<int64_t>(new QTextCursor(doc));
    }
    return 0;
}

void qTextCursorDelete(int64_t ptr) {
    delete reinterpret_cast<QTextCursor*>(ptr);
}

int32_t qTextCursorPosition(int64_t ptr) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    return cursor ? cursor->position() : 0;
}

void qTextCursorSetPosition(int64_t ptr, int32_t pos) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    if (cursor) cursor->setPosition(pos);
}

int32_t qTextCursorAnchor(int64_t ptr) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    return cursor ? cursor->anchor() : 0;
}

void qTextCursorInsertText(int64_t ptr, const char* text) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    if (cursor) cursor->insertText(QString::fromUtf8(text));
}

bool qTextCursorMovePosition(int64_t ptr, int32_t operation, int32_t mode, int32_t count) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    if (cursor) {
        return cursor->movePosition(
            static_cast<QTextCursor::MoveOperation>(operation),
            static_cast<QTextCursor::MoveMode>(mode),
            count
        );
    }
    return false;
}

void qTextCursorSelect(int64_t ptr, int32_t operation) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    if (cursor) {
        cursor->movePosition(static_cast<QTextCursor::MoveOperation>(operation), QTextCursor::KeepAnchor);
    }
}

const char* qTextCursorSelectedText(int64_t ptr) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    static QByteArray buffer;
    if (cursor) {
        buffer = cursor->selectedText().toUtf8();
        return buffer.constData();
    }
    return "";
}

void qTextCursorClearSelection(int64_t ptr) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    if (cursor) cursor->clearSelection();
}

bool qTextCursorHasSelection(int64_t ptr) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    return cursor ? cursor->hasSelection() : false;
}

void qTextCursorRemoveSelectedText(int64_t ptr) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    if (cursor) cursor->removeSelectedText();
}

void qTextCursorDeleteChar(int64_t ptr) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    if (cursor) cursor->deleteChar();
}

void qTextCursorDeletePreviousChar(int64_t ptr) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    if (cursor) cursor->deletePreviousChar();
}

void qTextCursorInsertNewBlock(int64_t ptr) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    if (cursor) cursor->insertBlock();
}

bool qTextCursorIsNull(int64_t ptr) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    return cursor ? cursor->isNull() : true;
}

int32_t qTextCursorBlockNumber(int64_t ptr) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    return cursor ? cursor->blockNumber() : 0;
}

int32_t qTextCursorColumnNumber(int64_t ptr) {
    QTextCursor* cursor = reinterpret_cast<QTextCursor*>(ptr);
    return cursor ? cursor->columnNumber() : 0;
}

} // extern "C"
