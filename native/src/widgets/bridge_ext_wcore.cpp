/**
 * @file bridge_ext_wcore.cpp
 * @brief v1.2.0 API 补全扩展 - wcore 批次控件（按钮类）桥接函数。
 *
 * 该文件补充 QPushButton / QToolButton / QCheckBox / QRadioButton 的常用
 * 属性、方法与信号，遵循 bridge_ext_new.cpp 的既有风格：
 *   - 入参 ptr 做空指针校验；
 *   - 字符串返回使用 static 缓冲区 + toUtf8().constData()；
 *   - 信号通过 std::unordered_map 注册回调，connect 前做去重保护。
 */

#include <QWidget>
#include <QString>
#include <QPushButton>
#include <QObject>
#include <QToolButton>
#include <QCheckBox>
#include <QRadioButton>
#include <QAbstractButton>
#include <QIcon>
#include <QKeySequence>
#include <functional>
#include <unordered_map>
#include "bridge_string_utils.h"

// 扩展信号槽存储（C++ 类型，必须位于 extern "C" 之外）
template <typename Fn>
struct ExtSlot { QMetaObject::Connection conn; Fn cb; };

extern "C" {

// ============================================================
// QPushButton 补充 API
// ============================================================

const char* qButtonIconName(int64_t ptr) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn) {
        return cjqt6::dupUtf8(btn->icon().name());
    }
    return cjqt6::emptyString();
}

const char* qButtonShortcut(int64_t ptr) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn) {
        return cjqt6::dupUtf8(btn->shortcut().toString());
    }
    return cjqt6::emptyString();
}

void qButtonSetShortcut(int64_t ptr, const char* key) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn) btn->setShortcut(QKeySequence(QString::fromUtf8(key)));
}

int32_t qButtonIsCheckable(int64_t ptr) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    return btn ? (btn->isCheckable() ? 1 : 0) : 0;
}

// 注：qButtonIsChecked 已在 bridge_widgets.cpp 中定义（返回 bool），Cangjie 侧
// 已通过 foreign func qButtonIsChecked(ptr: Int64): Bool 直接链接，此处不再重复定义。

int32_t qButtonIsAutoDefault(int64_t ptr) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    return btn ? (btn->autoDefault() ? 1 : 0) : 0;
}

void qButtonSetAutoDefault(int64_t ptr, int32_t v) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn) btn->setAutoDefault(v != 0);
}

int32_t qButtonIsDefault(int64_t ptr) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    return btn ? (btn->isDefault() ? 1 : 0) : 0;
}

int32_t qButtonIsFlat(int64_t ptr) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    return btn ? (btn->isFlat() ? 1 : 0) : 0;
}

int32_t qButtonIsAutoRepeat(int64_t ptr) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    return btn ? (btn->autoRepeat() ? 1 : 0) : 0;
}

void qButtonSetAutoRepeat(int64_t ptr, int32_t v) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn) btn->setAutoRepeat(v != 0);
}

// QPushButton 信号回调映射（P1 改进：保存 QMetaObject::Connection，支持真正断开 + 替换式连接）

static std::unordered_map<int64_t, ExtSlot<std::function<void()>>>         g_btnPressed;
static std::unordered_map<int64_t, ExtSlot<std::function<void()>>>         g_btnReleased;
static std::unordered_map<int64_t, ExtSlot<std::function<void(int32_t)>>> g_btnToggled;
static std::unordered_map<int64_t, ExtSlot<std::function<void(int32_t)>>> g_btnClickedChecked;

// 声明 bridge_signal.cpp 中的捕获路径断开函数（P1c）
void qButtonPressedIdDisconnect(int64_t ptr);
void qButtonReleasedIdDisconnect(int64_t ptr);
void qToolButtonPressedIdDisconnect(int64_t ptr);
void qToolButtonReleasedIdDisconnect(int64_t ptr);

void qButtonDisconnectPressed(int64_t ptr) {
    auto it = g_btnPressed.find(ptr);
    if (it != g_btnPressed.end()) { QObject::disconnect(it->second.conn); g_btnPressed.erase(it); }
    qButtonPressedIdDisconnect(ptr);  // P1c：同步清理捕获路径
}
void qButtonDisconnectReleased(int64_t ptr) {
    auto it = g_btnReleased.find(ptr);
    if (it != g_btnReleased.end()) { QObject::disconnect(it->second.conn); g_btnReleased.erase(it); }
    qButtonReleasedIdDisconnect(ptr);  // P1c：同步清理捕获路径
}
void qButtonDisconnectToggled(int64_t ptr) {
    auto it = g_btnToggled.find(ptr);
    if (it != g_btnToggled.end()) { QObject::disconnect(it->second.conn); g_btnToggled.erase(it); }
}
void qButtonDisconnectClickedChecked(int64_t ptr) {
    auto it = g_btnClickedChecked.find(ptr);
    if (it != g_btnClickedChecked.end()) { QObject::disconnect(it->second.conn); g_btnClickedChecked.erase(it); }
}

