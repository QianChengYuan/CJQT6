package CJQT6.widgets

import CJQT6.core.*

// QLineEdit - 单行文本输入框
foreign func qLineEditCreate(): Int64
foreign func qLineEditSetText(ptr: Int64, text: CString): Unit
foreign func qLineEditText(ptr: Int64): CString
foreign func qLineEditSetPlaceholder(ptr: Int64, text: CString): Unit
foreign func qLineEditSetMaxLength(ptr: Int64, length: Int32): Unit
foreign func qLineEditSetReadOnly(ptr: Int64, readonly: Bool): Unit
foreign func qLineEditSetEchoMode(ptr: Int64, mode: Int32): Unit
foreign func qLineEditClear(ptr: Int64): Unit
foreign func qLineEditConnectTextChanged(ptr: Int64, callback: CStringCallback): Unit
foreign func qLineEditDisconnectTextChanged(ptr: Int64): Unit
foreign func qLineEditAddPasswordToggleAction(ptr: Int64, callback: VoidCallback): Unit
foreign func qLineEditSetPasswordToggleIcon(ptr: Int64, visible: Bool): Unit
foreign func qLineEditSetInputMask(ptr: Int64, mask: CString): Unit
foreign func qLineEditSetFrame(ptr: Int64, enabled: Bool): Unit
foreign func qLineEditSetAlignment(ptr: Int64, alignment: Int32): Unit
foreign func qLineEditLength(ptr: Int64): Int32
foreign func qLineEditMaxLength(ptr: Int64): Int32
foreign func qLineEditHasSelectedText(ptr: Int64): Bool
foreign func qLineEditSelectedText(ptr: Int64): CString
foreign func qLineEditSelectAll(ptr: Int64): Unit
foreign func qLineEditSetFocus(ptr: Int64): Unit
foreign func qLineEditDelete(ptr: Int64): Unit

/// 输入掩码预设模板
public class InputMask {
    /// IP地址: 000.000.000.000
    public static let IP: String = "000.000.000.000;_"
    /// MAC地址: HH:HH:HH:HH:HH:HH
    public static let MAC: String = "HH:HH:HH:HH:HH:HH;_"
    /// 日期: 9999-99-99
    public static let Date: String = "9999-99-99;_"
    /// 时间: 99:99
    public static let Time: String = "99:99;_"
    /// 电话号码: (999) 999-9999
    public static let Phone: String = "(999) 999-9999;_"
    /// 软件密钥: >AAAAA-AAAAA-AAAAA-AAAAA-AAAAA
    public static let LicenseKey: String = ">AAAAA-AAAAA-AAAAA-AAAAA-AAAAA;#"
}

/// 对齐方式常量
public class Alignment {
    public static let Left: Int32 = 0x01
    public static let Right: Int32 = 0x02
    public static let HCenter: Int32 = 0x04
    public static let Top: Int32 = 0x20
    public static let Bottom: Int32 = 0x40
    public static let VCenter: Int32 = 0x80
    public static let Center: Int32 = 0x84  // HCenter | VCenter
}

