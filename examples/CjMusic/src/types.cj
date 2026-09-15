// ============================================================
// CjMusic 公共类型与全局状态
// ============================================================
package CjMusic

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.multimedia.*
import cjqt6.views.*
import cjqt6.menu.*
import std.collection.*
import std.fs.*
import std.random.*

// QEventWidget/QPushButton/QSlider 未暴露部分 QWidget 方法，声明 FFI 直接调用
foreign func qWidgetSetStyleSheet(ptr: Int64, styleSheet: CString): Unit
foreign func qWidgetSetMinimumSize(ptr: Int64, minw: Int32, minh: Int32): Unit
foreign func qWidgetSetFixedSize(ptr: Int64, width: Int32, height: Int32): Unit
foreign func qWidgetSetToolTip(ptr: Int64, toolTip: CString): Unit
foreign func qWidgetWidth(ptr: Int64): Int32
foreign func qWidgetHeight(ptr: Int64): Int32

// ============================================================
// 播放模式
// ============================================================
public enum PlayMode {
    | Sequential  // 顺序播放（播完停止）
    | Loop        // 列表循环
    | LoopOne     // 单曲循环
    | Random      // 随机播放

    // 切换到下一个模式
    public func next(): PlayMode {
        match (this) {
            case Sequential => Loop
            case Loop => LoopOne
            case LoopOne => Random
            case Random => Sequential
        }
    }

    // 模式显示名
    public func displayName(): String {
        match (this) {
            case Sequential => "顺序"
            case Loop => "循环"
            case LoopOne => "单曲"
            case Random => "随机"
        }
    }

}

// ============================================================
// 音乐项
// ============================================================
public class MusicItem {
    public var filePath: String
    public var fileName: String
    public var title: String
    public var artist: String
    public var duration: Int64
    public var invalid: Bool   // 文件损坏/丢失标记

    public init(path: String) {
        filePath = path
        let p = Path(path)
        fileName = p.fileName
        title = ""
        artist = ""
        duration = 0
        invalid = false
        // 添加时即从文件名解析 "歌手 - 歌名"，列表立即显示干净的歌名；
        // 播放后 updateInfo 有元数据则元数据优先
        parseFromFileName()
        if (title.isEmpty()) {
            title = fileName
        }
        if (artist.isEmpty()) {
            artist = "未知艺术家"
        }
    }

    public func updateInfo(player: QMediaPlayer): Unit {
        title = player.title()
        artist = player.artist()
        duration = player.duration()
        // 元数据 title 只是回退的文件名时视为缺失，走文件名解析
        if (let Some(dot) <- fileName.lastIndexOf(".")) {
            if (dot > 0 && title == fileName[0..dot]) {
                title = ""
            }
        }
        if (title.isEmpty() || artist.isEmpty()) {
            parseFromFileName()
        }
        if (title.isEmpty()) {
            title = fileName
        }
        if (artist.isEmpty()) {
            artist = "未知艺术家"
        }
    }

    // 从文件名解析 "歌手 - 歌名"（如 "周杰伦 - 晴天.mp3" → 歌手:周杰伦 歌名:晴天）
    func parseFromFileName(): Unit {
        var base = fileName
        if (let Some(dot) <- base.lastIndexOf(".")) {
            if (dot > 0) {
                base = base[0..dot]
            }
        }
        if (let Some(dash) <- base.indexOf(" - ")) {
            if (dash > 0 && dash + 3 < base.size) {
                if (artist.isEmpty()) {
                    artist = base[0..dash].trimAscii()
                }
                if (title.isEmpty()) {
                    title = base[dash + 3..base.size].trimAscii()
                }
            }
        }
    }

    // 列表显示文本
    public func displayText(): String {
        if (invalid) {
            "⚠ ${title}"
        } else {
            title
        }
    }
}

// ============================================================
// 全局状态（用顶层 var 持有强引用，防 GC 回收）
// ============================================================

// 播放器核心对象（必须全局持有，防 GC 回收导致播放中断）
var gPlayer: ?QMediaPlayer = None
var gAudioOutput: ?QAudioOutput = None