void qButtonConnectPressed(int64_t ptr, void (*cb)()) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn && cb) {
        qButtonDisconnectPressed(ptr);  // 替换式：先断开旧连接
        ExtSlot<std::function<void()>> s;
        s.cb = [cb]() { cb(); };
        s.conn = QObject::connect(btn, &QPushButton::pressed, [ptr]() {
            auto it = g_btnPressed.find(ptr);
            if (it != g_btnPressed.end() && it->second.cb) it->second.cb();
        });
        g_btnPressed[ptr] = std::move(s);
    }
}

void qButtonConnectReleased(int64_t ptr, void (*cb)()) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn && cb) {
        qButtonDisconnectReleased(ptr);
        ExtSlot<std::function<void()>> s;
        s.cb = [cb]() { cb(); };
        s.conn = QObject::connect(btn, &QPushButton::released, [ptr]() {
            auto it = g_btnReleased.find(ptr);
            if (it != g_btnReleased.end() && it->second.cb) it->second.cb();
        });
        g_btnReleased[ptr] = std::move(s);
    }
}

void qButtonConnectToggled(int64_t ptr, void (*cb)(int32_t)) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn && cb) {
        qButtonDisconnectToggled(ptr);
        ExtSlot<std::function<void(int32_t)>> s;
        s.cb = [cb](int32_t v) { cb(v); };
        s.conn = QObject::connect(btn, &QPushButton::toggled, [ptr](bool checked) {
            auto it = g_btnToggled.find(ptr);
            if (it != g_btnToggled.end() && it->second.cb) it->second.cb(checked ? 1 : 0);
        });
        g_btnToggled[ptr] = std::move(s);
    }
}

void qButtonConnectClickedChecked(int64_t ptr, void (*cb)(int32_t)) {
    QPushButton* btn = reinterpret_cast<QPushButton*>(ptr);
    if (btn && cb) {
        qButtonDisconnectClickedChecked(ptr);
        ExtSlot<std::function<void(int32_t)>> s;
        s.cb = [cb](int32_t v) { cb(v); };
        s.conn = QObject::connect(btn, &QPushButton::clicked, [ptr](bool checked) {
            auto it = g_btnClickedChecked.find(ptr);
            if (it != g_btnClickedChecked.end() && it->second.cb) it->second.cb(checked ? 1 : 0);
        });
        g_btnClickedChecked[ptr] = std::move(s);
    }
}

// ============================================================
// QToolButton 补充 API
// ============================================================

void qToolButtonSetIconPath(int64_t ptr, const char* path) {
    QToolButton* btn = reinterpret_cast<QToolButton*>(ptr);
    if (btn) btn->setIcon(QIcon(QString::fromUtf8(path)));
}

int32_t qToolButtonToolButtonStyle(int64_t ptr) {
    QToolButton* btn = reinterpret_cast<QToolButton*>(ptr);
    return btn ? static_cast<int32_t>(btn->toolButtonStyle()) : 0;
}

// QToolButton 信号回调映射（P1 改进：保存 QMetaObject::Connection，支持真正断开 + 替换式连接）
static std::unordered_map<int64_t, ExtSlot<std::function<void()>>>         g_tbPressed;
static std::unordered_map<int64_t, ExtSlot<std::function<void()>>>         g_tbReleased;
static std::unordered_map<int64_t, ExtSlot<std::function<void(int32_t)>>> g_tbClickedChecked;

void qToolButtonDisconnectPressed(int64_t ptr) {
    auto it = g_tbPressed.find(ptr);
    if (it != g_tbPressed.end()) { QObject::disconnect(it->second.conn); g_tbPressed.erase(it); }
    qToolButtonPressedIdDisconnect(ptr);  // P1c：同步清理捕获路径
}
void qToolButtonDisconnectReleased(int64_t ptr) {
    auto it = g_tbReleased.find(ptr);
    if (it != g_tbReleased.end()) { QObject::disconnect(it->second.conn); g_tbReleased.erase(it); }
    qToolButtonReleasedIdDisconnect(ptr);  // P1c：同步清理捕获路径
}
void qToolButtonDisconnectClickedChecked(int64_t ptr) {
    auto it = g_tbClickedChecked.find(ptr);
    if (it != g_tbClickedChecked.end()) { QObject::disconnect(it->second.conn); g_tbClickedChecked.erase(it); }
}

void qToolButtonConnectPressed(int64_t ptr, void (*cb)()) {
    QToolButton* btn = reinterpret_cast<QToolButton*>(ptr);
    if (btn && cb) {
        qToolButtonDisconnectPressed(ptr);
        ExtSlot<std::function<void()>> s;
        s.cb = [cb]() { cb(); };
        s.conn = QObject::connect(btn, &QToolButton::pressed, [ptr]() {
            auto it = g_tbPressed.find(ptr);
            if (it != g_tbPressed.end() && it->second.cb) it->second.cb();
        });
        g_tbPressed[ptr] = std::move(s);
    }
}

