// Widgets模块实现

// 必须在所有Qt头文件之前包含cstring
#include <cstring>

// 项目头文件
#include "widgets.h"
#include <QMessageBox>
#include <QFileDialog>
#include <QColorDialog>
#include <QInputDialog>

namespace cjqt6 {

// ============================================================
// CheckBox 实现
// ============================================================

CheckBox::CheckBox(Widget* parent) : QWidget(parent), m_checkBox(new QCheckBox()), m_layout(new QVBoxLayout(this)) {
    m_layout->setContentsMargins(0, 0, 0, 0);
    m_layout->addWidget(m_checkBox);
    connect(m_checkBox, &QCheckBox::stateChanged, this, &CheckBox::stateChangedHandler);
}

String CheckBox::text() const {
    return String(m_checkBox->text());
}

void CheckBox::setText(const String& text) {
    m_checkBox->setText(text.toQt());
}

bool CheckBox::isChecked() const {
    return m_checkBox->isChecked();
}

void CheckBox::setChecked(bool checked) {
    m_checkBox->setChecked(checked);
}

void CheckBox::stateChangedHandler(int state) {
    if (onStateChanged) {
        onStateChanged(state == Qt::Checked);
    }
}

// ============================================================
// RadioButton 实现
// ============================================================

RadioButton::RadioButton(Widget* parent) : QWidget(parent), m_radioButton(new QRadioButton()), m_layout(new QVBoxLayout(this)) {
    m_layout->setContentsMargins(0, 0, 0, 0);
    m_layout->addWidget(m_radioButton);
    connect(m_radioButton, &QRadioButton::toggled, this, &RadioButton::toggledHandler);
}

String RadioButton::text() const {
    return String(m_radioButton->text());
}

void RadioButton::setText(const String& text) {
    m_radioButton->setText(text.toQt());
}

bool RadioButton::isChecked() const {
    return m_radioButton->isChecked();
}

void RadioButton::setChecked(bool checked) {
    m_radioButton->setChecked(checked);
}

void RadioButton::toggledHandler(bool checked) {
    if (onStateChanged) {
        onStateChanged(checked);
    }
}

// ============================================================
// ComboBox 实现
// ============================================================

ComboBox::ComboBox(Widget* parent) : QWidget(parent), m_comboBox(new QComboBox()), m_layout(new QVBoxLayout(this)) {
    m_layout->setContentsMargins(0, 0, 0, 0);
    m_layout->addWidget(m_comboBox);
    connect(m_comboBox, QOverload<int>::of(&QComboBox::currentIndexChanged), this, &ComboBox::currentIndexChangedHandler);
}

void ComboBox::addItem(const String& item) {
    m_comboBox->addItem(item.toQt());
}

void ComboBox::addItems(const std::vector<String>& items) {
    for (const auto& item : items) {
        m_comboBox->addItem(item.toQt());
    }
}

void ComboBox::clear() {
    m_comboBox->clear();
}

String ComboBox::currentItem() const {
    return String(m_comboBox->currentText());
}

void ComboBox::setCurrentItem(const String& item) {
    int index = m_comboBox->findText(item.toQt());
    if (index >= 0) {
        m_comboBox->setCurrentIndex(index);
    }
}

int ComboBox::currentIndex() const {
    return m_comboBox->currentIndex();
}

void ComboBox::setCurrentIndex(int index) {
    m_comboBox->setCurrentIndex(index);
}

int ComboBox::count() const {
    return m_comboBox->count();
}

void ComboBox::currentIndexChangedHandler(int index) {
    if (onSelectionChanged) {
        onSelectionChanged(index, currentItem());
    }
}

// ============================================================
// SpinBox 实现
// ============================================================

SpinBox::SpinBox(Widget* parent) : QWidget(parent), m_spinBox(new QSpinBox()), m_layout(new QVBoxLayout(this)) {
    m_layout->setContentsMargins(0, 0, 0, 0);
    m_layout->addWidget(m_spinBox);
    connect(m_spinBox, QOverload<int>::of(&QSpinBox::valueChanged), this, &SpinBox::valueChangedHandler);
}

int SpinBox::value() const {
    return m_spinBox->value();
}

void SpinBox::setValue(int value) {
    m_spinBox->setValue(value);
}

void SpinBox::setMinimum(int min) {
    m_spinBox->setMinimum(min);
}

void SpinBox::setMaximum(int max) {
    m_spinBox->setMaximum(max);
}

void SpinBox::setRange(int min, int max) {
    m_spinBox->setRange(min, max);
}

int SpinBox::minimum() const {
    return m_spinBox->minimum();
}

int SpinBox::maximum() const {
    return m_spinBox->maximum();
}

void SpinBox::setSingleStep(int step) {
    m_spinBox->setSingleStep(step);
}

void SpinBox::valueChangedHandler(int value) {
    if (onValueChanged) {
        onValueChanged(value);
    }
}

// ============================================================
// DoubleSpinBox 实现
// ============================================================

DoubleSpinBox::DoubleSpinBox(Widget* parent) : QWidget(parent), m_spinBox(new QDoubleSpinBox()), m_layout(new QVBoxLayout(this)) {
    m_layout->setContentsMargins(0, 0, 0, 0);
    m_layout->addWidget(m_spinBox);
    connect(m_spinBox, QOverload<double>::of(&QDoubleSpinBox::valueChanged), this, &DoubleSpinBox::valueChangedHandler);
}

double DoubleSpinBox::value() const {
    return m_spinBox->value();
}

void DoubleSpinBox::setValue(double value) {
    m_spinBox->setValue(value);
}

void DoubleSpinBox::setMinimum(double min) {
    m_spinBox->setMinimum(min);
}

void DoubleSpinBox::setMaximum(double max) {
    m_spinBox->setMaximum(max);
}

void DoubleSpinBox::setRange(double min, double max) {
    m_spinBox->setRange(min, max);
}

double DoubleSpinBox::minimum() const {
    return m_spinBox->minimum();
}

double DoubleSpinBox::maximum() const {
    return m_spinBox->maximum();
}

void DoubleSpinBox::setSingleStep(double step) {
    m_spinBox->setSingleStep(step);
}

void DoubleSpinBox::setDecimals(int decimals) {
    m_spinBox->setDecimals(decimals);
}

void DoubleSpinBox::valueChangedHandler(double value) {
    if (onValueChanged) {
        onValueChanged(value);
    }
}

// ============================================================
// Slider 实现
// ============================================================

Slider::Slider(Widget* parent) : QWidget(parent), m_slider(new QSlider()), m_layout(new QVBoxLayout(this)) {
    m_layout->setContentsMargins(0, 0, 0, 0);
    m_layout->addWidget(m_slider);
    connect(m_slider, &QSlider::valueChanged, this, &Slider::valueChangedHandler);
}

int Slider::value() const {
    return m_slider->value();
}

void Slider::setValue(int value) {
    m_slider->setValue(value);
}

void Slider::setMinimum(int min) {
    m_slider->setMinimum(min);
}

void Slider::setMaximum(int max) {
    m_slider->setMaximum(max);
}

void Slider::setRange(int min, int max) {
    m_slider->setRange(min, max);
}

int Slider::minimum() const {
    return m_slider->minimum();
}

int Slider::maximum() const {
    return m_slider->maximum();
}

void Slider::setOrientation(int orientation) {
    m_slider->setOrientation(static_cast<Qt::Orientation>(orientation));
}

void Slider::valueChangedHandler(int value) {
    if (onValueChanged) {
        onValueChanged(value);
    }
}

// ============================================================
// ProgressBar 实现
// ============================================================

ProgressBar::ProgressBar(Widget* parent) : QWidget(parent), m_progressBar(new QProgressBar()), m_layout(new QVBoxLayout(this)) {
    m_layout->setContentsMargins(0, 0, 0, 0);
    m_layout->addWidget(m_progressBar);
}

int ProgressBar::value() const {
    return m_progressBar->value();
}

void ProgressBar::setValue(int value) {
    m_progressBar->setValue(value);
}

void ProgressBar::setMinimum(int min) {
    m_progressBar->setMinimum(min);
}

void ProgressBar::setMaximum(int max) {
    m_progressBar->setMaximum(max);
}

void ProgressBar::setRange(int min, int max) {
    m_progressBar->setRange(min, max);
}

int ProgressBar::minimum() const {
    return m_progressBar->minimum();
}

int ProgressBar::maximum() const {
    return m_progressBar->maximum();
}

void ProgressBar::setTextVisible(bool visible) {
    m_progressBar->setTextVisible(visible);
}

bool ProgressBar::isTextVisible() const {
    return m_progressBar->isTextVisible();
}

String ProgressBar::format() const {
    return String(m_progressBar->format());
}

void ProgressBar::setFormat(const String& format) {
    m_progressBar->setFormat(format.toQt());
}

// ============================================================
// GroupBox 实现
// ============================================================

GroupBox::GroupBox(Widget* parent) : QWidget(parent), m_groupBox(new QGroupBox()), m_layout(new QVBoxLayout(this)) {
    m_layout->setContentsMargins(0, 0, 0, 0);
    m_layout->addWidget(m_groupBox);
}

String GroupBox::title() const {
    return String(m_groupBox->title());
}

void GroupBox::setTitle(const String& title) {
    m_groupBox->setTitle(title.toQt());
}

void GroupBox::setLayout(Layout* layout) {
    if (layout) {
        m_groupBox->setLayout(layout->toQtLayout());
    }
}

void GroupBox::setCheckable(bool checkable) {
    m_groupBox->setCheckable(checkable);
}

bool GroupBox::isCheckable() const {
    return m_groupBox->isCheckable();
}

// ============================================================
// TabWidget 实现
// ============================================================

TabWidget::TabWidget(Widget* parent) : QWidget(parent), m_tabWidget(new QTabWidget()), m_layout(new QVBoxLayout(this)) {
    m_layout->setContentsMargins(0, 0, 0, 0);
    m_layout->addWidget(m_tabWidget);
    connect(m_tabWidget, &QTabWidget::currentChanged, this, &TabWidget::currentChangedHandler);
}

void TabWidget::addTab(QWidget* widget, const String& title) {
    m_tabWidget->addTab(widget, title.toQt());
}

void TabWidget::insertTab(int index, QWidget* widget, const String& title) {
    m_tabWidget->insertTab(index, widget, title.toQt());
}

void TabWidget::removeTab(int index) {
    m_tabWidget->removeTab(index);
}

int TabWidget::currentIndex() const {
    return m_tabWidget->currentIndex();
}

void TabWidget::setCurrentIndex(int index) {
    m_tabWidget->setCurrentIndex(index);
}

int TabWidget::count() const {
    return m_tabWidget->count();
}

String TabWidget::tabTitle(int index) const {
    return String(m_tabWidget->tabText(index));
}

void TabWidget::setTabTitle(int index, const String& title) {
    m_tabWidget->setTabText(index, title.toQt());
}

void TabWidget::currentChangedHandler(int index) {
    if (onTabChanged) {
        onTabChanged(index);
    }
}

// ============================================================
// Dialog 实现
// ============================================================

void Dialog::showMessage(Widget* parent, const String& title, const String& message) {
    QMessageBox::information(parent ? qobject_cast<QWidget*>(parent) : nullptr, 
                             title.toQt(), message.toQt());
}

void Dialog::showInfo(Widget* parent, const String& title, const String& message) {
    QMessageBox::information(parent ? qobject_cast<QWidget*>(parent) : nullptr,
                             title.toQt(), message.toQt());
}

void Dialog::showWarning(Widget* parent, const String& title, const String& message) {
    QMessageBox::warning(parent ? qobject_cast<QWidget*>(parent) : nullptr,
                         title.toQt(), message.toQt());
}

void Dialog::showError(Widget* parent, const String& title, const String& message) {
    QMessageBox::critical(parent ? qobject_cast<QWidget*>(parent) : nullptr,
                          title.toQt(), message.toQt());
}

bool Dialog::showQuestion(Widget* parent, const String& title, const String& message) {
    return QMessageBox::question(parent ? qobject_cast<QWidget*>(parent) : nullptr,
                                 title.toQt(), message.toQt(),
                                 QMessageBox::Yes | QMessageBox::No) == QMessageBox::Yes;
}

Option<String> Dialog::openFile(Widget* parent, const String& caption, const String& filter) {
    QString result = QFileDialog::getOpenFileName(
        parent ? qobject_cast<QWidget*>(parent) : nullptr,
        caption.toQt(),
        QString(),
        filter.toQt()
    );
    if (result.isEmpty()) {
        return Option<String>();
    }
    return Option<String>(String(result));
}

Option<String> Dialog::saveFile(Widget* parent, const String& caption, const String& filter) {
    QString result = QFileDialog::getSaveFileName(
        parent ? qobject_cast<QWidget*>(parent) : nullptr,
        caption.toQt(),
        QString(),
        filter.toQt()
    );
    if (result.isEmpty()) {
        return Option<String>();
    }
    return Option<String>(String(result));
}

std::vector<String> Dialog::openFiles(Widget* parent, const String& caption, const String& filter) {
    QStringList results = QFileDialog::getOpenFileNames(
        parent ? qobject_cast<QWidget*>(parent) : nullptr,
        caption.toQt(),
        QString(),
        filter.toQt()
    );
    std::vector<String> files;
    files.reserve(results.size());
    for (const auto& file : results) {
        files.emplace_back(file);
    }
    return files;
}

Option<String> Dialog::getText(Widget* parent, const String& title, const String& label, const String& text) {
    bool ok;
    QString result = QInputDialog::getText(
        parent ? qobject_cast<QWidget*>(parent) : nullptr,
        title.toQt(),
        label.toQt(),
        QLineEdit::Normal,
        text.toQt(),
        &ok
    );
    if (!ok || result.isEmpty()) {
        return Option<String>();
    }
    return Option<String>(String(result));
}

Option<int> Dialog::getInt(Widget* parent, const String& title, const String& label, int value, int min, int max) {
    bool ok;
    int result = QInputDialog::getInt(
        parent ? qobject_cast<QWidget*>(parent) : nullptr,
        title.toQt(),
        label.toQt(),
        value,
        min,
        max,
        1,
        &ok
    );
    if (!ok) {
        return Option<int>();
    }
    return Option<int>(result);
}

// ============================================================
// Color 实现
// ============================================================

Option<String> Color::select(Widget* parent, const String& title) {
    QColor result = QColorDialog::getColor(
        Qt::white,
        parent ? qobject_cast<QWidget*>(parent) : nullptr,
        title.toQt()
    );
    if (!result.isValid()) {
        return Option<String>();
    }
    return Option<String>(String(result.name()));
}

String Color::red(int value) {
    return String(QString("#%1%2%3").arg(value, 2, 16, QChar('0')).arg(0, 2, 16, QChar('0')).arg(0, 2, 16, QChar('0')));
}

String Color::green(int value) {
    return String(QString("#%1%2%3").arg(0, 2, 16, QChar('0')).arg(value, 2, 16, QChar('0')).arg(0, 2, 16, QChar('0')));
}

String Color::blue(int value) {
    return String(QString("#%1%2%3").arg(0, 2, 16, QChar('0')).arg(0, 2, 16, QChar('0')).arg(value, 2, 16, QChar('0')));
}

String Color::rgba(int r, int g, int b, int a) {
    return String(QString("rgba(%1,%2,%3,%4)").arg(r).arg(g).arg(b).arg(a));
}

} // namespace cjqt6
