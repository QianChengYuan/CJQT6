package CJQT6.core

// QApplication - 应用程序主类
foreign func qApplicationCreate(): Int64
foreign func qApplicationExec(): Int32
foreign func qApplicationQuit(): Unit
foreign func qApplicationDelete(ptr: Int64): Unit

// 翻译/语言相关
foreign func qApplicationLoadQtTranslation(locale: CString): Bool
foreign func qApplicationLoadAppTranslation(qmFile: CString, directory: CString): Bool
foreign func qApplicationSetLocale(locale: CString): Unit
foreign func qApplicationLocale(): CString
foreign func qApplicationSystemLocale(): CString
foreign func qApplicationSwitchLanguage(locale: CString): Bool

/// 语言类型
public class Language {
    public static func chinese(): String { "zh_CN" }
    public static func chineseSimplified(): String { "zh_CN" }
    public static func chineseTraditional(): String { "zh_TW" }
    public static func english(): String { "en_US" }
    public static func japanese(): String { "ja_JP" }
    public static func korean(): String { "ko_KR" }
}

public class QApplication {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qApplicationCreate()
        }
    }
    
    public func exec(): Int32 {
        unsafe {
            qApplicationExec()
        }
    }
    
    public func quit() {
        unsafe {
            qApplicationQuit()
        }
    }
    
    // ==================== 语言/翻译相关 ====================
    
    /// 加载Qt内置翻译（用于对话框等显示中文）
    /// locale: 语言代码，如 "zh_CN"，为空则使用系统语言
    public func loadQtTranslation(locale: String): Bool {
        unsafe {
            var cstr = LibC.mallocCString(locale)
            let result = qApplicationLoadQtTranslation(cstr)
            LibC.free(cstr)
            return result
        }
    }
    
    /// 加载应用程序翻译文件
    public func loadAppTranslation(qmFile: String, directory: String): Bool {
        unsafe {
            var qmCstr = LibC.mallocCString(qmFile)
            var dirCstr = LibC.mallocCString(directory)
            let result = qApplicationLoadAppTranslation(qmCstr, dirCstr)
            LibC.free(qmCstr)
            LibC.free(dirCstr)
            return result
        }
    }
    
    /// 设置应用程序语言环境
    public func setLocale(locale: String) {
        unsafe {
            var cstr = LibC.mallocCString(locale)
            qApplicationSetLocale(cstr)
            LibC.free(cstr)
        }
    }
    
    /// 获取当前语言环境
    public func locale(): String {
        unsafe {
            let cstr = qApplicationLocale()
            return cstr.toString()
        }
    }
    
    /// 获取系统语言环境
    public func systemLocale(): String {
        unsafe {
            let cstr = qApplicationSystemLocale()
            return cstr.toString()
        }
    }
    
    /// 切换语言（设置locale并加载Qt翻译）
    /// locale: 语言代码，如 "zh_CN"，为空则恢复系统默认
    public func switchLanguage(locale: String): Bool {
        unsafe {
            var cstr = LibC.mallocCString(locale)
            let result = qApplicationSwitchLanguage(cstr)
            LibC.free(cstr)
            return result
        }
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qApplicationDelete(ptr)
            }
            ptr = 0
        }
    }
}
