/**
 * @file bridge_ext_wtext.cpp
 * @brief v1.2.0 API 补全扩展 - wtext 批次控件（标签/单行文本/多行文本/纯文本/富文本浏览器）
 * 该文件补充 wtext 批次控件的桥接函数，遵循 bridge_ext_new.cpp 的既有风格：
 *   - 入参 ptr 做空指针校验；
 *   - 字符串返回使用 static 缓冲区 + toUtf8().constData()；
 *   - 信号通过 std::unordered_map 注册回调，connect 前做去重保护。
 */
#include <QWidget>
#include <QString>
#include <functional>
#include <unordered_map>

#include <QLabel>
#include <QLineEdit>
#include <QTextEdit>
#include <QPlainTextEdit>
#include <QTextBrowser>
#include <QPixmap>
#include <QIcon>
#include <QTextDocument>
#include <QRegularExpression>
#include <QCompleter>
#include <QColor>
#include <QUrl>
#include "bridge_string_utils.h"

extern "C" {

// ============================================================
// QLabel 补充 API
// ============================================================

int32_t qLabelAlignment(int64_t ptr) {
    QLabel* lbl = reinterpret_cast<QLabel*>(ptr);
    return lbl ? static_cast<int32_t>(lbl->alignment()) : 0;
}

void qLabelSetPixmapByPath(int64_t ptr, const char* path) {
    QLabel* lbl = reinterpret_cast<QLabel*>(ptr);
    if (lbl) lbl->setPixmap(QPixmap(QString::fromUtf8(path)));
}

void qLabelSetScaledContents(int64_t ptr, int32_t v) {
    QLabel* lbl = reinterpret_cast<QLabel*>(ptr);
    if (lbl) lbl->setScaledContents(v != 0);
}

bool qLabelIsScaledContents(int64_t ptr) {
    QLabel* lbl = reinterpret_cast<QLabel*>(ptr);
    return lbl ? lbl->hasScaledContents() : false;
}


void qLabelSetIndent(int64_t ptr, int32_t v) {
    QLabel* lbl = reinterpret_cast<QLabel*>(ptr);
    if (lbl) lbl->setIndent(v);
}

int32_t qLabelIndent(int64_t ptr) {
    QLabel* lbl = reinterpret_cast<QLabel*>(ptr);
    return lbl ? static_cast<int32_t>(lbl->indent()) : -1;
}

void qLabelSetMargin(int64_t ptr, int32_t v) {
    QLabel* lbl = reinterpret_cast<QLabel*>(ptr);
    if (lbl) lbl->setMargin(v);
}

int32_t qLabelMargin(int64_t ptr) {
    QLabel* lbl = reinterpret_cast<QLabel*>(ptr);
    return lbl ? static_cast<int32_t>(lbl->margin()) : -1;
}

void qLabelSetOpenExternalLinks(int64_t ptr, int32_t v) {
    QLabel* lbl = reinterpret_cast<QLabel*>(ptr);
    if (lbl) lbl->setOpenExternalLinks(v != 0);
}

void qLabelSetTextFormat(int64_t ptr, int32_t v) {
    QLabel* lbl = reinterpret_cast<QLabel*>(ptr);
    if (lbl) lbl->setTextFormat(static_cast<Qt::TextFormat>(v));
}

void qLabelSetBuddy(int64_t ptr, int64_t buddyPtr) {
    QLabel* lbl = reinterpret_cast<QLabel*>(ptr);
    QWidget* buddy = reinterpret_cast<QWidget*>(buddyPtr);
    if (lbl && buddy) lbl->setBuddy(buddy);
}

// ============================================================
// QLineEdit 补充 API
// ============================================================

int32_t qLineEditEchoMode(int64_t ptr) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    return le ? static_cast<int32_t>(le->echoMode()) : 0;
}

bool qLineEditIsReadOnly(int64_t ptr) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    return le ? le->isReadOnly() : false;
}

int32_t qLineEditCursorPosition(int64_t ptr) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    return le ? static_cast<int32_t>(le->cursorPosition()) : 0;
}

void qLineEditSetCursorPosition(int64_t ptr, int32_t pos) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    if (le) le->setCursorPosition(pos);
}

void qLineEditSetSelection(int64_t ptr, int32_t start, int32_t length) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    if (le) le->setSelection(start, length);
}

bool qLineEditHasFrame(int64_t ptr) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    return le ? le->hasFrame() : false;
}

