// Qt6 检测模块
// 扫描 Qt6 安装路径、版本号、可用组件

package Cjqt6Diagnose

import std.env.*
import std.fs.*
import std.collection.*
import std.sort.*

class Qt6Info {
    let path: String
    let version: String
    let components: Array<String>

    init(path: String, version: String, components: Array<String>) {
        this.path = path
        this.version = version
        this.components = components
    }

    func isVersionCompatible(minVersion: String): Bool {
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

func detectQt6(): ?Qt6Info {
    // 1. 命令行参数
    let args = getCommandLine()
    if (args.size > 1) {
        let p = Path(args[1])
        if (let Some(info) <- checkQt6Path(p)) {
            return Some(info)
        }
    }

    // 2. 环境变量 QTDIR
    if (let Some(qtdir) <- getVariable("QTDIR")) {
        if (let Some(info) <- checkQt6Path(Path(qtdir))) {
            return Some(info)
        }
    }

    // 3. 扫描 C:\Qt\6.*\ 中的 msvc 目录
    let qtBase = Path("C:\\Qt")
    if (exists(qtBase)) {
        let entries = Directory.readFrom(qtBase)
        // 收集所有候选路径
        let candidates = ArrayList<Path>()
        for (entry in entries) {
            let childPath = qtBase.join(entry.name)
            if (entry.name.startsWith("6.") && isDir(childPath)) {
                let subEntries = Directory.readFrom(childPath)
                for (sub in subEntries) {
                    let subPath = childPath.join(sub.name)
                    if (sub.name.startsWith("msvc") && isDir(subPath)) {
                        candidates.add(subPath)
                    }
                }
            }
        }
        // 优先尝试高版本
        for (i in candidates.size - 1..0) {
            if (let Some(info) <- checkQt6Path(candidates[i])) {
                return Some(info)
            }
        }
    }

    // 4. 常见固定路径（兜底）
    let fallbacks = [
        "C:\\Qt\\6.10.3\\msvc2022_64",
        "C:\\Qt\\6.10.2\\msvc2022_64",
        "C:\\Qt\\6.5.0\\msvc2019_64",
        "C:\\Qt\\6.7.0\\msvc2019_64"
    ]
    for (fb in fallbacks) {
        if (let Some(info) <- checkQt6Path(Path(fb))) {
            return Some(info)
        }
    }

    return None
}

func checkQt6Path(path: Path): ?Qt6Info {
    if (!exists(path)) { return None }

    let qtCoreLib = path.join("bin").join("Qt6Core.dll")
    if (!exists(qtCoreLib)) { return None }

    let version = parseQtVersion(path.toString())
    let components = scanComponents(path)

    return Some(Qt6Info(path.toString(), version, components))
}

func parseQtVersion(pathStr: String): String {
    let parts = pathStr.split("\\")
    for (part in parts) {
        if (part.startsWith("6.")) { return part }
    }
    let parts2 = pathStr.split("/")
    for (part in parts2) {
        if (part.startsWith("6.")) { return part }
    }
    return "6.0.0"
}

func scanComponents(path: Path): Array<String> {
    let components = ArrayList<String>()
    let binDir = path.join("bin")

    if (exists(binDir)) {
        let seen = ArrayList<String>()
        let entries = Directory.readFrom(binDir)
        for (entry in entries) {
            let name = entry.name
            if (name.startsWith("Qt6") && (name.endsWith(".dll") || name.endsWith(".so") || name.endsWith(".dylib"))) {
                // 去掉扩展名
                let dotIdx = name.size - 4
                var compName = if (dotIdx > 0) { name[0..dotIdx] } else { name }
                // 去掉末尾的 'd'（debug 版标记）
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
        sort(components)
    }

    return components.toArray()
}

func isDir(path: Path): Bool {
    try {
        Directory.readFrom(path)
        return true
    } catch (_) {
        return false
    }
}


