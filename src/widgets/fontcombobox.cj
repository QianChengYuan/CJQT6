package cjqt6.widgets

foreign func qFontComboBoxCreate(): Int64
foreign func qFontComboBoxCreateWithParent(parentPtr: Int64): Int64
foreign func qFontComboBoxSetCurrentFont(ptr: Int64, family: CString): Unit
foreign func qFontComboBoxCurrentFont(ptr: Int64): CString
foreign func qFontComboBoxSetWritingSystem(ptr: Int64, ws: Int32): Unit
foreign func qFontComboBoxSetFontFilters(ptr: Int64, filters: Int32): Unit
foreign func qFontComboBoxDelete(ptr: Int64): Unit

public class FontWritingSystem {
    public static let Any: Int32 = 0
    public static let Latin: Int32 = 1
    public static let Greek: Int32 = 2
    public static let Cyrillic: Int32 = 3
    public static let Arabic: Int32 = 4
    public static let Hebrew: Int32 = 5
    public static let Japanese: Int32 = 6
    public static let Korean: Int32 = 7
    public static let Chinese: Int32 = 8
    public static let SimplifiedChinese: Int32 = 9
    public static let TraditionalChinese: Int32 = 10
}

public class QFontComboBox {
    private var ptr: Int64 = 0

    public init(parent!: Int64 = 0) {
        unsafe { ptr = qFontComboBoxCreateWithParent(parent) }
    }

    public func show(): Unit {
        unsafe { qWidgetShow(ptr) }
    }

    public func hide(): Unit {
        unsafe { qWidgetHide(ptr) }
    }

    public func resize(width: Int32, height: Int32): Unit {
        unsafe { qWidgetResize(ptr, width, height) }
    }

    public func setStyleSheet(styleSheet: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(styleSheet)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func setCurrentFont(family: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(family)
            qFontComboBoxSetCurrentFont(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func currentFont(): String {
        unsafe {
            let cstr = qFontComboBoxCurrentFont(ptr)
            return cstr.toString()
        }
    }

    public func setWritingSystem(ws: Int32): Unit {
        unsafe { qFontComboBoxSetWritingSystem(ptr, ws) }
    }

    public func setFontFilters(filters: Int32): Unit {
        unsafe { qFontComboBoxSetFontFilters(ptr, filters) }
    }

    public func getPtr(): Int64 {
        ptr
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qSignalCleanup(ptr)
                qFontComboBoxDelete(ptr)
            }
            ptr = 0
        }
    }
}
