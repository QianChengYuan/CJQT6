package cjqt6.core

// ============================================================
// QDesktopServices - 桌面服务
// ============================================================

foreign func qDesktopServicesOpenUrl(url: CString): Bool
foreign func qDesktopServicesOpenFile(filePath: CString): Bool

/// 桌面级服务，提供使用系统默认程序打开 URL 或文件的能力（静态方法，无需实例化）
public class QDesktopServices {
    /// 使用系统默认浏览器/关联程序打开指定 URL（http/https/mailto 等），成功返回 true
    public static func openUrl(url: String): Bool {
        unsafe {
            let cstr = LibC.mallocCString(url)
            let result = qDesktopServicesOpenUrl(cstr)
            LibC.free(cstr)
            return result
        }
    }

    /// 使用系统默认关联程序打开指定文件，成功返回 true
    public static func openFile(filePath: String): Bool {
        unsafe {
            let cstr = LibC.mallocCString(filePath)
            let result = qDesktopServicesOpenFile(cstr)
            LibC.free(cstr)
            return result
        }
    }
}
