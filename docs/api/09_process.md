# CJQT6 进程管理模块

本模块提供进程启动、参数设置、状态查询以及环境变量管理能力。当前实现主要位于 core 包下，提供了 QProcess 和 QProcessEnvironment 两个封装。

```cangjie
import cjqt6.core.*

let process = QProcess()
process.startWithArgs("python", "-V")

if (process.waitForFinished(5000)) {
    println(process.readAllStandardOutput())
    println(process.readAllStandardError())
    println(process.exitCode())
}

process.delete()
```

## QProcess

### 启动与控制

| 方法 | 说明 |
|------|------|
| `start(program: String)` | 启动程序 |
| `startWithArgs(program: String, args: String)` | 启动程序并传入参数字符串 |
| `startCommand(command: String)` | 启动命令字符串 |
| `startDetached(): Int32` | 启动独立进程并返回退出码/状态 |
| `waitForStarted(msecs: Int32)` | 等待进程启动 |
| `waitForFinished(msecs: Int32)` | 等待进程结束 |
| `kill()` | 强制终止 |
| `terminate()` | 终止进程 |

### 配置与查询

| 方法 | 说明 |
|------|------|
| `setProgram(program: String)` | 设置程序路径 |
| `program(): String` | 获取程序路径 |
| `setArguments(args: String)` | 设置参数字符串 |
| `arguments(): String` | 获取参数字符串 |
| `setWorkingDirectory(dir: String)` | 设置工作目录 |
| `workingDirectory(): String` | 获取工作目录 |
| `setProcessEnvironment(env: QProcessEnvironment)` | 绑定环境变量 |
| `state(): Int32` | 获取状态 |
| `isRunning(): Bool` | 是否正在运行 |
| `exitCode(): Int32` | 获取退出码 |
| `exitStatus(): Int32` | 获取退出状态 |
| `error(): Int32` | 获取错误类型 |
| `processId(): Int64` | 获取进程 ID |
| `write(data: String): Int64` | 向子进程写入标准输入 |
| `readAllStandardOutput(): String` | 读取标准输出 |
| `readAllStandardError(): String` | 读取标准错误 |
| `closeWriteChannel()` | 关闭写入通道 |
| `closeReadChannel(channel: Int32)` | 关闭读取通道 |
| `setProcessChannelMode(mode: Int32)` | 设置通道模式 |
| `processChannelMode(): Int32` | 获取通道模式 |
| `setReadChannel(channel: Int32)` | 设置读取通道 |
| `readChannel(): Int32` | 获取当前读取通道 |

### 信号回调

```cangjie
process.setOnFinished({ exitCode: Int32, exitStatus: Int32 =>
    println("finished: ${exitCode}")
})

process.setOnStarted({ =>
    println("started")
})

process.setOnReadyReadStandardOutput({ =>
    println(process.readAllStandardOutput())
})

process.setOnReadyReadStandardError({ =>
    println(process.readAllStandardError())
})
```

### 常量

```cangjie
ProcessState.NotRunning
ProcessState.Starting
ProcessState.Running

ExitStatus.NormalExit
ExitStatus.CrashExit

ProcessError.FailedToStart
ProcessError.Crashed
ProcessError.Timedout
ProcessError.ReadError
ProcessError.WriteError
ProcessError.UnknownError

ProcessChannelMode.SeparateChannels
ProcessChannelMode.MergedChannels
ProcessChannelMode.ForwardedChannels
ProcessChannelMode.ForwardedOutputChannel
ProcessChannelMode.ForwardedErrorChannel

ProcessChannel.StandardOutput
ProcessChannel.StandardError
```

## QProcessEnvironment

```cangjie
let env = QProcessEnvironment.system()
env.insert("PATH", "/usr/bin:/bin")
env.remove("OLDPWD")

if (env.contains("HOME")) {
    println(env.value("HOME"))
}
```

| 方法 | 说明 |
|------|------|
| `init()` | 创建空环境 |
| `system()` | 获取系统环境 |
| `insert(name: String, value: String)` | 设置变量 |
| `remove(name: String)` | 删除变量 |
| `value(name: String): String` | 获取变量值 |
| `contains(name: String): Bool` | 是否存在 |
| `clear()` | 清空环境 |
| `isEmpty(): Bool` | 是否为空 |
| `delete()` | 释放资源 |