void qLineEditSetClearButtonEnabled(int64_t ptr, int32_t v) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    if (le) le->setClearButtonEnabled(v != 0);
}

bool qLineEditIsClearButtonEnabled(int64_t ptr) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    return le ? le->isClearButtonEnabled() : false;
}

void qLineEditSetCompleter(int64_t ptr, int64_t completerPtr) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    QCompleter* comp = reinterpret_cast<QCompleter*>(completerPtr);
    if (le && comp) le->setCompleter(comp);
}

const char* qLineEditDisplayText(int64_t ptr) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    if (le) {
        return cjqt6::dupUtf8(le->displayText());
    }
    return cjqt6::emptyString();
}

static std::unordered_map<int64_t, std::function<void(int32_t, int32_t)>> g_leCursorPos;
static std::unordered_map<int64_t, std::function<void()>> g_leSelection;
static std::unordered_map<int64_t, std::function<void()>> g_leInputRejected;

void qLineEditConnectCursorPositionChanged(int64_t ptr, void (*cb)(int32_t, int32_t)) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    if (le && cb && g_leCursorPos.find(ptr) == g_leCursorPos.end()) {
        g_leCursorPos[ptr] = [cb](int32_t a, int32_t b) { cb(a, b); };
        QObject::connect(le, &QLineEdit::cursorPositionChanged, [ptr](int oldPos, int newPos) {
            auto it = g_leCursorPos.find(ptr);
            if (it != g_leCursorPos.end()) it->second(static_cast<int32_t>(oldPos), static_cast<int32_t>(newPos));
        });
    }
}

void qLineEditConnectSelectionChanged(int64_t ptr, void (*cb)()) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    if (le && cb && g_leSelection.find(ptr) == g_leSelection.end()) {
        g_leSelection[ptr] = [cb]() { cb(); };
        QObject::connect(le, &QLineEdit::selectionChanged, [ptr]() {
            auto it = g_leSelection.find(ptr);
            if (it != g_leSelection.end()) it->second();
        });
    }
}

void qLineEditConnectInputRejected(int64_t ptr, void (*cb)()) {
    QLineEdit* le = reinterpret_cast<QLineEdit*>(ptr);
    if (le && cb && g_leInputRejected.find(ptr) == g_leInputRejected.end()) {
        g_leInputRejected[ptr] = [cb]() { cb(); };
        QObject::connect(le, &QLineEdit::inputRejected, [ptr]() {
            auto it = g_leInputRejected.find(ptr);
            if (it != g_leInputRejected.end()) it->second();
        });
    }
}

// ============================================================
// QTextEdit 补充 API
// ============================================================

void qTextEditSetHtml(int64_t ptr, const char* html) {
    QTextEdit* te = reinterpret_cast<QTextEdit*>(ptr);
    if (te) te->setHtml(QString::fromUtf8(html));
}

const char* qTextEditToHtml(int64_t ptr) {
    QTextEdit* te = reinterpret_cast<QTextEdit*>(ptr);
    if (te) {
        return cjqt6::dupUtf8(te->toHtml());
    }
    return cjqt6::emptyString();
}

void qTextEditSetPlainText(int64_t ptr, const char* text) {
    QTextEdit* te = reinterpret_cast<QTextEdit*>(ptr);
    if (te) te->setPlainText(QString::fromUtf8(text));
}

const char* qTextEditToPlainText(int64_t ptr) {
    QTextEdit* te = reinterpret_cast<QTextEdit*>(ptr);
    if (te) {
        return cjqt6::dupUtf8(te->toPlainText());
    }
    return cjqt6::emptyString();
}

void qTextEditAppend(int64_t ptr, const char* text) {
    QTextEdit* te = reinterpret_cast<QTextEdit*>(ptr);
    if (te) te->append(QString::fromUtf8(text));
}

void qTextEditInsertHtml(int64_t ptr, const char* html) {
    QTextEdit* te = reinterpret_cast<QTextEdit*>(ptr);
    if (te) te->insertHtml(QString::fromUtf8(html));
}

void qTextEditSetTextColor(int64_t ptr, int32_t r, int32_t g, int32_t b) {
    QTextEdit* te = reinterpret_cast<QTextEdit*>(ptr);
    if (!te) return;
    QTextCursor cursor = te->textCursor();
    const int anchor = cursor.anchor();
    const int pos = cursor.position();
    QTextCharFormat fmt;
    fmt.setForeground(QBrush(QColor(r, g, b)));
    if (cursor.hasSelection()) {
        cursor.mergeCharFormat(fmt);
    } else {
        cursor.select(QTextCursor::Document);
        cursor.mergeCharFormat(fmt);
    }
    cursor.setPosition(anchor, QTextCursor::MoveAnchor);
    cursor.setPosition(pos, QTextCursor::KeepAnchor);
    te->setTextCursor(cursor);
    te->mergeCurrentCharFormat(fmt);
}

