package cjqt6.core

// ============================================================
// 进程状态常量
// ============================================================

public class ProcessState {
    public static let NotRunning: Int32 = 0
    public static let Starting: Int32 = 1
    public static let Running: Int32 = 2
}

// ============================================================
// 退出状态常量
// ============================================================

public class ExitStatus {
    public static let NormalExit: Int32 = 0
    public static let CrashExit: Int32 = 1
}

// ============================================================
// 进程错误常量
// ============================================================

public class ProcessError {
    public static let FailedToStart: Int32 = 0
    public static let Crashed: Int32 = 1
    public static let Timedout: Int32 = 2
    public static let ReadError: Int32 = 3
    public static let WriteError: Int32 = 4
    public static let UnknownError: Int32 = 5
}

// ============================================================
// 进程通道常量
// ============================================================

public class ProcessChannel {
    public static let StandardOutput: Int32 = 0
    public static let StandardError: Int32 = 1
}

// ============================================================
// 进程通道模式常量
// ============================================================

public class ProcessChannelMode {
    public static let SeparateChannels: Int32 = 0
    public static let MergedChannels: Int32 = 1
    public static let ForwardedChannels: Int32 = 2
    public static let ForwardedOutputChannel: Int32 = 3
    public static let ForwardedErrorChannel: Int32 = 4
}

// ============================================================
// QProcessEnvironment - 进程环境变量
// ============================================================

public class QProcessEnvironment <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: CreateFailedException 底层对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qProcessEnvironmentCreate()
            if (ptr == 0) {
                throw CreateFailedException("QProcessEnvironment 创建失败")
            }
        }
    }

    // 内部包装构造：直接持有 FFI 返回指针（system() 用，避免多余临时对象）
    private init(native: Int64) {
        this.ptr = native
    }

    public static func system(): QProcessEnvironment {
        unsafe { QProcessEnvironment(qProcessEnvironmentCreateSystem()) }
    }

    public func insert(name: String, value: String): QProcessEnvironment {
        checkValid()
        unsafe {
            var n = LibC.mallocCString(name)
            var v = LibC.mallocCString(value)
            qProcessEnvironmentInsert(ptr, n, v)
            LibC.free(n)
            LibC.free(v)
        }
        this
    }

    public func remove(name: String): QProcessEnvironment {
        checkValid()
        unsafe {
            var n = LibC.mallocCString(name)
            qProcessEnvironmentRemove(ptr, n)
            LibC.free(n)
        }
        this
    }

    public func value(name: String): String {
        checkValid()
        unsafe {
            var n = LibC.mallocCString(name)
            let cstr = qProcessEnvironmentValue(ptr, n)
            let result = cstr.toString()
            freeBridgeString(cstr)
            LibC.free(n)
            result
        }
    }

    public func contains(name: String): Bool {
        checkValid()
        unsafe {
            var n = LibC.mallocCString(name)
            let result = qProcessEnvironmentContains(ptr, n) != 0
            LibC.free(n)
            result
        }
    }

    public func clear(): QProcessEnvironment {
        checkValid();
        unsafe { qProcessEnvironmentClear(ptr) };
        this
    }
    public func isEmpty(): Bool {
        checkValid();
        unsafe { qProcessEnvironmentIsEmpty(ptr) != 0 }
    }
    public func getPtr(): Int64 {
        ptr
    }

    /// 是否已关闭（资源已释放）
    public func isClosed(): Bool {
        closed
    }

    /// 检查对象有效性（QProcessEnvironment 非 QObject，不做存活表查询）
    public func isValid(): Bool {
        return !closed && ptr != 0
    }

    /// 检查有效性，无效时抛出异常
    /// throws: ResourceDisposedException 对象已释放时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QProcessEnvironment 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QProcessEnvironment 指针为空")
        }
    }

    /// 关闭资源，释放底层对象（幂等）
    public func close(): Unit {
        if (!closed && ptr != 0) {
            unsafe { qProcessEnvironmentDelete(ptr) }
            ptr = 0
            closed = true
        }
    }

    /// 删除环境变量集（兼容旧API）
    public func delete(): Unit {
        close()
    }
}

