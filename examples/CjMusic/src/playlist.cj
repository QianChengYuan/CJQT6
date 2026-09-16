// ============================================================
// 播放列表逻辑（不依赖 Qt，纯数据操作）
// 设计文档 2.4 节播放状态机、2.5 节搜索过滤
// ============================================================
package CjMusic

import std.collection.*
import std.random.*
import std.fs.*
import cjqt6.multimedia.*



/// 添加多个文件到播放列表
/// paths: 文件路径列表
/// 返回新增数量
public func playlistAddMany(paths: Array<String>): Int32 {
    var count: Int32 = 0
    for (path in paths) {
        if (isAudioFile(path)) {
            let item = MusicItem(path)
            gPlaylist.add(item)
            count += 1
        }
    }
    count
}

/// 添加目录下所有音频文件
/// dirPath: 目录路径
/// 返回新增数量
public func playlistAddFolder(dirPath: String): Int32 {
    var count: Int32 = 0
    try {
        let entries = Directory.readFrom(Path(dirPath))
        for (entry in entries) {
            let fullPath = entry.path.toString()
            if (isAudioFile(fullPath)) {
                let item = MusicItem(fullPath)
                gPlaylist.add(item)
                count += 1
            }
        }
    } catch (e: Exception) {
        // 目录读取失败，静默返回
    }
    count
}


/// 计算下一曲索引（根据播放模式）
/// 返回 -1 表示无下一曲（顺序播放到末尾）
public func calcNextIndex(): Int32 {
    let size = Int32(gPlaylist.size)
    if (size == 0) {
        return -1
    }
    match (gPlayMode) {
        case LoopOne =>
            // 单曲循环：保持当前索引
            if (gCurrentIndex < 0) {
                0
            } else {
                gCurrentIndex
            }
        case Random =>
            // 随机播放
            if (size == 1) {
                0
            } else {
                var next = Int32(gRandomGen.nextUInt32() % UInt32(size))
                if (next == gCurrentIndex) {
                    next = (next + 1) % size
                }
                next
            }
        case Sequential | Loop =>
            // 顺序/循环：下一首
            if (gCurrentIndex < 0) {
                0
            } else if (gCurrentIndex + 1 < size) {
                gCurrentIndex + 1
            } else {
                match (gPlayMode) {
                    case Loop => 0  // 循环回到第一首
                    case _ => -1   // 顺序播放到末尾，停止
                }
            }
    }
}

/// 计算上一曲索引
public func calcPrevIndex(): Int32 {
    let size = Int32(gPlaylist.size)
    if (size == 0) {
        return -1
    }
    if (gCurrentIndex <= 0) {
        match (gPlayMode) {
            case Loop => size - 1  // 循环回到最后一首
            case _ => 0  // 已是第一首，保持
        }
    } else {
        gCurrentIndex - 1
    }
}

/// 切换到指定索引并播放
public func playAt(index: Int32): Unit {
    let size = Int32(gPlaylist.size)
    if (index < 0 || index >= size) {
        return
    }
    let item = gPlaylist[Int64(index)]
    if (item.invalid) {
        updateStatus("⚠ 该文件无效，已跳过")
        return
    }
    gCurrentIndex = index
    if (let Some(p) <- gPlayer) {
        p.setSourceFile(item.filePath)
        p.play()
        gIsPlaying = true
        // 切歌时惰性匹配歌词（文档 2.3.7 节）
        loadLyricsForCurrent()
        updateUI()
    }
}

/// 播放/暂停切换
public func togglePlay(): Unit {
    if (gPlaylist.size == 0) {
        updateStatus("播放列表为空，请先打开文件")
        return
    }
    if (gCurrentIndex < 0) {
        // 未开始播放，从第一首开始
        playAt(0)
        return
    }
    if (let Some(p) <- gPlayer) {
        let state = p.playbackState()
        if (state == PlaybackState.playing()) {
            p.pause()
            gIsPlaying = false
        } else if (state == PlaybackState.paused()) {
            p.play()
            gIsPlaying = true
        } else {
            // Stopped 状态，重新播放
            p.play()
            gIsPlaying = true
        }
        updatePlayButton()
    }
}

/// 停止播放
public func stopPlay(): Unit {
    if (let Some(p) <- gPlayer) {
        p.stop()
    }
    gIsPlaying = false
    gCurrentIndex = -1
    clearLyrics()
    updateUI()
}

/// 下一曲
public func nextTrack(): Unit {
    let idx = calcNextIndex()
    if (idx >= 0) {
        playAt(idx)
    } else {
        stopPlay()
    }
}

/// 上一曲
public func prevTrack(): Unit {
    let idx = calcPrevIndex()
    if (idx >= 0) {
        playAt(idx)
    }
}

/// 切换播放模式
public func cyclePlayMode(): Unit {
    gPlayMode = gPlayMode.next()
    updateModeButton()
    updateStatus("播放模式: ${gPlayMode.displayName()}")
}

/// 播放结束处理（由 mediaStatusChanged EndOfMedia 触发）
public func onPlaybackFinished(): Unit {
    match (gPlayMode) {
        case LoopOne =>
            // 单曲循环：重新播放
            if (let Some(p) <- gPlayer) {
                p.setPosition(0)
                p.play()
                gIsPlaying = true
            }
        case _ =>
            let idx = calcNextIndex()
            if (idx >= 0 && idx != gCurrentIndex) {
                playAt(idx)
            } else if (idx == gCurrentIndex) {
                // 单曲循环场景
                if (let Some(p) <- gPlayer) {
                    p.setPosition(0)
                    p.play()
                }
            } else {
                // 顺序播放到末尾
                gIsPlaying = false
                updatePlayButton()
            }
    }
}

