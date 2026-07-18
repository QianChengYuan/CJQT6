package cjqt6.core

foreign func qDesktopServicesOpenUrl(url: CString): Bool
foreign func qDesktopServicesOpenFile(filePath: CString): Bool

public class QDesktopServices {
    public static func openUrl(url: String): Bool {
        unsafe {
            let cstr = LibC.mallocCString(url)
            let result = qDesktopServicesOpenUrl(cstr)
            LibC.free(cstr)
            return result
        }
    }

    public static func openFile(filePath: String): Bool {
        unsafe {
            let cstr = LibC.mallocCString(filePath)
            let result = qDesktopServicesOpenFile(cstr)
            LibC.free(cstr)
            return result
        }
    }
}
