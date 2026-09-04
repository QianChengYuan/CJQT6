package cjqt6.widgets

import cjqt6.core.*

// QProgressBar - 进度条
// QProgressBar::QProgressBar() - 创建进度条
foreign func qProgressBarCreate(): Int64
// QProgressBar::setValue() - 设置进度值
foreign func qProgressBarSetValue(ptr: Int64, value: Int32): Unit
// QProgressBar::value() - 获取进度值
foreign func qProgressBarValue(ptr: Int64): Int32
// QProgressBar::setRange() - 设置范围
foreign func qProgressBarSetRange(ptr: Int64, min: Int32, max: Int32): Unit
// QProgressBar::setTextVisible() - 设置文本是否可见
foreign func qProgressBarSetTextVisible(ptr: Int64, visible: Bool): Unit
// QProgressBar::setFormat() - 设置显示格式
foreign func qProgressBarSetFormat(ptr: Int64, format: CString): Unit
// QProgressBar::format() - 获取显示格式
foreign func qProgressBarFormat(ptr: Int64): CString
// QProgressBar::setOrientation() - 设置方向
foreign func qProgressBarSetOrientation(ptr: Int64, orientation: Int32): Unit
// QProgressBar::setInvertedAppearance() - 设置反向外观
foreign func qProgressBarSetInvertedAppearance(ptr: Int64, invert: Bool): Unit
// QProgressBar::reset() - 重置进度条
foreign func qProgressBarReset(ptr: Int64): Unit
// QProgressBar::setMinimum() - 设置最小值
foreign func qProgressBarSetMinimum(ptr: Int64, value: Int32): Unit
// QProgressBar::minimum() - 获取最小值
foreign func qProgressBarMinimum(ptr: Int64): Int32
// QProgressBar::setMaximum() - 设置最大值
foreign func qProgressBarSetMaximum(ptr: Int64, value: Int32): Unit
// QProgressBar::maximum() - 获取最大值
foreign func qProgressBarMaximum(ptr: Int64): Int32
// QProgressBar::setTextDirection() - 设置文本方向
foreign func qProgressBarSetTextDirection(ptr: Int64, direction: Int32): Unit
// QProgressBar::textDirection() - 获取文本方向
foreign func qProgressBarTextDirection(ptr: Int64): Int32
// QProgressBar::isTextVisible() - 文本是否可见
foreign func qProgressBarIsTextVisible(ptr: Int64): Int32
// QProgressBar::invertedAppearance() - 是否反向外观
foreign func qProgressBarInvertedAppearance(ptr: Int64): Int32
// QProgressBar::setAlignment() - 设置对齐方式
foreign func qProgressBarSetAlignment(ptr: Int64, alignment: Int32): Unit
// QProgressBar::text() - 获取当前显示文本
foreign func qProgressBarText(ptr: Int64): CString
// QProgressBar::connectValueChanged() - 连接值变化信号
foreign func qProgressBarConnectValueChanged(ptr: Int64, callback: Int32Callback): Unit
// QProgressBar析构 - 删除控件
foreign func qProgressBarDelete(ptr: Int64): Unit

