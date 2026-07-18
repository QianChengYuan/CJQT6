package cjqt6.core

foreign func qClipboardText(): CString
foreign func qClipboardSetText(text: CString): Unit
foreign func qClipboardHasText(): Bool
foreign func qClipboardClear(): Unit

public class QClipboard {
    public static func text(): String {
        unsafe {
            let cstr = qClipboardText()
            return cstr.toString()
        }
    }

    public static func setText(text: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qClipboardSetText(cstr)
            LibC.free(cstr)
        }
    }

    public static func hasText(): Bool {
        unsafe {
            return qClipboardHasText()
        }
    }

    public static func clear(): Unit {
        unsafe {
            qClipboardClear()
        }
    }
}
