package cjqt6.widgets

import cjqt6.core.*

// QScrollBar FFI 声明
foreign func qScrollBarCreate(orientation: Int32): Int64
foreign func qScrollBarSetRange(ptr: Int64, min: Int32, max: Int32): Unit
foreign func qScrollBarSetValue(ptr: Int64, value: Int32): Unit
foreign func qScrollBarValue(ptr: Int64): Int32
foreign func qScrollBarSetSingleStep(ptr: Int64, step: Int32): Unit
foreign func qScrollBarSetPageStep(ptr: Int64, step: Int32): Unit
foreign func qScrollBarSetOrientation(ptr: Int64, orientation: Int32): Unit
foreign func qScrollBarConnectValueChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qScrollBarDelete(ptr: Int64): Unit
foreign func qScrollBarSetMinimum(ptr: Int64, value: Int32): Unit
foreign func qScrollBarMinimum(ptr: Int64): Int32
foreign func qScrollBarSetMaximum(ptr: Int64, value: Int32): Unit
foreign func qScrollBarMaximum(ptr: Int64): Int32
foreign func qScrollBarSetSliderPosition(ptr: Int64, value: Int32): Unit
foreign func qScrollBarSliderPosition(ptr: Int64): Int32
foreign func qScrollBarSetTracking(ptr: Int64, tracking: Int32): Unit
foreign func qScrollBarIsTracking(ptr: Int64): Int32
foreign func qScrollBarSetInvertedAppearance(ptr: Int64, value: Int32): Unit
foreign func qScrollBarInvertedAppearance(ptr: Int64): Int32
foreign func qScrollBarSetInvertedControls(ptr: Int64, value: Int32): Unit
foreign func qScrollBarInvertedControls(ptr: Int64): Int32
foreign func qScrollBarSetRepeatAction(ptr: Int64, action: Int32): Unit
foreign func qScrollBarRepeatAction(ptr: Int64): Int32
foreign func qScrollBarTriggerAction(ptr: Int64, action: Int32): Unit
foreign func qScrollBarConnectSliderPressed(ptr: Int64, callback: VoidCallback): Unit
foreign func qScrollBarConnectSliderMoved(ptr: Int64, callback: Int32Callback): Unit
foreign func qScrollBarConnectSliderReleased(ptr: Int64, callback: VoidCallback): Unit
foreign func qScrollBarConnectRangeChanged(ptr: Int64, callback: Int32Int32Callback): Unit
foreign func qScrollBarConnectActionTriggered(ptr: Int64, callback: Int32Callback): Unit

/// 独立滚动条部件
public class QScrollBar {
    private var ptr: Int64 = 0
    
    /// 创建滚动条
    /// orientation: ScrollBarOrientation.Horizontal 或 ScrollBarOrientation.Vertical
    public init(orientation: Int32) {
        unsafe {
            ptr = qScrollBarCreate(orientation)
        }
    }
    
    public func show() {
        unsafe { qWidgetShow(ptr) }
    }
    
    public func hide() {
        unsafe { qWidgetHide(ptr) }
    }
    
    public func resize(width: Int32, height: Int32) {
        unsafe { qWidgetResize(ptr, width, height) }
    }
    
    /// 设置范围 [min, max]
    public func setRange(min: Int32, max: Int32) {
        unsafe { qScrollBarSetRange(ptr, min, max) }
    }
    
    /// 设置当前值
    public func setValue(value: Int32) {
        unsafe { qScrollBarSetValue(ptr, value) }
    }
    
    /// 获取当前值
    public func value(): Int32 {
        unsafe { return qScrollBarValue(ptr) }
    }
    
    /// 设置单步步长（箭头点击）
    public func setSingleStep(step: Int32) {
        unsafe { qScrollBarSetSingleStep(ptr, step) }
    }
    
    /// 设置翻页步长（点击滑块空白区域）
    public func setPageStep(step: Int32) {
        unsafe { qScrollBarSetPageStep(ptr, step) }
    }
    
    /// 设置方向
    public func setOrientation(orientation: Int32) {
        unsafe { qScrollBarSetOrientation(ptr, orientation) }
    }
    
    /// 设置值变化回调
    public func setOnValueChanged(callback: Int32Callback) {
        unsafe { qScrollBarConnectValueChanged(ptr, callback) }
    }

