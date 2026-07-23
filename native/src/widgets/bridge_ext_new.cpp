/**
 * @file bridge_ext_new.cpp
 * @brief v1.2.0 新控件 API 补全扩展桥接函数
 *
 * 该文件集中放置 v1.2.0 新增及较薄控件的补充桥接函数，避免改动共享的
 * bridge_widgets.cpp。所有函数遵循既有风格：
 *   - 入参 ptr 做空指针校验；
 *   - 字符串返回使用 static 缓冲区 + toUtf8().constData()；
 *   - 信号通过 std::unordered_map 注册回调，connect 前做去重保护。
 */

#include <QScrollBar>
#include <QCommandLinkButton>
#include <QDialogButtonBox>
#include <QSizeGrip>
#include <QRubberBand>
#include <QSplashScreen>
#include <QIntValidator>
#include <QDoubleValidator>
#include <QRegularExpressionValidator>
#include <QValidator>
#include <QPixmap>
#include <QIcon>
#include <QString>
#include <QAbstractButton>
#include <QRegularExpression>
#include <functional>
#include <unordered_map>

extern "C" {

// ============================================================
// QScrollBar 补充 API
// ============================================================

int32_t qScrollBarMinimum(int64_t ptr) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    return bar ? static_cast<int32_t>(bar->minimum()) : 0;
}

void qScrollBarSetMinimum(int64_t ptr, int32_t v) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar) bar->setMinimum(v);
}

int32_t qScrollBarMaximum(int64_t ptr) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    return bar ? static_cast<int32_t>(bar->maximum()) : 0;
}

void qScrollBarSetMaximum(int64_t ptr, int32_t v) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar) bar->setMaximum(v);
}

int32_t qScrollBarSliderPosition(int64_t ptr) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    return bar ? static_cast<int32_t>(bar->sliderPosition()) : 0;
}

void qScrollBarSetSliderPosition(int64_t ptr, int32_t v) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar) bar->setSliderPosition(v);
}

int32_t qScrollBarIsTracking(int64_t ptr) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    return bar ? (bar->hasTracking() ? 1 : 0) : 0;
}

void qScrollBarSetTracking(int64_t ptr, int32_t v) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar) bar->setTracking(v != 0);
}

int32_t qScrollBarInvertedAppearance(int64_t ptr) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    return bar ? (bar->invertedAppearance() ? 1 : 0) : 0;
}

void qScrollBarSetInvertedAppearance(int64_t ptr, int32_t v) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar) bar->setInvertedAppearance(v != 0);
}

int32_t qScrollBarInvertedControls(int64_t ptr) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    return bar ? (bar->invertedControls() ? 1 : 0) : 0;
}

void qScrollBarSetInvertedControls(int64_t ptr, int32_t v) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar) bar->setInvertedControls(v != 0);
}

// QScrollBar 的 repeatAction()/setRepeatAction() 是 QAbstractSlider 的 protected 成员，
// 自由函数无法直接访问，故用 accessor 子类在成员函数内访问。
class QScrollBarAccess : public QScrollBar {
public:
    QAbstractSlider::SliderAction getRepeatAction() const { return repeatAction(); }
    void setRepeatAction(QAbstractSlider::SliderAction action) {
        QAbstractSlider::setRepeatAction(action);
    }
};

int32_t qScrollBarRepeatAction(int64_t ptr) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (!bar) return 0;
    QScrollBarAccess* acc = static_cast<QScrollBarAccess*>(bar);
    return static_cast<int32_t>(acc->getRepeatAction());
}

void qScrollBarSetRepeatAction(int64_t ptr, int32_t v) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar) {
        QScrollBarAccess* acc = static_cast<QScrollBarAccess*>(bar);
        acc->setRepeatAction(static_cast<QAbstractSlider::SliderAction>(v));
    }
}

void qScrollBarTriggerAction(int64_t ptr, int32_t v) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar) bar->triggerAction(static_cast<QAbstractSlider::SliderAction>(v));
}

// QScrollBar 信号回调映射
static std::unordered_map<int64_t, std::function<void()>> g_sbPressed;
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_sbMoved;
static std::unordered_map<int64_t, std::function<void()>> g_sbReleased;
static std::unordered_map<int64_t, std::function<void(int32_t, int32_t)>> g_sbRange;
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_sbAction;

void qScrollBarConnectSliderPressed(int64_t ptr, void (*cb)()) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar && cb && g_sbPressed.find(ptr) == g_sbPressed.end()) {
        g_sbPressed[ptr] = [cb]() { cb(); };
        QObject::connect(bar, &QScrollBar::sliderPressed, [ptr]() {
            auto it = g_sbPressed.find(ptr);
            if (it != g_sbPressed.end()) it->second();
        });
    }
}

