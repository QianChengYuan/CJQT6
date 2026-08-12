/**
 * @file bridge_ext_wselect.cpp
 * @brief v1.2.0 API 补全扩展 - 由子代理/脚本填充。
 * 该文件补充 wselect 批次控件的桥接函数，遵循 bridge_ext_new.cpp 的既有风格：
 *   - 入参 ptr 做空指针校验；
 *   - 字符串返回使用 static 缓冲区 + toUtf8().constData()；
 *   - 信号通过 std::unordered_map 注册回调，connect 前做去重保护。
 */
#include <QWidget>
#include <QComboBox>
#include <QFontComboBox>
#include <QCompleter>
#include <QKeySequence>
#include <QKeySequenceEdit>
#include <QAbstractItemModel>
#include <QVariant>
#include <QString>
#include <functional>
#include <unordered_map>

extern "C" {

// ============================================================
// QComboBox 补充 API
// ============================================================

int32_t qComboBoxIsEditable(int64_t ptr) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    return w ? (w->isEditable() ? 1 : 0) : 0;
}

void qComboBoxSetInsertPolicy(int64_t ptr, int32_t policy) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    if (w) w->setInsertPolicy(static_cast<QComboBox::InsertPolicy>(policy));
}

int32_t qComboBoxInsertPolicy(int64_t ptr) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    return w ? static_cast<int32_t>(w->insertPolicy()) : 0;
}

void qComboBoxSetMaxVisibleItems(int64_t ptr, int32_t v) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    if (w) w->setMaxVisibleItems(v);
}

int32_t qComboBoxMaxVisibleItems(int64_t ptr) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    return w ? static_cast<int32_t>(w->maxVisibleItems()) : 0;
}

void qComboBoxSetMaxCount(int64_t ptr, int32_t v) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    if (w) w->setMaxCount(v);
}

int32_t qComboBoxMaxCount(int64_t ptr) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    return w ? static_cast<int32_t>(w->maxCount()) : 0;
}

void qComboBoxSetFrame(int64_t ptr, int32_t v) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    if (w) w->setFrame(v != 0);
}

int32_t qComboBoxHasFrame(int64_t ptr) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    return w ? (w->hasFrame() ? 1 : 0) : 0;
}

void qComboBoxSetDuplicatesEnabled(int64_t ptr, int32_t v) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    if (w) w->setDuplicatesEnabled(v != 0);
}

void qComboBoxSetCurrentData(int64_t ptr, int64_t value) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    if (w) {
        QVariant v = QVariant::fromValue<qlonglong>(value);
        int idx = w->findData(v);
        if (idx >= 0) w->setCurrentIndex(idx);
    }
}

void qComboBoxSetCompleter(int64_t ptr, int64_t completerPtr) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    QCompleter* c = reinterpret_cast<QCompleter*>(completerPtr);
    if (w) w->setCompleter(c);
}

void qComboBoxSetSizeAdjustPolicy(int64_t ptr, int32_t policy) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    if (w) w->setSizeAdjustPolicy(static_cast<QComboBox::SizeAdjustPolicy>(policy));
}

// QComboBox 信号回调映射
static std::unordered_map<int64_t, std::function<void(const char*)>> g_cbEditTextChanged;
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_cbActivated;
static std::unordered_map<int64_t, std::function<void(int32_t)>> g_cbHighlighted;

void qComboBoxConnectEditTextChanged(int64_t ptr, void (*cb)(const char*)) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    if (w && cb && g_cbEditTextChanged.find(ptr) == g_cbEditTextChanged.end()) {
        g_cbEditTextChanged[ptr] = [cb](const char* s) { cb(s); };
        QObject::connect(w, &QComboBox::editTextChanged, [ptr](const QString& text) {
            auto it = g_cbEditTextChanged.find(ptr);
            if (it != g_cbEditTextChanged.end()) {
                static QString buf;
                buf = text;
                it->second(buf.toUtf8().constData());
            }
        });
    }
}

void qComboBoxConnectActivated(int64_t ptr, void (*cb)(int32_t)) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    if (w && cb && g_cbActivated.find(ptr) == g_cbActivated.end()) {
        g_cbActivated[ptr] = [cb](int32_t idx) { cb(idx); };
        QObject::connect(w, &QComboBox::activated, [ptr](int index) {
            auto it = g_cbActivated.find(ptr);
            if (it != g_cbActivated.end()) it->second(static_cast<int32_t>(index));
        });
    }
}

