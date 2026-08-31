package cjqt6.core

// ============================================================
// 公共FFI声明 - QWidget基础函数
// 集中管理core包内共享的QWidget FFI声明，避免在多个文件中重复声明
// 注意：qSignalCleanup在signal.cj中声明，不在此处重复
// ============================================================

// QWidget::show() - 显示控件
foreign func qWidgetShow(ptr: Int64): Unit
// QWidget::hide() - 隐藏控件
foreign func qWidgetHide(ptr: Int64): Unit
// QWidget::resize() - 调整控件大小
foreign func qWidgetResize(ptr: Int64, width: Int32, height: Int32): Unit
// QWidget::setWindowTitle() - 设置窗口标题
foreign func qWidgetSetTitle(ptr: Int64, title: CString): Unit
// QWidget析构 - 删除控件
foreign func qWidgetDelete(ptr: Int64): Unit
// QWidget::setLayout() - 设置布局管理器
foreign func qWidgetSetLayout(widgetPtr: Int64, layoutPtr: Int64): Unit
// QWidget::setStyleSheet() - 设置样式表
foreign func qWidgetSetStyleSheet(ptr: Int64, styleSheet: CString): Unit
// QWidget::styleSheet() - 获取样式表
foreign func qWidgetStyleSheet(ptr: Int64): CString
// QWidget::setEnabled() - 设置启用/禁用
foreign func qWidgetSetEnabled(ptr: Int64, enabled: Int32): Unit
// QWidget::isEnabled() - 获取启用状态
foreign func qWidgetIsEnabled(ptr: Int64): Int32
// QWidget::setVisible() - 设置可见性
foreign func qWidgetSetVisible(ptr: Int64, visible: Int32): Unit
// QWidget::isVisible() - 获取可见性
foreign func qWidgetIsVisible(ptr: Int64): Int32
// QWidget::setToolTip() - 设置工具提示
foreign func qWidgetSetToolTip(ptr: Int64, toolTip: CString): Unit
// QWidget::setMinimumSize() - 设置最小尺寸
foreign func qWidgetSetMinimumSize(ptr: Int64, width: Int32, height: Int32): Unit
// QWidget::setMaximumSize() - 设置最大尺寸
foreign func qWidgetSetMaximumSize(ptr: Int64, width: Int32, height: Int32): Unit
// QWidget::width() - 获取宽度
foreign func qWidgetWidth(ptr: Int64): Int32
// QWidget::height() - 获取高度
foreign func qWidgetHeight(ptr: Int64): Int32
// QWidget::setSizePolicy() - 设置尺寸策略（水平/垂直）
foreign func qWidgetSetSizePolicy(ptr: Int64, hPolicy: Int32, vPolicy: Int32): Unit
// QWidget::sizePolicy() - 获取水平尺寸策略
foreign func qWidgetSizePolicyH(ptr: Int64): Int32
// QWidget::sizePolicy() - 获取垂直尺寸策略
foreign func qWidgetSizePolicyV(ptr: Int64): Int32
