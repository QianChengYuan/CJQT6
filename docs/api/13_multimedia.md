# CJQT6 多媒体模块

多媒体模块提供音频播放功能。

```cangjie
import cjqt6.multimedia.*
```

## QMediaPlayer - 媒体播放器

```cangjie
import cjqt6.multimedia.*

let player = QMediaPlayer()
let audioOutput = QAudioOutput()

player.setAudioOutput(audioOutput)
player.setSourceFile("/path/to/music.mp3")

player.play()
player.pause()
player.stop()

audioOutput.setVolume(50.0f32)
player.setPlaybackRate(1.5f32)
player.setLoops(Loops.infinite())
```

**播放控制方法**:
| 方法 | 说明 |
|------|------|
| `setSource(url: String)` | 设置媒体源（URL） |
| `setSourceFile(filePath: String)` | 设置本地文件 |
| `setAudioOutput(output: QAudioOutput)` | 绑定音频输出设备 |
| `play()` | 播放 |
| `pause()` | 暂停 |
| `stop()` | 停止 |
| `setPosition(position: Int64)` | 设置播放位置（毫秒） |
| `position(): Int64` | 获取播放位置（毫秒） |
| `duration(): Int64` | 获取总时长（毫秒） |
| `setVolume(volume: Float32)` | 设置音量 |
| `volume(): Float32` | 获取音量 |
| `setLoops(loops: Int32)` | 设置循环次数，`Loops.infinite()` 表示无限循环 |
| `setPlaybackRate(rate: Float32)` | 设置播放速度 |
| `playbackRate(): Float32` | 获取播放速度 |
| `delete()` | 释放资源 |

**媒体信息与状态**:
| 方法 | 说明 |
|------|------|
| `metaData(key: String): String` | 获取元数据 |
| `title(): String` | 获取标题 |
| `artist(): String` | 获取艺术家 |
| `album(): String` | 获取专辑 |
| `isSeekable(): Bool` | 是否可跳转 |
| `hasAudio(): Bool` | 是否有音频 |
| `playbackState(): Int32` | 获取播放状态 |
| `mediaStatus(): Int32` | 获取媒体状态 |
| `error(): Int32` | 获取错误码 |
| `errorString(): String` | 获取错误描述 |

**状态常量**:
| 常量类 | 说明 |
|------|------|
| `PlaybackState.stopped()` | 已停止 |
| `PlaybackState.playing()` | 正在播放 |
| `PlaybackState.paused()` | 已暂停 |
| `MediaStatus.noMedia()` | 无媒体 |
| `MediaStatus.loading()` | 加载中 |
| `MediaStatus.loaded()` | 已加载 |
| `MediaStatus.buffering()` | 缓冲中 |
| `MediaStatus.stalled()` | 停滞 |
| `MediaStatus.buffered()` | 已缓冲 |
| `MediaStatus.endOfMedia()` | 播放结束 |
| `MediaStatus.invalidMedia()` | 无效媒体 |
| `Loops.infinite()` | 无限循环 |

---

## 信号回调

QMediaPlayer 目前通过直接传入 `CFunc<(...) -> Unit>` 的方式注册回调：

```cangjie
let player = QMediaPlayer()

let onPositionChanged: CFunc<(Int64) -> Unit> = { pos: Int64 =>
    println("播放位置: ${pos}ms")
}

let onDurationChanged: CFunc<(Int64) -> Unit> = { dur: Int64 =>
    println("总时长: ${dur}ms")
}

player.onPositionChanged(onPositionChanged)
player.onDurationChanged(onDurationChanged)
```

**信号回调方法**:
| 方法 | 回调类型 | 说明 |
|------|----------|------|
| `onPositionChanged(callback)` | `CFunc<(Int64) -> Unit>` | 播放位置变化 |
| `onDurationChanged(callback)` | `CFunc<(Int64) -> Unit>` | 媒体时长变化 |
| `onPlaybackStateChanged(callback)` | `CFunc<(Int32) -> Unit>` | 播放状态变化 |
| `onMediaStatusChanged(callback)` | `CFunc<(Int32) -> Unit>` | 媒体状态变化 |

> 说明：当前封装没有要求使用 `@C` 修饰顶层函数；只要传入与签名匹配的 `CFunc` 即可。

---

## QCameraDevice — 摄像头设备描述

描述摄像头设备信息。

```cangjie
import cjqt6.multimedia.*

// 获取默认摄像头
let device = QMediaDevices.defaultVideoInput()
println("设备: ${device.description()}")
println("ID: ${device.id()}")
device.delete()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `description(): String` | 获取设备描述名称 |
| `id(): String` | 获取设备 ID |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

---

## QMediaDevices — 媒体设备信息（静态类）

提供设备枚举功能。

```cangjie
import cjqt6.multimedia.*

// 获取默认视频输入设备
let device = QMediaDevices.defaultVideoInput()

// 获取视频输入设备数量
let count = QMediaDevices.videoInputCount()
println("可用摄像头数: ${count}")
```

**方法**:
| 方法 | 说明 |
|------|------|
| `defaultVideoInput(): QCameraDevice` | 获取默认摄像头设备 |
| `videoInputCount(): Int32` | 获取可用摄像头数量 |

---

## QCamera — 摄像头控制

控制摄像头采集。

```cangjie
import cjqt6.multimedia.*

// 使用默认摄像头
let camera = QCamera()

// 使用指定摄像头
let device = QMediaDevices.defaultVideoInput()
let camera = QCamera(device)
device.delete()  // 创建设备后可释放

// 启动/停止
camera.start()
camera.stop()

// 查询状态
let active = camera.isActive()
let error = camera.errorString()

camera.close()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 使用默认设备创建 |
| `init(device: QCameraDevice)` | 使用指定设备创建 |
| `start()` | 启动摄像头 |
| `stop()` | 停止摄像头 |
| `isActive(): Bool` | 是否激活 |
| `errorCode(): Int32` | 获取错误码 |
| `errorString(): String` | 获取错误描述 |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

---

## QMediaCaptureSession — 媒体捕获会话

管理摄像头到视频输出的连接。

```cangjie
import cjqt6.multimedia.*

let session = QMediaCaptureSession()
let camera = QCamera()
let videoWidget = QVideoWidget()

// 配置捕获会话
session.setCamera(camera.getPtr())
session.setVideoOutput(videoWidget.getPtr())

camera.start()    // 开始采集
videoWidget.show() // 显示视频

// 清理
camera.close()
session.close()
videoWidget.close()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建捕获会话 |
| `setCamera(cameraPtr: Int64)` | 设置摄像头 |
| `setVideoOutput(outputPtr: Int64)` | 设置视频输出（QVideoWidget 指针） |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

---

## QVideoWidget — 视频显示控件

用于显示视频画面的窗口部件。

```cangjie
import cjqt6.multimedia.*

let videoWidget = QVideoWidget()

// 设置宽高比模式
videoWidget.setAspectRatioMode(AspectRatioMode.keep())

// 显示
videoWidget.show()

videoWidget.close()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建视频显示控件 |
| `show()` | 显示控件 |
| `setAspectRatioMode(mode: Int32)` | 设置宽高比模式 |
| `aspectRatioMode(): Int32` | 获取宽高比模式 |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

**宽高比模式常量** (`AspectRatioMode`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `AspectRatioMode.ignore()` | 0 | 忽略宽高比 |
| `AspectRatioMode.keep()` | 1 | 保持宽高比 |
| `AspectRatioMode.keepByExpanding()` | 2 | 保持宽高比并扩展 |