void qComboBoxConnectHighlighted(int64_t ptr, void (*cb)(int32_t)) {
    QComboBox* w = reinterpret_cast<QComboBox*>(ptr);
    if (w && cb && g_cbHighlighted.find(ptr) == g_cbHighlighted.end()) {
        g_cbHighlighted[ptr] = [cb](int32_t idx) { cb(idx); };
        QObject::connect(w, &QComboBox::highlighted, [ptr](int index) {
            auto it = g_cbHighlighted.find(ptr);
            if (it != g_cbHighlighted.end()) it->second(static_cast<int32_t>(index));
        });
    }
}

// ============================================================
// QFontComboBox 补充 API（setWritingSystem / setFontFilters 已在 bridge_widgets.cpp 定义）
// ============================================================

int32_t qFontComboBoxWritingSystem(int64_t ptr) {
    QFontComboBox* w = reinterpret_cast<QFontComboBox*>(ptr);
    return w ? static_cast<int32_t>(w->writingSystem()) : 0;
}

int32_t qFontComboBoxFontFilters(int64_t ptr) {
    QFontComboBox* w = reinterpret_cast<QFontComboBox*>(ptr);
    return w ? static_cast<int32_t>(w->fontFilters()) : 0;
}

// ============================================================
// QCompleter 补充 API
// ============================================================

int32_t qCompleterCaseSensitivity(int64_t ptr) {
    QCompleter* w = reinterpret_cast<QCompleter*>(ptr);
    return w ? static_cast<int32_t>(w->caseSensitivity()) : 0;
}

int32_t qCompleterCompletionMode(int64_t ptr) {
    QCompleter* w = reinterpret_cast<QCompleter*>(ptr);
    return w ? static_cast<int32_t>(w->completionMode()) : 0;
}

void qCompleterSetModelSorting(int64_t ptr, int32_t sorting) {
    QCompleter* w = reinterpret_cast<QCompleter*>(ptr);
    if (w) w->setModelSorting(static_cast<QCompleter::ModelSorting>(sorting));
}

void qCompleterSetCompletionColumn(int64_t ptr, int32_t column) {
    QCompleter* w = reinterpret_cast<QCompleter*>(ptr);
    if (w) w->setCompletionColumn(column);
}

void qCompleterSetCompletionRole(int64_t ptr, int32_t role) {
    QCompleter* w = reinterpret_cast<QCompleter*>(ptr);
    if (w) w->setCompletionRole(role);
}

// ============================================================
// QKeySequenceEdit 补充 API（create/keySequence/setKeySequence/clear 已在 bridge_widgets.cpp 定义）
// ============================================================

static std::unordered_map<int64_t, std::function<void(const char*)>> g_kseChanged;

void qKeySequenceEditConnectKeySequenceChanged(int64_t ptr, void (*cb)(const char*)) {
    QKeySequenceEdit* w = reinterpret_cast<QKeySequenceEdit*>(ptr);
    if (w && cb && g_kseChanged.find(ptr) == g_kseChanged.end()) {
        g_kseChanged[ptr] = [cb](const char* s) { cb(s); };
        QObject::connect(w, &QKeySequenceEdit::keySequenceChanged, [ptr](const QKeySequence& seq) {
            auto it = g_kseChanged.find(ptr);
            if (it != g_kseChanged.end()) {
                static QString buf;
                buf = seq.toString(QKeySequence::NativeText);
                it->second(buf.toUtf8().constData());
            }
        });
    }
}

// 选择控件模块统一信号回调清理：对象 delete 后残留的条目会让 connect 去重
// 保护（find != end 跳过注册）误判，复用同一地址的新对象 connect 被跳过、
// 回调永不触发。由 qComboBoxDelete/qFontComboBoxDelete/qKeySequenceEditDelete 调用。
void qWselectSignalCleanup(int64_t ptr) {
    g_cbEditTextChanged.erase(ptr);
    g_cbActivated.erase(ptr);
    g_cbHighlighted.erase(ptr);
    g_kseChanged.erase(ptr);
}

// 测试专用内省：查询 ptr 是否仍注册在任一选择控件信号回调 map 中。
int32_t qWselectSignalRegistered(int64_t ptr) {
    return (g_cbEditTextChanged.find(ptr) != g_cbEditTextChanged.end() ||
            g_cbActivated.find(ptr) != g_cbActivated.end() ||
            g_cbHighlighted.find(ptr) != g_cbHighlighted.end() ||
            g_kseChanged.find(ptr) != g_kseChanged.end()) ? 1 : 0;
}

} // extern "C"