// ============================================================
// QProcess - 进程管理
// ============================================================

public class QProcess <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qProcessCreate()
            if (ptr == 0) {
                throw CreateFailedException("QProcess 创建失败")
            }
        }
        trackObject(ptr)
    }

    /// 是否已关闭（资源已释放）
    public func isClosed(): Bool {
        closed
    }

    /// 检查对象有效性（未关闭且指针有效）
    public func isValid(): Bool {
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }

    /// 检查有效性，无效时抛出异常
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QProcess 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QProcess 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QProcess 底层 Qt 对象已失效")
        }
    }

    /// 关闭资源，释放Qt对象（幂等；native qProcessDelete 内部会断开信号并清理回调表）
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe { qProcessDelete(ptr) }
            ptr = 0
            closed = true
        }
    }

    public func delete(): Unit {
        close()
    }

    // ========== 启动进程 ==========

    public func start(program: String): QProcess {
        unsafe {
            var p = LibC.mallocCString(program)
            qProcessStart(ptr, p)
            LibC.free(p)
        }
        this
    }

    public func startWithArgs(program: String, args: String): QProcess {
        unsafe {
            var p = LibC.mallocCString(program)
            var a = LibC.mallocCString(args)
            qProcessStartWithArgs(ptr, p, a)
            LibC.free(p)
            LibC.free(a)
        }
        this
    }

    public func startCommand(command: String): QProcess {
        unsafe {
            var c = LibC.mallocCString(command)
            qProcessStartCommand(ptr, c)
            LibC.free(c)
        }
        this
    }

    public func startDetached(): Int32 {
        unsafe { qProcessStartDetached(ptr) }
    }

    // ========== 静态方法 ==========

    public static func startDetachedProcess(program: String, args: String, workingDir: String): Int32 {
        unsafe {
            var p = LibC.mallocCString(program)
            var a = LibC.mallocCString(args)
            var w = LibC.mallocCString(workingDir)
            let result = qProcessStartDetachedStatic(p, a, w)
            LibC.free(p)
            LibC.free(a)
            LibC.free(w)
            result
        }
    }

    public static func executeCommand(program: String, args: String): Int32 {
        unsafe {
            var p = LibC.mallocCString(program)
            var a = LibC.mallocCString(args)
            let result = qProcessExecute(p, a)
            LibC.free(p)
            LibC.free(a)
            result
        }
    }

    public static func systemEnvironment(): String {
        unsafe {
            let cstr = qProcessSystemEnvironment();
            let result = cstr.toString();
            freeBridgeString(cstr);
            result
        }
    }

    // ========== 等待 ==========

    public func waitForStarted(msecs: Int32): Bool {
        unsafe { qProcessWaitForStarted(ptr, msecs) != 0 }
    }
    public func waitForStarted(): Bool {
        waitForStarted(30000)
    }

    public func waitForFinished(msecs: Int32): Bool {
        unsafe { qProcessWaitForFinished(ptr, msecs) != 0 }
    }
    public func waitForFinished(): Bool {
        waitForFinished(30000)
    }

    // ========== 状态 ==========

    public func state(): Int32 {
        unsafe { qProcessState(ptr) }
    }
    public func isRunning(): Bool {
        state() == ProcessState.Running
    }

    public func exitCode(): Int32 {
        unsafe { qProcessExitCode(ptr) }
    }
    public func exitStatus(): Int32 {
        unsafe { qProcessExitStatus(ptr) }
    }
    public func error(): Int32 {
        unsafe { qProcessError(ptr) }
    }

    public func processId(): Int64 {
        unsafe { qProcessProcessId(ptr) }
    }

    // ========== 终止 ==========

    public func kill(): QProcess {
        unsafe { qProcessKill(ptr) };
        this
    }
    public func terminate(): QProcess {
        unsafe { qProcessTerminate(ptr) };
        this
    }

    // ========== 设置 ==========

    public func setProgram(program: String): QProcess {
        unsafe {
            var p = LibC.mallocCString(program)
            qProcessSetProgram(ptr, p)
            LibC.free(p)
        }
        this
    }

    public func program(): String {
        unsafe {
            let cstr = qProcessProgram(ptr);
            let result = cstr.toString();
            freeBridgeString(cstr);
            result
        }
    }

    public func setArguments(args: String): QProcess {
        unsafe {
            var a = LibC.mallocCString(args)
            qProcessSetArguments(ptr, a)
            LibC.free(a)
        }
        this
    }

    public func arguments(): String {
        unsafe {
            let cstr = qProcessArguments(ptr);
            let result = cstr.toString();
            freeBridgeString(cstr);
            result
        }
    }

    public func setWorkingDirectory(dir: String): QProcess {
        unsafe {
            var d = LibC.mallocCString(dir)
            qProcessSetWorkingDirectory(ptr, d)
            LibC.free(d)
        }
        this
    }

    public func workingDirectory(): String {
        unsafe {
            let cstr = qProcessWorkingDirectory(ptr);
            let result = cstr.toString();
            freeBridgeString(cstr);
            result
        }
    }

    public func setProcessEnvironment(env: QProcessEnvironment): QProcess {
        unsafe { qProcessSetProcessEnvironment(ptr, env.getPtr()) }
        this
    }

    // ========== 读写 ==========

    public func write(data: String): Int64 {
        unsafe {
            var d = LibC.mallocCString(data)
            let result = qProcessWrite(ptr, d)
            LibC.free(d)
            result
        }
    }

    public func readAllStandardOutput(): String {
        unsafe {
            let cstr = qProcessReadAllStandardOutput(ptr);
            let result = cstr.toString();
            freeBridgeString(cstr);
            result
        }
    }
    public func readAllStandardError(): String {
        unsafe {
            let cstr = qProcessReadAllStandardError(ptr);
            let result = cstr.toString();
            freeBridgeString(cstr);
            result
        }
    }

    public func closeWriteChannel(): QProcess {
        unsafe { qProcessCloseWriteChannel(ptr) };
        this
    }
    public func closeReadChannel(channel: Int32): QProcess {
        unsafe { qProcessCloseReadChannel(ptr, channel) };
        this
    }

    // ========== 通道模式 ==========

    public func setProcessChannelMode(mode: Int32): QProcess {
        unsafe { qProcessSetProcessChannelMode(ptr, mode) };
        this
    }
    public func processChannelMode(): Int32 {
        unsafe { qProcessProcessChannelMode(ptr) }
    }

    public func setReadChannel(channel: Int32): QProcess {
        unsafe { qProcessSetReadChannel(ptr, channel) };
        this
    }
    public func readChannel(): Int32 {
        unsafe { qProcessReadChannel(ptr) }
    }

    // ========== 信号回调 ==========

    public func setOnFinished(callback: CFunc<(Int32, Int32) -> Unit>): QProcess {
        unsafe { qProcessSetOnFinished(ptr, callback) }
        this
    }

    public func setOnStarted(callback: CFunc<() -> Unit>): QProcess {
        unsafe { qProcessSetOnStarted(ptr, callback) }
        this
    }

    public func setOnReadyReadStandardOutput(callback: CFunc<() -> Unit>): QProcess {
        unsafe { qProcessSetOnReadyReadStandardOutput(ptr, callback) }
        this
    }

    public func setOnReadyReadStandardError(callback: CFunc<() -> Unit>): QProcess {
        unsafe { qProcessSetOnReadyReadStandardError(ptr, callback) }
        this
    }

    public func setOnErrorOccurred(callback: CFunc<(Int32) -> Unit>): QProcess {
        unsafe { qProcessSetOnErrorOccurred(ptr, callback) }
        this
    }

    public func setOnStateChanged(callback: CFunc<(Int32) -> Unit>): QProcess {
        unsafe { qProcessSetOnStateChanged(ptr, callback) }
        this
    }

    public func getPtr(): Int64 {
        ptr
    }
}

