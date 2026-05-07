#ifndef CJFW_GUI_H
#define CJFW_GUI_H

// 标准C库 - 必须放在所有其他头文件之前
#include <cstddef>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <cstdint>
#include <functional>

// Qt头文件
#include <QWidget>
#include <QMainWindow>
#include <QLabel>
#include <QPushButton>
#include <QLineEdit>
#include <QTextEdit>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QGridLayout>
#include <QStackedLayout>
#include <QApplication>
#include <QMouseEvent>
#include <QKeyEvent>
#include <QResizeEvent>
#include <QCloseEvent>
#include <QPaintEvent>
#include <QFont>

// 项目头文件 (必须在标准库和Qt头文件之后)
#include "types.h"
#include "cj_string.h"

namespace cjfw {

// 前向声明
class Layout;

// ============================================================
// Widget - 基础窗口部件类
// ============================================================

/**
 * @brief 仓颉风格的基础窗口部件类
 */
class Widget : public QWidget {
    Q_OBJECT
public:
    explicit Widget(Widget* parent = nullptr);
    virtual ~Widget() = default;

    // 属性
    String title() const;
    void setTitle(const String& title);
    
    int width() const;
    int height() const;
    void resize(int w, int h);
    void resize(const String& size);
    
    bool isVisible() const;
    void setVisible(bool visible);
    void show();
    void hide();
    
    // 布局
    void setLayout(Layout* layout);
    
    // 样式
    void setStyle(const String& style);
    String style() const;

protected:
    virtual void mousePressEvent(QMouseEvent* event) override;
    virtual void mouseReleaseEvent(QMouseEvent* event) override;
    virtual void mouseMoveEvent(QMouseEvent* event) override;
    virtual void keyPressEvent(QKeyEvent* event) override;
    virtual void keyReleaseEvent(QKeyEvent* event) override;
    virtual void resizeEvent(QResizeEvent* event) override;
    virtual void closeEvent(QCloseEvent* event) override;
    virtual void paintEvent(QPaintEvent* event) override;

    // 事件回调
    std::function<void(int x, int y)> onMousePress;
    std::function<void(int x, int y)> onMouseRelease;
    std::function<void(int x, int y)> onMouseMove;
    std::function<void(int key)> onKeyPress;
    std::function<void(int key)> onKeyRelease;
    std::function<void(int w, int h)> onResize;
    std::function<void()> onClose;
    std::function<void()> onPaint;
};

// ============================================================
// Window - 窗口类
// ============================================================

/**
 * @brief 仓颉风格的窗口类
 */
class Window : public QMainWindow {
    Q_OBJECT
public:
    explicit Window(Widget* parent = nullptr);
    virtual ~Window() = default;

    // 属性
    String title() const;
    void setTitle(const String& title);
    
    void setCentralWidget(Widget* widget);
    Widget* centralWidget() const;
    
    // 菜单和工具栏
    void addMenuBar(class QMenuBar* menuBar);
    void addToolBar(class QToolBar* toolBar);
    void addStatusBar(class QStatusBar* statusBar);
    
    // 窗口状态
    void maximize();
    void minimize();
    void restore();
    void close();

protected:
    virtual void closeEvent(QCloseEvent* event) override;
    std::function<void()> onClose;
};

// ============================================================
// Label - 标签类
// ============================================================

/**
 * @brief 仓颉风格的标签类
 */
class Label : public QWidget {
    Q_OBJECT
public:
    explicit Label(Widget* parent = nullptr);
    virtual ~Label() = default;

    String text() const;
    void setText(const String& text);
    
    void setAlignment(int alignment);
    
    // 样式
    void setFontSize(int size);
    void setFontFamily(const String& family);
    void setFontBold(bool bold);
    void setTextColor(const String& color);

private:
    QLabel* m_label;
    QVBoxLayout* m_layout;
};

// ============================================================
// Button - 按钮类
// ============================================================

/**
 * @brief 仓颉风格的按钮类
 */
class Button : public QWidget {
    Q_OBJECT
public:
    explicit Button(Widget* parent = nullptr);
    virtual ~Button() = default;

    String text() const;
    void setText(const String& text);
    
    void setEnabled(bool enabled);
    bool isEnabled() const;
    
    // 点击事件
    std::function<void()> onClick;

private slots:
    void clickHandler();

private:
    QPushButton* m_button;
    QVBoxLayout* m_layout;
};

// ============================================================
// TextField - 文本输入框类
// ============================================================

/**
 * @brief 仓颉风格的文本输入框类
 */
class TextField : public QWidget {
    Q_OBJECT
public:
    explicit TextField(Widget* parent = nullptr);
    virtual ~TextField() = default;

    String text() const;
    void setText(const String& text);
    
    void setPlaceholder(const String& placeholder);
    String placeholder() const;
    
    void setReadOnly(bool readOnly);
    bool isReadOnly() const;
    
    void setMaxLength(int length);
    
    // 文本变化事件
    std::function<void(const String&)> onTextChanged;

private slots:
    void textChangedHandler(const QString& text);

private:
    QLineEdit* m_lineEdit;
    QVBoxLayout* m_layout;
};

// ============================================================
// TextArea - 文本区域类
// ============================================================

/**
 * @brief 仓颉风格的文本区域类
 */
class TextArea : public QWidget {
    Q_OBJECT
public:
    explicit TextArea(Widget* parent = nullptr);
    virtual ~TextArea() = default;

    String text() const;
    void setText(const String& text);
    
    void append(const String& text);
    void clear();
    
    void setReadOnly(bool readOnly);
    bool isReadOnly() const;
    
    // 文本变化事件
    std::function<void(const String&)> onTextChanged;

private slots:
    void textChangedHandler();

private:
    QTextEdit* m_textEdit;
    QVBoxLayout* m_layout;
};

// ============================================================
// Layout - 布局类
// ============================================================

/**
 * @brief 仓颉风格的布局基类
 */
class Layout {
public:
    virtual ~Layout() = default;
    virtual QLayout* toQtLayout() = 0;
};

// ============================================================
// VBoxLayout - 垂直布局类
// ============================================================

/**
 * @brief 仓颉风格的垂直布局类
 */
class VBoxLayout : public Layout {
public:
    VBoxLayout();
    virtual ~VBoxLayout() = default;

    void addWidget(QWidget* widget, int stretch = 0);
    void addLayout(Layout* layout, int stretch = 0);
    void addSpacing(int spacing);
    void addStretch(int stretch = 1);
    
    void setMargin(int margin);
    void setSpacing(int spacing);

    QLayout* toQtLayout() override;

private:
    QVBoxLayout* m_layout;
};

// ============================================================
// HBoxLayout - 水平布局类
// ============================================================

/**
 * @brief 仓颉风格的水平布局类
 */
class HBoxLayout : public Layout {
public:
    HBoxLayout();
    virtual ~HBoxLayout() = default;

    void addWidget(QWidget* widget, int stretch = 0);
    void addLayout(Layout* layout, int stretch = 0);
    void addSpacing(int spacing);
    void addStretch(int stretch = 1);
    
    void setMargin(int margin);
    void setSpacing(int spacing);

    QLayout* toQtLayout() override;

private:
    QHBoxLayout* m_layout;
};

} // namespace cjfw

#endif // CJFW_GUI_H