void qTextEditZoomIn(int64_t ptr, int32_t range) {
    QTextEdit* te = reinterpret_cast<QTextEdit*>(ptr);
    if (te) te->zoomIn(range);
}

void qTextEditZoomOut(int64_t ptr, int32_t range) {
    QTextEdit* te = reinterpret_cast<QTextEdit*>(ptr);
    if (te) te->zoomOut(range);
}

static std::unordered_map<int64_t, std::function<void()>> g_teTextChanged;
static std::unordered_map<int64_t, std::function<void(bool)>> g_teUndoAvail;
static std::unordered_map<int64_t, std::function<void(bool)>> g_teRedoAvail;
static std::unordered_map<int64_t, std::function<void(bool)>> g_teCopyAvail;

void qTextEditConnectTextChanged(int64_t ptr, void (*cb)()) {
    QTextEdit* te = reinterpret_cast<QTextEdit*>(ptr);
    if (te && cb && g_teTextChanged.find(ptr) == g_teTextChanged.end()) {
        g_teTextChanged[ptr] = [cb]() { cb(); };
        QObject::connect(te, &QTextEdit::textChanged, [ptr]() {
            auto it = g_teTextChanged.find(ptr);
            if (it != g_teTextChanged.end()) it->second();
        });
    }
}

void qTextEditConnectUndoAvailable(int64_t ptr, void (*cb)(bool)) {
    QTextEdit* te = reinterpret_cast<QTextEdit*>(ptr);
    if (te && cb && g_teUndoAvail.find(ptr) == g_teUndoAvail.end()) {
        g_teUndoAvail[ptr] = [cb](bool v) { cb(v); };
        QObject::connect(te, &QTextEdit::undoAvailable, [ptr](bool avail) {
            auto it = g_teUndoAvail.find(ptr);
            if (it != g_teUndoAvail.end()) it->second(avail);
        });
    }
}

void qTextEditConnectRedoAvailable(int64_t ptr, void (*cb)(bool)) {
    QTextEdit* te = reinterpret_cast<QTextEdit*>(ptr);
    if (te && cb && g_teRedoAvail.find(ptr) == g_teRedoAvail.end()) {
        g_teRedoAvail[ptr] = [cb](bool v) { cb(v); };
        QObject::connect(te, &QTextEdit::redoAvailable, [ptr](bool avail) {
            auto it = g_teRedoAvail.find(ptr);
            if (it != g_teRedoAvail.end()) it->second(avail);
        });
    }
}

void qTextEditConnectCopyAvailable(int64_t ptr, void (*cb)(bool)) {
    QTextEdit* te = reinterpret_cast<QTextEdit*>(ptr);
    if (te && cb && g_teCopyAvail.find(ptr) == g_teCopyAvail.end()) {
        g_teCopyAvail[ptr] = [cb](bool v) { cb(v); };
        QObject::connect(te, &QTextEdit::copyAvailable, [ptr](bool avail) {
            auto it = g_teCopyAvail.find(ptr);
            if (it != g_teCopyAvail.end()) it->second(avail);
        });
    }
}

// ============================================================
// QPlainTextEdit 补充 API
// ============================================================

void qPlainTextEditAppendHtml(int64_t ptr, const char* html) {
    QPlainTextEdit* te = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (te) te->appendHtml(QString::fromUtf8(html));
}

void qPlainTextEditZoomIn(int64_t ptr, int32_t range) {
    QPlainTextEdit* te = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (te) te->zoomIn(range);
}

void qPlainTextEditZoomOut(int64_t ptr, int32_t range) {
    QPlainTextEdit* te = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (te) te->zoomOut(range);
}

int32_t qPlainTextEditBlockCount(int64_t ptr) {
    QPlainTextEdit* te = reinterpret_cast<QPlainTextEdit*>(ptr);
    return te ? static_cast<int32_t>(te->blockCount()) : 0;
}