// ============================================================
// 搜索过滤（文档 2.5 节）
// ============================================================

/// 重建可见行索引（搜索过滤后保留的原始索引）
public func rebuildVisibleRows(): Unit {
    gVisibleRows.clear()
    // 用 textChanged 回调更新的全局关键词，避免回读 QLineEdit.text() 的链路不确定性
    let keyword = gSearchKeyword.toAsciiLower()
    if (keyword.isEmpty()) {
        // 无搜索词：全部可见
        for (i in 0..gPlaylist.size) {
            gVisibleRows.add(Int32(i))
        }
    } else {
        // 有搜索词：按标题/文件名/歌手过滤
        for (i in 0..gPlaylist.size) {
            let item = gPlaylist[i]
            let title = item.title.toAsciiLower()
            let fileName = item.fileName.toAsciiLower()
            let artist = item.artist.toAsciiLower()
            if (title.contains(keyword) || fileName.contains(keyword) || artist.contains(keyword)) {
                gVisibleRows.add(Int32(i))
            }
        }
    }
}

/// UI 行号 → 原始索引（文档 2.5 节：过滤不影响底层索引）
public func uiRowToOriginal(uiRow: Int32): Int32 {
    if (uiRow < 0 || Int64(uiRow) >= Int64(gVisibleRows.size)) {
        return -1
    }
    gVisibleRows[Int64(uiRow)]
}

// ============================================================
// 辅助函数
// ============================================================

/// 判断文件是否为支持的音频格式
public func isAudioFile(path: String): Bool {
    let lower = path.toAsciiLower()
    for (ext in AUDIO_EXTENSIONS) {
        if (lower.endsWith(".${ext}")) {
            return true
        }
    }
    false
}

/// 路径拼接（跨平台，文档 7.1 节：不硬编码分隔符）
public func joinPath(dir: String, name: String): String {
    let p = Path(dir)
    p.join(name).toString()
}

/// 清空歌词状态
public func clearLyrics(): Unit {
    gLyricLines = ArrayList<LyricLineInfo>()
    gCurrentLyricIndex = -1
    gHasLyrics = false
    gLyricSource = ""
    gLyricOffsetMs = 0
}

/// 更新状态栏（由 UI 层实现）
public func updateStatus(msg: String): Unit {
    if (let Some(lbl) <- gStatusBar) {
        lbl.setText(msg)
    }
}

/// 更新播放按钮图标（由 UI 层实现）
public func updatePlayButton(): Unit {
    if (let Some(btn) <- gPlayButton) {
        if (gIsPlaying) {
            btn.setIcon(gIconDir + "/pause.svg")
        } else {
            btn.setIcon(gIconDir + "/play.svg")
        }
    }
}

/// 更新播放模式按钮（由 UI 层实现）
public func updateModeButton(): Unit {
    if (let Some(btn) <- gModeButton) {
        match (gPlayMode) {
            case Sequential => btn.setIcon(gIconDir + "/sequential.svg")
            case Loop => btn.setIcon(gIconDir + "/loop.svg")
            case LoopOne => btn.setIcon(gIconDir + "/loop_one.svg")
            case Random => btn.setIcon(gIconDir + "/random.svg")
        }
        unsafe {
            var tipCstr = LibC.mallocCString("播放模式: ${gPlayMode.displayName()}")
            qWidgetSetToolTip(btn.getPtr(), tipCstr)
            LibC.free(tipCstr)
        }
    }
}

/// 更新传输按钮启用/禁用状态（列表有歌曲时启用）
public func updateTransportButtons(): Unit {
    let hasItems = gPlaylist.size > 0
    if (let Some(btn) <- gPrevButton) { btn.setEnabled(hasItems) }
    if (let Some(btn) <- gPlayButton) { btn.setEnabled(hasItems) }
    if (let Some(btn) <- gNextButton) { btn.setEnabled(hasItems) }
    if (!hasItems) {
        if (let Some(slider) <- gProgressSlider) { slider.setEnabled(false) }
    }
}

/// 更新 UI 显示（由 UI 层实现）
public func updateUI(): Unit {
    if (let Some(item) <- getCurrentItem()) {
        if (let Some(lbl) <- gTitleLabel) {
            lbl.setText(item.title)
        }
        if (let Some(lbl) <- gArtistLabel) {
            lbl.setText(item.artist)
        }
        if (let Some(lbl) <- gFileNameLabel) {
            lbl.setText(item.fileName)
        }
    } else {
        if (let Some(lbl) <- gTitleLabel) {
            lbl.setText("未播放")
        }
        if (let Some(lbl) <- gArtistLabel) {
            lbl.setText("")
        }
        if (let Some(lbl) <- gFileNameLabel) {
            lbl.setText("未播放")
        }
    }
    updatePlayButton()
    updateModeButton()
    updateTransportButtons()
    highlightCurrentItem()
}

/// 加载当前歌曲歌词（由 lyric_controller 实现）
public func loadLyricsForCurrent(): Unit {
    // 在 lyric_controller.cj 中实现
    loadLyricsForCurrentImpl()
}

/// 歌词区重绘触发（由 lyric_widget 实现）
public func triggerLyricRepaint(): Unit {
    if (let Some(w) <- gLyricWidget) {
        w.update()
    }
}