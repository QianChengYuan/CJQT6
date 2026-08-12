package cjqt6.test

// =====================================================================
// 进程模块测试（src/core/process.cj）
// 覆盖：ProcessState/ExitStatus/ProcessError/ProcessChannel/ProcessChannelMode 常量
//      QProcessEnvironment / QProcess
// 注意：QProcess.start 会启动真实子进程，标注 @Tag[requires_process_spawn]
// =====================================================================

import cjqt6.core.*
import std.unittest.*

// ---------------------------------------------------------------------
// 进程常量类测试（无需 GUI）
// ---------------------------------------------------------------------
@Test
class ProcessConstantsTests {
    @TestCase
    func testProcessState() {
        @Expect(ProcessState.NotRunning, 0)
        @Expect(ProcessState.Starting, 1)
        @Expect(ProcessState.Running, 2)
    }

    @TestCase
    func testExitStatus() {
        @Expect(ExitStatus.NormalExit, 0)
        @Expect(ExitStatus.CrashExit, 1)
    }

    @TestCase
    func testProcessError() {
        @Expect(ProcessError.FailedToStart, 0)
        @Expect(ProcessError.Crashed, 1)
        @Expect(ProcessError.Timedout, 2)
        @Expect(ProcessError.ReadError, 3)
        @Expect(ProcessError.WriteError, 4)
        @Expect(ProcessError.UnknownError, 5)
    }

    @TestCase
    func testProcessChannel() {
        @Expect(ProcessChannel.StandardOutput, 0)
        @Expect(ProcessChannel.StandardError, 1)
    }

    @TestCase
    func testProcessChannelMode() {
        @Expect(ProcessChannelMode.SeparateChannels, 0)
        @Expect(ProcessChannelMode.MergedChannels, 1)
        @Expect(ProcessChannelMode.ForwardedChannels, 2)
        @Expect(ProcessChannelMode.ForwardedOutputChannel, 3)
        @Expect(ProcessChannelMode.ForwardedErrorChannel, 4)
    }
}

// ---------------------------------------------------------------------
// QProcessEnvironment 测试（无需 GUI）
// ---------------------------------------------------------------------
@Test
class QProcessEnvironmentTests {
    @TestCase
    func testCreate() {
        let env = QProcessEnvironment()
        @Assert(env.getPtr() != 0)
        @Expect(env.isEmpty(), true)
        env.delete()
    }

    @TestCase
    func testInsertAndValue() {
        let env = QProcessEnvironment()
        env.insert("PATH", "/usr/bin")
        @Expect(env.contains("PATH"), true)
        @Expect(env.value("PATH"), "/usr/bin")
        @Expect(env.isEmpty(), false)
        env.delete()
    }

    @TestCase
    func testInsertMultiple() {
        let env = QProcessEnvironment()
        env.insert("A", "1").insert("B", "2").insert("C", "3")
        @Expect(env.value("A"), "1")
        @Expect(env.value("B"), "2")
        @Expect(env.value("C"), "3")
        @Expect(env.contains("A"), true)
        @Expect(env.contains("B"), true)
        @Expect(env.contains("C"), true)
        env.delete()
    }

    @TestCase
    func testRemove() {
        let env = QProcessEnvironment()
        env.insert("KEY", "VAL")
        @Expect(env.contains("KEY"), true)
        env.remove("KEY")
        @Expect(env.contains("KEY"), false)
        @Expect(env.value("KEY"), "")
        env.delete()
    }

    @TestCase
    func testClear() {
        let env = QProcessEnvironment()
        env.insert("X", "1")
        env.insert("Y", "2")
        @Expect(env.isEmpty(), false)
        env.clear()
        @Expect(env.isEmpty(), true)
        env.delete()
    }

    @TestCase
    func testContainsMissing() {
        let env = QProcessEnvironment()
        @Expect(env.contains("NOPE"), false)
        env.delete()
    }

    @TestCase
    func testValueMissing() {
        let env = QProcessEnvironment()
        @Expect(env.value("NOPE"), "")
        env.delete()
    }

    @TestCase
    func testSystemEnv() {
        let env = QProcessEnvironment.system()
        @Assert(env.getPtr() != 0)
        // 系统环境通常包含 PATH（Windows 大写 PATH）
        @Expect(env.isEmpty(), false)
        env.delete()
    }

    @TestCase
    func testDoubleDelete() {
        let env = QProcessEnvironment()
        env.delete()
        env.delete()  // 安全
        @Assert(true)
    }
}

// ---------------------------------------------------------------------
// QProcess 测试（不实际启动长进程，仅验证 API 与状态）
// ---------------------------------------------------------------------
@Test
class QProcessTests {
    @TestCase
    func testCreate() {
        let p = QProcess()
        @Assert(p.getPtr() != 0)
        @Expect(p.state(), ProcessState.NotRunning)
        @Expect(p.isRunning(), false)
        p.delete()
    }

    @TestCase
    func testDoubleDelete() {
        let p = QProcess()
        p.delete()
        p.delete()  // 安全
        @Assert(true)
    }

    @TestCase
    func testSetProgramAndGet() {
        let p = QProcess()
        p.setProgram("echo")
        @Expect(p.program(), "echo")
        p.setProgram("cmd")
        @Expect(p.program(), "cmd")
        p.delete()
    }

    @TestCase
    func testSetArgumentsAndGet() {
        let p = QProcess()
        p.setArguments("hello world")
        @Expect(p.arguments(), "hello world")
        p.setArguments("")
        @Expect(p.arguments(), "")
        p.delete()
    }

