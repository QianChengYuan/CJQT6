package cjqt6.core

// ============================================================
// QClipboard - 剪贴板
// ============================================================

foreign func qClipboardText(): CString
foreign func qClipboardSetText(text: CString): Unit
foreign func qClipboardHasText(): Bool
foreign func qClipboardClear(): Unit

/// 系统剪贴板，提供文本的读取、写入、清空与存在性判断（静态方法，无需实例化）
public class QClipboard {
    /// 获取剪贴板中的纯文本，无文本时返回空字符串
    public static func text(): String {
        unsafe {
            let cstr = qClipboardText()
            return cstr.toString()
        }
    }

    /// 将指定文本写入剪贴板
    public static func setText(text: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qClipboardSetText(cstr)
            LibC.free(cstr)
        }
    }

    /// 剪贴板中是否包含文本
    public static func hasText(): Bool {
        unsafe {
            return qClipboardHasText()
        }
    }

    /// 清空剪贴板内容
    public static func clear(): Unit {
        unsafe {
            qClipboardClear()
        }
    }
}
