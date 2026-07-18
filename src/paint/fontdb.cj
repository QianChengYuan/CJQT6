package cjqt6.paint

foreign func qFontDatabaseFamilies(): CString
foreign func qFontDatabaseStandardSizes(): Int32
foreign func qFontDatabaseIsFixedPitch(family: CString, style: CString): Bool
foreign func qFontDatabaseIsScalable(family: CString): Bool
foreign func qFontDatabaseStyles(family: CString): CString
foreign func qFontDatabasePointSizes(family: CString, style: CString): Int32

public class QFontDatabase {
    public static func families(): String {
        unsafe {
            let cstr = qFontDatabaseFamilies()
            cstr.toString()
        }
    }

    public static func standardSizes(): Int32 {
        unsafe { qFontDatabaseStandardSizes() }
    }

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

    public static func isScalable(family: String): Bool {
        unsafe {
            let f = LibC.mallocCString(family)
            let result = qFontDatabaseIsScalable(f)
            LibC.free(f)
            result
        }
    }

    public static func styles(family: String): String {
        unsafe {
            let f = LibC.mallocCString(family)
            let cstr = qFontDatabaseStyles(f)
            LibC.free(f)
            cstr.toString()
        }
    }

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
