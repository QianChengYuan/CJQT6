package cjqt6.core

foreign func qStandardPathWritableLocation(`type`: Int32): CString
foreign func qStandardPathLocate(`type`: Int32, fileName: CString): CString
foreign func qStandardPathDisplayName(`type`: Int32): CString
foreign func qStandardPathTempDir(): CString

public const StandardLocationDesktop: Int32 = 0
public const StandardLocationDocuments: Int32 = 1
public const StandardLocationFonts: Int32 = 2
public const StandardLocationApplications: Int32 = 3
public const StandardLocationMusic: Int32 = 4
public const StandardLocationMovies: Int32 = 5
public const StandardLocationPictures: Int32 = 6
public const StandardLocationTemp: Int32 = 7
public const StandardLocationHome: Int32 = 8
public const StandardLocationAppLocalData: Int32 = 9
public const StandardLocationAppConfig: Int32 = 10
public const StandardLocationDownload: Int32 = 11
public const StandardLocationGenericData: Int32 = 12
public const StandardLocationRuntime: Int32 = 13
public const StandardLocationConfig: Int32 = 14
public const StandardLocationGenericCache: Int32 = 15
public const StandardLocationAppLocalDataLocation: Int32 = 16
public const StandardLocationAppConfigLocation: Int32 = 17

public class QStandardPaths {
    public static func writableLocation(`type`: Int32): String {
        unsafe {
            let cstr = qStandardPathWritableLocation(`type`)
            return cstr.toString()
        }
    }

    public static func locate(`type`: Int32, fileName: String): String {
        unsafe {
            let cstrFile = LibC.mallocCString(fileName)
            let cstr = qStandardPathLocate(`type`, cstrFile)
            LibC.free(cstrFile)
            return cstr.toString()
        }
    }

    public static func displayName(`type`: Int32): String {
        unsafe {
            let cstr = qStandardPathDisplayName(`type`)
            return cstr.toString()
        }
    }

    public static func tempDir(): String {
        unsafe {
            let cstr = qStandardPathTempDir()
            return cstr.toString()
        }
    }
}
