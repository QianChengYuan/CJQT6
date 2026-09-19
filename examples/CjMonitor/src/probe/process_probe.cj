package CjMonitor.probe

import cjqt6.core.*
import CjMonitor.common.*

// ============================================================
// 子进程采集器（Windows / macOS 共用）
//
// 通用化设计：平台差异只体现在「程序名 + 脚本内容 + 脚本文件名」三个参数上，
// 读流、攒行、解析、回收等逻辑只实现一次。
//
// 子进程契约：每约 100ms 输出一行，空格分隔 5 个数：
//   cpu% mem% disk% rx_KBps tx_KBps
// ============================================================

/// 全局持有当前子进程采集器，供顶层 CFunc 回调路由
/// （CFunc 不能捕获局部变量，只能经全局变量取上下文）
var gProcProbe: ?ProcessProbe = None
let onProcProbeStdout: CFunc<() -> Unit> = {
    => if (let Some(p) <- gProcProbe) {
        p.ingestStdout()
    }
}
let onProcProbeError: CFunc<(Int32) -> Unit> = {
    code: Int32 => if (let Some(p) <- gProcProbe) {
        p.noteError(code)
    }
}
let onProcProbeStderr: CFunc<() -> Unit> = {
    => if (let Some(p) <- gProcProbe) {
        p.ingestStderr()
    }
}

/// 诊断信息：最近一次尝试解析的原始行与是否解析成功。
/// 新平台首次接入时，这条信息能直接暴露「子进程输出格式与解析器不匹配」。
var gProcLastLine: String = ""
var gProcParsedOk: Bool = false

/// 子进程 stderr（仅保留前 600 字符：错误信息通常在开头）
var gProcStderr: String = ""

/// 子进程启动参数与工作目录（诊断用）
var gProcLaunchArgs: String = ""
var gProcWorkDir: String = ""

/// 子进程采集诊断串（供自测报告输出）
public func procDiag(): String {
    let st = match (gProcProbe) {
        case Some(p) => p.stateText()
        case None => "未创建"
    }
    "启动参数=[${gProcLaunchArgs}] 工作目录=[${gProcWorkDir}] 进程=${st} 解析成功=${gProcParsedOk} 最近原始行=[${gProcLastLine}] stderr=[${gProcStderr}]"
}

public class ProcessProbe <: Probe {
    private let label: String
    private let program: String
    private let scriptName: String
    private let scriptContent: String

    private var proc: ?QProcess = None
    private var started: Bool = false
    private var scriptReady: Bool = false
    private var errorCode: Int32 = -1
    private var buffer: String = ""
    private var hasData: Bool = false
    private var last: ?Sample = None

    public init(label: String, program: String, scriptName: String, scriptContent: String) {
        this.label = label
        this.program = program
        this.scriptName = scriptName
        this.scriptContent = scriptContent
    }

    /// 启动子进程。由 createPlatformProbe 在挂好全局变量后调用，
    /// 避免回调在全局尚未就绪时到达。
    public func start(): Unit {
        scriptReady = writeTempScript(scriptName, scriptContent)
        if (!scriptReady) {
            errorCode = ProcessError.Crashed
            return
        }
        let p = QProcess()
        p.setProgram(program)
        // 工作目录设为脚本所在目录：脚本名不含空格，
        // 从而绕开桥接层「参数按空格切分」的限制
        p.setWorkingDirectory(tempDir())
        p.setArguments(launchArgs())
        gProcLaunchArgs = launchArgs()
        gProcWorkDir = tempDir()
        p.setOnReadyReadStandardOutput(onProcProbeStdout)
        p.setOnReadyReadStandardError(onProcProbeStderr)
        p.setOnErrorOccurred(onProcProbeError)
        // 用 startWithArgs 显式传参：避免 start(program) 是否沿用 setArguments
        // 因实现版本而异（实测某些组合下子进程会以无参交互模式启动，
        // 表现为只输出 PowerShell 版权横幅后阻塞等待 stdin）。
        p.startWithArgs(program, launchArgs())
        proc = Some(p)
        started = true
    }

    public func probeName(): String {
        label
    }

    /// 子进程启动参数。
    /// ⚠ 必须带 -NoLogo：PowerShell 在控制台会话下会先向 stdout 打印版权横幅
    /// （"Copyright (C) Microsoft Corporation. All rights reserved."），
    /// 该行含 7 个空格分隔字段，会被误当成数据行解析成全零样本。
    func launchArgs(): String {
        if (program == "powershell" || program == "pwsh") {
            "-NoLogo -NoProfile -ExecutionPolicy Bypass -File " + scriptName
        } else {
            scriptName
        }
    }

    public func available(): Bool {
        started && errorCode == -1
    }

    public func baselineReady(): Bool {
        hasData
    }

    public func sample(): ?Sample {
        last
    }

    public func dispose(): Unit {
        if (let Some(p) <- proc) {
            if (p.isRunning()) {
                p.kill()
            }
            p.close()
        }
        proc = None
        started = false
    }

    // ========================================================
    // 标准输出摄入
    //
    // readAllStandardOutput() 是「消费式」读取，且子进程输出可能按不完整行
    // 分批到达，因此必须跨回调累积，凑齐完整行再解析。
    // ========================================================

    public func ingestStdout(): Unit {
        if (let Some(p) <- proc) {
            buffer += p.readAllStandardOutput()

            // 防御：长时间收不到换行时不无限增长
            if (buffer.size > 4096) {
                buffer = ""
                return
            }

            let parts = buffer.split("\n")
            if (parts.size <= 1) {
                if (parts.size == 1) {
                    buffer = parts[0]
                }
                return
            }

            // 最后一个元素是不完整行，留待下次拼接
            let remainder = parts[parts.size - 1]
            var idx = parts.size - 2
            while (idx >= 0) {
                let line = parts[idx].trimAscii()
                if (!line.isEmpty()) {
                    gProcLastLine = line
                    if (let Some(s) <- parseProbeLine(line)) {
                        last = Some(s)
                        hasData = true
                        gProcParsedOk = true
                    } else {
                        gProcParsedOk = false
                    }
                    break
                }
                idx -= 1
            }
            buffer = remainder
        }
    }

    /// 子进程状态描述（诊断用）
    public func stateText(): String {
        match (proc) {
            case Some(p) => "state=${p.state()} running=${p.isRunning()} exitCode=${p.exitCode()} exitStatus=${p.exitStatus()}"
            case None => "未启动"
        }
    }

    /// 摄入 stderr（仅保留开头，错误信息通常在最前）
    public func ingestStderr(): Unit {
        if (let Some(p) <- proc) {
            let chunk = p.readAllStandardError()
            if (gProcStderr.size < 600) {
                gProcStderr += chunk
            }
        }
    }

    public func noteError(code: Int32): Unit {
        errorCode = code
    }
}
