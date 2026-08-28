/**
 * @file bridge_ext_wmisc.cpp
 * @brief v1.2.0 API 补全扩展 - wmisc 批次控件桥接函数。
 * 补充 datetime / graphiceffect / graphicsview / systemtrayicon / buttongroup
 * 批次控件的常用方法、属性与信号，遵循 bridge_ext_new.cpp 既有风格：
 *   - 入参 ptr 做空指针校验；
 *   - 字符串返回使用 static 缓冲区 + toUtf8().constData()；
 *   - 信号通过 std::unordered_map 注册回调，connect 前做去重保护；
 *   - 布尔参数/返回值使用 int32_t（0/1）。
 */
#include <QWidget>
#include <QString>
#include <functional>
#include <unordered_map>

#include <QDate>
#include <QTime>
#include <QDateTime>
#include <QCalendarWidget>
#include <QDateEdit>
#include <QDateTimeEdit>
#include <QTimeEdit>

#include <QGraphicsEffect>
#include <QGraphicsOpacityEffect>
#include <QGraphicsDropShadowEffect>
#include <QGraphicsView>
#include <QGraphicsScene>

#include <QSystemTrayIcon>
#include <QMenu>
#include <QIcon>
#include <QAction>
#include <QButtonGroup>
#include <QAbstractButton>

