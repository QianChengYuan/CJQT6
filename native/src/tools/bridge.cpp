#include <QApplication>
#include <QWidget>
#include <QLabel>
#include <QPushButton>
#include <QTimer>
#include <QLineEdit>
#include <QTextEdit>
#include <QCheckBox>
#include <QRadioButton>
#include <QSpinBox>
#include <QSlider>
#include <QComboBox>
#include <QProgressBar>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QGridLayout>
#include <QMessageBox>
#include <QFileDialog>
#include <QGroupBox>
#include <QTabWidget>
#include <QScrollArea>
#include <QFrame>
#include <QTableWidget>
#include <QTableWidgetItem>
#include <QHeaderView>
#include <QDebug>
#include <functional>
#include <unordered_map>

// 全局应用程序指针
static QApplication* g_app = nullptr;

// 回调函数映射
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_buttonCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_timerCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_lineEditCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_spinBoxCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_sliderCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_comboBoxCallbacks;

extern "C" {

// ============================================================
// QApplication 桥接函数
// ============================================================

int64_t qApplicationCreate() {
    if (!g_app) {
        int argc = 0;
        g_app = new QApplication(argc, nullptr);
    }
    return reinterpret_cast<int64_t>(g_app);
}

int32_t qApplicationExec() {
    if (g_app) {
        return g_app->exec();
    }
    return -1;
}

void qApplicationQuit() {
    if (g_app) {
        g_app->quit();
    }
}

void qApplicationDelete(int64_t ptr) {
    // 不删除全局 QApplication
}

// ============================================================
// QWidget 桥接函数
// ============================================================

int64_t qWidgetCreate() {
    QWidget* widget = new QWidget();
    return reinterpret_cast<int64_t>(widget);
}

void qWidgetShow(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->show();
    }
}

void qWidgetHide(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->hide();
    }
}

void qWidgetSetTitle(int64_t ptr, const char* title) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setWindowTitle(title);
    }
}

void qWidgetResize(int64_t ptr, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->resize(width, height);
    }
}

void qWidgetSetGeometry(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setGeometry(x, y, width, height);
    }
}

void qWidgetDelete(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        delete widget;
    }
}

// ============================================================
// QLabel 桥接函数
// ============================================================

int64_t qLabelCreate() {
    QLabel* label = new QLabel();
    return reinterpret_cast<int64_t>(label);
}

void qLabelSetText(int64_t ptr, const char* text) {
    QLabel* label = reinterpret_cast<QLabel*>(ptr);
    if (label) {
        label->setText(text);
    }
}

void qLabelSetAlignment(int64_t ptr, int32_t alignment) {
    QLabel* label = reinterpret_cast<QLabel*>(ptr);
    if (label) {
        label->setAlignment(static_cast<Qt::AlignmentFlag>(alignment));
    }
}

void qLabelDelete(int64_t ptr) {
    QLabel* label = reinterpret_cast<QLabel*>(ptr);
    if (label) {
        delete label;
    }
}

// ============================================================
// QPushButton 桥接函数
// ============================================================

int64_t qButtonCreate() {
    QPushButton* button = new QPushButton();
    return reinterpret_cast<int64_t>(button);
}

void qButtonSetText(int64_t ptr, const char* text) {
    QPushButton* button = reinterpret_cast<QPushButton*>(ptr);
    if (button) {
        button->setText(text);
    }
}

void qButtonSetOnClick(int64_t ptr, void (*callback)(int64_t)) {
    QPushButton* button = reinterpret_cast<QPushButton*>(ptr);
    if (button) {
        int64_t widgetPtr = ptr;
        g_buttonCallbacks[ptr] = [callback, widgetPtr](int64_t) { callback(widgetPtr); };
        QObject::connect(button, &QPushButton::clicked, [widgetPtr]() {
            auto it = g_buttonCallbacks.find(widgetPtr);
            if (it != g_buttonCallbacks.end()) {
                it->second(widgetPtr);
            }
        });
    }
}

void qButtonDelete(int64_t ptr) {
    QPushButton* button = reinterpret_cast<QPushButton*>(ptr);
    if (button) {
        g_buttonCallbacks.erase(ptr);
        delete button;
    }
}

// ============================================================
// QTimer 桥接函数
// ============================================================

