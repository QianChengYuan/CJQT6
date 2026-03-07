package CJQT6.dialogs

// ============================================================
// 对话框 FFI声明
// ============================================================

// QMessageBox
foreign func qMessageBoxInformation(parentPtr: Int64, title: CString, text: CString): Unit
foreign func qMessageBoxWarning(parentPtr: Int64, title: CString, text: CString): Unit
foreign func qMessageBoxCritical(parentPtr: Int64, title: CString, text: CString): Unit
foreign func qMessageBoxQuestion(parentPtr: Int64, title: CString, text: CString): Int32

// QFileDialog
foreign func qFileDialogGetOpenFileName(parentPtr: Int64, title: CString, filter: CString): CString
foreign func qFileDialogGetSaveFileName(parentPtr: Int64, title: CString, filter: CString): CString
foreign func qFileDialogGetExistingDirectory(parentPtr: Int64, title: CString): CString

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
            LibC.free(cstr)
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
            LibC.free(cstr)
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
            LibC.free(cstr)
            return result
        }
    }
}
