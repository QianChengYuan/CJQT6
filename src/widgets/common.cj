package CJQT6.widgets

// 公共FFI声明 - QWidget基础函数
foreign func qWidgetShow(ptr: Int64): Unit
foreign func qWidgetHide(ptr: Int64): Unit
foreign func qWidgetResize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qWidgetSetTitle(ptr: Int64, title: CString): Unit
foreign func qWidgetDelete(ptr: Int64): Unit
foreign func qWidgetSetLayout(widgetPtr: Int64, layoutPtr: Int64): Unit