int64_t qTimerCreate() {
    QTimer* timer = new QTimer();
    return reinterpret_cast<int64_t>(timer);
}

void qTimerSetInterval(int64_t ptr, int32_t interval) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        timer->setInterval(interval);
    }
}

void qTimerStart(int64_t ptr) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        timer->start();
    }
}

void qTimerStop(int64_t ptr) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        timer->stop();
    }
}

void qTimerSetTimeout(int64_t ptr, void (*callback)(int64_t)) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        int64_t timerPtr = ptr;
        g_timerCallbacks[ptr] = [callback, timerPtr](int64_t) { callback(timerPtr); };
        QObject::connect(timer, &QTimer::timeout, [timerPtr]() {
            auto it = g_timerCallbacks.find(timerPtr);
            if (it != g_timerCallbacks.end()) {
                it->second(timerPtr);
            }
        });
    }
}

void qTimerDelete(int64_t ptr) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        g_timerCallbacks.erase(ptr);
        delete timer;
    }
}

// ==================== QLineEdit ====================
int64_t qLineEditCreate() {
    QLineEdit* lineEdit = new QLineEdit();
    return reinterpret_cast<int64_t>(lineEdit);
}

void qLineEditSetText(int64_t ptr, const char* text) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->setText(QString::fromUtf8(text));
    }
}

const char* qLineEditText(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        static QString text;
        text = lineEdit->text();
        return text.toUtf8().constData();
    }
    return "";
}

void qLineEditSetPlaceholder(int64_t ptr, const char* text) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->setPlaceholderText(QString::fromUtf8(text));
    }
}

void qLineEditSetMaxLength(int64_t ptr, int32_t length) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->setMaxLength(length);
    }
}

void qLineEditSetReadOnly(int64_t ptr, bool readonly) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->setReadOnly(readonly);
    }
}

void qLineEditSetEchoMode(int64_t ptr, int32_t mode) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->setEchoMode(static_cast<QLineEdit::EchoMode>(mode));
    }
}

void qLineEditClear(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        lineEdit->clear();
    }
}

void qLineEditSetOnTextChanged(int64_t ptr, void (*callback)(int64_t)) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        int64_t widgetPtr = ptr;
        g_lineEditCallbacks[ptr] = [callback, widgetPtr](int64_t) { callback(widgetPtr); };
        QObject::connect(lineEdit, &QLineEdit::textChanged, [widgetPtr](const QString&) {
            auto it = g_lineEditCallbacks.find(widgetPtr);
            if (it != g_lineEditCallbacks.end()) {
                it->second(widgetPtr);
            }
        });
    }
}

void qLineEditDelete(int64_t ptr) {
    QLineEdit* lineEdit = reinterpret_cast<QLineEdit*>(ptr);
    if (lineEdit) {
        delete lineEdit;
    }
}

// ==================== QTextEdit ====================
int64_t qTextEditCreate() {
    QTextEdit* textEdit = new QTextEdit();
    return reinterpret_cast<int64_t>(textEdit);
}

void qTextEditSetText(int64_t ptr, const char* text) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        textEdit->setText(QString::fromUtf8(text));
    }
}

const char* qTextEditText(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        static QString text;
        text = textEdit->toPlainText();
        return text.toUtf8().constData();
    }
    return "";
}

void qTextEditSetReadOnly(int64_t ptr, bool readonly) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        textEdit->setReadOnly(readonly);
    }
}

void qTextEditClear(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        textEdit->clear();
    }
}

void qTextEditDelete(int64_t ptr) {
    QTextEdit* textEdit = reinterpret_cast<QTextEdit*>(ptr);
    if (textEdit) {
        delete textEdit;
    }
}

// ==================== QCheckBox ====================
int64_t qCheckBoxCreate() {
    QCheckBox* checkBox = new QCheckBox();
    return reinterpret_cast<int64_t>(checkBox);
}

void qCheckBoxSetText(int64_t ptr, const char* text) {
    QCheckBox* checkBox = reinterpret_cast<QCheckBox*>(ptr);
    if (checkBox) {
        checkBox->setText(QString::fromUtf8(text));
    }
}

void qCheckBoxSetChecked(int64_t ptr, bool checked) {
    QCheckBox* checkBox = reinterpret_cast<QCheckBox*>(ptr);
    if (checkBox) {
        checkBox->setChecked(checked);
    }
}

