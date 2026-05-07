package cjqt6.dialogs

// ============================================================
// 对话框 FFI声明
// ============================================================

// QMessageBox
foreign func qMessageBoxInformation(parentPtr: Int64, title: CString, text: CString): Unit
foreign func qMessageBoxWarning(parentPtr: Int64, title: CString, text: CString): Unit
foreign func qMessageBoxCritical(parentPtr: Int64, title: CString, text: CString): Unit
foreign func qMessageBoxQuestion(parentPtr: Int64, title: CString, text: CString): Int32

// QFileDialog (返回静态缓冲区指针，不需要free)
foreign func qFileDialogGetOpenFileName(parentPtr: Int64, title: CString, filter: CString): CString
foreign func qFileDialogGetSaveFileName(parentPtr: Int64, title: CString, filter: CString): CString
foreign func qFileDialogGetExistingDirectory(parentPtr: Int64, title: CString): CString
foreign func qFileDialogGetOpenFileNames(parentPtr: Int64, title: CString, filter: CString): CString

// QInputDialog (简化版，直接返回值)
foreign func qInputDialogGetTextValue(parentPtr: Int64, title: CString, label: CString, text: CString): CString
foreign func qInputDialogGetTextWithOk(parentPtr: Int64, title: CString, label: CString, text: CString, okPtr: CPointer<Int32>): CString
foreign func qInputDialogGetIntValue(parentPtr: Int64, title: CString, label: CString, value: Int32, min: Int32, max: Int32): Int32
foreign func qInputDialogGetIntWithOk(parentPtr: Int64, title: CString, label: CString, value: Int32, min: Int32, max: Int32, okPtr: CPointer<Int32>): Int32
foreign func qInputDialogGetDoubleValue(parentPtr: Int64, title: CString, label: CString, value: Float64, min: Float64, max: Float64): Float64

// QColorDialog
foreign func qColorDialogGetColorHex(parentPtr: Int64, title: CString): CString

// ============================================================
// QMessageBox - 消息对话框
// ============================================================
public class QMessageBox {
    
    // 信息对话框
    public static func information(parent: Int64, title: String, text: String) {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            var textCstr = LibC.mallocCString(text)
            qMessageBoxInformation(parent, titleCstr, textCstr)
            LibC.free(titleCstr)
            LibC.free(textCstr)
        }
    }
    
    // 警告对话框
    public static func warning(parent: Int64, title: String, text: String) {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            var textCstr = LibC.mallocCString(text)
            qMessageBoxWarning(parent, titleCstr, textCstr)
            LibC.free(titleCstr)
            LibC.free(textCstr)
        }
    }
    
    // 错误对话框
    public static func critical(parent: Int64, title: String, text: String) {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            var textCstr = LibC.mallocCString(text)
            qMessageBoxCritical(parent, titleCstr, textCstr)
            LibC.free(titleCstr)
            LibC.free(textCstr)
        }
    }
    
    // 询问对话框，返回true表示选择Yes
    public static func question(parent: Int64, title: String, text: String): Bool {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            var textCstr = LibC.mallocCString(text)
            let result = qMessageBoxQuestion(parent, titleCstr, textCstr)
            LibC.free(titleCstr)
            LibC.free(textCstr)
            return result == 1
        }
    }
}

// ============================================================
// QFileDialog - 文件对话框
// ============================================================
public class QFileDialog {
    
