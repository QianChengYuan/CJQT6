#include <QFont>
#include <QFontMetrics>
#include <QFontInfo>
#include <unordered_map>

static QByteArray g_fontBuffer;
// Qt6 的 QFontMetrics 无 font() 成员，需保存创建时的 QFont 以便获取 family
static std::unordered_map<int64_t, QFont> g_fontMetricsFonts;

extern "C" {

// ============================================================
// QFontMetrics 桥接函数
// ============================================================

int64_t qFontMetricsCreate(int64_t fontPtr) {
    QFont* font = reinterpret_cast<QFont*>(fontPtr);
    QFontMetrics* fm = font ? new QFontMetrics(*font) : new QFontMetrics(QFont());
    g_fontMetricsFonts[reinterpret_cast<int64_t>(fm)] = font ? *font : QFont();
    return reinterpret_cast<int64_t>(fm);
}

void qFontMetricsDelete(int64_t ptr) {
    g_fontMetricsFonts.erase(ptr);
    delete reinterpret_cast<QFontMetrics*>(ptr);
}

int32_t qFontMetricsHeight(int64_t ptr) {
    QFontMetrics* fm = reinterpret_cast<QFontMetrics*>(ptr);
    return fm ? fm->height() : 0;
}

int32_t qFontMetricsAscent(int64_t ptr) {
    QFontMetrics* fm = reinterpret_cast<QFontMetrics*>(ptr);
    return fm ? fm->ascent() : 0;
}

int32_t qFontMetricsDescent(int64_t ptr) {
    QFontMetrics* fm = reinterpret_cast<QFontMetrics*>(ptr);
    return fm ? fm->descent() : 0;
}

int32_t qFontMetricsLeading(int64_t ptr) {
    QFontMetrics* fm = reinterpret_cast<QFontMetrics*>(ptr);
    return fm ? fm->leading() : 0;
}

int32_t qFontMetricsLineSpacing(int64_t ptr) {
    QFontMetrics* fm = reinterpret_cast<QFontMetrics*>(ptr);
    return fm ? fm->lineSpacing() : 0;
}

int32_t qFontMetricsAverageCharWidth(int64_t ptr) {
    QFontMetrics* fm = reinterpret_cast<QFontMetrics*>(ptr);
    return fm ? fm->averageCharWidth() : 0;
}

int32_t qFontMetricsHorizontalAdvance(int64_t ptr, const char* text) {
    QFontMetrics* fm = reinterpret_cast<QFontMetrics*>(ptr);
    return fm ? fm->horizontalAdvance(QString::fromUtf8(text)) : 0;
}

int32_t qFontMetricsMaxWidth(int64_t ptr) {
    QFontMetrics* fm = reinterpret_cast<QFontMetrics*>(ptr);
    return fm ? fm->maxWidth() : 0;
}

const char* qFontMetricsFontFamily(int64_t ptr) {
    auto it = g_fontMetricsFonts.find(ptr);
    if (it != g_fontMetricsFonts.end()) {
        g_fontBuffer = it->second.family().toUtf8();
        return g_fontBuffer.constData();
    }
    return "";
}

// ============================================================
// QFontInfo 桥接函数
// ============================================================

int64_t qFontInfoCreate(int64_t fontPtr) {
    QFont* font = reinterpret_cast<QFont*>(fontPtr);
    if (font) return reinterpret_cast<int64_t>(new QFontInfo(*font));
    return reinterpret_cast<int64_t>(new QFontInfo(QFont()));
}

void qFontInfoDelete(int64_t ptr) {
    delete reinterpret_cast<QFontInfo*>(ptr);
}

const char* qFontInfoFamily(int64_t ptr) {
    QFontInfo* fi = reinterpret_cast<QFontInfo*>(ptr);
    if (fi) {
        g_fontBuffer = fi->family().toUtf8();
        return g_fontBuffer.constData();
    }
    return "";
}

int32_t qFontInfoPointSize(int64_t ptr) {
    QFontInfo* fi = reinterpret_cast<QFontInfo*>(ptr);
    return fi ? fi->pointSize() : 0;
}

double qFontInfoPointSizeF(int64_t ptr) {
    QFontInfo* fi = reinterpret_cast<QFontInfo*>(ptr);
    return fi ? fi->pointSizeF() : 0.0;
}

int32_t qFontInfoPixelSize(int64_t ptr) {
    QFontInfo* fi = reinterpret_cast<QFontInfo*>(ptr);
    return fi ? fi->pixelSize() : 0;
}

bool qFontInfoBold(int64_t ptr) {
    QFontInfo* fi = reinterpret_cast<QFontInfo*>(ptr);
    return fi ? fi->bold() : false;
}

bool qFontInfoItalic(int64_t ptr) {
    QFontInfo* fi = reinterpret_cast<QFontInfo*>(ptr);
    return fi ? fi->italic() : false;
}

bool qFontInfoUnderline(int64_t ptr) {
    QFontInfo* fi = reinterpret_cast<QFontInfo*>(ptr);
    return fi ? fi->underline() : false;
}

bool qFontInfoStrikeOut(int64_t ptr) {
    QFontInfo* fi = reinterpret_cast<QFontInfo*>(ptr);
    return fi ? fi->strikeOut() : false;
}

bool qFontInfoFixedPitch(int64_t ptr) {
    QFontInfo* fi = reinterpret_cast<QFontInfo*>(ptr);
    return fi ? fi->fixedPitch() : false;
}

int32_t qFontInfoWeight(int64_t ptr) {
    QFontInfo* fi = reinterpret_cast<QFontInfo*>(ptr);
    return fi ? fi->weight() : 0;
}

int32_t qFontInfoStyleHint(int64_t ptr) {
    QFontInfo* fi = reinterpret_cast<QFontInfo*>(ptr);
    return fi ? fi->styleHint() : 0;
}

} // extern "C"