bool qCheckBoxIsChecked(int64_t ptr) {
    QCheckBox* checkBox = reinterpret_cast<QCheckBox*>(ptr);
    if (checkBox) {
        return checkBox->isChecked();
    }
    return false;
}

void qCheckBoxDelete(int64_t ptr) {
    QCheckBox* checkBox = reinterpret_cast<QCheckBox*>(ptr);
    if (checkBox) {
        delete checkBox;
    }
}

// ==================== QRadioButton ====================
int64_t qRadioButtonCreate() {
    QRadioButton* radioButton = new QRadioButton();
    return reinterpret_cast<int64_t>(radioButton);
}

void qRadioButtonSetText(int64_t ptr, const char* text) {
    QRadioButton* radioButton = reinterpret_cast<QRadioButton*>(ptr);
    if (radioButton) {
        radioButton->setText(QString::fromUtf8(text));
    }
}

void qRadioButtonSetChecked(int64_t ptr, bool checked) {
    QRadioButton* radioButton = reinterpret_cast<QRadioButton*>(ptr);
    if (radioButton) {
        radioButton->setChecked(checked);
    }
}

bool qRadioButtonIsChecked(int64_t ptr) {
    QRadioButton* radioButton = reinterpret_cast<QRadioButton*>(ptr);
    if (radioButton) {
        return radioButton->isChecked();
    }
    return false;
}

void qRadioButtonDelete(int64_t ptr) {
    QRadioButton* radioButton = reinterpret_cast<QRadioButton*>(ptr);
    if (radioButton) {
        delete radioButton;
    }
}

// ==================== QSpinBox ====================
int64_t qSpinBoxCreate() {
    QSpinBox* spinBox = new QSpinBox();
    return reinterpret_cast<int64_t>(spinBox);
}

void qSpinBoxSetValue(int64_t ptr, int32_t value) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox) {
        spinBox->setValue(value);
    }
}

int32_t qSpinBoxValue(int64_t ptr) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox) {
        return spinBox->value();
    }
    return 0;
}

void qSpinBoxSetRange(int64_t ptr, int32_t min, int32_t max) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox) {
        spinBox->setRange(min, max);
    }
}

void qSpinBoxSetSingleStep(int64_t ptr, int32_t step) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox) {
        spinBox->setSingleStep(step);
    }
}

void qSpinBoxSetOnValueChanged(int64_t ptr, void (*callback)(int64_t)) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox) {
        int64_t widgetPtr = ptr;
        g_spinBoxCallbacks[ptr] = [callback, widgetPtr](int64_t) { callback(widgetPtr); };
        QObject::connect(spinBox, QOverload<int>::of(&QSpinBox::valueChanged), [widgetPtr](int) {
            auto it = g_spinBoxCallbacks.find(widgetPtr);
            if (it != g_spinBoxCallbacks.end()) {
                it->second(widgetPtr);
            }
        });
    }
}

void qSpinBoxDelete(int64_t ptr) {
    QSpinBox* spinBox = reinterpret_cast<QSpinBox*>(ptr);
    if (spinBox) {
        delete spinBox;
    }
}

// ==================== QSlider ====================
int64_t qSliderCreate() {
    QSlider* slider = new QSlider();
    return reinterpret_cast<int64_t>(slider);
}

void qSliderSetValue(int64_t ptr, int32_t value) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        slider->setValue(value);
    }
}

int32_t qSliderValue(int64_t ptr) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        return slider->value();
    }
    return 0;
}

void qSliderSetRange(int64_t ptr, int32_t min, int32_t max) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        slider->setRange(min, max);
    }
}

void qSliderSetOrientation(int64_t ptr, int32_t orientation) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        slider->setOrientation(static_cast<Qt::Orientation>(orientation));
    }
}

void qSliderSetOnValueChanged(int64_t ptr, void (*callback)(int64_t)) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        int64_t widgetPtr = ptr;
        g_sliderCallbacks[ptr] = [callback, widgetPtr](int64_t) { callback(widgetPtr); };
        QObject::connect(slider, &QSlider::valueChanged, [widgetPtr](int) {
            auto it = g_sliderCallbacks.find(widgetPtr);
            if (it != g_sliderCallbacks.end()) {
                it->second(widgetPtr);
            }
        });
    }
}

