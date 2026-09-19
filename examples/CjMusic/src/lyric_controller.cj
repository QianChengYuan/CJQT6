// ============================================================
// 歌词控制器：封装 lrc4cj，含偏移校准
// 设计文档 2.3.8/2.3.9/2.3.11 节
// ============================================================
package CjMusic

import std.collection.*
import std.fs.*
import lrc4cj.core.*
import lrc4cj.model.*

// ============================================================
// 歌词解析与加载
// ============================================================

/// 加载当前播放歌曲的歌词（被 playlist.cj 的 loadLyricsForCurrent 调用）
/// 实现文档 2.3.7 节：切歌时惰性匹配
public func loadLyricsForCurrentImpl(): Unit {
    clearLyrics()
    if (let Some(item) <- getCurrentItem()) {
        loadLyricsForFile(item.filePath)
    }
}

/// 为指定音频文件加载歌词
/// 流程：手动指定 → L1~L5 分级匹配 → 解析 → 转换为 UI 数据
public func loadLyricsForFile(audioPath: String): Unit {
    // 1. 先查用户手动指定（文档 2.3.5 节第 3 点）
    var lrcPath: ?String = getManualLyric(audioPath)
    var matchLevel: Int32 = 6 // 手动指定

    // 2. 无手动指定 → 分级匹配
    match (lrcPath) {
        case None => match (matchLyrics(audioPath)) {
            case Some(result) =>
                lrcPath = Some(result.path)
                matchLevel = result.level
            case None =>
                // 无匹配
                gHasLyrics = false
                gLyricSource = ""
                updateStatus("未找到歌词")
                return
        }
        case Some(_) => () // 已有手动指定，跳过匹配
    }

    // 3. 解析歌词文件
    match (lrcPath) {
        case Some(path) =>
            if (!exists(Path(path))) {
                gHasLyrics = false
                gLyricSource = ""
                return
            }
            try {
                let parser = LrcParser()
                let lyrics = parser.parse(path)
                // 转换为 UI 层数据（文档 2.3.9 节：过滤 start < 0 的行）
                convertLyrics(lyrics)
                // 记录匹配来源（文档 2.3.6 节）
                gLyricSource = Path(path).fileName
                gHasLyrics = gLyricLines.size > 0
                if (gHasLyrics) {
                    updateStatus("歌词已加载: ${gLyricSource} (L${matchLevel})")
                } else {
                    updateStatus("歌词文件无有效行: ${gLyricSource}")
                }
            } catch (e: LrcException) {
                // 文档 2.3.8 节：解析失败不崩溃
                gHasLyrics = false
                gLyricSource = ""
                updateStatus("歌词解析失败（编码不支持）: ${Path(path).fileName}")
            } catch (e: Exception) {
                gHasLyrics = false
                gLyricSource = ""
                updateStatus("歌词加载失败: ${e.message}")
            }
        case None => gHasLyrics = false
    }
}

/// 将 lrc4cj 的 Lyrics 转换为 UI 层的 LyricLineInfo
/// 文档 2.3.9 节：过滤 start < 0 的行（plain 模式等不绘制）
func convertLyrics(lyrics: Lyrics): Unit {
    gLyricLines = ArrayList<LyricLineInfo>()
    for (line in lyrics.lines) {
        if (line.start >= 0) {
            gLyricLines.add(LyricLineInfo(line.start, line.text))
        }
    }
    gCurrentLyricIndex = -1
}

// ============================================================
// 歌词定位（文档 2.2 节核心同步机制）
// ============================================================

/// 根据播放位置（毫秒）定位当前歌词行
/// 返回是否发生了行变化（需要更新 UI）
public func updateLyricIndex(positionMs: Int64): Bool {
    if (!gHasLyrics || gLyricLines.size == 0) {
        return false
    }
    // 应用偏移校准
    let adjustedPos = positionMs + gLyricOffsetMs
    let newIdx = findLyricIndex(adjustedPos)
    if (newIdx != gCurrentLyricIndex) {
        gCurrentLyricIndex = newIdx
        return true
    }
    false
}

/// 二分查找当前歌词行索引（最后一个 start <= timeMs）
/// 对应 lrc4cj 的 indexAt，但这里直接操作 UI 层数据
func findLyricIndex(timeMs: Int64): Int32 {
    if (gLyricLines.size == 0) {
        return -1
    }
    // 线性查找（歌词行数通常 < 100，二分收益不大）
    var result: Int32 = -1
    for (i in 0..gLyricLines.size) {
        if (gLyricLines[i].startMs <= timeMs) {
            result = Int32(i)
        } else {
            break
        }
    }
    result
}

// ============================================================

// 歌词区交互
// ============================================================

/// 双击歌词行跳转（点击 Y 坐标 → 行索引 → seek）
public func seekToLyricRow(clickY: Int32, widgetHeight: Int32): Unit {
    if (!gHasLyrics || gLyricLines.size == 0) {
        return
    }
    let centerY = widgetHeight / 2
    let rowIdx = calcRowIndex(clickY, centerY, gScrollCurrentY, LYRIC_LINE_HEIGHT, gCurrentLyricIndex)
    if (rowIdx < 0 || Int64(rowIdx) >= Int64(gLyricLines.size)) {
        return
    }
    let targetMs = gLyricLines[Int64(rowIdx)].startMs - gLyricOffsetMs
    if (targetMs < 0) {
        return
    }
    // seek 到该行
    if (let Some(p) <- gPlayer) {
        p.setPosition(targetMs)
    }
}

// ============================================================
// 滚动动画触发
// ============================================================

/// 滚动动画 elapsed 时间（ms，由 timer tick 累加）
var gScrollElapsed: Int64 = 0
/// timer interval（ms）
let SCROLL_TIMER_INTERVAL: Int32 = 16

/// 当歌词行变化时，启动滚动动画到新位置
public func onLyricLineChanged(): Unit {
    // 计算新目标 Y（让当前行居中，即 scrollOffset = 0）
    // 但在动画过程中，需要从当前视觉位置插值到新位置
    gScrollStartY = gScrollCurrentY
    gScrollTargetY = 0.0 // 目标是让当前行居中，scrollOffset 归零
    gScrollElapsed = 0
    // 启动滚动定时器
    if (let Some(timer) <- gScrollTimer) {
        timer.start()
    }
    // 立即触发一次重绘
    triggerLyricRepaint()
}

/// 滚动动画 tick（由 timer 每次触发调用）
/// 返回 true 表示动画仍在进行，false 表示动画结束
public func scrollTick(): Bool {
    gScrollElapsed += Int64(SCROLL_TIMER_INTERVAL)
    if (gScrollElapsed >= SCROLL_DURATION) {
        // 动画结束
        gScrollCurrentY = gScrollTargetY
        return false
    }
    // 插值计算当前位置
    gScrollCurrentY = interpolateScroll(gScrollStartY, gScrollTargetY, gScrollElapsed, SCROLL_DURATION)
    return true
}
