package cjqt6.widgets

import cjqt6.core.*
import cjqt6.gui.{TickPosition}

// QSlider - 滑动条
// QSlider::QSlider() - 创建滑动条
foreign func qSliderCreate(): Int64
// QSlider::setValue() - 设置滑动条值
foreign func qSliderSetValue(ptr: Int64, value: Int32): Unit
// QSlider::value() - 获取滑动条值
foreign func qSliderValue(ptr: Int64): Int32
// QSlider::setRange() - 设置范围
foreign func qSliderSetRange(ptr: Int64, min: Int32, max: Int32): Unit
// QSlider::setOrientation() - 设置方向
foreign func qSliderSetOrientation(ptr: Int64, orientation: Int32): Unit
// QSlider::connectValueChanged() - 连接值变化信号
foreign func qSliderConnectValueChanged(ptr: Int64, callback: Int32Callback): Unit
// QSlider::disconnectValueChanged() - 断开值变化信号
foreign func qSliderDisconnectValueChanged(ptr: Int64): Unit
// QSlider::connectSliderMoved() - 连接滑块拖动信号
foreign func qSliderConnectSliderMoved(ptr: Int64, callback: Int32Callback): Unit
// QSlider::disconnectSliderMoved() - 断开滑块拖动信号
foreign func qSliderDisconnectSliderMoved(ptr: Int64): Unit
// QSlider::setSingleStep() - 设置单步步长
foreign func qSliderSetSingleStep(ptr: Int64, step: Int32): Unit
// QSlider::singleStep() - 获取单步步长
foreign func qSliderSingleStep(ptr: Int64): Int32
// QSlider::setPageStep() - 设置页步步长
foreign func qSliderSetPageStep(ptr: Int64, step: Int32): Unit
// QSlider::pageStep() - 获取页步步长
foreign func qSliderPageStep(ptr: Int64): Int32
// QSlider::setTickPosition() - 设置刻度位置
foreign func qSliderSetTickPosition(ptr: Int64, position: Int32): Unit
// QSlider::tickPosition() - 获取刻度位置
foreign func qSliderTickPosition(ptr: Int64): Int32
// QSlider::setTickInterval() - 设置刻度间隔
foreign func qSliderSetTickInterval(ptr: Int64, interval: Int32): Unit
// QSlider::tickInterval() - 获取刻度间隔
foreign func qSliderTickInterval(ptr: Int64): Int32
// QSlider::setInvertedControls() - 设置反向控制
foreign func qSliderSetInvertedControls(ptr: Int64, inverted: Bool): Unit
// QSlider::invertedControls() - 是否反向控制
foreign func qSliderInvertedControls(ptr: Int64): Bool
// QSlider::setInvertedAppearance() - 设置反向外观
foreign func qSliderSetInvertedAppearance(ptr: Int64, inverted: Int32): Unit
// QSlider::invertedAppearance() - 是否反向外观
foreign func qSliderInvertedAppearance(ptr: Int64): Int32
// QSlider::setTracking() - 设置追踪模式
foreign func qSliderSetTracking(ptr: Int64, enable: Bool): Unit
// QSlider::hasTracking() - 是否启用追踪模式
foreign func qSliderHasTracking(ptr: Int64): Bool
// QSlider::deleteCleanup() - 清理信号连接
foreign func qSliderDeleteCleanup(ptr: Int64): Unit
// QSlider::connectSliderPressed() - 连接滑块按下信号
foreign func qSliderSetOnSliderPressed(ptr: Int64, callback: Int64Callback): Unit
// QSlider::connectSliderReleased() - 连接滑块释放信号
foreign func qSliderSetOnSliderReleased(ptr: Int64, callback: Int64Callback): Unit
// QSlider析构 - 删除控件
foreign func qSliderDelete(ptr: Int64): Unit

/// 滑动条方向常量（使用 Orientation 枚举值：Horizontal=1, Vertical=2）