void qSliderDelete(int64_t ptr) {
    QSlider* slider = reinterpret_cast<QSlider*>(ptr);
    if (slider) {
        delete slider;
    }
}

// ==================== QComboBox ====================
int64_t qComboBoxCreate() {
    QComboBox* comboBox = new QComboBox();
    return reinterpret_cast<int64_t>(comboBox);
}

void qComboBoxAddItem(int64_t ptr, const char* text) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox) {
        comboBox->addItem(QString::fromUtf8(text));
    }
}

const char* qComboBoxCurrentText(int64_t ptr) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox) {
        static QString text;
        text = comboBox->currentText();
        return text.toUtf8().constData();
    }
    return "";
}

void qComboBoxSetCurrentIndex(int64_t ptr, int32_t index) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox) {
        comboBox->setCurrentIndex(index);
    }
}

int32_t qComboBoxCurrentIndex(int64_t ptr) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox) {
        return comboBox->currentIndex();
    }
    return -1;
}

void qComboBoxClear(int64_t ptr) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox) {
        comboBox->clear();
    }
}

void qComboBoxDelete(int64_t ptr) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox) {
        delete comboBox;
    }
}

// ==================== QProgressBar ====================
int64_t qProgressBarCreate() {
    QProgressBar* progressBar = new QProgressBar();
    return reinterpret_cast<int64_t>(progressBar);
}

void qProgressBarSetValue(int64_t ptr, int32_t value) {
    QProgressBar* progressBar = reinterpret_cast<QProgressBar*>(ptr);
    if (progressBar) {
        progressBar->setValue(value);
    }
}

int32_t qProgressBarValue(int64_t ptr) {
    QProgressBar* progressBar = reinterpret_cast<QProgressBar*>(ptr);
    if (progressBar) {
        return progressBar->value();
    }
    return 0;
}

void qProgressBarSetRange(int64_t ptr, int32_t min, int32_t max) {
    QProgressBar* progressBar = reinterpret_cast<QProgressBar*>(ptr);
    if (progressBar) {
        progressBar->setRange(min, max);
    }
}

void qProgressBarSetTextVisible(int64_t ptr, bool visible) {
    QProgressBar* progressBar = reinterpret_cast<QProgressBar*>(ptr);
    if (progressBar) {
        progressBar->setTextVisible(visible);
    }
}

void qProgressBarDelete(int64_t ptr) {
    QProgressBar* progressBar = reinterpret_cast<QProgressBar*>(ptr);
    if (progressBar) {
        delete progressBar;
    }
}

// ============================================================
// 布局管理 桥接函数
// ============================================================

// ==================== QVBoxLayout ====================
int64_t qVBoxLayoutCreate() {
    QVBoxLayout* layout = new QVBoxLayout();
    return reinterpret_cast<int64_t>(layout);
}

