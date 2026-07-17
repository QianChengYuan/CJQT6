# CJQT6 多媒体模块

多媒体模块提供音频播放功能。

```cangjie
import cjqt6.multimedia.*
```

## QMediaPlayer - 媒体播放器

```cangjie
let player = QMediaPlayer()
let audioOutput = QAudioOutput()

// 设置音频输出
player.setAudioOutput(audioOutput.getPtr())

// 加载文件
player.setSourceFile("/path/to/music.mp3")

// 播放控制
player.play()
player.pause()
player.stop()

// 音量控制
audioOutput.setVolume(50)  // 0-100

// 播放速度
player.setPlaybackRate(1.5)  // 1.5倍速

// 循环播放
player.setLoops(-1)  // -1 表示无限循环，0 表示播放一次，n 表示循环 n 次
```

**背景音乐示例**:
```cangjie
// 全局变量保存播放器
var gAudioOutput: ?QAudioOutput = None
var gMusicPlayer: ?QMediaPlayer = None

func setupBackgroundMusic(): Unit {
    gAudioOutput = QAudioOutput()
    gMusicPlayer = QMediaPlayer()
    
    if (let Some(audio) <- gAudioOutput) {
        audio.setVolume(50)  // 50% 音量
    }
    
    if (let Some(player) <- gMusicPlayer) {
        if (let Some(audio) <- gAudioOutput) {
            player.setAudioOutput(audio)
        }
        player.setSourceFile("background.mp3")
        player.setLoops(-1)  // 无限循环
        player.play()
    }
}

// 在程序退出时释放资源
func cleanupBackgroundMusic(): Unit {
    if (let Some(player) <- gMusicPlayer) {
        player.stop()
        player.delete()
    }
    if (let Some(audio) <- gAudioOutput) {
        audio.delete()
    }
}
```

**播放控制方法**:
| 方法 | 说明 |
|------|------|
| `play()` | 播放 |
| `pause()` | 暂停 |
| `stop()` | 停止 |
| `setSource(url: String)` | 设置媒体源（URL） |
| `setSourceFile(path: String)` | 设置本地文件 |
| `setLoops(count: Int32)` | 设置循环次数（-1=无限循环） |
| `loops(): Int32` | 获取循环次数 |

**播放状态**:
| 方法 | 说明 |
|------|------|
| `isPlaying(): Bool` | 是否正在播放 |
| `isPaused(): Bool` | 是否暂停 |
| `isStopped(): Bool` | 是否停止 |
| `position(): Int64` | 获取播放位置（毫秒） |
| `duration(): Int64` | 获取总时长（毫秒） |
| `setPosition(pos: Int64)` | 设置播放位置 |
| `playbackRate(): Float64` | 获取播放速度 |
| `setPlaybackRate(rate: Float64)` | 设置播放速度 |
| `delete()` | **必须调用** - 释放资源 |

**媒体信息**:
| 方法 | 说明 |
|------|------|
| `title(): String` | 获取标题 |
| `artist(): String` | 获取艺术家 |
| `album(): String` | 获取专辑 |
| `metaData(key: String): String` | 获取元数据 |

**状态查询**:
| 方法 | 说明 |
|------|------|
| `isSeekable(): Bool` | 是否可跳转 |
| `hasAudio(): Bool` | 是否有音频 |
| `mediaStatus(): Int32` | 媒体状态 |
| `error(): Int32` | 错误类型 |
| `errorString(): String` | 错误描述 |

---

## 信号回调

回调函数必须是顶级函数，使用 `@C` 修饰，参数类型为 `CFunc<(参数类型) -> Unit>`:

```cangjie
// 定义 @C 回调函数
@C
func onPositionChanged(pos: Int64): Unit {
    println("播放位置: ${pos}ms")
}

@C
func onDurationChanged(dur: Int64): Unit {
    println("总时长: ${dur}ms")
}

@C
func onPlaybackStateChanged(state: Int32): Unit {
    // state: 0=Stopped, 1=Playing, 2=Paused
    match (state) {
        case 1 => println("开始播放")
        case 2 => println("已暂停")
        case 0 => println("已停止")
        case _ => ()
    }
}

@C
func onMediaStatusChanged(status: Int32): Unit {
    // status == 6 表示 EndOfMedia
    if (status == 6) {
        println("播放结束")
    }
}

// 注册回调
player.onPositionChanged(onPositionChanged)
player.onDurationChanged(onDurationChanged)
player.onPlaybackStateChanged(onPlaybackStateChanged)
player.onMediaStatusChanged(onMediaStatusChanged)
```

**信号回调方法**:
| 方法 | 回调类型 | 说明 |
|------|----------|------|
| `onPositionChanged(callback)` | `CFunc<(Int64) -> Unit>` | 播放位置变化 |
| `onDurationChanged(callback)` | `CFunc<(Int64) -> Unit>` | 媒体时长变化 |
| `onPlaybackStateChanged(callback)` | `CFunc<(Int32) -> Unit>` | 播放状态变化 |
| `onMediaStatusChanged(callback)` | `CFunc<(Int32) -> Unit>` | 媒体状态变化 |

**注意事项**:
- 回调函数必须是顶级函数，不能是嵌套函数或类方法
- 回调函数需要 `@C` 修饰符
- 使用信号回调比定时器轮询更高效，避免音频卡顿
- 更新 UI 控件时注意防止循环触发（如 slider.setValue 触发 valueChanged）

**媒体状态常量** (MediaStatus):
```cangjie
NoMedia         // 无媒体
LoadingMedia    // 加载中
LoadedMedia     // 已加载
BufferingMedia  // 缓冲中
StalledMedia    // 停滞
BufferedMedia   // 已缓冲
EndOfMedia      // 播放结束
InvalidMedia    // 无效媒体
```

---

## QAudioOutput - 音频输出

```cangjie
let audioOutput = QAudioOutput()
audioOutput.setVolume(80)  // 音量 0-100
audioOutput.setMuted(true) // 静音

if (audioOutput.isMuted()) {
    audioOutput.setMuted(false)
}

// 使用完毕后释放资源
audioOutput.delete()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建音频输出 |
| `setVolume(volume: Int32)` | 设置音量（0-100） |
| `volume(): Int32` | 获取音量 |
| `setMuted(muted: Bool)` | 设置静音 |
| `isMuted(): Bool` | 是否静音 |
| `delete()` | 释放资源 |