// 播放列表数据
var gPlaylist: ArrayList<MusicItem> = ArrayList<MusicItem>()
var gCurrentIndex: Int32 = -1
var gPlayMode: PlayMode = PlayMode.Loop
var gIsPlaying: Bool = false
var gIsMuted: Bool = false
var gCurrentVolume: Float32 = 0.7f32
var gIsUpdatingSlider: Bool = false   // 防 slider valueChanged 循环
var gIsSeeking: Bool = false          // 用户正在拖动进度条（不更新歌词 + 不被定时器覆盖）
let gRandomGen: Random = Random()

// 歌词状态
var gLyricLines: ArrayList<LyricLineInfo> = ArrayList<LyricLineInfo>()
var gCurrentLyricIndex: Int32 = -1
var gLyricOffsetMs: Int64 = 0         // 手动偏移校准（毫秒）
var gHasLyrics: Bool = false
var gLyricSource: String = ""         // 匹配到的 .lrc 文件名（显示匹配来源）

// 歌词滚动动画状态
var gScrollTargetY: Float64 = 0.0     // 目标 Y 偏移
var gScrollCurrentY: Float64 = 0.0    // 当前 Y 偏移（插值中）
var gScrollStartY: Float64 = 0.0      // 动画起点

let SCROLL_DURATION: Int64 = 400      // 动画时长（ms，降级方案：QTimer 无 PreciseTimer，用 400ms 掩盖抖动）

// UI 组件引用
var gMainWindow: ?QMainWindow = None
var gCentralWidget: ?QWidget = None
var gSplitter: ?QSplitter = None

// 左栏：播放列表
var gPlaylistWidget: ?QListWidget = None
var gSearchEdit: ?QLineEdit = None
var gSearchKeyword: String = ""                        // 当前搜索词（由 textChanged 回调更新）
var gVisibleRows: ArrayList<Int32> = ArrayList<Int32>()  // 搜索过滤后的原始索引

// 右上：歌词区
var gLyricWidget: ?QEventWidget = None
var gScrollTimer: ?QTimer = None

// 右下：控制区
var gTitleLabel: ?QLabel = None
var gArtistLabel: ?QLabel = None
var gFileNameLabel: ?QLabel = None
var gTimeLabel: ?QLabel = None       // 当前时间（左时间戳）
var gTotalTimeLabel: ?QLabel = None  // 总时间（右时间戳）
var gProgressSlider: ?QSlider = None
var gVolumeSlider: ?QSlider = None
var gVolumeLabel: ?QLabel = None      // 音量百分比标签
var gPlayButton: ?QPushButton = None
var gPrevButton: ?QPushButton = None
var gNextButton: ?QPushButton = None
var gModeButton: ?QPushButton = None
var gMuteButton: ?QPushButton = None
var gOpenFileButton: ?QPushButton = None
var gOpenFolderButton: ?QPushButton = None
var gStatusBar: ?QLabel = None

// 图标目录路径（运行时由 main() 设置）
var gIconDir: String = ""

// ============================================================
// 歌词行信息（UI 层使用，从 lrc4cj 的 LyricLine 转换）
// ============================================================
public class LyricLineInfo {
    public var startMs: Int64
    public var text: String

    public init(startMs: Int64, text: String) {
        this.startMs = startMs
        this.text = text
    }
}

// ============================================================
// 辅助函数
// ============================================================

// 毫秒转 mm:ss 格式
public func formatTime(ms: Int64): String {
    if (ms < 0) {
        return "0:00"
    }
    let totalSeconds = ms / 1000
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    if (seconds < 10) {
        return "${minutes}:0${seconds}"
    } else {
        return "${minutes}:${seconds}"
    }
}

// 获取当前播放项
public func getCurrentItem(): ?MusicItem {
    if (gCurrentIndex < 0 || Int64(gCurrentIndex) >= Int64(gPlaylist.size)) {
        return None
    }
    return gPlaylist[Int64(gCurrentIndex)]
}