void qVBoxLayoutAddWidget(int64_t layoutPtr, int64_t widgetPtr) {
    QVBoxLayout* layout = reinterpret_cast<QVBoxLayout*>(layoutPtr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (layout && widget) {
        layout->addWidget(widget);
    }
}

void qVBoxLayoutAddLayout(int64_t layoutPtr, int64_t childLayoutPtr) {
    QVBoxLayout* layout = reinterpret_cast<QVBoxLayout*>(layoutPtr);
    QLayout* childLayout = reinterpret_cast<QLayout*>(childLayoutPtr);
    if (layout && childLayout) {
        layout->addLayout(childLayout);
    }
}

void qVBoxLayoutAddStretch(int64_t ptr) {
    QVBoxLayout* layout = reinterpret_cast<QVBoxLayout*>(ptr);
    if (layout) {
        layout->addStretch();
    }
}

void qVBoxLayoutSetSpacing(int64_t ptr, int32_t spacing) {
    QVBoxLayout* layout = reinterpret_cast<QVBoxLayout*>(ptr);
    if (layout) {
        layout->setSpacing(spacing);
    }
}

void qVBoxLayoutSetMargin(int64_t ptr, int32_t margin) {
    QVBoxLayout* layout = reinterpret_cast<QVBoxLayout*>(ptr);
    if (layout) {
        layout->setContentsMargins(margin, margin, margin, margin);
    }
}

void qVBoxLayoutDelete(int64_t ptr) {
    QVBoxLayout* layout = reinterpret_cast<QVBoxLayout*>(ptr);
    if (layout) {
        delete layout;
    }
}

// ==================== QHBoxLayout ====================
int64_t qHBoxLayoutCreate() {
    QHBoxLayout* layout = new QHBoxLayout();
    return reinterpret_cast<int64_t>(layout);
}

void qHBoxLayoutAddWidget(int64_t layoutPtr, int64_t widgetPtr) {
    QHBoxLayout* layout = reinterpret_cast<QHBoxLayout*>(layoutPtr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (layout && widget) {
        layout->addWidget(widget);
    }
}

void qHBoxLayoutAddLayout(int64_t layoutPtr, int64_t childLayoutPtr) {
    QHBoxLayout* layout = reinterpret_cast<QHBoxLayout*>(layoutPtr);
    QLayout* childLayout = reinterpret_cast<QLayout*>(childLayoutPtr);
    if (layout && childLayout) {
        layout->addLayout(childLayout);
    }
}

void qHBoxLayoutAddStretch(int64_t ptr) {
    QHBoxLayout* layout = reinterpret_cast<QHBoxLayout*>(ptr);
    if (layout) {
        layout->addStretch();
    }
}

void qHBoxLayoutSetSpacing(int64_t ptr, int32_t spacing) {
    QHBoxLayout* layout = reinterpret_cast<QHBoxLayout*>(ptr);
    if (layout) {
        layout->setSpacing(spacing);
    }
}

void qHBoxLayoutSetMargin(int64_t ptr, int32_t margin) {
    QHBoxLayout* layout = reinterpret_cast<QHBoxLayout*>(ptr);
    if (layout) {
        layout->setContentsMargins(margin, margin, margin, margin);
    }
}

void qHBoxLayoutDelete(int64_t ptr) {
    QHBoxLayout* layout = reinterpret_cast<QHBoxLayout*>(ptr);
    if (layout) {
        delete layout;
    }
}

// ==================== QGridLayout ====================
int64_t qGridLayoutCreate() {
    QGridLayout* layout = new QGridLayout();
    return reinterpret_cast<int64_t>(layout);
}

void qGridLayoutAddWidget(int64_t layoutPtr, int64_t widgetPtr, int32_t row, int32_t col) {
    QGridLayout* layout = reinterpret_cast<QGridLayout*>(layoutPtr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (layout && widget) {
        layout->addWidget(widget, row, col);
    }
}

void qGridLayoutAddWidgetSpan(int64_t layoutPtr, int64_t widgetPtr, int32_t row, int32_t col, int32_t rowSpan, int32_t colSpan) {
    QGridLayout* layout = reinterpret_cast<QGridLayout*>(layoutPtr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (layout && widget) {
        layout->addWidget(widget, row, col, rowSpan, colSpan);
    }
}

void qGridLayoutSetSpacing(int64_t ptr, int32_t spacing) {
    QGridLayout* layout = reinterpret_cast<QGridLayout*>(ptr);
    if (layout) {
        layout->setSpacing(spacing);
    }
}

void qGridLayoutSetMargin(int64_t ptr, int32_t margin) {
    QGridLayout* layout = reinterpret_cast<QGridLayout*>(ptr);
    if (layout) {
        layout->setContentsMargins(margin, margin, margin, margin);
    }
}

void qGridLayoutDelete(int64_t ptr) {
    QGridLayout* layout = reinterpret_cast<QGridLayout*>(ptr);
    if (layout) {
        delete layout;
    }
}

// ==================== QWidget布局设置 ====================
void qWidgetSetLayout(int64_t widgetPtr, int64_t layoutPtr) {
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    QLayout* layout = reinterpret_cast<QLayout*>(layoutPtr);
    if (widget && layout) {
        widget->setLayout(layout);
    }
}

// ============================================================
// 对话框 桥接函数
// ============================================================

// ==================== QMessageBox ====================
void qMessageBoxInformation(int64_t parentPtr, const char* title, const char* text) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QMessageBox::information(parent, QString::fromUtf8(title), QString::fromUtf8(text));
}

void qMessageBoxWarning(int64_t parentPtr, const char* title, const char* text) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QMessageBox::warning(parent, QString::fromUtf8(title), QString::fromUtf8(text));
}

void qMessageBoxCritical(int64_t parentPtr, const char* title, const char* text) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    QMessageBox::critical(parent, QString::fromUtf8(title), QString::fromUtf8(text));
}

int32_t qMessageBoxQuestion(int64_t parentPtr, const char* title, const char* text) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    return QMessageBox::question(parent, QString::fromUtf8(title), QString::fromUtf8(text),
                                  QMessageBox::Yes | QMessageBox::No) == QMessageBox::Yes ? 1 : 0;
}

