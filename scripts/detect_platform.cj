// 平台检测工具
// 编译: cjc detect_platform.cj -o detect_platform.exe --import-path "<CANGJIE_HOME>/modules/<platform>/std"
// 注意: 运行时 OS/架构检测需要平台特定实现，此处按 Windows 逻辑编译
// 编译并运行：cjc detect_platform.cj -o detect_platform.exe; .\detect_platform.exe

import std.env.*

class PlatformInfo {
    let os: String
    let arch: String
    let platformId: String

    init(os: String, arch: String) {
        this.os = os
        this.arch = arch
        this.platformId = "${os}-${arch}"
    }

    func isSupported(): Bool {
        let supportedPlatforms = [
            "linux-x64",
            "linux-arm64",
            "windows-x64",
            "macos-x64",
            "macos-arm64"
        ]
        return supportedPlatforms.contains(this.platformId)
    }

    func getBinaryName(): String {
        if (this.os == "linux") {
            return "libcjqt6_bridge.so"
        } else if (this.os == "windows" && this.arch == "x64") {
            return "cjqt6_bridge.dll"
        } else if (this.os == "macos") {
            return "libcjqt6_bridge.dylib"
        } else {
            throw Exception("Unsupported platform: ${this.platformId}")
        }
    }
}

func detectPlatform(): PlatformInfo {
    // 运行时检测: 尝试读取环境变量
    // 在 Windows 上 OS 通常有 "OS" 环境变量 = "Windows_NT"
    var osName = "windows"
    var archName = "x64"

    if (let Some(osEnv) <- getVariable("OS")) {
        if (osEnv.contains("Windows")) {
            osName = "windows"
        } else {
            osName = "linux"
        }
    }

    if (let Some(procArch) <- getVariable("PROCESSOR_ARCHITECTURE")) {
        if (procArch.contains("ARM64") || procArch.contains("arm64")) {
            archName = "arm64"
        }
    }

    // 检查是否有 uname (非 Windows 环境)
    // 无运行时 API 时默认返回 windows-x64
    return PlatformInfo(osName, archName)
}

main() {
    println("平台检测工具")
    println("=====================================")

    try {
        let platform = detectPlatform()

        println("操作系统: ${platform.os}")
        println("CPU架构: ${platform.arch}")
        println("平台标识: ${platform.platformId}")
        println("支持状态: ${if (platform.isSupported()) { "✓ 支持" } else { "✗ 不支持" }}")

        if (platform.isSupported()) {
            println("桥接库文件: ${platform.getBinaryName()}")
        } else {
            println("")
            println("错误: 当前平台不支持")
            println("支持的平台列表:")
            println("  - linux-x64")
            println("  - linux-arm64")
            println("  - windows-x64")
            println("  - macos-x64")
            println("  - macos-arm64")
        }
    } catch (e: Exception) {
        eprintln("检测失败: ${e.message}")
    }
}
