package CJQT6.dialogs

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

// QInputDialog (简化版，直接返回值)
foreign func qInputDialogGetTextValue(parentPtr: Int64, title: CString, label: CString, text: CString): CString
foreign func qInputDialogGetIntValue(parentPtr: Int64, title: CString, label: CString, value: Int32, min: Int32, max: Int32): Int32
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