// ==================== QFileDialog ====================
const char* qFileDialogGetOpenFileName(int64_t parentPtr, const char* title, const char* filter) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    static QString result;
    result = QFileDialog::getOpenFileName(parent, QString::fromUtf8(title), QString(), QString::fromUtf8(filter));
    return result.toUtf8().constData();
}

const char* qFileDialogGetSaveFileName(int64_t parentPtr, const char* title, const char* filter) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    static QString result;
    result = QFileDialog::getSaveFileName(parent, QString::fromUtf8(title), QString(), QString::fromUtf8(filter));
    return result.toUtf8().constData();
}

const char* qFileDialogGetExistingDirectory(int64_t parentPtr, const char* title) {
    QWidget* parent = reinterpret_cast<QWidget*>(parentPtr);
    static QString result;
    result = QFileDialog::getExistingDirectory(parent, QString::fromUtf8(title));
    return result.toUtf8().constData();
}

// ============================================================
// 容器控件 桥接函数
// ============================================================

// ==================== QGroupBox ====================
int64_t qGroupBoxCreate() {
    QGroupBox* groupBox = new QGroupBox();
    return reinterpret_cast<int64_t>(groupBox);
}

void qGroupBoxSetTitle(int64_t ptr, const char* title) {
    QGroupBox* groupBox = reinterpret_cast<QGroupBox*>(ptr);
    if (groupBox) {
        groupBox->setTitle(QString::fromUtf8(title));
    }
}

const char* qGroupBoxTitle(int64_t ptr) {
    QGroupBox* groupBox = reinterpret_cast<QGroupBox*>(ptr);
    if (groupBox) {
        static QString title;
        title = groupBox->title();
        return title.toUtf8().constData();
    }
    return "";
}

void qGroupBoxSetCheckable(int64_t ptr, bool checkable) {
    QGroupBox* groupBox = reinterpret_cast<QGroupBox*>(ptr);
    if (groupBox) {
        groupBox->setCheckable(checkable);
    }
}

bool qGroupBoxIsCheckable(int64_t ptr) {
    QGroupBox* groupBox = reinterpret_cast<QGroupBox*>(ptr);
    if (groupBox) {
        return groupBox->isCheckable();
    }
    return false;
}

void qGroupBoxSetChecked(int64_t ptr, bool checked) {
    QGroupBox* groupBox = reinterpret_cast<QGroupBox*>(ptr);
    if (groupBox) {
        groupBox->setChecked(checked);
    }
}

bool qGroupBoxIsChecked(int64_t ptr) {
    QGroupBox* groupBox = reinterpret_cast<QGroupBox*>(ptr);
    if (groupBox) {
        return groupBox->isChecked();
    }
    return false;
}

void qGroupBoxDelete(int64_t ptr) {
    QGroupBox* groupBox = reinterpret_cast<QGroupBox*>(ptr);
    if (groupBox) {
        delete groupBox;
    }
}

// ==================== QTabWidget ====================
int64_t qTabWidgetCreate() {
    QTabWidget* tabWidget = new QTabWidget();
    return reinterpret_cast<int64_t>(tabWidget);
}

void qTabWidgetAddTab(int64_t ptr, int64_t widgetPtr, const char* title) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (tabWidget && widget) {
        tabWidget->addTab(widget, QString::fromUtf8(title));
    }
}

void qTabWidgetRemoveTab(int64_t ptr, int32_t index) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget) {
        tabWidget->removeTab(index);
    }
}

int32_t qTabWidgetCurrentIndex(int64_t ptr) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget) {
        return tabWidget->currentIndex();
    }
    return -1;
}

void qTabWidgetSetCurrentIndex(int64_t ptr, int32_t index) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget) {
        tabWidget->setCurrentIndex(index);
    }
}

int32_t qTabWidgetCount(int64_t ptr) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget) {
        return tabWidget->count();
    }
    return 0;
}

