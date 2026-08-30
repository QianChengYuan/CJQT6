package cjqt6.core

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

// 应用级全局样式表（QSS）
foreign func qApplicationSetStyleSheet(styleSheet: CString): Unit
foreign func qApplicationStyleSheet(): CString

// QLocale 封装（句柄为堆分配的 QLocale*，非 QObject，不入存活表）
foreign func qLocaleCreate(name: CString): Int64
foreign func qLocaleDelete(ptr: Int64): Unit
foreign func qLocaleName(ptr: Int64): CString
foreign func qLocaleNativeLanguageName(ptr: Int64): CString
foreign func qLocaleNativeTerritoryName(ptr: Int64): CString
foreign func qLocaleLanguageName(ptr: Int64): CString
foreign func qLocaleTerritoryName(ptr: Int64): CString
foreign func qLocaleLanguage(ptr: Int64): Int32
foreign func qLocaleTerritory(ptr: Int64): Int32

/// 静态方法
public class QApp {
    public static func quit(): Unit {
        unsafe { qApplicationQuit() }
    }

    /// 设置应用级全局样式表（QSS，作用于所有控件，可被控件自身 setStyleSheet 覆盖）
    public static func setStyleSheet(styleSheet: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(styleSheet)
            qApplicationSetStyleSheet(cstr)
            LibC.free(cstr)
        }
    }

    /// 获取应用级全局样式表
    public static func styleSheet(): String {
        unsafe {
            let cstr = qApplicationStyleSheet()
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
}

/// 语言类型
public class Language {
    public static func chinese(): String { "zh_CN" }
    public static func chineseSimplified(): String { "zh_CN" }
    public static func chineseTraditional(): String { "zh_TW" }
    public static func english(): String { "en_US" }
    public static func japanese(): String { "ja_JP" }
    public static func korean(): String { "ko_KR" }
}

/// 应用程序主类，管理 Qt 应用生命周期（创建/事件循环/退出）与界面翻译语言
public class QApplication {
    private var ptr: Int64 = 0
    
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qApplicationCreate()
            if (ptr == 0) {
                throw CreateFailedException("QApplication 创建失败")
            }
        }
    }
    
    public func exec(): Int32 {
        unsafe {
            qApplicationExec()
        }
    }
    
    public func quit(): Unit {
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
    public func setLocale(locale: String): Unit {
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
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
    
    /// 获取系统语言环境
    public func systemLocale(): String {
        unsafe {
            let cstr = qApplicationSystemLocale()
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
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
    
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qApplicationDelete(ptr)
            }
            ptr = 0
        }
    }
}

/// QLocale - 语言环境信息封装（句柄为堆分配的 QLocale*，非 QObject，需显式 close/delete）
public class QLocale {
    private var ptr: Int64 = 0

    /// 创建语言环境；name 为空字符串时使用系统默认语言环境（如 "zh_CN"、"en_US"）
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init(name: String) {
        unsafe {
            let cstr = LibC.mallocCString(name)
            ptr = qLocaleCreate(cstr)
            LibC.free(cstr)
            if (ptr == 0) {
                throw CreateFailedException("QLocale 创建失败")
            }
        }
    }

    /// 使用系统默认语言环境创建
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            let cstr = LibC.mallocCString("")
            ptr = qLocaleCreate(cstr)
            LibC.free(cstr)
            if (ptr == 0) {
                throw CreateFailedException("QLocale 创建失败")
            }
        }
    }

    /// 语言环境代码，如 "zh_CN"、"en_US"
    public func name(): String {
        unsafe {
            let cstr = qLocaleName(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 本地语言的名称，如中文为 "中文"
    public func nativeLanguageName(): String {
        unsafe {
            let cstr = qLocaleNativeLanguageName(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 本地语言中地区名称，如中国为 "中国"
    public func nativeTerritoryName(): String {
        unsafe {
            let cstr = qLocaleNativeTerritoryName(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 英文语言名称，如 "Chinese"
    public func languageName(): String {
        unsafe {
            let cstr = qLocaleLanguageName(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 英文地区名称，如 "China"
    public func territoryName(): String {
        unsafe {
            let cstr = qLocaleTerritoryName(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 语言枚举值（QLocale::Language），如 zh 对应 33
    public func language(): Int32 {
        unsafe { qLocaleLanguage(ptr) }
    }

    /// 地区枚举值（QLocale::Territory），如 CN 对应 43
    public func territory(): Int32 {
        unsafe { qLocaleTerritory(ptr) }
    }

    /// 释放语言环境
    public func close(): Unit {
        if (ptr != 0) {
            unsafe {
                qLocaleDelete(ptr)
            }
            ptr = 0
        }
    }
}