void qToolButtonConnectReleased(int64_t ptr, void (*cb)()) {
    QToolButton* btn = reinterpret_cast<QToolButton*>(ptr);
    if (btn && cb) {
        qToolButtonDisconnectReleased(ptr);
        ExtSlot<std::function<void()>> s;
        s.cb = [cb]() { cb(); };
        s.conn = QObject::connect(btn, &QToolButton::released, [ptr]() {
            auto it = g_tbReleased.find(ptr);
            if (it != g_tbReleased.end() && it->second.cb) it->second.cb();
        });
        g_tbReleased[ptr] = std::move(s);
    }
}

void qToolButtonConnectClickedChecked(int64_t ptr, void (*cb)(int32_t)) {
    QToolButton* btn = reinterpret_cast<QToolButton*>(ptr);
    if (btn && cb) {
        qToolButtonDisconnectClickedChecked(ptr);
        ExtSlot<std::function<void(int32_t)>> s;
        s.cb = [cb](int32_t v) { cb(v); };
        s.conn = QObject::connect(btn, &QToolButton::clicked, [ptr](bool checked) {
            auto it = g_tbClickedChecked.find(ptr);
            if (it != g_tbClickedChecked.end() && it->second.cb) it->second.cb(checked ? 1 : 0);
        });
        g_tbClickedChecked[ptr] = std::move(s);
    }
}

// ============================================================
// QCheckBox 补充 API
// ============================================================

void qCheckBoxSetCheckState(int64_t ptr, int32_t state) {
    QCheckBox* btn = reinterpret_cast<QCheckBox*>(ptr);
    if (btn) btn->setCheckState(static_cast<Qt::CheckState>(state));
}

int32_t qCheckBoxCheckState(int64_t ptr) {
    QCheckBox* btn = reinterpret_cast<QCheckBox*>(ptr);
    return btn ? static_cast<int32_t>(btn->checkState()) : 0;
}

int32_t qCheckBoxIsTristate(int64_t ptr) {
    QCheckBox* btn = reinterpret_cast<QCheckBox*>(ptr);
    return btn ? (btn->isTristate() ? 1 : 0) : 0;
}

void qCheckBoxSetTristate(int64_t ptr, int32_t v) {
    QCheckBox* btn = reinterpret_cast<QCheckBox*>(ptr);
    if (btn) btn->setTristate(v != 0);
}

// QCheckBox clicked(bool) 信号回调映射
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_cbClicked;

void qCheckBoxConnectClicked(int64_t ptr, void (*cb)(int32_t)) {
    QCheckBox* btn = reinterpret_cast<QCheckBox*>(ptr);
    if (btn && cb && g_cbClicked.find(ptr) == g_cbClicked.end()) {
        g_cbClicked[ptr] = [cb](int32_t v) { cb(v); };
        QObject::connect(btn, &QCheckBox::clicked, [ptr](bool checked) {
            auto it = g_cbClicked.find(ptr);
            if (it != g_cbClicked.end()) it->second(checked ? 1 : 0);
        });
    }
}

// ============================================================
// QRadioButton 补充 API
// ============================================================

int32_t qRadioButtonIsAutoExclusive(int64_t ptr) {
    QRadioButton* btn = reinterpret_cast<QRadioButton*>(ptr);
    return btn ? (btn->autoExclusive() ? 1 : 0) : 0;
}

void qRadioButtonSetAutoExclusive(int64_t ptr, int32_t v) {
    QRadioButton* btn = reinterpret_cast<QRadioButton*>(ptr);
    if (btn) btn->setAutoExclusive(v != 0);
}

// QRadioButton clicked(bool) 信号回调映射
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_rbClicked;

void qRadioButtonConnectClicked(int64_t ptr, void (*cb)(int32_t)) {
    QRadioButton* btn = reinterpret_cast<QRadioButton*>(ptr);
    if (btn && cb && g_rbClicked.find(ptr) == g_rbClicked.end()) {
        g_rbClicked[ptr] = [cb](int32_t v) { cb(v); };
        QObject::connect(btn, &QRadioButton::clicked, [ptr](bool checked) {
            auto it = g_rbClicked.find(ptr);
            if (it != g_rbClicked.end()) it->second(checked ? 1 : 0);
        });
    }
}

// wcore 模块统一信号回调清理：对象 delete 后残留的条目会让 connect 去重
// 保护（find != end 跳过注册）误判，复用同一地址的新对象 connect 被跳过、
// 回调永不触发。由 qCheckBoxDelete/qRadioButtonDelete 调用。
// （QPushButton/QToolButton 的 ExtSlot 映射为替换式连接，先 disconnect 后覆盖，
//   不存在去重守卫问题，无需在此清理。）
void qWcoreSignalCleanup(int64_t ptr) {
    g_cbClicked.erase(ptr);
    g_rbClicked.erase(ptr);
}

// 测试专用内省：查询 ptr 是否仍注册在任一 wcore 去重守卫回调 map 中。
int32_t qWcoreSignalRegistered(int64_t ptr) {
    return (g_cbClicked.find(ptr) != g_cbClicked.end() ||
            g_rbClicked.find(ptr) != g_rbClicked.end()) ? 1 : 0;
}

} // extern "C"
