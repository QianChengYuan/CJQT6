#ifndef CJQT6_WIDGETS_H
#define CJQT6_WIDGETS_H

// 标准C库 - 必须放在所有其他头文件之前
#include <cstddef>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <cstdint>
#include <functional>
#include <vector>

// Qt Widgets头文件
#include <QCheckBox>
#include <QRadioButton>
#include <QComboBox>
#include <QSpinBox>
#include <QDoubleSpinBox>
#include <QSlider>
#include <QProgressBar>
#include <QGroupBox>
#include <QTabWidget>
#include <QScrollArea>
#include <QFrame>
#include <QSplitter>
#include <QMessageBox>
#include <QFileDialog>
#include <QColorDialog>
#include <QInputDialog>

// 项目头文件 (必须在标准库和Qt头文件之后)
#include "types.h"
#include "cj_string.h"
#include "gui.h"

namespace cjqt6 {

// ============================================================
// CheckBox - 复选框类
// ============================================================

/**
 * @brief 仓颉风格的复选框类
 */
class CheckBox : public QWidget {
    Q_OBJECT
public:
    explicit CheckBox(Widget* parent = nullptr);
    virtual ~CheckBox() = default;

    String text() const;
    void setText(const String& text);
    
    bool isChecked() const;
    void setChecked(bool checked);
    
    // 状态变化事件
    std::function<void(bool)> onStateChanged;

private slots:
    void stateChangedHandler(int state);

private:
    QCheckBox* m_checkBox;
    QVBoxLayout* m_layout;
};

// ============================================================
// RadioButton - 单选按钮类
// ============================================================

/**
 * @brief 仓颉风格的单选按钮类
 */
class RadioButton : public QWidget {
    Q_OBJECT
public:
    explicit RadioButton(Widget* parent = nullptr);
    virtual ~RadioButton() = default;

    String text() const;
    void setText(const String& text);
    
    bool isChecked() const;
    void setChecked(bool checked);
    
    // 状态变化事件
    std::function<void(bool)> onStateChanged;

private slots:
    void toggledHandler(bool checked);

private:
    QRadioButton* m_radioButton;
    QVBoxLayout* m_layout;
};

// ============================================================
// ComboBox - 下拉框类
// ============================================================

/**
 * @brief 仓颉风格的下拉框类
 */
class ComboBox : public QWidget {
    Q_OBJECT
public:
    explicit ComboBox(Widget* parent = nullptr);
    virtual ~ComboBox() = default;

    void addItem(const String& item);
    void addItems(const std::vector<String>& items);
    void clear();
    
    String currentItem() const;
    void setCurrentItem(const String& item);
    
    int currentIndex() const;
    void setCurrentIndex(int index);
    
    int count() const;
    
    // 选择变化事件
    std::function<void(int index, const String& text)> onSelectionChanged;

private slots:
    void currentIndexChangedHandler(int index);

private:
    QComboBox* m_comboBox;
    QVBoxLayout* m_layout;
};

// ============================================================
// SpinBox - 整数旋转框类
// ============================================================

/**
 * @brief 仓颉风格的整数旋转框类
 */
class SpinBox : public QWidget {
    Q_OBJECT
public:
    explicit SpinBox(Widget* parent = nullptr);
    virtual ~SpinBox() = default;

    int value() const;
    void setValue(int value);
    
    void setMinimum(int min);
    void setMaximum(int max);
    void setRange(int min, int max);
    
    int minimum() const;
    int maximum() const;
    
    void setSingleStep(int step);
    
    // 值变化事件
    std::function<void(int value)> onValueChanged;

private slots:
    void valueChangedHandler(int value);

private:
    QSpinBox* m_spinBox;
    QVBoxLayout* m_layout;
};

// ============================================================
// DoubleSpinBox - 浮点数旋转框类
// ============================================================

/**
 * @brief 仓颉风格的浮点数旋转框类
 */
class DoubleSpinBox : public QWidget {
    Q_OBJECT
public:
    explicit DoubleSpinBox(Widget* parent = nullptr);
    virtual ~DoubleSpinBox() = default;

    double value() const;
    void setValue(double value);
    
    void setMinimum(double min);
    void setMaximum(double max);
    void setRange(double min, double max);
    
    double minimum() const;
    double maximum() const;
    
    void setSingleStep(double step);
    void setDecimals(int decimals);
    