void qTabWidgetDelete(int64_t ptr) {
    QTabWidget* tabWidget = reinterpret_cast<QTabWidget*>(ptr);
    if (tabWidget) {
        delete tabWidget;
    }
}

// ==================== QScrollArea ====================
int64_t qScrollAreaCreate() {
    QScrollArea* scrollArea = new QScrollArea();
    return reinterpret_cast<int64_t>(scrollArea);
}

void qScrollAreaSetWidget(int64_t ptr, int64_t widgetPtr) {
    QScrollArea* scrollArea = reinterpret_cast<QScrollArea*>(ptr);
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    if (scrollArea && widget) {
        scrollArea->setWidget(widget);
    }
}

void qScrollAreaSetWidgetResizable(int64_t ptr, bool resizable) {
    QScrollArea* scrollArea = reinterpret_cast<QScrollArea*>(ptr);
    if (scrollArea) {
        scrollArea->setWidgetResizable(resizable);
    }
}

int64_t qScrollAreaWidget(int64_t ptr) {
    QScrollArea* scrollArea = reinterpret_cast<QScrollArea*>(ptr);
    if (scrollArea) {
        return reinterpret_cast<int64_t>(scrollArea->widget());
    }
    return 0;
}

void qScrollAreaDelete(int64_t ptr) {
    QScrollArea* scrollArea = reinterpret_cast<QScrollArea*>(ptr);
    if (scrollArea) {
        delete scrollArea;
    }
}

// ==================== QFrame ====================
int64_t qFrameCreate() {
    QFrame* frame = new QFrame();
    return reinterpret_cast<int64_t>(frame);
}

void qFrameSetFrameShape(int64_t ptr, int32_t shape) {
    QFrame* frame = reinterpret_cast<QFrame*>(ptr);
    if (frame) {
        frame->setFrameShape(static_cast<QFrame::Shape>(shape));
    }
}

void qFrameSetFrameShadow(int64_t ptr, int32_t shadow) {
    QFrame* frame = reinterpret_cast<QFrame*>(ptr);
    if (frame) {
        frame->setFrameShadow(static_cast<QFrame::Shadow>(shadow));
    }
}

void qFrameSetLineWidth(int64_t ptr, int32_t width) {
    QFrame* frame = reinterpret_cast<QFrame*>(ptr);
    if (frame) {
        frame->setLineWidth(width);
    }
}

void qFrameDelete(int64_t ptr) {
    QFrame* frame = reinterpret_cast<QFrame*>(ptr);
    if (frame) {
        delete frame;
    }
}

// ============================================================
// QTableWidget - 表格控件
// ============================================================

int64_t qTableWidgetCreate() {
    QTableWidget* table = new QTableWidget();
    return reinterpret_cast<int64_t>(table);
}

int64_t qTableWidgetCreateWithSize(int32_t rows, int32_t cols) {
    QTableWidget* table = new QTableWidget(rows, cols);
    return reinterpret_cast<int64_t>(table);
}

void qTableWidgetSetRowCount(int64_t ptr, int32_t rows) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setRowCount(rows);
    }
}

void qTableWidgetSetColumnCount(int64_t ptr, int32_t cols) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setColumnCount(cols);
    }
}

int32_t qTableWidgetRowCount(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        return table->rowCount();
    }
    return 0;
}

int32_t qTableWidgetColumnCount(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        return table->columnCount();
    }
    return 0;
}

void qTableWidgetSetHorizontalHeaderLabels(int64_t ptr, int64_t labelsPtr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    QStringList* labels = reinterpret_cast<QStringList*>(labelsPtr);
    if (table && labels) {
        table->setHorizontalHeaderLabels(*labels);
    }
}

void qTableWidgetSetVerticalHeaderLabels(int64_t ptr, int64_t labelsPtr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    QStringList* labels = reinterpret_cast<QStringList*>(labelsPtr);
    if (table && labels) {
        table->setVerticalHeaderLabels(*labels);
    }
}

void qTableWidgetSetHorizontalHeaderLabel(int64_t ptr, int32_t col, const char* label) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        QTableWidgetItem* item = new QTableWidgetItem(QString::fromUtf8(label));
        table->setHorizontalHeaderItem(col, item);
    }
}

