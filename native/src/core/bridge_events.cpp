/**
 * @file bridge_events.cpp
 * @brief 事件处理桥接函数 - 鼠标事件、键盘事件、绘制事件、选择事件
 */

#include <QWidget>
#include <QMouseEvent>
#include <QKeyEvent>
#include <QPaintEvent>
#include <QPainter>
#include <QApplication>
#include <functional>
#include <unordered_map>

// 事件回调映射
static std::unordered_map<int64_t, std::function<void(int32_t, int32_t, int32_t)>> g_mousePressCallbacks;
static std::unordered_map<int64_t, std::function<void(int32_t, int32_t, int32_t)>> g_mouseMoveCallbacks;
static std::unordered_map<int64_t, std::function<void(int32_t, int32_t, int32_t)>> g_mouseReleaseCallbacks;
static std::unordered_map<int64_t, std::function<void(int32_t, int32_t, int32_t)>> g_keyPressCallbacks;
static std::unordered_map<int64_t, std::function<void(int32_t, int32_t, int32_t)>> g_keyReleaseCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_paintCallbacks;

// 全局widget映射
static std::unordered_map<int64_t, QWidget*> g_eventWidgets;

// 自定义Widget类，支持事件处理
class EventWidget : public QWidget {
public:
    int64_t m_id = 0;
    
    EventWidget(QWidget* parent = nullptr) : QWidget(parent) {
        static int64_t nextId = 1;
        m_id = nextId++;
        setMouseTracking(true);  // 启用鼠标追踪
        setFocusPolicy(Qt::StrongFocus);  // 启用键盘焦点
        g_eventWidgets[m_id] = this;
    }
    
    ~EventWidget() {
        g_eventWidgets.erase(m_id);
    }
    
    int64_t id() const { return m_id; }
    
protected:
    void mousePressEvent(QMouseEvent* event) override {
        auto it = g_mousePressCallbacks.find(m_id);
        if (it != g_mousePressCallbacks.end()) {
            try {
                it->second(event->button(), event->pos().x(), event->pos().y());
            } catch (...) {}
        }
        QWidget::mousePressEvent(event);
    }
    
    void mouseMoveEvent(QMouseEvent* event) override {
        auto it = g_mouseMoveCallbacks.find(m_id);
        if (it != g_mouseMoveCallbacks.end()) {
            try {
                it->second(event->buttons(), event->pos().x(), event->pos().y());
            } catch (...) {}
        }
        QWidget::mouseMoveEvent(event);
    }
    
    void mouseReleaseEvent(QMouseEvent* event) override {
        auto it = g_mouseReleaseCallbacks.find(m_id);
        if (it != g_mouseReleaseCallbacks.end()) {
            try {
                it->second(event->button(), event->pos().x(), event->pos().y());
            } catch (...) {}
        }
        QWidget::mouseReleaseEvent(event);
    }
    
    void keyPressEvent(QKeyEvent* event) override {
        auto it = g_keyPressCallbacks.find(m_id);
        if (it != g_keyPressCallbacks.end()) {
            try {
                it->second(event->key(), event->modifiers(), event->text().isEmpty() ? 0 : event->text()[0].unicode());
            } catch (...) {}
        }
        QWidget::keyPressEvent(event);
    }
    
    void keyReleaseEvent(QKeyEvent* event) override {
        auto it = g_keyReleaseCallbacks.find(m_id);
        if (it != g_keyReleaseCallbacks.end()) {
            try {
                it->second(event->key(), event->modifiers(), event->text().isEmpty() ? 0 : event->text()[0].unicode());
            } catch (...) {}
        }
        QWidget::keyReleaseEvent(event);
    }
    
    void paintEvent(QPaintEvent* event) override {
        auto it = g_paintCallbacks.find(m_id);
        if (it != g_paintCallbacks.end()) {
            try {
                QPainter painter(this);
                it->second(reinterpret_cast<int64_t>(&painter));
            } catch (...) {}
        }
        QWidget::paintEvent(event);
    }
};

