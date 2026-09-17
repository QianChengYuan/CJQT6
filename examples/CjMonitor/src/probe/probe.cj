package CjMonitor.probe

import std.env.*
import std.fs.*
import std.convert.*
import CjMonitor.common.*

// ============================================================
// 采集层契约与平台分发
//
// 两条采集路径，同时验证「文件 IO」与「QProcess 跨进程」：
//   - 文件直读（Linux /proc）：开销最低，100ms 无压力
//   - 常驻子进程（Windows / macOS）：QProcess 异步读标准输出
// ============================================================

/// 采集器契约
public interface Probe {
    /// 采集器名称（状态栏 / 日志用）
    func probeName(): String

    /// 启动自检结果：该平台的采集手段是否可用
    func available(): Bool

    /// 是否已产出过数据（未就绪时 sample 返回 None）
    func baselineReady(): Bool

    /// 采一帧；None 表示本帧不可用（基线帧或读取失败）
    func sample(): ?Sample

    /// 释放资源（子进程、句柄等）
    func dispose(): Unit
}

/// 平台判定
public class Platform {
    /// Linux：以 /proc/stat 是否存在为准
    public static func isLinux(): Bool {
        exists(Path("/proc/stat"))
    }

    /// Windows：环境变量 OS == "Windows_NT"
    public static func isWindows(): Bool {
        match (getVariable("OS")) {
            case Some(v) => v == "Windows_NT"
            case None => false
        }
    }

    /// 其余按 macOS 处理
    public static func isMac(): Bool {
        !isLinux() && !isWindows()
    }

    /// 平台名（展示用）
    public static func name(): String {
        if (isLinux()) {
            "Linux"
        } else if (isWindows()) {
            "Windows"
        } else {
            "macOS"
        }
    }
}

/// 按当前平台创建采集器并启动。
/// 子进程型采集器需先挂全局变量再启动，避免回调在全局就绪前到达。
public func createPlatformProbe(): Probe {
    if (Platform.isLinux()) {
        return LinuxProbe()
    }
    let p = if (Platform.isWindows()) {
        createWindowsProbe()
    } else {
        createMacProbe()
    }
    gProcProbe = Some(p)
    p.start()
    p
}

// ============================================================
// 子进程采集脚本落盘
//
// ⚠ 关键约束：桥接层 qProcessSetArguments 会把参数字符串按空格切分
//   （native/src/process/bridge_process.cpp: `split(' ', Qt::SkipEmptyParts)`），
//   因此**无法传递含空格的参数**，也就不能把脚本绝对路径当参数传。
//   规避方式：脚本写入临时目录，把子进程工作目录设为该目录，
//   参数只给「不含空格的文件名」。
// ============================================================

/// 临时目录（优先 TEMP，其次 TMP，最后当前工作目录）。
/// 该路径仅通过 setWorkingDirectory 传入（不参与空格切分），故含空格也安全。
public func tempDir(): String {
    match (getVariable("TEMP")) {
        case Some(v) => if (v.isEmpty()) { fallbackTemp() } else { v }
        case None => fallbackTemp()
    }
}

func fallbackTemp(): String {
    match (getVariable("TMP")) {
        case Some(v) => if (v.isEmpty()) { cwdString() } else { v }
        case None => cwdString()
    }
}

func cwdString(): String {
    getWorkingDirectory().toString()
}

/// 把采集脚本写入临时目录，返回是否成功
public func writeTempScript(fileName: String, content: String): Bool {
    try {
        let dir = tempDir()
        let sep = if (dir.endsWith("/") || dir.endsWith("\\")) { "" } else { "\\" }
        File.writeTo(Path(dir + sep + fileName), content.toArray())
        true
    } catch (_: Exception) {
        false
    }
}

// ============================================================
// 文本解析工具（/proc 与子进程输出共用）
// ============================================================

/// 按空白切分一行并去掉空项（/proc 用多个空格对齐）
public func splitFields(line: String): Array<String> {
    line.trimAscii().split(" ", removeEmpty: true)
}

/// 安全取字段（越界返回空串）
public func field(fields: Array<String>, idx: Int64): String {
    if (idx >= 0 && idx < fields.size) {
        fields[idx]
    } else {
        ""
    }
}

/// 字符串转 Int64（失败得 0）
public func toI64(s: String): Int64 {
    match (Int64.tryParse(s)) {
        case Some(v) => v
        case None => 0
    }
}

/// 字符串转 Float64（失败得 0.0）
public func toF64(s: String): Float64 {
    match (Float64.tryParse(s)) {
        case Some(v) => v
        case None => 0.0
    }
}

/// 截断到 [0, 100]
public func clampPercent(v: Float64): Float64 {
    if (v < 0.0) {
        0.0
    } else if (v > 100.0) {
        100.0
    } else {
        v
    }
}

/// 是否为可解析的数字
public func isNumber(s: String): Bool {
    match (Float64.tryParse(s)) {
        case Some(_) => true
        case None => false
    }
}

/// 解析子进程输出的一行（"cpu mem disk rx tx"）
///
/// 要求 5 个字段**全部为数字**才接受：子进程可能混入非数据输出
/// （版本横幅、警告、退出码提示等），只按字段数判断会把它们解析成
/// 全零样本，从而让曲线「静默归零」而采集计数看似正常。
public func parseProbeLine(line: String): ?Sample {
    let f = splitFields(line)
    if (f.size < 5) {
        return None
    }
    if (!isNumber(f[0]) || !isNumber(f[1]) || !isNumber(f[2]) || !isNumber(f[3]) || !isNumber(f[4])) {
        return None
    }
    Some(Sample(
        epochMs(),
        clampPercent(toF64(f[0])),
        clampPercent(toF64(f[1])),
        clampPercent(toF64(f[2])),
        toF64(f[3]),
        toF64(f[4])
    ))
}