// ============================================================
// QSS 深色主题样式
// ============================================================
let QSS_WINDOW: String = "QWidget { background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #24262d, stop:1 #191b21); color: #e6e8ec; font-family: 'Microsoft YaHei UI', 'Microsoft YaHei', 'SimSun', sans-serif; font-size: 13px; } QLabel { background: transparent; color: #e6e8ec; } QPushButton { background: #2c2f38; border: 1px solid #3a3e49; border-radius: 8px; padding: 6px 14px; color: #d5d8e0; } QPushButton:hover { background: #3a3f4c; border-color: #00D9B5; } QPushButton:pressed { background: #22242b; } QPushButton:disabled { color: #5a5d66; background: #262931; } QMenuBar { background: transparent; } QMenuBar::item { background: transparent; padding: 5px 10px; border-radius: 6px; } QMenuBar::item:selected { background: #2f323d; } QMenu { background: #2c2f38; border: 1px solid #3a3e49; border-radius: 8px; padding: 4px; } QMenu::item { padding: 6px 24px; border-radius: 6px; color: #d5d8e0; } QMenu::item:selected { background: #00D9B5; color: #191b21; } QMenu::separator { height: 1px; background: #3a3e49; margin: 4px 8px; } QSlider::groove:horizontal { height: 4px; background: #3a3e49; border-radius: 2px; } QSlider::sub-page:horizontal { background: #00D9B5; border-radius: 2px; } QSlider::add-page:horizontal { background: #3a3e49; border-radius: 2px; } QSlider::handle:horizontal { width: 12px; height: 12px; margin: -5px 0; background: #f2f3f5; border: 2px solid #00D9B5; border-radius: 6px; } QSlider::handle:horizontal:hover { background: #ffffff; } QListWidget { background: #232530; border: 1px solid #2f323d; border-radius: 10px; padding: 4px; outline: none; } QListWidget::item { padding: 7px 10px; border-radius: 6px; color: #c9cdd6; } QListWidget::item:hover { background: #2f323d; } QListWidget::item:selected { background: #00D9B5; color: #191b21; } QLineEdit { background: #232530; border: 1px solid #2f323d; border-radius: 8px; padding: 6px 10px; color: #e6e8ec; } QLineEdit:focus { border-color: #00D9B5; } QSplitter::handle { background: #2f323d; } QSplitter::handle:hover { background: #00D9B5; } QScrollBar:vertical { background: #232530; width: 8px; margin: 0; border: none; } QScrollBar::handle:vertical { background: #3a3e49; border-radius: 4px; min-height: 30px; } QScrollBar::handle:vertical:hover { background: #00D9B5; } QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical { height: 0; width: 0; } QScrollBar::add-page:vertical, QScrollBar::sub-page:vertical { background: transparent; }"

// 圆形控制按钮
let QSS_BTN_TRANSPORT: String = "QPushButton { background: #2c2f38; border: none; border-radius: 20px; color: #d5d8e0; font-size: 16px; } QPushButton:hover { background: #3a3f4c; color: #00D9B5; } QPushButton:pressed { background: #22242b; }"

// 播放主按钮（强调色圆形）
let QSS_BTN_PLAY: String = "QPushButton { background: qlineargradient(x1:0, y1:0, x2:1, y2:1, stop:0 #00D9B5, stop:1 #00BFA5); border: none; border-radius: 28px; color: #191b21; font-size: 20px; } QPushButton:hover { background: #33E0C0; } QPushButton:pressed { background: #00D9B5; }"

// 透明小图标按钮
let QSS_BTN_ICON: String = "QPushButton { background: transparent; border: none; border-radius: 13px; color: #d5d8e0; font-size: 14px; } QPushButton:hover { background: #2f323d; color: #00D9B5; } QPushButton:pressed { background: #232530; }"

// 歌词区样式
let QSS_LYRIC_AREA: String = "QWidget { background: #1a1c22; }"

// 控制区样式（深蓝黑底，无边框）
let QSS_CONTROL_AREA: String = "QWidget { background: #0B1220; }"

// 支持的音频格式过滤器
let AUDIO_FILTER: String = "音频文件 (*.mp3 *.flac *.wav *.m4a *.ogg *.aac);;所有文件 (*)"

// 支持的扩展名集合
let AUDIO_EXTENSIONS: Array<String> = ["mp3", "flac", "wav", "m4a", "ogg", "aac"]