    // 获取打开文件路径
    public static func getOpenFileName(parent: Int64, title: String, filter: String): String {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            var filterCstr = LibC.mallocCString(filter)
            let cstr = qFileDialogGetOpenFileName(parent, titleCstr, filterCstr)
            let result = cstr.toString()
            LibC.free(titleCstr)
            LibC.free(filterCstr)
            // 注意：cstr指向静态缓冲区，不要free
            return result
        }
    }
    
    // 获取保存文件路径
    public static func getSaveFileName(parent: Int64, title: String, filter: String): String {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            var filterCstr = LibC.mallocCString(filter)
            let cstr = qFileDialogGetSaveFileName(parent, titleCstr, filterCstr)
            let result = cstr.toString()
            LibC.free(titleCstr)
            LibC.free(filterCstr)
            // 注意：cstr指向静态缓冲区，不要free
            return result
        }
    }
    
    // 获取目录路径
    public static func getExistingDirectory(parent: Int64, title: String): String {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            let cstr = qFileDialogGetExistingDirectory(parent, titleCstr)
            let result = cstr.toString()
            LibC.free(titleCstr)
            // 注意：cstr指向静态缓冲区，不要free
            return result
        }
    }
    
    // 获取多个打开文件路径（用\n分隔）
    public static func getOpenFileNames(parent: Int64, title: String, filter: String): String {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            var filterCstr = LibC.mallocCString(filter)
            let cstr = qFileDialogGetOpenFileNames(parent, titleCstr, filterCstr)
            let result = cstr.toString()
            LibC.free(titleCstr)
            LibC.free(filterCstr)
            // 注意：cstr指向静态缓冲区，不要free
            return result
        }
    }
}

// ============================================================
// QInputDialog - 输入对话框 (简化版)
// ============================================================
public class QInputDialog {
    
    // 获取文本输入 (返回空字符串表示取消)
    public static func getText(parent: Int64, title: String, label: String, defaultText: String): String {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            var labelCstr = LibC.mallocCString(label)
            var textCstr = LibC.mallocCString(defaultText)
            
            let cstr = qInputDialogGetTextValue(parent, titleCstr, labelCstr, textCstr)
            let result = cstr.toString()
            
            LibC.free(titleCstr)
            LibC.free(labelCstr)
            LibC.free(textCstr)
            // 注意：cstr指向静态缓冲区，不要free
            
            return result
        }
    }
    
    // 获取文本输入并返回确认状态 (推荐使用)
    // 返回元组 (文本, 是否确认)，可以区分"取消"和"输入空字符串"
    public static func getTextWithResult(parent: Int64, title: String, label: String, defaultText: String): (String, Bool) {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            var labelCstr = LibC.mallocCString(label)
            var textCstr = LibC.mallocCString(defaultText)
            
            var okValue: Int32 = 0
            let cstr = qInputDialogGetTextWithOk(parent, titleCstr, labelCstr, textCstr, inout okValue)
            let result = cstr.toString()
            
            LibC.free(titleCstr)
            LibC.free(labelCstr)
            LibC.free(textCstr)
            
            return (result, okValue != 0)
        }
    }
    
    // 获取整数输入 (返回Int32最小值表示取消)
    public static func getInt(parent: Int64, title: String, label: String, value: Int32, min: Int32, max: Int32): Int32 {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            var labelCstr = LibC.mallocCString(label)
            
            let result = qInputDialogGetIntValue(parent, titleCstr, labelCstr, value, min, max)
            
            LibC.free(titleCstr)
            LibC.free(labelCstr)
            
            return result
        }
    }
    
    // 获取整数输入（返回元组，可区分取消）
    public static func getIntWithResult(parent: Int64, title: String, label: String, value: Int32, min: Int32, max: Int32): (Int32, Bool) {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            var labelCstr = LibC.mallocCString(label)
            var okValue: Int32 = 0
            
            let result = qInputDialogGetIntWithOk(parent, titleCstr, labelCstr, value, min, max, inout okValue)
            
            LibC.free(titleCstr)
            LibC.free(labelCstr)
            
            return (result, okValue != 0)
        }
    }
    
    // 获取浮点数输入 (返回NaN表示取消)
    public static func getDouble(parent: Int64, title: String, label: String, value: Float64, min: Float64, max: Float64): Float64 {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            var labelCstr = LibC.mallocCString(label)
            
            let result = qInputDialogGetDoubleValue(parent, titleCstr, labelCstr, value, min, max)
            
            LibC.free(titleCstr)
            LibC.free(labelCstr)
            
            return result
        }
    }
}

// ============================================================
// QColorDialog - 颜色对话框
// ============================================================
public class QColorDialog {
    