void qTableWidgetSetVerticalHeaderLabel(int64_t ptr, int32_t row, const char* label) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        QTableWidgetItem* item = new QTableWidgetItem(QString::fromUtf8(label));
        table->setVerticalHeaderItem(row, item);
    }
}

void qTableWidgetSetItem(int64_t ptr, int32_t row, int32_t col, const char* text) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        QTableWidgetItem* item = new QTableWidgetItem(QString::fromUtf8(text));
        table->setItem(row, col, item);
    }
}

const char* qTableWidgetItemText(int64_t ptr, int32_t row, int32_t col) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        QTableWidgetItem* item = table->item(row, col);
        if (item) {
            static QString text;
            text = item->text();
            return text.toUtf8().constData();
        }
    }
    return "";
}

void qTableWidgetClear(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->clear();
    }
}

void qTableWidgetClearContents(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->clearContents();
    }
}

void qTableWidgetInsertRow(int64_t ptr, int32_t row) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->insertRow(row);
    }
}

void qTableWidgetInsertColumn(int64_t ptr, int32_t col) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->insertColumn(col);
    }
}

void qTableWidgetRemoveRow(int64_t ptr, int32_t row) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->removeRow(row);
    }
}

void qTableWidgetRemoveColumn(int64_t ptr, int32_t col) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->removeColumn(col);
    }
}

int32_t qTableWidgetCurrentRow(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        return table->currentRow();
    }
    return -1;
}

int32_t qTableWidgetCurrentColumn(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        return table->currentColumn();
    }
    return -1;
}

void qTableWidgetSetCurrentCell(int64_t ptr, int32_t row, int32_t col) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setCurrentCell(row, col);
    }
}

void qTableWidgetSetSelectionBehavior(int64_t ptr, int32_t behavior) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setSelectionBehavior(static_cast<QAbstractItemView::SelectionBehavior>(behavior));
    }
}

void qTableWidgetSetSelectionMode(int64_t ptr, int32_t mode) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setSelectionMode(static_cast<QAbstractItemView::SelectionMode>(mode));
    }
}

void qTableWidgetSetShowGrid(int64_t ptr, bool show) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setShowGrid(show);
    }
}

void qTableWidgetSetGridStyle(int64_t ptr, int32_t style) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setGridStyle(static_cast<Qt::PenStyle>(style));
    }
}

void qTableWidgetSetSortingEnabled(int64_t ptr, bool enabled) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setSortingEnabled(enabled);
    }
}

void qTableWidgetSetAlternatingRowColors(int64_t ptr, bool enabled) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setAlternatingRowColors(enabled);
    }
}

void qTableWidgetResizeColumnsToContents(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->resizeColumnsToContents();
    }
}

void qTableWidgetResizeRowsToContents(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->resizeRowsToContents();
    }
}

void qTableWidgetSetColumnWidth(int64_t ptr, int32_t col, int32_t width) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setColumnWidth(col, width);
    }
}

void qTableWidgetSetRowHeight(int64_t ptr, int32_t row, int32_t height) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->setRowHeight(row, height);
    }
}

// 水平表头拉伸模式
void qTableWidgetHorizontalHeaderSetStretchLastSection(int64_t ptr, bool stretch) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->horizontalHeader()->setStretchLastSection(stretch);
    }
}

void qTableWidgetHorizontalHeaderSetSectionResizeMode(int64_t ptr, int32_t mode) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->horizontalHeader()->setSectionResizeMode(static_cast<QHeaderView::ResizeMode>(mode));
    }
}

void qTableWidgetHorizontalHeaderSetSectionResizeModeColumn(int64_t ptr, int32_t col, int32_t mode) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->horizontalHeader()->setSectionResizeMode(col, static_cast<QHeaderView::ResizeMode>(mode));
    }
}

// 垂直表头
void qTableWidgetVerticalHeaderSetStretchLastSection(int64_t ptr, bool stretch) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->verticalHeader()->setStretchLastSection(stretch);
    }
}

void qTableWidgetVerticalHeaderSetDefaultSectionSize(int64_t ptr, int32_t size) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        table->verticalHeader()->setDefaultSectionSize(size);
    }
}

void qTableWidgetDelete(int64_t ptr) {
    QTableWidget* table = reinterpret_cast<QTableWidget*>(ptr);
    if (table) {
        delete table;
    }
}

} // extern "C"