/// 单行文本输入框部件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QLineEdit <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false
    
    /// 创建文本输入框
    public init() {
        unsafe {
            ptr = qLineEditCreate()
            if (ptr == 0) {
                throw CreateFailedException("QLineEdit 创建失败")
            }
        }
    }
    
    /// 显示
    public func show(): Unit {
        checkValid()
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    /// 隐藏
    public func hide(): Unit {
        checkValid()
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    /// 设置文本
    public func setText(text: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            qLineEditSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取文本
    public func text(): String {
        checkValid()
        unsafe {
            let cstr = qLineEditText(ptr)
            return cstr.toString()
        }
    }
    
    /// 设置样式表
    public func setStyleSheet(styleSheet: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(styleSheet)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置占位文本
    public func setPlaceholder(text: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            qLineEditSetPlaceholder(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置最大长度
    public func setMaxLength(length: Int32): Unit {
        checkValid()
        unsafe {
            qLineEditSetMaxLength(ptr, length)
        }
    }
    
    /// 设置只读
    public func setReadOnly(readonly: Bool): Unit {
        checkValid()
        unsafe {
            qLineEditSetReadOnly(ptr, readonly)
        }
    }
    
    /// 设置回显模式
    public func setEchoMode(mode: Int32): Unit {
        checkValid()
        unsafe {
            qLineEditSetEchoMode(ptr, mode)
        }
    }
    
    /// 清空文本
    public func clear(): Unit {
        checkValid()
        unsafe {
            qLineEditClear(ptr)
        }
    }
    
    /// 调整大小
    public func resize(width: Int32, height: Int32): Unit {
        checkValid()
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    /// 设置文本变化回调
    public func setOnTextChanged(callback: CStringCallback): Unit {
        checkValid()
        unsafe {
            qLineEditConnectTextChanged(ptr, callback)
        }
    }
    
    /// 断开文本变化信号
    public func disconnectTextChanged(): Unit {
        if (ptr != 0) {
            unsafe {
                qLineEditDisconnectTextChanged(ptr)
            }
        }
    }
    
    /// 添加密码可见性切换按钮到输入框右侧
    /// 点击按钮时会触发回调，用于切换密码显示/隐藏
    public func addPasswordToggleAction(callback: VoidCallback): Unit {
        checkValid()
        unsafe {
            qLineEditAddPasswordToggleAction(ptr, callback)
        }
    }
    
    /// 设置密码切换按钮图标
    /// visible: true 表示当前密码可见，显示"隐藏"图标
    public func setPasswordToggleIcon(visible: Bool): Unit {
        checkValid()
        unsafe {
            qLineEditSetPasswordToggleIcon(ptr, visible)
        }
    }
    
    /// 设置输入掩码（格式化输入）
    /// 掩码字符说明：
    /// 0 - 数字（必填）    9 - 数字（可选）
    /// A - 字母（必填）    a - 字母（可选）
    /// N - 字母或数字（必填）  n - 字母或数字（可选）
    /// H - 十六进制（必填）    h - 十六进制（可选）
    /// X - 任意字符（必填）    x - 任意字符（可选）
    /// > - 转大写    < - 转小写    ! - 关闭大小写转换
    /// ;c - 设置占位字符为 c
    /// 
    /// 示例：
    /// - IP地址: "000.000.000.000;_"
    /// - MAC地址: "HH:HH:HH:HH:HH:HH;_"
    /// - 日期: "9999-99-99;_"
    /// - 密钥: ">AAAAA-AAAAA-AAAAA;#"
    public func setInputMask(mask: String): Unit {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(mask)
            qLineEditSetInputMask(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    /// 设置是否显示边框
    public func setFrame(enabled: Bool): Unit {
        checkValid()
        unsafe {
            qLineEditSetFrame(ptr, enabled)
        }
    }
    
    /// 设置文本对齐方式
    /// 使用 Alignment 类中的常量
    public func setAlignment(alignment: Int32): Unit {
        checkValid()
        unsafe {
            qLineEditSetAlignment(ptr, alignment)
        }
    }
    
    /// 获取文本长度
    public func length(): Int32 {
        checkValid()
        unsafe {
            return qLineEditLength(ptr)
        }
    }
    
    /// 获取最大长度
    public func maxLength(): Int32 {
        checkValid()
        unsafe {
            return qLineEditMaxLength(ptr)
        }
    }
    
    /// 是否有选中文本
    public func hasSelectedText(): Bool {
        checkValid()
        unsafe {
            return qLineEditHasSelectedText(ptr)
        }
    }
    
    /// 获取选中的文本
    public func selectedText(): String {
        checkValid()
        unsafe {
            let cstr = qLineEditSelectedText(ptr)
            return cstr.toString()
        }
    }
    
    /// 选中所有文本
    public func selectAll(): Unit {
        checkValid()
        unsafe {
            qLineEditSelectAll(ptr)
        }
    }
    
    /// 设置焦点
    public func setFocus(): Unit {
        checkValid()
        unsafe {
            qLineEditSetFocus(ptr)
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
            throw ResourceDisposedException("QLineEdit 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QLineEdit 指针为空")
        }
    }
    
    /// 关闭资源，释放Qt对象
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qLineEditDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    
    /// 删除文本框（兼容旧API）
    public func delete(): Unit {
        close()
    }
    
    /// 终结器 - 已禁用
    /// 注意：仓颉 GC 调用终结器的时机不确定，可能在 Qt 对象仍被使用时提前删除导致崩溃
    /// 请在不需要时显式调用 delete() 或 close() 释放资源
    // ~init() {
    //     if (!closed && ptr != 0) {
    //         unsafe {
    //             qSignalCleanup(ptr)
    //             qLineEditDelete(ptr)
    //         }
    //         closed = true
    //         ptr = 0
    //     }
    // }
}
