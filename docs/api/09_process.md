# CJQT6 进程管理模块

本模块提供进程管理功能。

## QProcess - 进程管理类

QProcess 用于启动外部程序并与之通信。

```cangjie
import cjqt6.core.*

// 创建进程
let process = QProcess()

// 启动进程
process.startWithArgs("ls", "-la /home")

// 等待完成
if (process.waitForFinished(5000)) {
    // 读取输出
    let output = process.readAllStandardOutput()
    let error = process.readAllStandardError()
    println("输出: ${output}")
    println("错误: ${error}")
    println("退出码: ${process.exitCode()}")
}

process.delete()
```

**启动进程方法**:
| 方法 | 说明 |
|------|------|
| `start(program)` | 启动程序（无参数） |
| `startWithArgs(program, args)` | 启动程序带参数（空格分隔） |
| `startCommand(command)` | 启动命令字符串 |
| `startDetached(): Int32` | 启动分离进程，返回PID |

**静态方法**:
| 方法 | 说明 |
|------|------|
| `startDetachedProcess(program, args, workingDir)` | 静态方法启动分离进程 |
| `executeCommand(program, args)` | 执行命令并等待，返回退出码 |
| `systemEnvironment()` | 获取系统环境变量 |

**进程控制**:
| 方法 | 说明 |
|------|------|
| `kill()` | 强制终止进程 |
| `terminate()` | 终止进程 |
| `waitForStarted(msecs)` | 等待进程启动 |
| `waitForFinished(msecs)` | 等待进程完成 |

**状态查询**:
| 方法 | 说明 |
|------|------|
| `state(): Int32` | 获取进程状态 |
| `isRunning(): Bool` | 是否正在运行 |
| `exitCode(): Int32` | 获取退出码 |
| `exitStatus(): Int32` | 获取退出状态 |
| `error(): Int32` | 获取错误类型 |
| `processId(): Int64` | 获取进程ID |

**输入输出**:
| 方法 | 说明 |
|------|------|
| `write(data)` | 写入数据到进程标准输入 |
| `readAllStandardOutput(): String` | 读取标准输出 |
| `readAllStandardError(): String` | 读取标准错误 |
| `closeWriteChannel()` | 关闭写入通道 |
| `closeReadChannel(channel)` | 关闭读取通道 |

**配置**:
| 方法 | 说明 |
|------|------|
| `setProgram(program)` | 设置程序路径 |
| `setArguments(args)` | 设置参数 |
| `setWorkingDirectory(dir)` | 设置工作目录 |
| `setProcessEnvironment(env)` | 设置环境变量 |
| `setProcessChannelMode(mode)` | 设置通道模式 |

**进程状态常量** (ProcessState):
```cangjie
ProcessState.NotRunning  // 未运行
ProcessState.Starting    // 正在启动
ProcessState.Running     // 正在运行
```

**退出状态常量** (ExitStatus):
```cangjie
ExitStatus.NormalExit  // 正常退出
ExitStatus.CrashExit   // 崩溃退出
```

**错误类型常量** (ProcessError):
```cangjie
ProcessError.FailedToStart  // 启动失败
ProcessError.Crashed        // 崩溃
ProcessError.Timedout       // 超时
ProcessError.ReadError      // 读取错误
ProcessError.WriteError     // 写入错误
ProcessError.UnknownError   // 未知错误
```

**通道模式常量** (ProcessChannelMode):
```cangjie
ProcessChannelMode.SeparateChannels     // 分离通道（默认）
ProcessChannelMode.MergedChannels       // 合并标准输出和错误
ProcessChannelMode.ForwardedChannels    // 转发到主进程
```

---

## 信号回调

```cangjie
// 进程完成回调
let finishedCallback: CFunc<(Int32, Int32) -> Unit> = { exitCode: Int32, exitStatus: Int32 =>
    println("进程完成，退出码: ${exitCode}")
}
process.setOnFinished(finishedCallback)

// 进程启动回调
let startedCallback: CFunc<() -> Unit> = { =>
    println("进程已启动")
}
process.setOnStarted(startedCallback)

// 标准输出就绪
let readyOutCallback: CFunc<() -> Unit> = { =>
    let output = process.readAllStandardOutput()
    println("输出: ${output}")
}
process.setOnReadyReadStandardOutput(readyOutCallback)

// 错误输出就绪
let readyErrCallback: CFunc<() -> Unit> = { =>
    let error = process.readAllStandardError()
    println("错误: ${error}")
}
process.setOnReadyReadStandardError(readyErrCallback)

// 错误发生
let errorCallback: CFunc<(Int32) -> Unit> = { error: Int32 =>
    println("进程错误: ${error}")
}
process.setOnErrorOccurred(errorCallback)

// 状态变化
let stateCallback: CFunc<(Int32) -> Unit> = { state: Int32 =>
    println("进程状态变化: ${state}")
}
process.setOnStateChanged(stateCallback)
```

---

## QProcessEnvironment - 环境变量

```cangjie
// 获取系统环境
let env = QProcessEnvironment.system()

// 创建空环境
let env2 = QProcessEnvironment()

// 设置环境变量
env2.insert("PATH", "/usr/bin:/bin")
env2.insert("HOME", "/home/user")
env2.insert("LANG", "zh_CN.UTF-8")

// 移除环境变量
env2.remove("OLDPWD")

// 检查是否存在
if (env2.contains("HOME")) {
    println("HOME: ${env2.value("HOME")}")
}

// 应用到进程
process.setProcessEnvironment(env2)
```

**QProcessEnvironment 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空环境 |
| `system()` | 获取系统环境（静态方法） |
| `insert(name, value)` | 设置环境变量 |
| `remove(name)` | 移除环境变量 |
| `value(name): String` | 获取环境变量值 |
| `contains(name): Bool` | 检查是否存在 |
| `clear()` | 清空所有变量 |
| `isEmpty(): Bool` | 是否为空 |
| `delete()` | 释放资源 |
