// 平台检测模块
// 检测操作系统、CPU 架构、Cangjie 环境

package Cjqt6Diagnose

import std.env.*
import std.fs.*

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

    func getBridgeFileName(): String {
        if (this.os == "linux") {
            return "libcjqt6_bridge.so"
        } else if (this.os == "windows" && this.arch == "x64") {
            return "cjqt6_bridge.dll"
        } else if (this.os == "macos") {
            return "libcjqt6_bridge.dylib"
        } else {
            throw Exception("不支持的平台: ${this.platformId}")
        }
    }
}

func detectPlatform(): PlatformInfo {
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

    return PlatformInfo(osName, archName)
}

func detectCangjieHome(): ?String {
    // 优先 CANGJIE_HOME 环境变量
    if (let Some(home) <- getVariable("CANGJIE_HOME")) {
        if (exists(Path(home).join("tools").join("bin"))) {
            return Some(home)
        }
    }
    // 回退扫描用户目录下的 .cangjie
    if (let Some(userProfile) <- getVariable("USERPROFILE")) {
        let candidate = Path(userProfile).join(".cangjie")
        if (exists(candidate.join("tools").join("bin"))) {
            return Some(candidate.toString())
        }
    }
    return None
}
