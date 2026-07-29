// Qt6 检测工具
// 编译: cjc check_qt6.cj -o check_qt6.exe --import-path "<CANGJIE_HOME>/modules/<platform>/std"
// 用法: check_qt6.exe [Qt路径]
// 编译并运行：cjc check_qt6.cj -o check_qt6.exe; .\check_qt6.exe

import std.env.*
import std.fs.*
import std.collection.*

class Qt6Info {
    let path: Path
    let version: String
    let components: Array<String>

    init(path: Path, version: String, components: Array<String>) {
        this.path = path
        this.version = version
        this.components = components
    }

    func isVersionCompatible(minVersion: String): Bool {
        // 语义化版本号比较: "6.10.3" >= "6.2.0"
        let thisParts = this.version.split(".")
        let minParts = minVersion.split(".")
        let maxLen = if (thisParts.size > minParts.size) { thisParts.size } else { minParts.size }
        for (i in 0..maxLen) {
            let thisV = if (i < thisParts.size) {
                var n: Int64 = 0
                for (c in thisParts[i]) { if (c >= 48 && c <= 57) { n = n * 10 + Int64(c - 48) } }
                n
            } else { 0 }
            let minV = if (i < minParts.size) {
                var n: Int64 = 0
                for (c in minParts[i]) { if (c >= 48 && c <= 57) { n = n * 10 + Int64(c - 48) } }
                n
            } else { 0 }
            if (thisV < minV) { return false }
            if (thisV > minV) { return true }
        }
        return true
    }
}

func getSearchPaths(): Array<Path> {
    let paths = ArrayList<Path>()

    // 1. 命令行参数
    let args = getCommandLine()
    if (args.size > 1) {
        paths.add(Path(args[1]))
    }

    // 2. 环境变量 QTDIR
    let qtdirOpt = getVariable("QTDIR")
    if (let Some(qtdir) <- qtdirOpt) {
        paths.add(Path(qtdir))
    }

    // 3. 常见安装路径 (Windows)
    paths.add(Path("C:\\Qt\\6.10.3\\msvc2022_64"))
    paths.add(Path("C:\\Qt\\6.10.2\\msvc2022_64"))
    paths.add(Path("C:\\Qt\\6.7.0\\msvc2019_64"))

    return paths.toArray()
}

func checkQt6Path(path: Path): ?Qt6Info {
    // 检查路径是否存在
    if (!exists(path)) {
        return None
    }

    // 检查 Qt6Core.dll
    let qtCoreLib = path.join("bin").join("Qt6Core.dll")
    if (!exists(qtCoreLib)) {
        return None
    }

    // 解析版本号
    let version = parseQtVersion(path.toString())

    // 检测可用组件
    let components = detectComponents(path)

    return Some(Qt6Info(path, version, components))
}

func parseQtVersion(pathStr: String): String {
    // 从路径中提取版本号 (e.g. "C:\Qt\6.10.3\msvc2022_64" -> "6.10.3")
    let parts = pathStr.split("\\")
    for (part in parts) {
        if (part.startsWith("6.")) {
            return part
        }
    }
    let parts2 = pathStr.split("/")
    for (part in parts2) {
        if (part.startsWith("6.")) {
            return part
        }
    }
    return "6.0.0"
}

func detectComponents(path: Path): Array<String> {
    let components = ArrayList<String>()
    let binDir = path.join("bin")
    
    // 扫描 bin 目录下所有 Qt6 动态库，只取 release 版（过滤掉 debug 的 "d" 后缀）
    if (exists(binDir)) {
        let seen = ArrayList<String>()
        let entries = Directory.readFrom(binDir)
        for (entry in entries) {
            let name = entry.name
            if (name.startsWith("Qt6") && (name.endsWith(".dll") || name.endsWith(".so") || name.endsWith(".dylib"))) {
                // 去掉扩展名
                let dotIdx = name.size - 4
                var compName = if (dotIdx > 0) { name[0..dotIdx] } else { name }
                // 去掉末尾的 "d"（debug 版标记），保留 release 版
                if (compName.size > 0 && compName[compName.size - 1] == 100) { // 'd'
                    compName = compName[0..compName.size - 1]
                }
                // 去重
                var alreadyAdded = false
                for (s in seen) {
                    if (s == compName) { alreadyAdded = true; break }
                }
                if (!alreadyAdded) {
                    seen.add(compName)
                    components.add(compName)
                }
            }
        }
        // 排序
        components.sort()
    }
    
    return components.toArray()
}

func detectQt6(): ?Qt6Info {
    let searchPaths = getSearchPaths()
    for (path in searchPaths) {
        if (let Some(info) <- checkQt6Path(path)) {
            return Some(info)
        }
    }
    return None
}

main() {
    println("Qt6 检测工具")
    println("=====================================")

    let qt6Info = detectQt6()

    match (qt6Info) {
        case Some(info) =>
            println("✓ Qt6 已找到")
            println("")
            println("安装路径: ${info.path}")
            println("版本: ${info.version}")
            let compStr = StringBuilder()
            var first = true
            for (c in info.components) {
                if (!first) {
                    compStr.append(", ")
                }
                compStr.append(c)
                first = false
            }
            println("组件: ${compStr.toString()}")
            println("")

            if (info.isVersionCompatible("6.2.0")) {
                println("✓ 版本符合要求 (>= 6.2)")
            } else {
                println("⚠ 版本过低，建议升级到 Qt6.2 或更高版本")
            }

        case None =>
            println("✗ 未找到Qt6安装")
            println("")
            println("请安装 Qt6 (>= 6.2) 并确保正确配置:")
            println("")
            println("Windows:")
            println("  从 https://www.qt.io/download 下载安装")
            println("  并设置环境变量: set QTDIR=C:\\Qt\\6.10.3\\msvc2022_64")
    }
}
