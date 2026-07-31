package cjqt6.paint

// ============================================================
// QFontDatabase - 字体数据库
// ============================================================

foreign func qFontDatabaseFamilies(): CString
foreign func qFontDatabaseStandardSizes(): Int32
foreign func qFontDatabaseIsFixedPitch(family: CString, style: CString): Bool
foreign func qFontDatabaseIsScalable(family: CString): Bool
foreign func qFontDatabaseStyles(family: CString): CString
foreign func qFontDatabasePointSizes(family: CString, style: CString): Int32

/// 系统字体数据库，查询可用字体族、样式与字号信息（静态方法，无需实例化）
public class QFontDatabase {
    /// 获取系统全部可用字体族名称（多个名称以逗号分隔）
    public static func families(): String {
        unsafe {
            let cstr = qFontDatabaseFamilies()
            cstr.toString()
        }
    }

    /// 获取系统标准字号列表（通常为 6 到 40 的等差序列）
    public static func standardSizes(): Int32 {
        unsafe { qFontDatabaseStandardSizes() }
    }

    /// 指定字体族/样式的字体是否为等宽字体
    public static func isFixedPitch(family: String, style: String): Bool {
        unsafe {
            let f = LibC.mallocCString(family)
            let s = LibC.mallocCString(style)
            let result = qFontDatabaseIsFixedPitch(f, s)
            LibC.free(f)
            LibC.free(s)
            result
        }
    }

    /// 指定字体族是否可缩放（TrueType 等矢量字体返回 true）
    public static func isScalable(family: String): Bool {
        unsafe {
            let f = LibC.mallocCString(family)
            let result = qFontDatabaseIsScalable(f)
            LibC.free(f)
            result
        }
    }

    /// 获取指定字体族支持的样式名称（如 Regular/Bold/Italic，多个以逗号分隔）
    public static func styles(family: String): String {
        unsafe {
            let f = LibC.mallocCString(family)
            let cstr = qFontDatabaseStyles(f)
            LibC.free(f)
            cstr.toString()
        }
    }

    /// 获取指定字体族/样式支持的字号（磅值，多个以逗号分隔的数字）
    public static func pointSizes(family: String, style: String): Int32 {
        unsafe {
            let f = LibC.mallocCString(family)
            let s = LibC.mallocCString(style)
            let result = qFontDatabasePointSizes(f, s)
            LibC.free(f)
            LibC.free(s)
            result
        }
    }
}
