// ============================================================
// CjMusic 入口 + 信号槽连接
// ============================================================
package CjMusic

import cjqt6.core.*

import cjqt6.multimedia.*
import std.env.*
import std.fs.*

// ============================================================
// QMediaPlayer 信号回调（@C func，不能捕获局部变量）
// ============================================================

@C
func cbPositionChanged(pos: Int64): Unit {
    if (pos < 0) {
        return
    }
    // 用户正在拖动进度条：不更新 slider/timeLabel，避免定时器把用户拖动的值覆盖
    // （slider/timeLabel 由 onProgressSliderMoved 实时更新）
    if (gIsSeeking) {
        return
    }
    if (let Some(p) <- gPlayer) {
        let dur = p.duration()
        if (dur > 0) {
            // 更新进度条（防循环）
            gIsUpdatingSlider = true
            if (let Some(slider) <- gProgressSlider) {
                slider.setValue(Int32(pos * 100 / dur))
            }
            gIsUpdatingSlider = false
            // 更新时间显示（当前时间 + 总时间分别更新）
            if (let Some(lbl) <- gTimeLabel) {
                lbl.setText(formatTime(pos))
            }
            if (let Some(lbl) <- gTotalTimeLabel) {
                lbl.setText(formatTime(dur))
            }
        }
        // 更新歌词定位（拖动进度条时不更新，避免闪烁）
        if (!gIsSeeking) {
            if (updateLyricIndex(pos)) {
                // 歌词行变化，触发滚动动画 + 重绘
                onLyricLineChanged()
            }
        }
    }
}

@C
func cbDurationChanged(dur: Int64): Unit {
    if (dur > 0) {
        if (let Some(p) <- gPlayer) {
            if (let Some(lbl) <- gTimeLabel) {
                lbl.setText(formatTime(p.position()))
            }
            if (let Some(lbl) <- gTotalTimeLabel) {
                lbl.setText(formatTime(dur))
            }
        }
    }
}

@C
func cbPlaybackStateChanged(state: Int32): Unit {
    // state: 0=Stopped, 1=Playing, 2=Paused
    match (state) {
        case 1 =>
            // Playing
            gIsPlaying = true
            updatePlayButton()
        case 0 =>
            // Stopped
            // 只有在播放中状态变为 Stopped 且位置接近结尾时才认为播放结束
            if (gIsPlaying) {
                if (let Some(p) <- gPlayer) {
                    let pos = p.position()
                    let dur = p.duration()
                    if (dur > 0 && pos >= dur - 1000) {
                        gIsPlaying = false
                        onPlaybackFinished()
                    }
                }
            }
        case 2 =>
            // Paused
            gIsPlaying = false
            updatePlayButton()
        case _ => ()
    }
}

@C
func cbMediaStatusChanged(status: Int32): Unit {
    // status: 0=NoMedia, 1=Loading, 2=Loaded, 3=Buffering, 4=Stalled, 5=Buffered, 6=EndOfMedia, 7=InvalidMedia
    match (status) {
        case 6 =>
            // EndOfMedia → 自动下一曲
            onPlaybackFinished()
        case 7 =>
            // InvalidMedia → 文件损坏/丢失
            if (let Some(item) <- getCurrentItem()) {
                item.invalid = true
                updatePlaylistItemDisplay(gCurrentIndex)
            }
            updateStatus("⚠ 文件不存在或已损坏")
            // 自动跳到下一曲
            nextTrack()
        case 2 | 5 =>
            // Loaded/Buffered → 读取元数据并刷新界面
            if (let Some(p) <- gPlayer) {
                if (let Some(item) <- getCurrentItem()) {
                    item.updateInfo(p)
                    updatePlaylistItemDisplay(gCurrentIndex)
                    updateUI()
                    updateStatus("正在播放: ${item.title} - ${item.artist}")
                }
            }
        case _ => ()
    }
}

// ============================================================
// 初始化播放器
// ============================================================

func initPlayer(): Unit {
    let player = QMediaPlayer()
    let audioOutput = QAudioOutput()
    player.setAudioOutput(audioOutput)
    audioOutput.setVolume(gCurrentVolume)

    // 连接信号
    player.onPositionChanged(cbPositionChanged)
    player.onDurationChanged(cbDurationChanged)
    player.onPlaybackStateChanged(cbPlaybackStateChanged)
    player.onMediaStatusChanged(cbMediaStatusChanged)

    // 全局持有（防 GC 回收，文档 3.3.1 节）
    gPlayer = Some(player)
    gAudioOutput = Some(audioOutput)
}

// ============================================================
// 入口
// ============================================================

main(): Int32 {
    setVariable("QT_MEDIA_BACKEND", "windows")

    // 设置图标目录路径（相对于工作目录的 icons/ 解析为绝对路径）
    let iconPath = canonicalize(Path("icons"))
    gIconDir = "${iconPath}"

    let app = QApplication()

    initPlayer()

    let window = createMainWindow()
    window.show()

    app.exec()
    0
}

