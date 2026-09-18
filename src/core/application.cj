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
    public static func chinese(): String {
        "zh_CN"
    }
    public static func chineseSimplified(): String {
        "zh_CN"
    }
    public static func chineseTraditional(): String {
        "zh_TW"
    }
    public static func english(): String {
        "en_US"
    }
    public static func japanese(): String {
        "ja_JP"
    }
    public static func korean(): String {
        "ko_KR"
    }
}

// ============================================================
// GUI 线程守卫（见 docs/internal/cjmonitor-findings.md P1-5）
// ------------------------------------------------------------
// Qt 要求控件的创建/显示/销毁都在 QApplication 所属线程执行。实测在其它线程销毁一个
// 「已显示」的顶层 QWidget，会阻塞在：
//   QWidget::~QWidget → QWindow::close() → QWindowSystemInterface::flushWindowSystemEvents()
//   → QWaitCondition::wait()
// 该等待需 app 线程处理事件才会被唤醒；当 app 线程不再跑事件循环（测试框架把用例派到
// adopted worker 线程、或应用把 GUI 操作放到后台线程）时即永久阻塞（CPU 0%，不会自愈）。
// 这里记录 app 所属线程，并提供快速失败入口，把「静默挂死」变成「可诊断错误」。
// ============================================================

/// QApplication 所属线程指针（0 表示尚未创建 app，此时不施加线程约束）
private var gAppThreadPtr: Int64 = 0

/// 记录 QApplication 所属线程（由 QApplication.init 调用；只在首次创建时记录）
func recordAppThreadPtr(threadPtr: Int64): Unit {
    if (gAppThreadPtr == 0) {
        gAppThreadPtr = threadPtr
    }
}

/// 当前线程是否为 QApplication 所属线程。尚未创建 app 时返回 true（不施加约束）。
public func isGuiThread(): Bool {
    if (gAppThreadPtr == 0) {
        return true
    }
    QThread.currentThreadPtr() == gAppThreadPtr
}

/// 查询 QApplication 所属线程指针（0 表示尚未创建 app）。
/// 用途：调用方自行判断「本线程能否做 GUI 操作」，或把 GUI 操作投递回该线程。
public func guiThreadPtr(): Int64 {
    gAppThreadPtr
}

/// 校验当前线程是否为 QApplication 所属线程，不是则抛异常。
/// throws: GuiThreadViolationException 在非 GUI 线程执行 GUI 操作时抛出
public func checkGuiThread(operation: String): Unit {
    if (!isGuiThread()) {
        throw GuiThreadViolationException(
            "${operation} 必须在 QApplication 所属线程调用：Qt 要求控件（尤其顶层窗口）的创建/显示/销毁在同一线程；跨线程销毁已显示的顶层控件会永久阻塞在 QWindowSystemInterface::flushWindowSystemEvents 的等待上。"
        )
    }
}

/// 应用程序主类，管理 Qt 应用生命周期（创建/事件循环/退出）与界面翻译语言
public class QApplication {
    private var ptr: Int64 = 0

    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        recordAppThreadPtr(QThread.currentThreadPtr())
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