static std::unordered_map<int64_t, std::function<void()>> g_pteTextChanged;
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_pteBlockCount;
static std::unordered_map<int64_t, std::function<void(bool)>> g_pteModChanged;
static std::unordered_map<int64_t, std::function<void(bool)>> g_pteCopyAvail;

void qPlainTextEditConnectTextChanged(int64_t ptr, void (*cb)()) {
    QPlainTextEdit* te = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (te && cb && g_pteTextChanged.find(ptr) == g_pteTextChanged.end()) {
        g_pteTextChanged[ptr] = [cb]() { cb(); };
        QObject::connect(te, &QPlainTextEdit::textChanged, [ptr]() {
            auto it = g_pteTextChanged.find(ptr);
            if (it != g_pteTextChanged.end()) it->second();
        });
    }
}

void qPlainTextEditConnectBlockCountChanged(int64_t ptr, void (*cb)(int32_t)) {
    QPlainTextEdit* te = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (te && cb && g_pteBlockCount.find(ptr) == g_pteBlockCount.end()) {
        g_pteBlockCount[ptr] = [cb](int32_t v) { cb(v); };
        QObject::connect(te, &QPlainTextEdit::blockCountChanged, [ptr](int count) {
            auto it = g_pteBlockCount.find(ptr);
            if (it != g_pteBlockCount.end()) it->second(static_cast<int32_t>(count));
        });
    }
}

void qPlainTextEditConnectModificationChanged(int64_t ptr, void (*cb)(bool)) {
    QPlainTextEdit* te = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (te && cb && g_pteModChanged.find(ptr) == g_pteModChanged.end()) {
        g_pteModChanged[ptr] = [cb](bool v) { cb(v); };
        QObject::connect(te, &QPlainTextEdit::modificationChanged, [ptr](bool modified) {
            auto it = g_pteModChanged.find(ptr);
            if (it != g_pteModChanged.end()) it->second(modified);
        });
    }
}

void qPlainTextEditConnectCopyAvailable(int64_t ptr, void (*cb)(bool)) {
    QPlainTextEdit* te = reinterpret_cast<QPlainTextEdit*>(ptr);
    if (te && cb && g_pteCopyAvail.find(ptr) == g_pteCopyAvail.end()) {
        g_pteCopyAvail[ptr] = [cb](bool v) { cb(v); };
        QObject::connect(te, &QPlainTextEdit::copyAvailable, [ptr](bool avail) {
            auto it = g_pteCopyAvail.find(ptr);
            if (it != g_pteCopyAvail.end()) it->second(avail);
        });
    }
}

// ============================================================
// QTextBrowser 补充 API
// ============================================================

bool qTextBrowserIsOpenExternalLinks(int64_t ptr) {
    QTextBrowser* tb = reinterpret_cast<QTextBrowser*>(ptr);
    return tb ? tb->openExternalLinks() : false;
}

bool qTextBrowserIsOpenLinks(int64_t ptr) {
    QTextBrowser* tb = reinterpret_cast<QTextBrowser*>(ptr);
    return tb ? tb->openLinks() : false;
}

const char* qTextBrowserSource(int64_t ptr) {
    QTextBrowser* tb = reinterpret_cast<QTextBrowser*>(ptr);
    if (tb) {
        return cjqt6::dupUtf8(tb->source().toString());
    }
    return cjqt6::emptyString();
}

void qTextBrowserClearHistory(int64_t ptr) {
    QTextBrowser* tb = reinterpret_cast<QTextBrowser*>(ptr);
    if (tb) tb->clearHistory();
}

static std::unordered_map<int64_t, std::function<void(bool)>> g_tbBackAvail;
static std::unordered_map<int64_t, std::function<void(bool)>> g_tbFwdAvail;
static std::unordered_map<int64_t, std::function<void(const char*)>> g_tbSourceChanged;
static std::unordered_map<int64_t, std::function<void()>> g_tbTextChanged;

void qTextBrowserConnectBackwardAvailable(int64_t ptr, void (*cb)(bool)) {
    QTextBrowser* tb = reinterpret_cast<QTextBrowser*>(ptr);
    if (tb && cb && g_tbBackAvail.find(ptr) == g_tbBackAvail.end()) {
        g_tbBackAvail[ptr] = [cb](bool v) { cb(v); };
        QObject::connect(tb, &QTextBrowser::backwardAvailable, [ptr](bool avail) {
            auto it = g_tbBackAvail.find(ptr);
            if (it != g_tbBackAvail.end()) it->second(avail);
        });
    }
}