    // 获取颜色 (返回十六进制颜色字符串，如 "#FF0000"，空字符串表示取消)
    public static func getColor(parent: Int64, title: String): String {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            
            let cstr = qColorDialogGetColorHex(parent, titleCstr)
            let result = cstr.toString()
            
            LibC.free(titleCstr)
            // 注意：cstr指向静态缓冲区，不要free
            
            return result
        }
    }
}

// ============================================================
// QFontDialog - 字体对话框
// ============================================================
foreign func qFontDialogGetFontName(parentPtr: Int64, title: CString): CString
foreign func qFontDialogGetFontSize(parentPtr: Int64, title: CString): Int32
foreign func qFontDialogGetFontInfo(parentPtr: Int64, title: CString): CString
foreign func qFontDialogGetFontWithDefault(parentPtr: Int64, title: CString, family: CString, size: Int32, bold: Int32, italic: Int32): CString

// 字体信息类
public class QFontInfo {
    public let family: String
    public let size: Int32
    public let bold: Bool
    public let italic: Bool
    
    public init(family: String, size: Int32, bold: Bool, italic: Bool) {
        this.family = family
        this.size = size
        this.bold = bold
        this.italic = italic
    }
}


// 辅助函数：字符串转Int32
func parseSize(s: String): Int32 {
    var result: Int32 = 0
    var negative = false
    var start = 0
    if (s.size > 0 && s[0] == 45) {  // '-' ASCII码是45
        negative = true
        start = 1
    }
    for (i in start..s.size) {
        let c = s[i]
        if (c >= 48 && c <= 57) {  // '0'-'9' ASCII码是48-57
            result = result * 10 + Int32(c - 48)
        }
    }
    return if (negative) { -result } else { result }
}
public class QFontDialog {
    
    // 获取字体名称 (返回空字符串表示取消)
    public static func getFontName(parent: Int64, title: String): String {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            let cstr = qFontDialogGetFontName(parent, titleCstr)
            let result = cstr.toString()
            LibC.free(titleCstr)
            return result
        }
    }
    
    // 获取字体大小 (返回-1表示取消)
    public static func getFontSize(parent: Int64, title: String): Int32 {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            let result = qFontDialogGetFontSize(parent, titleCstr)
            LibC.free(titleCstr)
            return result
        }
    }
    
    // 获取完整字体信息 (返回None表示取消)
    public static func getFont(parent: Int64, title: String): Option<QFontInfo> {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            let cstr = qFontDialogGetFontInfo(parent, titleCstr)
            let info = cstr.toString()
            LibC.free(titleCstr)
            
            if (info.isEmpty()) {
                return None
            }
            
            // 解析格式: "Family,Size,Bold,Italic"
            let parts = info.split(",")
            if (parts.size >= 4) {
                let family = parts[0]
                let size = parseSize(parts[1])
                let bold = parts[2] == "1"
                let italic = parts[3] == "1"
                return Some(QFontInfo(family, size, bold, italic))
            }
            return None
        }
    }
    
    // 使用默认字体获取字体信息
    public static func getFontWithDefault(parent: Int64, title: String, defaultFamily: String, defaultSize: Int32, defaultBold: Bool, defaultItalic: Bool): Option<QFontInfo> {
        unsafe {
            var titleCstr = LibC.mallocCString(title)
            var familyCstr = LibC.mallocCString(defaultFamily)
            
            let cstr = qFontDialogGetFontWithDefault(parent, titleCstr, familyCstr, defaultSize, (if (defaultBold) { 1 } else { 0 }), (if (defaultItalic) { 1 } else { 0 }))
            let info = cstr.toString()
            
            LibC.free(titleCstr)
            LibC.free(familyCstr)
            
            if (info.isEmpty()) {
                return None
            }
            
            // 解析格式: "Family,Size,Bold,Italic"
            let parts = info.split(",")
            if (parts.size >= 4) {
                let family = parts[0]
                let size = parseSize(parts[1])
                let bold = parts[2] == "1"
                let italic = parts[3] == "1"
                return Some(QFontInfo(family, size, bold, italic))
            }
            return None
        }
    }
}