void qScrollBarConnectSliderMoved(int64_t ptr, void (*cb)(int32_t)) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar && cb && g_sbMoved.find(ptr) == g_sbMoved.end()) {
        g_sbMoved[ptr] = [cb](int32_t v) { cb(v); };
        QObject::connect(bar, &QScrollBar::sliderMoved, [ptr](int v) {
            auto it = g_sbMoved.find(ptr);
            if (it != g_sbMoved.end()) it->second(static_cast<int32_t>(v));
        });
    }
}

void qScrollBarConnectSliderReleased(int64_t ptr, void (*cb)()) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar && cb && g_sbReleased.find(ptr) == g_sbReleased.end()) {
        g_sbReleased[ptr] = [cb]() { cb(); };
        QObject::connect(bar, &QScrollBar::sliderReleased, [ptr]() {
            auto it = g_sbReleased.find(ptr);
            if (it != g_sbReleased.end()) it->second();
        });
    }
}

void qScrollBarConnectRangeChanged(int64_t ptr, void (*cb)(int32_t, int32_t)) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar && cb && g_sbRange.find(ptr) == g_sbRange.end()) {
        g_sbRange[ptr] = [cb](int32_t a, int32_t b) { cb(a, b); };
        QObject::connect(bar, &QScrollBar::rangeChanged, [ptr](int min, int max) {
            auto it = g_sbRange.find(ptr);
            if (it != g_sbRange.end()) it->second(static_cast<int32_t>(min), static_cast<int32_t>(max));
        });
    }
}

void qScrollBarConnectActionTriggered(int64_t ptr, void (*cb)(int32_t)) {
    QScrollBar* bar = reinterpret_cast<QScrollBar*>(ptr);
    if (bar && cb && g_sbAction.find(ptr) == g_sbAction.end()) {
        g_sbAction[ptr] = [cb](int32_t v) { cb(v); };
        QObject::connect(bar, &QScrollBar::actionTriggered, [ptr](int action) {
            auto it = g_sbAction.find(ptr);
            if (it != g_sbAction.end()) it->second(static_cast<int32_t>(action));
        });
    }
}

// ============================================================
// QCommandLinkButton 补充 API
// ============================================================

const char* qCommandLinkButtonDescription(int64_t ptr) {
    QCommandLinkButton* btn = reinterpret_cast<QCommandLinkButton*>(ptr);
    if (btn) {
        static QString desc;
        desc = btn->description();
        return desc.toUtf8().constData();
    }
    return "";
}

void qCommandLinkButtonSetIcon(int64_t ptr, const char* path) {
    QCommandLinkButton* btn = reinterpret_cast<QCommandLinkButton*>(ptr);
    if (btn) btn->setIcon(QIcon(QString::fromUtf8(path)));
}

void qCommandLinkButtonSetFlat(int64_t ptr, int32_t flat) {
    QCommandLinkButton* btn = reinterpret_cast<QCommandLinkButton*>(ptr);
    if (btn) btn->setFlat(flat != 0);
}

int32_t qCommandLinkButtonIsFlat(int64_t ptr) {
    QCommandLinkButton* btn = reinterpret_cast<QCommandLinkButton*>(ptr);
    return btn ? (btn->isFlat() ? 1 : 0) : 0;
}

// ============================================================
// QRubberBand 补充 API
// ============================================================

void qRubberBandSetShape(int64_t ptr, int32_t shape) {
    // QRubberBand 的 shape 只能在构造时指定，Qt 不提供运行时 setter，
    // 故保留接口但为 no-op（Cangjie 侧 setShape 调用保持链接兼容）。
    (void)ptr;
    (void)shape;
}

int32_t qRubberBandShape(int64_t ptr) {
    QRubberBand* band = reinterpret_cast<QRubberBand*>(ptr);
    return band ? static_cast<int32_t>(band->shape()) : 0;
}

// ============================================================
// QSplashScreen 补充 API
// ============================================================

void qSplashScreenClearMessage(int64_t ptr) {
    QSplashScreen* s = reinterpret_cast<QSplashScreen*>(ptr);
    if (s) s->clearMessage();
}

const char* qSplashScreenMessage(int64_t ptr) {
    QSplashScreen* s = reinterpret_cast<QSplashScreen*>(ptr);
    if (s) {
        static QString msg;
        msg = s->message();
        return msg.toUtf8().constData();
    }
    return "";
}

void qSplashScreenShowMessageAlign(int64_t ptr, const char* message, int32_t alignment) {
    QSplashScreen* s = reinterpret_cast<QSplashScreen*>(ptr);
    if (s) s->showMessage(QString::fromUtf8(message), static_cast<int>(alignment));
}

// ============================================================
// QDialogButtonBox 补充 API
// ============================================================

int32_t qDialogButtonBoxStandardButtons(int64_t ptr) {
    QDialogButtonBox* box = reinterpret_cast<QDialogButtonBox*>(ptr);
    return box ? static_cast<int32_t>(box->standardButtons()) : 0;
}

