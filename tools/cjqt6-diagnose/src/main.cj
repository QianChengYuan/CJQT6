// CJQT6 环境诊断工具
// 综合检测：平台信息、Qt6 安装、Cangjie 环境、开发建议
//
// 编译: cjpm build
// 运行: cjpm run

package Cjqt6Diagnose

import std.fs.*

main() {
    println("========================================")
    println("  CJQT6 环境诊断工具")
    println("========================================")
    println("")

    // ---- 1. 平台检测 ----
    println("--- 1. 平台信息 ---")
    let platform = detectPlatform()
    println("  操作系统 : ${platform.os}")
    println("  CPU 架构 : ${platform.arch}")
    println("  平台标识 : ${platform.platformId}")
    println("  支持状态 : ${if (platform.isSupported()) { "✓ 支持" } else { "✗ 不支持" }}")
    if (platform.isSupported()) {
        println("  桥接库   : ${platform.getBridgeFileName()}")
    }
    println("")

    // ---- 2. Cangjie 环境 ----
    println("--- 2. Cangjie 环境 ---")
    let cangjieHome = detectCangjieHome()
    match (cangjieHome) {
        case Some(home) =>
            println("  CANGJIE_HOME : ${home}")

            // 检测 cjc 编译器（可能在 bin/ 或 tools/bin/ 下）
            var foundCjc = false
            let cjcCandidates = [
                Path(home).join("bin").join("cjc.exe"),
                Path(home).join("tools").join("bin").join("cjc.exe")
            ]
            for (cp in cjcCandidates) {
                if (exists(cp)) {
                    println("  cjc         : ${cp} (已找到)")
                    foundCjc = true
                    break
                }
            }
            if (!foundCjc) {
                println("  cjc         : 未找到")
            }

            // 检测 std 库
            let stdPath = Path(home).join("modules").join("windows_x86_64_cjnative")
            if (exists(stdPath)) {
                println("  标准库      : ${stdPath} (已找到)")
            } else {
                println("  标准库      : 未找到")
            }

        case None =>
            println("  CANGJIE_HOME : 未设置")
    }
    println("")

    // ---- 3. Qt6 检测 ----
    println("--- 3. Qt6 安装 ---")
    let qt6Info = detectQt6()
    match (qt6Info) {
        case Some(qt) =>
            println("  ✓ Qt6 已找到")
            println("  安装路径 : ${qt.path}")
            println("  版本     : ${qt.version}")

            if (qt.isVersionCompatible("6.2.0")) {
                println("  版本要求 : ✓ 符合 (>= 6.2)")
            } else {
                println("  版本要求 : ⚠ 过低，建议升级到 6.2+")
            }
            println("")

            // 输出组件摘要
            println("  组件概览:")
            var coreCount = 0
            var otherCount = 0
            for (comp in qt.components) {
                if (comp == "Qt6Core" || comp == "Qt6Gui" || comp == "Qt6Widgets" ||
                    comp == "Qt6Multimedia" || comp == "Qt6Network" || comp == "Qt6Sql" ||
                    comp == "Qt6PrintSupport" || comp == "Qt6Svg" || comp == "Qt6Test" ||
                    comp == "Qt6OpenGL" || comp == "Qt6OpenGLWidgets") {
                    println("    ✓ ${comp}")
                    coreCount++
                } else {
                    otherCount++
                }
            }
            println("    ... 及其他 ${otherCount} 个组件")
            println("  组件总数 : ${qt.components.size}")

            // 检查关键组件
            println("")
            println("  关键组件检查:")
            var hasWidgets = false
            var hasMultimedia = false
            var hasNetwork = false
            var hasSql = false
            for (comp in qt.components) {
                if (comp == "Qt6Widgets") { hasWidgets = true }
                if (comp == "Qt6Multimedia") { hasMultimedia = true }
                if (comp == "Qt6Network") { hasNetwork = true }
                if (comp == "Qt6Sql") { hasSql = true }
            }
            println("    Qt6Widgets    : ${formatCheck(hasWidgets)}")
            println("    Qt6Multimedia : ${formatCheck(hasMultimedia)}")
            println("    Qt6Network    : ${formatCheck(hasNetwork)}")
            println("    Qt6Sql        : ${formatCheck(hasSql)}")

        case None =>
            println("  ✗ 未找到 Qt6 安装")
            println("")
            println("  请从 https://www.qt.io/download 下载安装 Qt6 (>= 6.2)")
            println("  并设置环境变量: set QTDIR=C:\\Qt\\6.10.3\\msvc2022_64")
    }
    println("")

    // ---- 4. 桥接库检查 ----
    println("--- 4. FFI 桥接库 ---")
    let bridgeFile = platform.getBridgeFileName()
    // 从 tools/cjqt6-diagnose/ 往项目根目录找 releases/
    let bridgePath = Path("..\\..\\releases\\${platform.platformId}\\${bridgeFile}")
    if (exists(bridgePath)) {
        println("  ✓ 桥接库已就绪: ${bridgePath}")
    } else {
        // 再试几个可能的位置
        let altPaths = [
            Path("..\\releases\\${platform.platformId}\\${bridgeFile}"),
            Path("releases\\${platform.platformId}\\${bridgeFile}")
        ]
        var found = false
        for (p in altPaths) {
            if (exists(p)) {
                println("  ✓ 桥接库已就绪: ${p}")
                found = true
                break
            }
        }
        if (!found) {
            println("  ⚠ 桥接库未找到")
            println("  请运行: .\\scripts\\update-bridge.ps1")
        }
    }
    println("")

    // ---- 5. 开发建议 ----
    println("--- 5. 开发建议 ---")
    println("  1. 如果 Qt6 环境变量未设置，运行:")
    println("     .\\scripts\\setup-qt-env.ps1")
    println("")
    println("  2. 构建桥接库:")
    println("     .\\scripts\\update-bridge.ps1")
    println("")
    println("  3. 完整构建:")
    println("     .\\scripts\\rebuild_all.ps1 -Example notepad")
    println("")
    println("  4. 运行示例:")
    println("     cd examples\\notepad && cjpm run")
    println("")
    println("========================================")
}

func formatCheck(found: Bool): String {
    return if (found) { "✓ 已安装" } else { "✗ 未安装" }
}


