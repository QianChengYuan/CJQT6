package CjMonitor.widget

// ============================================================
// 尺寸 FFI
//
// QEventWidget 只暴露了 show/hide/resize/setGeometry/setLayout/update/setFocus
// 与事件回调，**没有** QWidget 的 width()/height()/setMinimumSize() 等。
// native 层已导出这些符号，但库内声明不是 public（跨包不可见），
// 因此应用包必须自行再声明一次（范式同 examples/CjMusic/src/types.cj）。
// ============================================================

foreign func qWidgetWidth(ptr: Int64): Int32

foreign func qWidgetHeight(ptr: Int64): Int32

foreign func qWidgetSetMinimumSize(ptr: Int64, minW: Int32, minH: Int32): Unit

foreign func qWidgetSetStyleSheet(ptr: Int64, styleSheet: CString): Unit
