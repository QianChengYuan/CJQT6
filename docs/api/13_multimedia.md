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