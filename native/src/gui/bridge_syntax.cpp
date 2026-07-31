#include <QSyntaxHighlighter>
#include <QTextDocument>
#include <QTextCharFormat>

typedef void (*HighlightBlockFunc)(int64_t selfPtr, const char* text);

class CjSyntaxHighlighter : public QSyntaxHighlighter {
public:
    explicit CjSyntaxHighlighter(int64_t selfId, QTextDocument* parent)
        : QSyntaxHighlighter(parent), m_selfId(selfId), m_cb(nullptr) {}

    void setCallback(HighlightBlockFunc cb) { m_cb = cb; }
    CjSyntaxHighlighter* setDoc(QTextDocument* doc) { 
        setDocument(doc); return this; 
    }

    void setFormatRange(int start, int count, const QTextCharFormat& fmt) {
        setFormat(start, count, fmt);
    }

    void applyFormat(int start, int count, const QTextCharFormat& fmt) {
        setFormat(start, count, fmt);
    }

protected:
    void highlightBlock(const QString& text) override {
        if (m_cb && m_selfId != 0) {
            QByteArray utf8 = text.toUtf8();
            m_cb(m_selfId, utf8.constData());
        }
    }

private:
    int64_t m_selfId;
    HighlightBlockFunc m_cb;
};

extern "C" {

int64_t qSyntaxHighlighterCreate(int64_t selfId, int64_t docPtr) {
    QTextDocument* doc = reinterpret_cast<QTextDocument*>(docPtr);
    CjSyntaxHighlighter* h = new CjSyntaxHighlighter(selfId, doc);
    return reinterpret_cast<int64_t>(h);
}

void qSyntaxHighlighterDelete(int64_t ptr) {
    delete reinterpret_cast<CjSyntaxHighlighter*>(ptr);
}

void qSyntaxHighlighterSetCallback(int64_t ptr, HighlightBlockFunc cb) {
    CjSyntaxHighlighter* h = reinterpret_cast<CjSyntaxHighlighter*>(ptr);
    if (h) h->setCallback(cb);
}

void qSyntaxHighlighterSetFormat(int64_t ptr, int32_t start, int32_t count,
                                  int64_t color, bool bold, bool italic, bool underline) {
    CjSyntaxHighlighter* h = reinterpret_cast<CjSyntaxHighlighter*>(ptr);
    if (h) {
        QTextCharFormat fmt;
        int r = static_cast<int>(color & 0xFF);
        int g = static_cast<int>((color >> 8) & 0xFF);
        int b = static_cast<int>((color >> 16) & 0xFF);
        fmt.setForeground(QColor(r, g, b));
        if (bold) fmt.setFontWeight(QFont::Bold);
        if (italic) fmt.setFontItalic(true);
        if (underline) fmt.setFontUnderline(true);
        h->applyFormat(start, count, fmt);
    }
}

void qSyntaxHighlighterRehighlight(int64_t ptr) {
    CjSyntaxHighlighter* h = reinterpret_cast<CjSyntaxHighlighter*>(ptr);
    if (h) h->rehighlight();
}

int64_t qSyntaxHighlighterDocument(int64_t ptr) {
    CjSyntaxHighlighter* h = reinterpret_cast<CjSyntaxHighlighter*>(ptr);
    return h ? reinterpret_cast<int64_t>(h->document()) : 0;
}

} // extern "C"
