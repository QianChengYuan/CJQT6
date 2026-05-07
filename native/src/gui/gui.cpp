// GUI模块实现
// 注意：大部分实现在头文件中内联定义

#include "gui.h"
#include <QMenuBar>
#include <QToolBar>
#include <QStatusBar>

namespace cjfw {

// ============================================================
// Widget 实现
// ============================================================

Widget::Widget(Widget* parent) : QWidget(parent) {
}

String Widget::title() const {
    return String(windowTitle());
}

void Widget::setTitle(const String& title) {
    setWindowTitle(title.toQt());
}

int Widget::width() const {
    return QWidget::width();
}

int Widget::height() const {
    return QWidget::height();
}

void Widget::resize(int w, int h) {
    QWidget::resize(w, h);
}

void Widget::resize(const String& size) {
    // 解析 "宽x高" 格式
    auto parts = size.split("x");
    if (parts.size() == 2) {
        int w = parts[0].toInt();
        int h = parts[1].toInt();
        QWidget::resize(w, h);
    }
}

bool Widget::isVisible() const {
    return QWidget::isVisible();
}

void Widget::setVisible(bool visible) {
    QWidget::setVisible(visible);
}

void Widget::show() {
    QWidget::show();
}

void Widget::hide() {
    QWidget::hide();
}

void Widget::setLayout(Layout* layout) {
    if (layout) {
        QWidget::setLayout(layout->toQtLayout());
    }
}

void Widget::setStyle(const String& style) {
    setStyleSheet(style.toQt());
}

String Widget::style() const {
    return String(styleSheet());
}

void Widget::mousePressEvent(QMouseEvent* event) {
    if (onMousePress) {
        onMousePress(event->x(), event->y());
    }
    QWidget::mousePressEvent(event);
}

void Widget::mouseReleaseEvent(QMouseEvent* event) {
    if (onMouseRelease) {
        onMouseRelease(event->x(), event->y());
    }
    QWidget::mouseReleaseEvent(event);
}

void Widget::mouseMoveEvent(QMouseEvent* event) {
    if (onMouseMove) {
        onMouseMove(event->x(), event->y());
    }
    QWidget::mouseMoveEvent(event);
}

void Widget::keyPressEvent(QKeyEvent* event) {
    if (onKeyPress) {
        onKeyPress(event->key());
    }
    QWidget::keyPressEvent(event);
}

void Widget::keyReleaseEvent(QKeyEvent* event) {
    if (onKeyRelease) {
        onKeyRelease(event->key());
    }
    QWidget::keyReleaseEvent(event);
}

void Widget::resizeEvent(QResizeEvent* event) {
    if (onResize) {
        onResize(event->size().width(), event->size().height());
    }
    QWidget::resizeEvent(event);
}

void Widget::closeEvent(QCloseEvent* event) {
    if (onClose) {
        onClose();
    }
    QWidget::closeEvent(event);
}

void Widget::paintEvent(QPaintEvent* event) {
    if (onPaint) {
        onPaint();
    }
    QWidget::paintEvent(event);
}

// ============================================================
// Window 实现
// ============================================================

Window::Window(Widget* parent) : QMainWindow(parent ? qobject_cast<QWidget*>(parent) : nullptr) {
}

String Window::title() const {
    return String(windowTitle());
}

void Window::setTitle(const String& title) {
    setWindowTitle(title.toQt());
}

void Window::setCentralWidget(Widget* widget) {
    QMainWindow::setCentralWidget(widget);
}

Widget* Window::centralWidget() const {
    return qobject_cast<Widget*>(QMainWindow::centralWidget());
}

void Window::addMenuBar(QMenuBar* menuBar) {
    setMenuBar(menuBar);
}

void Window::addToolBar(QToolBar* toolBar) {
    QMainWindow::addToolBar(toolBar);
}

void Window::addStatusBar(QStatusBar* statusBar) {
    setStatusBar(statusBar);
}

void Window::maximize() {
    showMaximized();
}

void Window::minimize() {
    showMinimized();
}

void Window::restore() {
    showNormal();
}

void Window::close() {
    QMainWindow::close();
}

void Window::closeEvent(QCloseEvent* event) {
    if (onClose) {
        onClose();
    }
    QMainWindow::closeEvent(event);
}

// ============================================================
// Label 实现
// ============================================================

Label::Label(Widget* parent) : QWidget(parent), m_label(new QLabel()), m_layout(new QVBoxLayout(this)) {
    m_layout->setContentsMargins(0, 0, 0, 0);
    m_layout->addWidget(m_label);
}

String Label::text() const {
    return String(m_label->text());
}

void Label::setText(const String& text) {
    m_label->setText(text.toQt());
}

void Label::setAlignment(int alignment) {
    m_label->setAlignment(static_cast<Qt::Alignment>(alignment));
}

void Label::setFontSize(int size) {
    QFont font = m_label->font();
    font.setPointSize(size);
    m_label->setFont(font);
}

void Label::setFontFamily(const String& family) {
    QFont font = m_label->font();
    font.setFamily(family.toQt());
    m_label->setFont(font);
}

void Label::setFontBold(bool bold) {
    QFont font = m_label->font();
    font.setBold(bold);
    m_label->setFont(font);
}

void Label::setTextColor(const String& color) {
    m_label->setStyleSheet(QString("color: %1;").arg(color.toQt()));
}

// ============================================================
// Button 实现
// ============================================================

Button::Button(Widget* parent) : QWidget(parent), m_button(new QPushButton()), m_layout(new QVBoxLayout(this)) {
    m_layout->setContentsMargins(0, 0, 0, 0);
    m_layout->addWidget(m_button);
    connect(m_button, &QPushButton::clicked, this, &Button::clickHandler);
}

String Button::text() const {
    return String(m_button->text());
}

void Button::setText(const String& text) {
    m_button->setText(text.toQt());
}

void Button::setEnabled(bool enabled) {
    m_button->setEnabled(enabled);
}

bool Button::isEnabled() const {
    return m_button->isEnabled();
}

void Button::clickHandler() {
    if (onClick) {
        onClick();
    }
}

// ============================================================
// TextField 实现
// ============================================================

TextField::TextField(Widget* parent) : QWidget(parent), m_lineEdit(new QLineEdit()), m_layout(new QVBoxLayout(this)) {
    m_layout->setContentsMargins(0, 0, 0, 0);
    m_layout->addWidget(m_lineEdit);
    connect(m_lineEdit, &QLineEdit::textChanged, this, &TextField::textChangedHandler);
}

String TextField::text() const {
    return String(m_lineEdit->text());
}

void TextField::setText(const String& text) {
    m_lineEdit->setText(text.toQt());
}

void TextField::setPlaceholder(const String& placeholder) {
    m_lineEdit->setPlaceholderText(placeholder.toQt());
}

String TextField::placeholder() const {
    return String(m_lineEdit->placeholderText());
}

void TextField::setReadOnly(bool readOnly) {
    m_lineEdit->setReadOnly(readOnly);
}

bool TextField::isReadOnly() const {
    return m_lineEdit->isReadOnly();
}

void TextField::setMaxLength(int length) {
    m_lineEdit->setMaxLength(length);
}

void TextField::textChangedHandler(const QString& text) {
    if (onTextChanged) {
        onTextChanged(String(text));
    }
}

// ============================================================
// TextArea 实现
// ============================================================

TextArea::TextArea(Widget* parent) : QWidget(parent), m_textEdit(new QTextEdit()), m_layout(new QVBoxLayout(this)) {
    m_layout->setContentsMargins(0, 0, 0, 0);
    m_layout->addWidget(m_textEdit);
    connect(m_textEdit, &QTextEdit::textChanged, this, &TextArea::textChangedHandler);
}

String TextArea::text() const {
    return String(m_textEdit->toPlainText());
}

void TextArea::setText(const String& text) {
    m_textEdit->setText(text.toQt());
}

void TextArea::append(const String& text) {
    m_textEdit->append(text.toQt());
}

void TextArea::clear() {
    m_textEdit->clear();
}

void TextArea::setReadOnly(bool readOnly) {
    m_textEdit->setReadOnly(readOnly);
}

bool TextArea::isReadOnly() const {
    return m_textEdit->isReadOnly();
}

void TextArea::textChangedHandler() {
    if (onTextChanged) {
        onTextChanged(text());
    }
}

// ============================================================
// VBoxLayout 实现
// ============================================================

VBoxLayout::VBoxLayout() : m_layout(new QVBoxLayout()) {
}

void VBoxLayout::addWidget(QWidget* widget, int stretch) {
    m_layout->addWidget(widget, stretch);
}

void VBoxLayout::addLayout(Layout* layout, int stretch) {
    if (layout) {
        m_layout->addLayout(layout->toQtLayout(), stretch);
    }
}

void VBoxLayout::addSpacing(int spacing) {
    m_layout->addSpacing(spacing);
}

void VBoxLayout::addStretch(int stretch) {
    m_layout->addStretch(stretch);
}

void VBoxLayout::setMargin(int margin) {
    m_layout->setContentsMargins(margin, margin, margin, margin);
}

void VBoxLayout::setSpacing(int spacing) {
    m_layout->setSpacing(spacing);
}

QLayout* VBoxLayout::toQtLayout() {
    return m_layout;
}

// ============================================================
// HBoxLayout 实现
// ============================================================

HBoxLayout::HBoxLayout() : m_layout(new QHBoxLayout()) {
}

void HBoxLayout::addWidget(QWidget* widget, int stretch) {
    m_layout->addWidget(widget, stretch);
}

void HBoxLayout::addLayout(Layout* layout, int stretch) {
    if (layout) {
        m_layout->addLayout(layout->toQtLayout(), stretch);
    }
}

void HBoxLayout::addSpacing(int spacing) {
    m_layout->addSpacing(spacing);
}

void HBoxLayout::addStretch(int stretch) {
    m_layout->addStretch(stretch);
}

void HBoxLayout::setMargin(int margin) {
    m_layout->setContentsMargins(margin, margin, margin, margin);
}

void HBoxLayout::setSpacing(int spacing) {
    m_layout->setSpacing(spacing);
}

QLayout* HBoxLayout::toQtLayout() {
    return m_layout;
}

} // namespace cjfw