// ============================================================
// FFI 声明
// ============================================================

foreign func qProcessCreate(): Int64

foreign func qProcessDelete(p: Int64): Unit

foreign func qProcessStart(p: Int64, program: CString): Unit

foreign func qProcessStartWithArgs(p: Int64, program: CString, args: CString): Unit

foreign func qProcessStartCommand(p: Int64, command: CString): Unit

foreign func qProcessStartDetached(p: Int64): Int32

foreign func qProcessStartDetachedStatic(program: CString, args: CString, workingDir: CString): Int32

foreign func qProcessExecute(program: CString, args: CString): Int32

foreign func qProcessSystemEnvironment(): CString

foreign func qProcessWaitForStarted(p: Int64, msecs: Int32): Int32

foreign func qProcessWaitForFinished(p: Int64, msecs: Int32): Int32

foreign func qProcessState(p: Int64): Int32

foreign func qProcessExitCode(p: Int64): Int32

foreign func qProcessExitStatus(p: Int64): Int32

foreign func qProcessError(p: Int64): Int32

foreign func qProcessProcessId(p: Int64): Int64

foreign func qProcessKill(p: Int64): Unit

foreign func qProcessTerminate(p: Int64): Unit

foreign func qProcessSetProgram(p: Int64, program: CString): Unit