extern "C" {

// ============================================================
// QCalendarWidget 补充 API - 信号
// ============================================================

static std::unordered_map<int64_t, std::function<void(const char*)>> g_calClicked;
static std::unordered_map<int64_t, std::function<void(const char*)>> g_calActivated;
static std::unordered_map<int64_t, std::function<void()>> g_calSelectionChanged;

void qCalendarWidgetConnectClicked(int64_t ptr, void (*cb)(const char*)) {
    QCalendarWidget* cal = reinterpret_cast<QCalendarWidget*>(ptr);
    if (cal && cb && g_calClicked.find(ptr) == g_calClicked.end()) {
        g_calClicked[ptr] = [cb](const char* s) { cb(s); };
        QObject::connect(cal, &QCalendarWidget::clicked, [ptr](const QDate& date) {
            auto it = g_calClicked.find(ptr);
            if (it != g_calClicked.end()) {
                static QString buf;
                buf = date.toString("yyyy-MM-dd");
                it->second(buf.toUtf8().constData());
            }
        });
    }
}

void qCalendarWidgetConnectActivated(int64_t ptr, void (*cb)(const char*)) {
    QCalendarWidget* cal = reinterpret_cast<QCalendarWidget*>(ptr);
    if (cal && cb && g_calActivated.find(ptr) == g_calActivated.end()) {
        g_calActivated[ptr] = [cb](const char* s) { cb(s); };
        QObject::connect(cal, &QCalendarWidget::activated, [ptr](const QDate& date) {
            auto it = g_calActivated.find(ptr);
            if (it != g_calActivated.end()) {
                static QString buf;
                buf = date.toString("yyyy-MM-dd");
                it->second(buf.toUtf8().constData());
            }
        });
    }
}

void qCalendarWidgetConnectSelectionChanged(int64_t ptr, void (*cb)()) {
    QCalendarWidget* cal = reinterpret_cast<QCalendarWidget*>(ptr);
    if (cal && cb && g_calSelectionChanged.find(ptr) == g_calSelectionChanged.end()) {
        g_calSelectionChanged[ptr] = [cb]() { cb(); };
        QObject::connect(cal, &QCalendarWidget::selectionChanged, [ptr]() {
            auto it = g_calSelectionChanged.find(ptr);
            if (it != g_calSelectionChanged.end()) it->second();
        });
    }
}

// ============================================================
// QDateEdit 补充 API
// ============================================================

void qDateEditSetDateFromParts(int64_t ptr, int32_t y, int32_t mo, int32_t d) {
    QDateEdit* e = reinterpret_cast<QDateEdit*>(ptr);
    if (e) e->setDate(QDate(y, mo, d));
}

static std::unordered_map<int64_t, std::function<void(const char*)>> g_deDateChanged;
static std::unordered_map<int64_t, std::function<void(const char*)>> g_deDateTimeChanged;

void qDateEditConnectDateChanged(int64_t ptr, void (*cb)(const char*)) {
    QDateEdit* e = reinterpret_cast<QDateEdit*>(ptr);
    if (e && cb && g_deDateChanged.find(ptr) == g_deDateChanged.end()) {
        g_deDateChanged[ptr] = [cb](const char* s) { cb(s); };
        QObject::connect(e, &QDateEdit::dateChanged, [ptr](const QDate& date) {
            auto it = g_deDateChanged.find(ptr);
            if (it != g_deDateChanged.end()) {
                static QString buf;
                buf = date.toString("yyyy-MM-dd");
                it->second(buf.toUtf8().constData());
            }
        });
    }
}

void qDateEditConnectDateTimeChanged(int64_t ptr, void (*cb)(const char*)) {
    QDateEdit* e = reinterpret_cast<QDateEdit*>(ptr);
    if (e && cb && g_deDateTimeChanged.find(ptr) == g_deDateTimeChanged.end()) {
        g_deDateTimeChanged[ptr] = [cb](const char* s) { cb(s); };
        QObject::connect(e, &QDateEdit::dateTimeChanged, [ptr](const QDateTime& dt) {
            auto it = g_deDateTimeChanged.find(ptr);
            if (it != g_deDateTimeChanged.end()) {
                static QString buf;
                buf = dt.toString("yyyy-MM-dd hh:mm:ss");
                it->second(buf.toUtf8().constData());
            }
        });
    }
}

// ============================================================
// QTimeEdit 补充 API
// ============================================================

void qTimeEditSetTimeFromParts(int64_t ptr, int32_t h, int32_t mi, int32_t s) {
    QTimeEdit* e = reinterpret_cast<QTimeEdit*>(ptr);
    if (e) e->setTime(QTime(h, mi, s));
}

static std::unordered_map<int64_t, std::function<void(const char*)>> g_teTimeChanged;
static std::unordered_map<int64_t, std::function<void(const char*)>> g_teDateTimeChanged;

void qTimeEditConnectTimeChanged(int64_t ptr, void (*cb)(const char*)) {
    QTimeEdit* e = reinterpret_cast<QTimeEdit*>(ptr);
    if (e && cb && g_teTimeChanged.find(ptr) == g_teTimeChanged.end()) {
        g_teTimeChanged[ptr] = [cb](const char* s) { cb(s); };
        QObject::connect(e, &QTimeEdit::timeChanged, [ptr](const QTime& time) {
            auto it = g_teTimeChanged.find(ptr);
            if (it != g_teTimeChanged.end()) {
                static QString buf;
                buf = time.toString("hh:mm:ss");
                it->second(buf.toUtf8().constData());
            }
        });
    }
}

void qTimeEditConnectDateTimeChanged(int64_t ptr, void (*cb)(const char*)) {
    QTimeEdit* e = reinterpret_cast<QTimeEdit*>(ptr);
    if (e && cb && g_teDateTimeChanged.find(ptr) == g_teDateTimeChanged.end()) {
        g_teDateTimeChanged[ptr] = [cb](const char* s) { cb(s); };
        QObject::connect(e, &QTimeEdit::dateTimeChanged, [ptr](const QDateTime& dt) {
            auto it = g_teDateTimeChanged.find(ptr);
            if (it != g_teDateTimeChanged.end()) {
                static QString buf;
                buf = dt.toString("yyyy-MM-dd hh:mm:ss");
                it->second(buf.toUtf8().constData());
            }
        });
    }
}

// ============================================================
// QDateTimeEdit 补充 API
// ============================================================

void qDateTimeEditSetDateTimeFromParts(int64_t ptr, int32_t y, int32_t mo, int32_t d,
                                       int32_t h, int32_t mi, int32_t s) {
    QDateTimeEdit* e = reinterpret_cast<QDateTimeEdit*>(ptr);
    if (e) e->setDateTime(QDateTime(QDate(y, mo, d), QTime(h, mi, s)));
}

static std::unordered_map<int64_t, std::function<void(const char*)>> g_dteDateChanged;
static std::unordered_map<int64_t, std::function<void(const char*)>> g_dteTimeChanged;
static std::unordered_map<int64_t, std::function<void(const char*)>> g_dteDateTimeChanged;

void qDateTimeEditConnectDateChanged(int64_t ptr, void (*cb)(const char*)) {
    QDateTimeEdit* e = reinterpret_cast<QDateTimeEdit*>(ptr);
    if (e && cb && g_dteDateChanged.find(ptr) == g_dteDateChanged.end()) {
        g_dteDateChanged[ptr] = [cb](const char* s) { cb(s); };
        QObject::connect(e, &QDateTimeEdit::dateChanged, [ptr](const QDate& date) {
            auto it = g_dteDateChanged.find(ptr);
            if (it != g_dteDateChanged.end()) {
                static QString buf;
                buf = date.toString("yyyy-MM-dd");
                it->second(buf.toUtf8().constData());
            }
        });
    }
}

void qDateTimeEditConnectTimeChanged(int64_t ptr, void (*cb)(const char*)) {
    QDateTimeEdit* e = reinterpret_cast<QDateTimeEdit*>(ptr);
    if (e && cb && g_dteTimeChanged.find(ptr) == g_dteTimeChanged.end()) {
        g_dteTimeChanged[ptr] = [cb](const char* s) { cb(s); };
        QObject::connect(e, &QDateTimeEdit::timeChanged, [ptr](const QTime& time) {
            auto it = g_dteTimeChanged.find(ptr);
            if (it != g_dteTimeChanged.end()) {
                static QString buf;
                buf = time.toString("hh:mm:ss");
                it->second(buf.toUtf8().constData());
            }
        });
    }
}

void qDateTimeEditConnectDateTimeChanged(int64_t ptr, void (*cb)(const char*)) {
    QDateTimeEdit* e = reinterpret_cast<QDateTimeEdit*>(ptr);
    if (e && cb && g_dteDateTimeChanged.find(ptr) == g_dteDateTimeChanged.end()) {
        g_dteDateTimeChanged[ptr] = [cb](const char* s) { cb(s); };
        QObject::connect(e, &QDateTimeEdit::dateTimeChanged, [ptr](const QDateTime& dt) {
            auto it = g_dteDateTimeChanged.find(ptr);
            if (it != g_dteDateTimeChanged.end()) {
                static QString buf;
                buf = dt.toString("yyyy-MM-dd hh:mm:ss");
                it->second(buf.toUtf8().constData());
            }
        });
    }
}

// ============================================================
// QGraphicsDropShadowEffect 补充 API
// ============================================================

double qGraphicsDropShadowEffectXOffset(int64_t ptr) {
    QGraphicsDropShadowEffect* e = reinterpret_cast<QGraphicsDropShadowEffect*>(ptr);
    return e ? e->xOffset() : 0.0;
}

void qGraphicsDropShadowEffectSetXOffset(int64_t ptr, double v) {
    QGraphicsDropShadowEffect* e = reinterpret_cast<QGraphicsDropShadowEffect*>(ptr);
    if (e) e->setXOffset(v);
}

double qGraphicsDropShadowEffectYOffset(int64_t ptr) {
    QGraphicsDropShadowEffect* e = reinterpret_cast<QGraphicsDropShadowEffect*>(ptr);
    return e ? e->yOffset() : 0.0;
}

void qGraphicsDropShadowEffectSetYOffset(int64_t ptr, double v) {
    QGraphicsDropShadowEffect* e = reinterpret_cast<QGraphicsDropShadowEffect*>(ptr);
    if (e) e->setYOffset(v);
}

// ============================================================
// QGraphicsView 补充 API
// ============================================================

void qGraphicsViewSetRenderHints(int64_t ptr, int32_t hints) {
    QGraphicsView* v = reinterpret_cast<QGraphicsView*>(ptr);
    if (v) v->setRenderHints(static_cast<QPainter::RenderHints>(hints));
}

void qGraphicsViewSetViewportUpdateMode(int64_t ptr, int32_t mode) {
    QGraphicsView* v = reinterpret_cast<QGraphicsView*>(ptr);
    if (v) v->setViewportUpdateMode(static_cast<QGraphicsView::ViewportUpdateMode>(mode));
}

// ============================================================
// QSystemTrayIcon 信号补充 API
// ============================================================

static std::unordered_map<int64_t, std::function<void(int32_t)>> g_stiActivated;
static std::unordered_map<int64_t, std::function<void()>> g_stiMessageClicked;

void qSystemTrayIconConnectActivated(int64_t ptr, void (*cb)(int32_t)) {
    QSystemTrayIcon* t = reinterpret_cast<QSystemTrayIcon*>(ptr);
    if (t && cb && g_stiActivated.find(ptr) == g_stiActivated.end()) {
        g_stiActivated[ptr] = [cb](int32_t v) { cb(v); };
        QObject::connect(t, &QSystemTrayIcon::activated, [ptr](QSystemTrayIcon::ActivationReason reason) {
            auto it = g_stiActivated.find(ptr);
            if (it != g_stiActivated.end()) it->second(static_cast<int32_t>(reason));
        });
    }
}

void qSystemTrayIconConnectMessageClicked(int64_t ptr, void (*cb)()) {
    QSystemTrayIcon* t = reinterpret_cast<QSystemTrayIcon*>(ptr);
    if (t && cb && g_stiMessageClicked.find(ptr) == g_stiMessageClicked.end()) {
        g_stiMessageClicked[ptr] = [cb]() { cb(); };
        QObject::connect(t, &QSystemTrayIcon::messageClicked, [ptr]() {
            auto it = g_stiMessageClicked.find(ptr);
            if (it != g_stiMessageClicked.end()) it->second();
        });
    }
}

// ============================================================
// QButtonGroup 补充 API
// ============================================================

int64_t qButtonGroupButton(int64_t ptr, int32_t id) {
    QButtonGroup* g = reinterpret_cast<QButtonGroup*>(ptr);
    if (g) return reinterpret_cast<int64_t>(g->button(id));
    return 0;
}

static std::unordered_map<int64_t, std::function<void(int64_t)>> g_bgClicked;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_bgPressed;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_bgReleased;
static std::unordered_map<int64_t, std::function<void(int64_t, int32_t)>> g_bgToggled;
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_bgIdClicked;

void qButtonGroupConnectButtonClicked(int64_t ptr, void (*cb)(int64_t)) {
    QButtonGroup* g = reinterpret_cast<QButtonGroup*>(ptr);
    if (g && cb && g_bgClicked.find(ptr) == g_bgClicked.end()) {
        g_bgClicked[ptr] = [cb](int64_t b) { cb(b); };
        QObject::connect(g, &QButtonGroup::buttonClicked, [ptr](QAbstractButton* btn) {
            auto it = g_bgClicked.find(ptr);
            if (it != g_bgClicked.end()) it->second(reinterpret_cast<int64_t>(btn));
        });
    }
}

void qButtonGroupConnectButtonPressed(int64_t ptr, void (*cb)(int64_t)) {
    QButtonGroup* g = reinterpret_cast<QButtonGroup*>(ptr);
    if (g && cb && g_bgPressed.find(ptr) == g_bgPressed.end()) {
        g_bgPressed[ptr] = [cb](int64_t b) { cb(b); };
        QObject::connect(g, &QButtonGroup::buttonPressed, [ptr](QAbstractButton* btn) {
            auto it = g_bgPressed.find(ptr);
            if (it != g_bgPressed.end()) it->second(reinterpret_cast<int64_t>(btn));
        });
    }
}

void qButtonGroupConnectButtonReleased(int64_t ptr, void (*cb)(int64_t)) {
    QButtonGroup* g = reinterpret_cast<QButtonGroup*>(ptr);
    if (g && cb && g_bgReleased.find(ptr) == g_bgReleased.end()) {
        g_bgReleased[ptr] = [cb](int64_t b) { cb(b); };
        QObject::connect(g, &QButtonGroup::buttonReleased, [ptr](QAbstractButton* btn) {
            auto it = g_bgReleased.find(ptr);
            if (it != g_bgReleased.end()) it->second(reinterpret_cast<int64_t>(btn));
        });
    }
}

void qButtonGroupConnectButtonToggled(int64_t ptr, void (*cb)(int64_t, int32_t)) {
    QButtonGroup* g = reinterpret_cast<QButtonGroup*>(ptr);
    if (g && cb && g_bgToggled.find(ptr) == g_bgToggled.end()) {
        g_bgToggled[ptr] = [cb](int64_t b, int32_t v) { cb(b, v); };
        QObject::connect(g, &QButtonGroup::buttonToggled, [ptr](QAbstractButton* btn, bool checked) {
            auto it = g_bgToggled.find(ptr);
            if (it != g_bgToggled.end()) it->second(reinterpret_cast<int64_t>(btn), checked ? 1 : 0);
        });
    }
}

void qButtonGroupConnectIdClicked(int64_t ptr, void (*cb)(int32_t)) {
    QButtonGroup* g = reinterpret_cast<QButtonGroup*>(ptr);
    if (g && cb && g_bgIdClicked.find(ptr) == g_bgIdClicked.end()) {
        g_bgIdClicked[ptr] = [cb](int32_t v) { cb(v); };
        QObject::connect(g, &QButtonGroup::idClicked, [ptr](int id) {
            auto it = g_bgIdClicked.find(ptr);
            if (it != g_bgIdClicked.end()) it->second(static_cast<int32_t>(id));
        });
    }
}

// misc 模块统一信号回调清理：对象 delete 后残留的条目会让 connect 去重
// 保护（find != end 跳过注册）误判，复用同一地址的新对象 connect 被跳过、
// 回调永不触发。由 qDateEditDelete/qTimeEditDelete/qDateTimeEditDelete/
// qSystemTrayIconDelete/qButtonGroupDelete 调用。
void qWmiscSignalCleanup(int64_t ptr) {
    g_deDateChanged.erase(ptr);
    g_deDateTimeChanged.erase(ptr);
    g_teTimeChanged.erase(ptr);
    g_teDateTimeChanged.erase(ptr);
    g_dteDateChanged.erase(ptr);
    g_dteTimeChanged.erase(ptr);
    g_dteDateTimeChanged.erase(ptr);
    g_stiActivated.erase(ptr);
    g_stiMessageClicked.erase(ptr);
    g_bgClicked.erase(ptr);
    g_bgPressed.erase(ptr);
    g_bgReleased.erase(ptr);
    g_bgToggled.erase(ptr);
    g_bgIdClicked.erase(ptr);
    g_calClicked.erase(ptr);
    g_calActivated.erase(ptr);
    g_calSelectionChanged.erase(ptr);
}

// 测试专用内省：查询 ptr 是否仍注册在任一 misc 控件信号回调 map 中。
int32_t qWmiscSignalRegistered(int64_t ptr) {
    return (g_deDateChanged.find(ptr) != g_deDateChanged.end() ||
            g_deDateTimeChanged.find(ptr) != g_deDateTimeChanged.end() ||
            g_teTimeChanged.find(ptr) != g_teTimeChanged.end() ||
            g_teDateTimeChanged.find(ptr) != g_teDateTimeChanged.end() ||
            g_dteDateChanged.find(ptr) != g_dteDateChanged.end() ||
            g_dteTimeChanged.find(ptr) != g_dteTimeChanged.end() ||
            g_dteDateTimeChanged.find(ptr) != g_dteDateTimeChanged.end() ||
            g_stiActivated.find(ptr) != g_stiActivated.end() ||
            g_stiMessageClicked.find(ptr) != g_stiMessageClicked.end() ||
            g_bgClicked.find(ptr) != g_bgClicked.end() ||
            g_bgPressed.find(ptr) != g_bgPressed.end() ||
            g_bgReleased.find(ptr) != g_bgReleased.end() ||
            g_bgToggled.find(ptr) != g_bgToggled.end() ||
            g_bgIdClicked.find(ptr) != g_bgIdClicked.end() ||
            g_calClicked.find(ptr) != g_calClicked.end() ||
            g_calActivated.find(ptr) != g_calActivated.end() ||
            g_calSelectionChanged.find(ptr) != g_calSelectionChanged.end()) ? 1 : 0;
}

} // extern "C"
