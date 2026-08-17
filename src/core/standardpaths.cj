package cjqt6.core

// ============================================================
// QStandardPaths - 标准路径
// ============================================================

foreign func qStandardPathWritableLocation(`type`: Int32): CString
foreign func qStandardPathLocate(`type`: Int32, fileName: CString): CString
foreign func qStandardPathDisplayName(`type`: Int32): CString
foreign func qStandardPathTempDir(): CString

/// 标准路径位置类型：桌面
public const StandardLocationDesktop: Int32 = 0
/// 标准路径位置类型：文档
public const StandardLocationDocuments: Int32 = 1
/// 标准路径位置类型：字体
public const StandardLocationFonts: Int32 = 2
/// 标准路径位置类型：应用程序
public const StandardLocationApplications: Int32 = 3
/// 标准路径位置类型：音乐
public const StandardLocationMusic: Int32 = 4
/// 标准路径位置类型：影片
public const StandardLocationMovies: Int32 = 5
/// 标准路径位置类型：图片
public const StandardLocationPictures: Int32 = 6
/// 标准路径位置类型：临时目录
public const StandardLocationTemp: Int32 = 7
/// 标准路径位置类型：主目录
public const StandardLocationHome: Int32 = 8
/// 标准路径位置类型：应用本地数据
public const StandardLocationAppLocalData: Int32 = 9
/// 标准路径位置类型：应用配置
public const StandardLocationAppConfig: Int32 = 10
/// 标准路径位置类型：下载
public const StandardLocationDownload: Int32 = 11
/// 标准路径位置类型：通用数据
public const StandardLocationGenericData: Int32 = 12
/// 标准路径位置类型：运行时数据
public const StandardLocationRuntime: Int32 = 13
/// 标准路径位置类型：配置文件
public const StandardLocationConfig: Int32 = 14
/// 标准路径位置类型：通用缓存
public const StandardLocationGenericCache: Int32 = 15
/// 标准路径位置类型：应用本地数据（本地化）
public const StandardLocationAppLocalDataLocation: Int32 = 16
/// 标准路径位置类型：应用配置（本地化）
public const StandardLocationAppConfigLocation: Int32 = 17

/// 系统标准目录查询，用于获取各平台约定的文档/配置/缓存等路径（静态方法，无需实例化）
public class QStandardPaths {
    /// 获取指定类型位置中可写的目录路径，失败时返回空字符串
    public static func writableLocation(`type`: Int32): String { // cjlint-ignore !G.FUN.02 反引号参数名被cjlint误判
        unsafe {
            let cstr = qStandardPathWritableLocation(`type`)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 在指定类型位置中查找文件，找到返回完整路径，否则返回空字符串
    public static func locate(`type`: Int32, fileName: String): String { // cjlint-ignore !G.FUN.02 反引号参数名被cjlint误判
        unsafe {
            let cstrFile = LibC.mallocCString(fileName)
            let cstr = qStandardPathLocate(`type`, cstrFile)
            let result = cstr.toString()
            freeBridgeString(cstr)
            LibC.free(cstrFile)
            return result
        }
    }

    /// 获取指定类型位置的本地化显示名称（如"文档"、"图片"）
    public static func displayName(`type`: Int32): String { // cjlint-ignore !G.FUN.02 反引号参数名被cjlint误判
        unsafe {
            let cstr = qStandardPathDisplayName(`type`)
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 获取系统临时目录路径（自动带路径分隔符）
    public static func tempDir(): String {
        unsafe {
            let cstr = qStandardPathTempDir()
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }
}