    // 值变化事件
    std::function<void(double value)> onValueChanged;

private slots:
    void valueChangedHandler(double value);

private:
    QDoubleSpinBox* m_spinBox;
    QVBoxLayout* m_layout;
};

// ============================================================
// Slider - 滑块类
// ============================================================

/**
 * @brief 仓颉风格的滑块类
 */
class Slider : public QWidget {
    Q_OBJECT
public:
    explicit Slider(Widget* parent = nullptr);
    virtual ~Slider() = default;

    int value() const;
    void setValue(int value);
    
    void setMinimum(int min);
    void setMaximum(int max);
    void setRange(int min, int max);
    
    int minimum() const;
    int maximum() const;
    
    void setOrientation(int orientation); // Qt::Horizontal or Qt::Vertical
    
    // 值变化事件
    std::function<void(int value)> onValueChanged;

private slots:
    void valueChangedHandler(int value);

private:
    QSlider* m_slider;
    QVBoxLayout* m_layout;
};

// ============================================================
// ProgressBar - 进度条类
// ============================================================

/**
 * @brief 仓颉风格的进度条类
 */
class ProgressBar : public QWidget {
    Q_OBJECT
public:
    explicit ProgressBar(Widget* parent = nullptr);
    virtual ~ProgressBar() = default;

    int value() const;
    void setValue(int value);
    
    void setMinimum(int min);
    void setMaximum(int max);
    void setRange(int min, int max);
    
    int minimum() const;
    int maximum() const;
    
    void setTextVisible(bool visible);
    bool isTextVisible() const;
    
    String format() const;
    void setFormat(const String& format);

private:
    QProgressBar* m_progressBar;
    QVBoxLayout* m_layout;
};

// ============================================================
// GroupBox - 分组框类
// ============================================================

/**
 * @brief 仓颉风格的分组框类
 */
class GroupBox : public QWidget {
    Q_OBJECT
public:
    explicit GroupBox(Widget* parent = nullptr);
    virtual ~GroupBox() = default;

    String title() const;
    void setTitle(const String& title);
    
    void setLayout(Layout* layout);
    void setCheckable(bool checkable);
    bool isCheckable() const;

private:
    QGroupBox* m_groupBox;
    QVBoxLayout* m_layout;
};

// ============================================================
// TabWidget - 标签页类
// ============================================================

/**
 * @brief 仓颉风格的标签页类
 */
class TabWidget : public QWidget {
    Q_OBJECT
public:
    explicit TabWidget(Widget* parent = nullptr);
    virtual ~TabWidget() = default;

    void addTab(QWidget* widget, const String& title);
    void insertTab(int index, QWidget* widget, const String& title);
    void removeTab(int index);
    
    int currentIndex() const;
    void setCurrentIndex(int index);
    
    int count() const;
    String tabTitle(int index) const;
    void setTabTitle(int index, const String& title);
    
    // 标签页切换事件
    std::function<void(int index)> onTabChanged;

private slots:
    void currentChangedHandler(int index);

private:
    QTabWidget* m_tabWidget;
    QVBoxLayout* m_layout;
};

// ============================================================
// Dialog - 对话框类
// ============================================================

/**
 * @brief 仓颉风格的对话框工具类
 */
class Dialog {
public:
    // 消息对话框
    static void showMessage(Widget* parent, const String& title, const String& message);
    static void showInfo(Widget* parent, const String& title, const String& message);
    static void showWarning(Widget* parent, const String& title, const String& message);
    static void showError(Widget* parent, const String& title, const String& message);
    
    static bool showQuestion(Widget* parent, const String& title, const String& message);
    
    // 文件对话框
    static Option<String> openFile(Widget* parent, const String& caption = "Open File", 
                                   const String& filter = "All Files (*.*)");
    static Option<String> saveFile(Widget* parent, const String& caption = "Save File",
                                   const String& filter = "All Files (*.*)");
    static std::vector<String> openFiles(Widget* parent, const String& caption = "Open Files",
                                         const String& filter = "All Files (*.*)");
    
    // 输入对话框
    static Option<String> getText(Widget* parent, const String& title, const String& label,
                                  const String& text = String());
    static Option<int> getInt(Widget* parent, const String& title, const String& label,
                              int value = 0, int min = -2147483647, int max = 2147483647);
};

// ============================================================
// Color - 颜色对话框类
// ============================================================

/**
 * @brief 仓颉风格的颜色选择类
 */
class Color {
public:
    static Option<String> select(Widget* parent, const String& title = "Select Color");
    
    static String red(int value);
    static String green(int value);
    static String blue(int value);
    static String rgba(int r, int g, int b, int a = 255);
};

} // namespace cjqt6

#endif // CJQT6_WIDGETS_H