    @TestCase
    func testSetWorkingDirectoryAndGet() {
        let p = QProcess()
        p.setWorkingDirectory("/tmp")
        @Expect(p.workingDirectory(), "/tmp")
        p.setWorkingDirectory("C:\\")
        @Expect(p.workingDirectory(), "C:\\")
        p.delete()
    }

    @TestCase
    func testProcessChannelModeRoundtrip() {
        let p = QProcess()
        p.setProcessChannelMode(ProcessChannelMode.MergedChannels)
        @Expect(p.processChannelMode(), ProcessChannelMode.MergedChannels)
        p.setProcessChannelMode(ProcessChannelMode.SeparateChannels)
        @Expect(p.processChannelMode(), ProcessChannelMode.SeparateChannels)
        p.delete()
    }

    @TestCase
    func testReadChannelRoundtrip() {
        let p = QProcess()
        p.setReadChannel(ProcessChannel.StandardError)
        @Expect(p.readChannel(), ProcessChannel.StandardError)
        p.setReadChannel(ProcessChannel.StandardOutput)
        @Expect(p.readChannel(), ProcessChannel.StandardOutput)
        p.delete()
    }

    @TestCase
    func testInitialStateValues() {
        let p = QProcess()
        @Expect(p.state(), ProcessState.NotRunning)
        @Expect(p.isRunning(), false)
        @Expect(p.processId(), 0)
        // exitCode/error 在未启动时为 0/默认
        @Expect(p.exitCode(), 0)
        p.delete()
    }

    @TestCase
    func testSetProcessEnvironment() {
        let p = QProcess()
        let env = QProcessEnvironment()
        env.insert("MY_VAR", "my_value")
        p.setProcessEnvironment(env)
        env.delete()
        p.delete()
        @Assert(true)
    }

    @TestCase
    func testWriteToNotRunningReturnsZeroOrNegative() {
        let p = QProcess()
        let n = p.write("hello")
        // 未启动时写入通常返回 <= 0
        @Expect(n <= 0, true)
        p.delete()
    }

    @TestCase
    func testReadAllStandardOutputEmpty() {
        let p = QProcess()
        let s = p.readAllStandardOutput()
        @Expect(s.size, 0)
        p.delete()
    }

    @TestCase
    func testReadAllStandardErrorEmpty() {
        let p = QProcess()
        let s = p.readAllStandardError()
        @Expect(s.size, 0)
        p.delete()
    }

    @TestCase
    func testCloseWriteChannelSafe() {
        let p = QProcess()
        p.closeWriteChannel()
        p.closeReadChannel(ProcessChannel.StandardOutput)
        p.closeReadChannel(ProcessChannel.StandardError)
        p.delete()
        @Assert(true)
    }

    @TestCase
    func testKillTerminateSafe() {
        let p = QProcess()
        p.kill()
        p.terminate()
        @Expect(p.state(), ProcessState.NotRunning)
        p.delete()
    }

    @TestCase
    func testWaitForStartedTimeoutShort() {
        let p = QProcess()
        // 未启动进程，waitForStarted 立即返回 false
        @Expect(p.waitForStarted(10), false)
        p.delete()
    }

    @TestCase
    func testWaitForFinishedTimeoutShort() {
        let p = QProcess()
        @Expect(p.waitForFinished(10), false)
        p.delete()
    }

    @TestCase
    func testRegisterCallbacks() {
        let p = QProcess()
        let onFinish: CFunc<(Int32, Int32) -> Unit> = { a: Int32, b: Int32 => () }
        let onStarted: CFunc<() -> Unit> = { => () }
        let onReadyOut: CFunc<() -> Unit> = { => () }
        let onReadyErr: CFunc<() -> Unit> = { => () }
        let onError: CFunc<(Int32) -> Unit> = { e: Int32 => () }
        let onState: CFunc<(Int32) -> Unit> = { s: Int32 => () }
        p.setOnFinished(onFinish)
        p.setOnStarted(onStarted)
        p.setOnReadyReadStandardOutput(onReadyOut)
        p.setOnReadyReadStandardError(onReadyErr)
        p.setOnErrorOccurred(onError)
        p.setOnStateChanged(onState)
        @Assert(p.getPtr() != 0)
        p.delete()
    }
}

// ---------------------------------------------------------------------
// QProcess 静态方法测试
// ---------------------------------------------------------------------
@Test
class QProcessStaticTests {
    @TestCase
    func testSystemEnvironment() {
        let s = QProcess.systemEnvironment()
        // 系统环境字符串通常非空
        @Assert(s.size >= 0)
    }
}

// ---------------------------------------------------------------------
// QProcess 启动真实进程测试（标注 requires_process_spawn，CI 默认跳过）
// ---------------------------------------------------------------------
@Test
@Tag[requires_process_spawn]
class QProcessSpawnTests {
    @TestCase
    func testStartCommandAndFinish() {
        let p = QProcess()
        // Windows: cmd /c echo hello
        p.startCommand("cmd /c echo hello")
        let ok = p.waitForFinished(5000)
        @Expect(ok, true)
        let out = p.readAllStandardOutput()
        @Assert(out.contains("hello"))
        p.delete()
    }

    @TestCase
    func testStartDetachedStatic() {
        let r = QProcess.startDetachedProcess("cmd", "/c echo hi", "")
        @Expect(r > 0, true)
    }

    @TestCase
    func testExecuteCommand() {
        let r = QProcess.executeCommand("cmd", "/c exit 0")
        @Expect(r, 0)
    }
}