foreign func qProcessProgram(p: Int64): CString

foreign func qProcessSetArguments(p: Int64, args: CString): Unit

foreign func qProcessArguments(p: Int64): CString

foreign func qProcessSetWorkingDirectory(p: Int64, dir: CString): Unit

foreign func qProcessWorkingDirectory(p: Int64): CString

foreign func qProcessWrite(p: Int64, data: CString): Int64

foreign func qProcessReadAllStandardOutput(p: Int64): CString

foreign func qProcessReadAllStandardError(p: Int64): CString

foreign func qProcessCloseWriteChannel(p: Int64): Unit

foreign func qProcessCloseReadChannel(p: Int64, channel: Int32): Unit

foreign func qProcessSetProcessChannelMode(p: Int64, mode: Int32): Unit

foreign func qProcessProcessChannelMode(p: Int64): Int32

foreign func qProcessSetReadChannel(p: Int64, channel: Int32): Unit

foreign func qProcessReadChannel(p: Int64): Int32

foreign func qProcessSetOnFinished(p: Int64, callback: CFunc<(Int32, Int32) -> Unit>): Unit

foreign func qProcessSetOnStarted(p: Int64, callback: CFunc<() -> Unit>): Unit

foreign func qProcessSetOnReadyReadStandardOutput(p: Int64, callback: CFunc<() -> Unit>): Unit

foreign func qProcessSetOnReadyReadStandardError(p: Int64, callback: CFunc<() -> Unit>): Unit

foreign func qProcessSetOnErrorOccurred(p: Int64, callback: CFunc<(Int32) -> Unit>): Unit

foreign func qProcessSetOnStateChanged(p: Int64, callback: CFunc<(Int32) -> Unit>): Unit

foreign func qProcessEnvironmentCreate(): Int64

foreign func qProcessEnvironmentCreateSystem(): Int64

foreign func qProcessEnvironmentDelete(p: Int64): Unit

foreign func qProcessEnvironmentInsert(p: Int64, name: CString, value: CString): Unit

foreign func qProcessEnvironmentRemove(p: Int64, name: CString): Unit

foreign func qProcessEnvironmentValue(p: Int64, name: CString): CString

foreign func qProcessEnvironmentContains(p: Int64, name: CString): Int32

foreign func qProcessEnvironmentClear(p: Int64): Unit

foreign func qProcessEnvironmentIsEmpty(p: Int64): Int32

foreign func qProcessSetProcessEnvironment(procPtr: Int64, envPtr: Int64): Unit
