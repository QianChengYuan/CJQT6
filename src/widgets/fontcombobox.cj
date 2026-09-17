package cjqt6.widgets

import cjqt6.core.*

foreign func qFontComboBoxCreate(): Int64

foreign func qFontComboBoxCreateWithParent(parentPtr: Int64): Int64

foreign func qFontComboBoxSetCurrentFont(ptr: Int64, family: CString): Unit

foreign func qFontComboBoxCurrentFont(ptr: Int64): CString

foreign func qFontComboBoxSetWritingSystem(ptr: Int64, ws: Int32): Unit

foreign func qFontComboBoxSetFontFilters(ptr: Int64, filters: Int32): Unit

foreign func qFontComboBoxWritingSystem(ptr: Int64): Int32

foreign func qFontComboBoxFontFilters(ptr: Int64): Int32

foreign func qFontComboBoxDelete(ptr: Int64): Unit

/// 字体筛选器标志位（对应 QFontComboBox::FontFilters，可按位或组合）
public class FontFilters {
    public static let None: Int32 = 0
    public static let ScalableFonts: Int32 = 1
    public static let NonScalableFonts: Int32 = 2
    public static let MonospacedFonts: Int32 = 4
    public static let ProportionalFonts: Int32 = 8
}

/// 书写系统枚举，用于过滤字体列表中显示的书写系统（对应 QFontDatabase::WritingSystem）
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

/// 字体选择下拉框，列出系统可用字体族，支持按书写系统与字体筛选器过滤
public class QFontComboBox <: QtWidgetCore {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public init(parent!: Int64 = 0) {
        unsafe { ptr = qFontComboBoxCreateWithParent(parent) }
        trackObject(ptr)
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
            withCString(styleSheet) {c => qWidgetSetStyleSheet(ptr, c)}
        }
    }

    public func setCurrentFont(family: String): Unit {
        unsafe {
            withCString(family) {c => qFontComboBoxSetCurrentFont(ptr, c)}
        }
    }

    public func currentFont(): String {
        unsafe {
            let cstr = qFontComboBoxCurrentFont(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    public func setWritingSystem(ws: Int32): Unit {
        unsafe { qFontComboBoxSetWritingSystem(ptr, ws) }
    }

    public func setFontFilters(filters: Int32): Unit {
        unsafe { qFontComboBoxSetFontFilters(ptr, filters) }
    }

    /// 获取当前书写系统
    public func writingSystem(): Int32 {
        unsafe { qFontComboBoxWritingSystem(ptr) }
    }

    /// 获取当前字体筛选器标志位
    public func fontFilters(): Int32 {
        unsafe { qFontComboBoxFontFilters(ptr) }
    }

    public func getPtr(): Int64 {
        ptr
    }

    /// 是否已关闭
    public func isClosed(): Bool {
        closed
    }

    /// 对象是否仍然可用
    public func isValid(): Bool {
        !closed && ptr != 0 && isObjectAlive(ptr)
    }

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QFontComboBox 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QFontComboBox 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QFontComboBox 底层 Qt 对象已失效")
        }
    }

    /// 关闭资源，释放 Qt 对象（幂等）
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
                qFontComboBoxDelete(ptr)
            }
        }
        closed = true
        ptr = 0
    }

    /// 删除部件（兼容旧 API，等价于 close()）
    public func delete(): Unit {
        close()
    }
}