extern "C" {

// ============================================================
// EventWidget 桥接函数
// ============================================================

int64_t qEventWidgetCreate() {
    EventWidget* widget = new EventWidget();
    return widget->id();  // 返回ID
}

int64_t qEventWidgetGetPtr(int64_t id) {
    auto it = g_eventWidgets.find(id);
    if (it != g_eventWidgets.end()) {
        return reinterpret_cast<int64_t>(it->second);
    }
    return 0;
}

void qEventWidgetDelete(int64_t ptr) {
    EventWidget* widget = reinterpret_cast<EventWidget*>(ptr);
    if (widget) {
        g_mousePressCallbacks.erase(widget->id());
        g_mouseMoveCallbacks.erase(widget->id());
        g_mouseReleaseCallbacks.erase(widget->id());
        g_keyPressCallbacks.erase(widget->id());
        g_keyReleaseCallbacks.erase(widget->id());
        g_paintCallbacks.erase(widget->id());
        delete widget;
    }
}

// ============================================================
// 鼠标事件回调设置
// ============================================================

void qEventWidgetSetOnMousePress(int64_t ptr, void (*callback)(int32_t, int32_t, int32_t)) {
    EventWidget* widget = reinterpret_cast<EventWidget*>(ptr);
    if (widget) {
        g_mousePressCallbacks[widget->id()] = callback;
    }
}

void qEventWidgetSetOnMouseMove(int64_t ptr, void (*callback)(int32_t, int32_t, int32_t)) {
    EventWidget* widget = reinterpret_cast<EventWidget*>(ptr);
    if (widget) {
        g_mouseMoveCallbacks[widget->id()] = callback;
    }
}

void qEventWidgetSetOnMouseRelease(int64_t ptr, void (*callback)(int32_t, int32_t, int32_t)) {
    EventWidget* widget = reinterpret_cast<EventWidget*>(ptr);
    if (widget) {
        g_mouseReleaseCallbacks[widget->id()] = callback;
    }
}

// ============================================================
// 键盘事件回调设置
// ============================================================

void qEventWidgetSetOnKeyPress(int64_t ptr, void (*callback)(int32_t, int32_t, int32_t)) {
    EventWidget* widget = reinterpret_cast<EventWidget*>(ptr);
    if (widget) {
        g_keyPressCallbacks[widget->id()] = callback;
    }
}

void qEventWidgetSetOnKeyRelease(int64_t ptr, void (*callback)(int32_t, int32_t, int32_t)) {
    EventWidget* widget = reinterpret_cast<EventWidget*>(ptr);
    if (widget) {
        g_keyReleaseCallbacks[widget->id()] = callback;
    }
}

// ============================================================
// 绘制事件回调设置
// ============================================================

void qEventWidgetSetOnPaint(int64_t ptr, void (*callback)(int64_t)) {
    EventWidget* widget = reinterpret_cast<EventWidget*>(ptr);
    if (widget) {
        g_paintCallbacks[widget->id()] = callback;
    }
}

void qEventWidgetClearPaintCallback(int64_t ptr) {
    EventWidget* widget = reinterpret_cast<EventWidget*>(ptr);
    if (widget) {
        g_paintCallbacks.erase(widget->id());
    }
}

void qEventWidgetClearMousePressCallback(int64_t ptr) {
    EventWidget* widget = reinterpret_cast<EventWidget*>(ptr);
    if (widget) {
        g_mousePressCallbacks.erase(widget->id());
    }
}

void qEventWidgetClearMouseMoveCallback(int64_t ptr) {
    EventWidget* widget = reinterpret_cast<EventWidget*>(ptr);
    if (widget) {
        g_mouseMoveCallbacks.erase(widget->id());
    }
}

void qEventWidgetClearMouseReleaseCallback(int64_t ptr) {
    EventWidget* widget = reinterpret_cast<EventWidget*>(ptr);
    if (widget) {
        g_mouseReleaseCallbacks.erase(widget->id());
    }
}

void qEventWidgetClearKeyPressCallback(int64_t ptr) {
    EventWidget* widget = reinterpret_cast<EventWidget*>(ptr);
    if (widget) {
        g_keyPressCallbacks.erase(widget->id());
    }
}

void qEventWidgetClearKeyReleaseCallback(int64_t ptr) {
    EventWidget* widget = reinterpret_cast<EventWidget*>(ptr);
    if (widget) {
        g_keyReleaseCallbacks.erase(widget->id());
    }
}

void qEventWidgetClearAllCallbacks(int64_t ptr) {
    EventWidget* widget = reinterpret_cast<EventWidget*>(ptr);
    if (widget) {
        g_mousePressCallbacks.erase(widget->id());
        g_mouseMoveCallbacks.erase(widget->id());
        g_mouseReleaseCallbacks.erase(widget->id());
        g_keyPressCallbacks.erase(widget->id());
        g_keyReleaseCallbacks.erase(widget->id());
        g_paintCallbacks.erase(widget->id());
    }
}

void qEventWidgetSetFocus(int64_t ptr) {
    EventWidget* widget = reinterpret_cast<EventWidget*>(ptr);
    if (widget) {
        widget->setFocus();
    }
}

// ============================================================
// 鼠标按钮常量
// ============================================================

int32_t qMouseButtonLeft() { return Qt::LeftButton; }
int32_t qMouseButtonRight() { return Qt::RightButton; }
int32_t qMouseButtonMiddle() { return Qt::MiddleButton; }

// ============================================================
// 键盘按键常量
// ============================================================

int32_t qKeyEscape() { return Qt::Key_Escape; }
int32_t qKeyTab() { return Qt::Key_Tab; }
int32_t qKeyBackspace() { return Qt::Key_Backspace; }
int32_t qKeyReturn() { return Qt::Key_Return; }
int32_t qKeyEnter() { return Qt::Key_Enter; }
int32_t qKeyInsert() { return Qt::Key_Insert; }
int32_t qKeyDelete() { return Qt::Key_Delete; }
int32_t qKeyPause() { return Qt::Key_Pause; }
int32_t qKeyPrint() { return Qt::Key_Print; }
int32_t qKeyHome() { return Qt::Key_Home; }
int32_t qKeyEnd() { return Qt::Key_End; }
int32_t qKeyLeft() { return Qt::Key_Left; }
int32_t qKeyUp() { return Qt::Key_Up; }
int32_t qKeyRight() { return Qt::Key_Right; }
int32_t qKeyDown() { return Qt::Key_Down; }
int32_t qKeyPageUp() { return Qt::Key_PageUp; }
int32_t qKeyPageDown() { return Qt::Key_PageDown; }
int32_t qKeyShift() { return Qt::Key_Shift; }
int32_t qKeyControl() { return Qt::Key_Control; }
int32_t qKeyMeta() { return Qt::Key_Meta; }
int32_t qKeyAlt() { return Qt::Key_Alt; }
int32_t qKeyCapsLock() { return Qt::Key_CapsLock; }
int32_t qKeyNumLock() { return Qt::Key_NumLock; }
int32_t qKeyScrollLock() { return Qt::Key_ScrollLock; }
int32_t qKeyF1() { return Qt::Key_F1; }
int32_t qKeyF2() { return Qt::Key_F2; }
int32_t qKeyF3() { return Qt::Key_F3; }
int32_t qKeyF4() { return Qt::Key_F4; }
int32_t qKeyF5() { return Qt::Key_F5; }
int32_t qKeyF6() { return Qt::Key_F6; }
int32_t qKeyF7() { return Qt::Key_F7; }
int32_t qKeyF8() { return Qt::Key_F8; }
int32_t qKeyF9() { return Qt::Key_F9; }
int32_t qKeyF10() { return Qt::Key_F10; }
int32_t qKeyF11() { return Qt::Key_F11; }
int32_t qKeyF12() { return Qt::Key_F12; }
int32_t qKeySpace() { return Qt::Key_Space; }

// 修饰键常量
int32_t qModifierShift() { return Qt::ShiftModifier; }
int32_t qModifierControl() { return Qt::ControlModifier; }
int32_t qModifierAlt() { return Qt::AltModifier; }
int32_t qModifierMeta() { return Qt::MetaModifier; }

} // extern "C"