void qTextBrowserConnectForwardAvailable(int64_t ptr, void (*cb)(bool)) {
    QTextBrowser* tb = reinterpret_cast<QTextBrowser*>(ptr);
    if (tb && cb && g_tbFwdAvail.find(ptr) == g_tbFwdAvail.end()) {
        g_tbFwdAvail[ptr] = [cb](bool v) { cb(v); };
        QObject::connect(tb, &QTextBrowser::forwardAvailable, [ptr](bool avail) {
            auto it = g_tbFwdAvail.find(ptr);
            if (it != g_tbFwdAvail.end()) it->second(avail);
        });
    }
}

void qTextBrowserConnectSourceChanged(int64_t ptr, void (*cb)(const char*)) {
    QTextBrowser* tb = reinterpret_cast<QTextBrowser*>(ptr);
    if (tb && cb && g_tbSourceChanged.find(ptr) == g_tbSourceChanged.end()) {
        g_tbSourceChanged[ptr] = [cb](const char* s) { cb(s); };
        QObject::connect(tb, &QTextBrowser::sourceChanged, [ptr](const QUrl& url) {
            auto it = g_tbSourceChanged.find(ptr);
            if (it != g_tbSourceChanged.end()) {
                static QString tmp;
                tmp = url.toString();
                it->second(tmp.toUtf8().constData());
            }
        });
    }
}

void qTextBrowserConnectTextChanged(int64_t ptr, void (*cb)()) {
    QTextBrowser* tb = reinterpret_cast<QTextBrowser*>(ptr);
    if (tb && cb && g_tbTextChanged.find(ptr) == g_tbTextChanged.end()) {
        g_tbTextChanged[ptr] = [cb]() { cb(); };
        QObject::connect(tb, &QTextBrowser::textChanged, [ptr]() {
            auto it = g_tbTextChanged.find(ptr);
            if (it != g_tbTextChanged.end()) it->second();
        });
    }
}

// 文本控件模块统一信号回调清理：对象 delete 后残留的条目会让 connect 去重
// 保护（find != end 跳过注册）误判，复用同一地址的新对象 connect 被跳过、
// 回调永不触发。由 qLineEditDelete/qTextEditDelete/qPlainTextEditDelete/
// qTextBrowserDelete 调用。
void qWtextSignalCleanup(int64_t ptr) {
    g_leCursorPos.erase(ptr);
    g_leSelection.erase(ptr);
    g_leInputRejected.erase(ptr);
    g_teTextChanged.erase(ptr);
    g_teUndoAvail.erase(ptr);
    g_teRedoAvail.erase(ptr);
    g_teCopyAvail.erase(ptr);
    g_pteTextChanged.erase(ptr);
    g_pteBlockCount.erase(ptr);
    g_pteModChanged.erase(ptr);
    g_pteCopyAvail.erase(ptr);
    g_tbBackAvail.erase(ptr);
    g_tbFwdAvail.erase(ptr);
    g_tbSourceChanged.erase(ptr);
    g_tbTextChanged.erase(ptr);
}

// 测试专用内省：查询 ptr 是否仍注册在任一本文控控件信号回调 map 中。
int32_t qWtextSignalRegistered(int64_t ptr) {
    return (g_leCursorPos.find(ptr) != g_leCursorPos.end() ||
            g_leSelection.find(ptr) != g_leSelection.end() ||
            g_leInputRejected.find(ptr) != g_leInputRejected.end() ||
            g_teTextChanged.find(ptr) != g_teTextChanged.end() ||
            g_teUndoAvail.find(ptr) != g_teUndoAvail.end() ||
            g_teRedoAvail.find(ptr) != g_teRedoAvail.end() ||
            g_teCopyAvail.find(ptr) != g_teCopyAvail.end() ||
            g_pteTextChanged.find(ptr) != g_pteTextChanged.end() ||
            g_pteBlockCount.find(ptr) != g_pteBlockCount.end() ||
            g_pteModChanged.find(ptr) != g_pteModChanged.end() ||
            g_pteCopyAvail.find(ptr) != g_pteCopyAvail.end() ||
            g_tbBackAvail.find(ptr) != g_tbBackAvail.end() ||
            g_tbFwdAvail.find(ptr) != g_tbFwdAvail.end() ||
            g_tbSourceChanged.find(ptr) != g_tbSourceChanged.end() ||
            g_tbTextChanged.find(ptr) != g_tbTextChanged.end()) ? 1 : 0;
}

} // extern "C"