/// 滑动条部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QSlider <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qSliderCreate()
        }
    }
    
    public func show() {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    public func hide() {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    public func resize(width: Int32, height: Int32) {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    public func setValue(value: Int32) {
        checkValid()
        unsafe {
            qSliderSetValue(ptr, value)
        }
    }
    
    public func value(): Int32 {
        checkValid()
        unsafe {
            return qSliderValue(ptr)
        }
    }
    
    public func setRange(min: Int32, max: Int32) {
        checkValid()
        unsafe {
            qSliderSetRange(ptr, min, max)
        }
    }
    
    public func setOrientation(orientation: Int32) {
        checkValid()
        unsafe {
            qSliderSetOrientation(ptr, orientation)
        }
    }
    
    /// 设置单步步长
    public func setSingleStep(step: Int32) {
        checkValid()
        unsafe {
            qSliderSetSingleStep(ptr, step)
        }
    }
    
    /// 获取单步步长
    public func singleStep(): Int32 {
        checkValid()
        unsafe {
            return qSliderSingleStep(ptr)
        }
    }
    
    /// 设置页步步长
    public func setPageStep(step: Int32) {
        checkValid()
        unsafe {
            qSliderSetPageStep(ptr, step)
        }
    }
    
    /// 获取页步步长
    public func pageStep(): Int32 {
        checkValid()
        unsafe {
            return qSliderPageStep(ptr)
        }
    }
    
    /// 设置刻度位置
    public func setTickPosition(position: Int32) {
        checkValid()
        unsafe {
            qSliderSetTickPosition(ptr, position)
        }
    }
    
    /// 获取刻度位置
    public func tickPosition(): Int32 {
        checkValid()
        unsafe {
            return qSliderTickPosition(ptr)
        }
    }
    
    /// 设置刻度间隔
    public func setTickInterval(interval: Int32) {
        checkValid()
        unsafe {
            qSliderSetTickInterval(ptr, interval)
        }
    }
    
    /// 获取刻度间隔
    public func tickInterval(): Int32 {
        checkValid()
        unsafe {
            return qSliderTickInterval(ptr)
        }
    }
    
    /// 设置反向控制
    public func setInvertedControls(inverted: Bool) {
        checkValid()
        unsafe {
            qSliderSetInvertedControls(ptr, inverted)
        }
    }
    
    /// 获取反向控制
    public func invertedControls(): Bool {
        checkValid()
        unsafe {
            return qSliderInvertedControls(ptr)
        }
    }
    
    /// 设置追踪模式（为true时拖动过程中实时触发valueChanged）
    public func setTracking(enable: Bool) {
        checkValid()
        unsafe {
            qSliderSetTracking(ptr, enable)
        }
    }
    
    /// 是否启用追踪模式
    public func hasTracking(): Bool {
        checkValid()
        unsafe {
            return qSliderHasTracking(ptr)
        }
    }
    
    /// 设置反向外观（true: 最大值在底部/左侧，最小值在顶部/右侧）
    public func setInvertedAppearance(inverted: Bool) {
        checkValid()
        unsafe {
            qSliderSetInvertedAppearance(ptr, if (inverted) { 1 } else { 0 })
        }
    }
    
    /// 是否反向外观
    public func invertedAppearance(): Bool {
        checkValid()
        unsafe {
            return qSliderInvertedAppearance(ptr) != 0
        }
    }
    
    /// 设置启用/禁用
    public func setEnabled(enabled: Bool) {
        checkValid()
        unsafe {
            qWidgetSetEnabled(ptr, if (enabled) { 1 } else { 0 })
        }
    }
    
    /// 检查是否启用
    public func isEnabled(): Bool {
        checkValid()
        unsafe {
            qWidgetIsEnabled(ptr) == 1
        }
    }
    
    /// 设置样式表
    public func setStyleSheet(style: String) {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置最小尺寸
    public func setMinimumSize(minw: Int32, minh: Int32) {
        checkValid()
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }
    
    /// 设置最大尺寸
    public func setMaximumSize(maxw: Int32, maxh: Int32) {
        checkValid()
        unsafe {
            qWidgetSetMaximumSize(ptr, maxw, maxh)
        }
    }
    
    /// 设置值变化回调
    public func setOnValueChanged(callback: Int32Callback) {
        checkValid()
        unsafe {
            qSliderConnectValueChanged(ptr, callback)
        }
    }
    
    /// 断开值变化信号
    public func disconnectValueChanged() {
        if (ptr != 0) {
            unsafe {
                qSliderDisconnectValueChanged(ptr)
            }
        }
    }
    
    /// 设置滑块拖动回调（拖动过程中实时触发）
    public func setOnSliderMoved(callback: Int32Callback) {
        checkValid()
        unsafe {
            qSliderConnectSliderMoved(ptr, callback)
        }
    }
    
    /// 断开滑块拖动信号
    public func disconnectSliderMoved() {
        if (ptr != 0) {
            unsafe {
                qSliderDisconnectSliderMoved(ptr)
            }
        }
    }
    
    /// 断开该滑块的全部信号（valueChanged/sliderMoved）
    public func disconnect(): Unit {
        disconnectValueChanged()
        disconnectSliderMoved()
    }
    
    /// 设置滑块按下回调
    public func setOnSliderPressed(callback: Int64Callback) {
        checkValid()
        unsafe {
            qSliderSetOnSliderPressed(ptr, callback)
        }
    }
    
    /// 设置滑块释放回调
    public func setOnSliderReleased(callback: Int64Callback) {
        checkValid()
        unsafe {
            qSliderSetOnSliderReleased(ptr, callback)
        }
    }
    
    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 是否已关闭
    public func isClosed(): Bool {
        return closed
    }
    
    /// 检查对象有效性
    public func isValid(): Bool {
        return !closed && ptr != 0
    }
    
    /// 检查有效性，无效时抛出异常
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QSlider 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QSlider 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qSliderDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除滑动条（兼容旧API）
    public func delete(): Unit {
        close()
    }
}
