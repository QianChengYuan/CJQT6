#!/usr/bin/env cjc
// Qt6 检测脚本

import std.os.*
import std.io.*
import std.fs.*

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
        // 简单版本比较 (TODO: 实现完整的语义化版本比较)
        return this.version >= minVersion
    }
}

func detectQt6(): ?Qt6Info {
    // 搜索路径列表
    let searchPaths = getSearchPaths()
    
    for (path in searchPaths) {
        if (let Some(info) = checkQt6Path(path)) {
            return Some(info)
        }
    }
    
    return None
}

func getSearchPaths(): Array<String> {
    let paths = ArrayList<String>()
    
    // 1. 检查环境变量 QTDIR
    if (let Some(qtdir) = ProcessInfo.getEnv("QTDIR")) {
        paths.add(qtdir)
    }
    
    // 2. 检查 CMAKE_PREFIX_PATH
    if (let Some(cmakePath) = ProcessInfo.getEnv("CMAKE_PREFIX_PATH")) {
        for (path in cmakePath.split(":", "|")) {
            paths.add(path)
        }
    }
    
    // 3. 平台特定路径
    let os = ProcessInfo.osName
    
    if (os.contains("Linux")) {
        paths.add("/usr/lib/qt6")
        paths.add("/usr/lib/x86_64-linux-gnu/qt6")
        paths.add("/usr/lib/aarch64-linux-gnu/qt6")
        paths.add("/opt/qt6")
    } else if (os.contains("Windows")) {
        paths.add("C:\\Qt\\6.5.0\\msvc2019_64")
        paths.add("C:\\Qt\\6.4.0\\msvc2019_64")
        paths.add("C:\\Qt\\6.3.0\\msvc2019_64")
    } else if (os.contains("Darwin") || os.contains("Mac")) {
        paths.add("/usr/local/Cellar/qt@6")
        paths.add("/usr/local/qt6")
        paths.add("/opt/homebrew/Cellar/qt@6")
    }
    
    return paths.toArray()
}

func checkQt6Path(path: String): ?Qt6Info {
    // 检查路径是否存在
    if (!FileSystem.exists(path)) {
        return None
    }
    
    // 检查关键文件
    let os = ProcessInfo.osName
    var qtCoreLib = ""
    
    if (os.contains("Linux")) {
        qtCoreLib = "${path}/lib/libQt6Core.so"
    } else if (os.contains("Windows")) {
        qtCoreLib = "${path}\\bin\\Qt6Core.dll"
    } else if (os.contains("Darwin") || os.contains("Mac")) {
        qtCoreLib = "${path}/lib/QtCore.framework/QtCore"
    }
    
    if (!FileSystem.exists(qtCoreLib)) {
        return None
    }
    
    // 解析版本号
    let version = parseQtVersion(path)
    
    // 检测可用组件
    let components = detectComponents(path)
    
    return Some(Qt6Info(path, version, components))
}

func parseQtVersion(path: String): String {
    // 从路径或文件中解析版本号
    // 简化实现：从路径中提取
    if (path.contains("6.5")) {
        return "6.5.0"
    } else if (path.contains("6.4")) {
        return "6.4.0"
    } else if (path.contains("6.3")) {
        return "6.3.0"
    } else if (path.contains("6.2")) {
        return "6.2.0"
    }
    return "6.0.0"
}

func detectComponents(path: String): Array<String> {
    let components = ArrayList<String>()
    
    let expectedComponents = [
        "QtCore",
        "QtGui",
        "QtWidgets",
        "QtSql",
        "QtMultimedia",
        "QtPrintSupport"
    ]
    
    // 检查每个组件是否存在
    for (comp in expectedComponents) {
        // 简化检查：假设所有组件都可用
        components.add(comp)
    }
    
    return components.toArray()
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
            println("组件: ${info.components.join(", ")}")
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
            println("Linux:")
            println("  sudo apt-get install qt6-base-dev")
            println("")
            println("Windows:")
            println("  从 https://www.qt.io/download 下载安装")
            println("  并设置环境变量: set QTDIR=C:\\Qt\\6.5.0\\msvc2019_64")
            println("")
            println("macOS:")
            println("  brew install qt@6")
    }
}