// ============================================================
// QProgressDialog - 进度对话框
// ============================================================
foreign func qProgressDialogCreate(parentPtr: Int64, labelText: CString, cancelButtonText: CString, minimum: Int32, maximum: Int32): Int64
foreign func qProgressDialogDelete(ptr: Int64): Unit
foreign func qProgressDialogSetValue(ptr: Int64, value: Int32): Unit
foreign func qProgressDialogValue(ptr: Int64): Int32
foreign func qProgressDialogSetMinimum(ptr: Int64, minimum: Int32): Unit
foreign func qProgressDialogSetMaximum(ptr: Int64, maximum: Int32): Unit
foreign func qProgressDialogSetLabelText(ptr: Int64, text: CString): Unit
foreign func qProgressDialogSetCancelButtonText(ptr: Int64, text: CString): Unit
foreign func qProgressDialogSetWindowTitle(ptr: Int64, title: CString): Unit
foreign func qProgressDialogSetAutoClose(ptr: Int64, autoClose: Int32): Unit
foreign func qProgressDialogSetAutoReset(ptr: Int64, autoReset: Int32): Unit
foreign func qProgressDialogWasCanceled(ptr: Int64): Int32
foreign func qProgressDialogShow(ptr: Int64): Unit
foreign func qProgressDialogHide(ptr: Int64): Unit
foreign func qProgressDialogCancel(ptr: Int64): Unit
foreign func qProgressDialogReset(ptr: Int64): Unit

public class QProgressDialog {
    private let ptr: Int64
    
    public init(parent: Int64, labelText: String, cancelButtonText: String, minimum: Int32, maximum: Int32) {
        unsafe {
            var labelCstr = LibC.mallocCString(labelText)
            var cancelCstr = LibC.mallocCString(cancelButtonText)
            ptr = qProgressDialogCreate(parent, labelCstr, cancelCstr, minimum, maximum)
            LibC.free(labelCstr)
            LibC.free(cancelCstr)
        }
    }
    
    public func setValue(value: Int32) {
        unsafe {
            qProgressDialogSetValue(ptr, value)
        }
    }
    
    public func value(): Int32 {
        unsafe {
            qProgressDialogValue(ptr)
        }
    }
    
    public func setMinimum(minimum: Int32) {
        unsafe {
            qProgressDialogSetMinimum(ptr, minimum)
        }
    }
    
    public func setMaximum(maximum: Int32) {
        unsafe {
            qProgressDialogSetMaximum(ptr, maximum)
        }
    }
    
    public func setLabelText(text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            qProgressDialogSetLabelText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setCancelButtonText(text: String) {
        unsafe {
            var cstr = LibC.mallocCString(text)
            qProgressDialogSetCancelButtonText(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setWindowTitle(title: String) {
        unsafe {
            var cstr = LibC.mallocCString(title)
            qProgressDialogSetWindowTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setAutoClose(autoClose: Bool) {
        unsafe {
            qProgressDialogSetAutoClose(ptr, (if (autoClose) { 1 } else { 0 }))
        }
    }
    
    public func setAutoReset(autoReset: Bool) {
        unsafe {
            qProgressDialogSetAutoReset(ptr, (if (autoReset) { 1 } else { 0 }))
        }
    }
    
    public func wasCanceled(): Bool {
        unsafe {
            qProgressDialogWasCanceled(ptr) == 1
        }
    }
    
    public func show() {
        unsafe {
            qProgressDialogShow(ptr)
        }
    }
    
    public func hide() {
        unsafe {
            qProgressDialogHide(ptr)
        }
    }
    
    public func cancel() {
        unsafe {
            qProgressDialogCancel(ptr)
        }
    }
    
    public func reset() {
        unsafe {
            qProgressDialogReset(ptr)
        }
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qProgressDialogDelete(ptr)
            }
        }
    }
}