/// 进度条部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QProgressBar <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    public init() {
        unsafe {
            ptr = qProgressBarCreate()
        }
        trackObject(ptr)
    }
    
    public func show(): Unit {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    public func hide(): Unit {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    public func setValue(value: Int32): Unit {
        checkValid()
        unsafe {
            qProgressBarSetValue(ptr, value)
        }
    }
    
    public func value(): Int32 {
        checkValid()
        unsafe {
            qProgressBarValue(ptr)
        }
    }
    
    public func setRange(min: Int32, max: Int32): Unit {
        checkValid()
        unsafe {
            qProgressBarSetRange(ptr, min, max)
        }
    }
    
    public func setTextVisible(visible: Bool): Unit {
        checkValid()
        unsafe {
            qProgressBarSetTextVisible(ptr, visible)
        }
    }
    
    /// 设置显示格式（如 "%p%" 显示百分比）
    public func setFormat(format: String): Unit {
        checkValid()
        unsafe {
            withCString(format) { c => qProgressBarSetFormat(ptr, c) }
        }
    }
    
    /// 获取显示格式
    public func format(): String {
        checkValid()
        unsafe {
            let cstr = qProgressBarFormat(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 获取当前显示文本（如"50%"）
    public func text(): String {
        checkValid()
        unsafe {
            let cstr = qProgressBarText(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 设置方向
    public func setOrientation(orientation: Int32): Unit {
        checkValid()
        unsafe {
            qProgressBarSetOrientation(ptr, orientation)
        }
    }
    
    /// 设置反向外观
    public func setInvertedAppearance(invert: Bool): Unit {
        checkValid()
        unsafe {
            qProgressBarSetInvertedAppearance(ptr, invert)
        }
    }
    
    /// 重置进度条
    public func reset(): Unit {
        checkValid()
        unsafe {
            qProgressBarReset(ptr)
        }
    }

    /// 设置最小值
    public func setMinimum(value: Int32): Unit {
        checkValid()
        unsafe {
            qProgressBarSetMinimum(ptr, value)
        }
    }

    /// 获取最小值
    public func minimum(): Int32 {
        checkValid()
        unsafe {
            return qProgressBarMinimum(ptr)
        }
    }

    /// 设置最大值
    public func setMaximum(value: Int32): Unit {
        checkValid()
        unsafe {
            qProgressBarSetMaximum(ptr, value)
        }
    }

    /// 获取最大值
    public func maximum(): Int32 {
        checkValid()
        unsafe {
            return qProgressBarMaximum(ptr)
        }
    }

    /// 设置文本方向
    public func setTextDirection(direction: Int32): Unit {
        checkValid()
        unsafe {
            qProgressBarSetTextDirection(ptr, direction)
        }
    }

    /// 获取文本方向
    public func textDirection(): Int32 {
        checkValid()
        unsafe {
            return qProgressBarTextDirection(ptr)
        }
    }

    /// 文本是否可见
    public func isTextVisible(): Bool {
        checkValid()
        unsafe {
            return qProgressBarIsTextVisible(ptr) != 0
        }
    }

    /// 是否反向外观
    public func invertedAppearance(): Bool {
        checkValid()
        unsafe {
            return qProgressBarInvertedAppearance(ptr) != 0
        }
    }

    /// 设置文本对齐方式（Qt::Alignment 标志组合）
    public func setAlignment(alignment: Int32): Unit {
        checkValid()
        unsafe {
            qProgressBarSetAlignment(ptr, alignment)
        }
    }

    /// 设置值变化回调
    public func setOnValueChanged(callback: Int32Callback): Unit {
        checkValid()
        unsafe {
            qProgressBarConnectValueChanged(ptr, callback)
        }
    }

    /// 设置启用/禁用
    public func setEnabled(enabled: Bool): Unit {
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
    public func setStyleSheet(style: String): Unit {
        checkValid()
        unsafe {
            withCString(style) { c => qWidgetSetStyleSheet(ptr, c) }
        }
    }
    
    /// 设置最小尺寸
    public func setMinimumSize(minw: Int32, minh: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }
    
    /// 设置最大尺寸
    public func setMaximumSize(maxw: Int32, maxh: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetSetMaximumSize(ptr, maxw, maxh)
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
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }
    
    /// 检查有效性，无效时抛出异常
    /// throws: NullPointerException 空指针访问时抛出
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QProgressBar 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QProgressBar 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QProgressBar 底层 Qt 对象已失效")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe {
                qSignalCleanup(ptr)
                qProgressBarDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除进度条（兼容旧API）
    public func delete(): Unit {
        close()
    }
}

/// 进度条文本方向常量（对应 QProgressBar::Direction）
public class ProgressBarDirection {
    public static let TopToBottom: Int32 = 0
    public static let BottomToTop: Int32 = 1
}