int64_t qDialogButtonBoxButton(int64_t ptr, int32_t which) {
    QDialogButtonBox* box = reinterpret_cast<QDialogButtonBox*>(ptr);
    if (box) {
        QAbstractButton* btn = box->button(static_cast<QDialogButtonBox::StandardButton>(which));
        return reinterpret_cast<int64_t>(btn);
    }
    return 0;
}

int32_t qDialogButtonBoxButtonRole(int64_t ptr, int64_t buttonPtr) {
    QDialogButtonBox* box = reinterpret_cast<QDialogButtonBox*>(ptr);
    QAbstractButton* btn = reinterpret_cast<QAbstractButton*>(buttonPtr);
    if (box && btn) return static_cast<int32_t>(box->buttonRole(btn));
    return -1;
}

static std::unordered_map<int64_t, std::function<void(int64_t)>> g_dbbClicked;

void qDialogButtonBoxConnectClicked(int64_t ptr, void (*cb)(int64_t)) {
    QDialogButtonBox* box = reinterpret_cast<QDialogButtonBox*>(ptr);
    if (box && cb && g_dbbClicked.find(ptr) == g_dbbClicked.end()) {
        g_dbbClicked[ptr] = [cb](int64_t b) { cb(b); };
        QObject::connect(box, &QDialogButtonBox::clicked, [ptr](QAbstractButton* button) {
            auto it = g_dbbClicked.find(ptr);
            if (it != g_dbbClicked.end()) it->second(reinterpret_cast<int64_t>(button));
        });
    }
}

// ============================================================
// 验证器补充 API
// ============================================================

int32_t qIntValidatorBottom(int64_t ptr) {
    QIntValidator* v = reinterpret_cast<QIntValidator*>(ptr);
    return v ? static_cast<int32_t>(v->bottom()) : 0;
}

void qIntValidatorSetBottom(int64_t ptr, int32_t v) {
    QIntValidator* val = reinterpret_cast<QIntValidator*>(ptr);
    if (val) val->setBottom(v);
}

int32_t qIntValidatorTop(int64_t ptr) {
    QIntValidator* v = reinterpret_cast<QIntValidator*>(ptr);
    return v ? static_cast<int32_t>(v->top()) : 0;
}

void qIntValidatorSetTop(int64_t ptr, int32_t v) {
    QIntValidator* val = reinterpret_cast<QIntValidator*>(ptr);
    if (val) val->setTop(v);
}

double qDoubleValidatorBottom(int64_t ptr) {
    QDoubleValidator* v = reinterpret_cast<QDoubleValidator*>(ptr);
    return v ? v->bottom() : 0.0;
}

void qDoubleValidatorSetBottom(int64_t ptr, double v) {
    QDoubleValidator* val = reinterpret_cast<QDoubleValidator*>(ptr);
    if (val) val->setBottom(v);
}

double qDoubleValidatorTop(int64_t ptr) {
    QDoubleValidator* v = reinterpret_cast<QDoubleValidator*>(ptr);
    return v ? v->top() : 0.0;
}

void qDoubleValidatorSetTop(int64_t ptr, double v) {
    QDoubleValidator* val = reinterpret_cast<QDoubleValidator*>(ptr);
    if (val) val->setTop(v);
}

int32_t qDoubleValidatorDecimals(int64_t ptr) {
    QDoubleValidator* v = reinterpret_cast<QDoubleValidator*>(ptr);
    return v ? static_cast<int32_t>(v->decimals()) : 0;
}

void qDoubleValidatorSetDecimals(int64_t ptr, int32_t v) {
    QDoubleValidator* val = reinterpret_cast<QDoubleValidator*>(ptr);
    if (val) val->setDecimals(v);
}

int32_t qDoubleValidatorNotation(int64_t ptr) {
    QDoubleValidator* v = reinterpret_cast<QDoubleValidator*>(ptr);
    return v ? static_cast<int32_t>(v->notation()) : 0;
}

void qDoubleValidatorSetNotation(int64_t ptr, int32_t v) {
    QDoubleValidator* val = reinterpret_cast<QDoubleValidator*>(ptr);
    if (val) val->setNotation(static_cast<QDoubleValidator::Notation>(v));
}

int64_t qRegExpValidatorCreate(const char* pattern) {
    QRegularExpressionValidator* v = new QRegularExpressionValidator();
    v->setRegularExpression(QRegularExpression(QString::fromUtf8(pattern)));
    return reinterpret_cast<int64_t>(v);
}

void qRegExpValidatorSetPattern(int64_t ptr, const char* pattern) {
    QRegularExpressionValidator* v = reinterpret_cast<QRegularExpressionValidator*>(ptr);
    if (v) v->setRegularExpression(QRegularExpression(QString::fromUtf8(pattern)));
}

} // extern "C"