    /// 设置最小值
    public func setMinimum(value: Int32) {
        unsafe { qScrollBarSetMinimum(ptr, value) }
    }

    /// 获取最小值
    public func minimum(): Int32 {
        unsafe { return qScrollBarMinimum(ptr) }
    }

    /// 设置最大值
    public func setMaximum(value: Int32) {
        unsafe { qScrollBarSetMaximum(ptr, value) }
    }

    /// 获取最大值
    public func maximum(): Int32 {
        unsafe { return qScrollBarMaximum(ptr) }
    }

    /// 设置滑块位置
    public func setSliderPosition(value: Int32) {
        unsafe { qScrollBarSetSliderPosition(ptr, value) }
    }

    /// 获取滑块位置
    public func sliderPosition(): Int32 {
        unsafe { return qScrollBarSliderPosition(ptr) }
    }

    /// 设置是否跟踪（拖动时实时触发 valueChanged）
    public func setTracking(tracking: Bool) {
        unsafe { qScrollBarSetTracking(ptr, if (tracking) { 1 } else { 0 }) }
    }

    /// 是否跟踪
    public func isTracking(): Bool {
        unsafe { return qScrollBarIsTracking(ptr) != 0 }
    }

    /// 设置反向外观
    public func setInvertedAppearance(value: Bool) {
        unsafe { qScrollBarSetInvertedAppearance(ptr, if (value) { 1 } else { 0 }) }
    }

    /// 是否反向外观
    public func invertedAppearance(): Bool {
        unsafe { return qScrollBarInvertedAppearance(ptr) != 0 }
    }

    /// 设置反向控制
    public func setInvertedControls(value: Bool) {
        unsafe { qScrollBarSetInvertedControls(ptr, if (value) { 1 } else { 0 }) }
    }

    /// 是否反向控制
    public func invertedControls(): Bool {
        unsafe { return qScrollBarInvertedControls(ptr) != 0 }
    }

    /// 设置重复动作策略
    public func setRepeatAction(action: Int32) {
        unsafe { qScrollBarSetRepeatAction(ptr, action) }
    }

    /// 获取重复动作策略
    public func repeatAction(): Int32 {
        unsafe { return qScrollBarRepeatAction(ptr) }
    }

    /// 触发指定动作
    public func triggerAction(action: Int32) {
        unsafe { qScrollBarTriggerAction(ptr, action) }
    }

    /// 滑块按下回调
    public func setOnSliderPressed(callback: VoidCallback) {
        unsafe { qScrollBarConnectSliderPressed(ptr, callback) }
    }

    /// 滑块拖动回调
    public func setOnSliderMoved(callback: Int32Callback) {
        unsafe { qScrollBarConnectSliderMoved(ptr, callback) }
    }

    /// 滑块释放回调
    public func setOnSliderReleased(callback: VoidCallback) {
        unsafe { qScrollBarConnectSliderReleased(ptr, callback) }
    }

    /// 范围变化回调 (min, max)
    public func setOnRangeChanged(callback: Int32Int32Callback) {
        unsafe { qScrollBarConnectRangeChanged(ptr, callback) }
    }

    /// 动作触发回调（动作枚举值）
    public func setOnActionTriggered(callback: Int32Callback) {
        unsafe { qScrollBarConnectActionTriggered(ptr, callback) }
    }
    
    /// 设置启用/禁用
    public func setEnabled(enabled: Bool) {
        unsafe { qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 }) }
    }
    
    /// 设置样式表
    public func setStyleSheet(style: String) {
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 删除部件
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qScrollBarDelete(ptr)
            }
            ptr = 0
        }
    }
}

/// 滚动条方向常量
public class ScrollBarOrientation {
    public static let Horizontal: Int32 = 1
    public static let Vertical: Int32 = 2
}

/// 滚动条重复动作策略（对应 QAbstractSlider::RepeatAction）
public class ScrollBarRepeatAction {
    public static let SingleStep: Int32 = 1
    public static let PageStep: Int32 = 2
    public static let ToMinimum: Int32 = 3
    public static let ToMaximum: Int32 = 4
    public static let SliderToMinimum: Int32 = 5
    public static let SliderToMaximum: Int32 = 6
}
