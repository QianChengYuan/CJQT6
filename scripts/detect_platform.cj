#!/usr/bin/env cjc
// 平台检测脚本

import std.os.*
import std.io.*

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
        match (this.os, this.arch) {
            case ("linux", _) => "libcjfw_bridge.so"
            case ("windows", "x64") => "cjfw_bridge.dll"
            case ("macos", _) => "libcjfw_bridge.dylib"
            case _ => throw Exception("Unsupported platform: ${this.platformId}")
        }
    }
}

func detectPlatform(): PlatformInfo {
    let osName = getOSName()
    let archName = getArchName()
    return PlatformInfo(osName, archName)
}

func getOSName(): String {
    let os = ProcessInfo.osName
    
    if (os.contains("Linux")) {
        return "linux"
    } else if (os.contains("Windows")) {
        return "windows"
    } else if (os.contains("Darwin") || os.contains("Mac")) {
        return "macos"
    } else {
        throw Exception("Unknown OS: ${os}")
    }
}

func getArchName(): String {
    let arch = ProcessInfo.arch
    
    if (arch.contains("x86_64") || arch.contains("AMD64")) {
        return "x64"
    } else if (arch.contains("aarch64") || arch.contains("arm64")) {
        return "arm64"
    } else {
        throw Exception("Unknown architecture: ${arch}")
    }
}

main() {
    println("平台检测工具")
    println("=====================================")
    
    try {
        let platform = detectPlatform()
        
        println("操作系统: ${platform.os}")
        println("CPU架构: ${platform.arch}")
        println("平台标识: ${platform.platformId}")
        println("支持状态: ${if (platform.isSupported()) "✓ 支持" else "✗ 不支持"}")
        
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
