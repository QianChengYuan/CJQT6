package music_player

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.menu.*
import cjqt6.dialogs.*
import cjqt6.gui.QVBoxLayout
import cjqt6.gui.QHBoxLayout
import cjqt6.gui.Alignment
import cjqt6.multimedia.*
import cjqt6.views.*
import std.fs.*
import std.env.*
import std.collection.*
import std.random.*
import std.convert.*

// ============================================================
// CJQT6 音乐播放器 - 完整功能演示
// ============================================================

// 播放模式
enum PlayMode {
    | Sequential  // 顺序播放
    | Loop        // 循环播放
    | LoopOne     // 单曲循环
    | Random      // 随机播放
}

// 音乐项
class MusicItem {
    public var filePath: String
    public var fileName: String
    public var title: String
    public var artist: String
    public var duration: Int64
    
    public init(path: String) {
        filePath = path
        let p = Path(path)
        fileName = p.fileName
        title = fileName
        artist = "未知艺术家"
        duration = 0
    }
    
    public func updateInfo(player: QMediaPlayer) {
        title = player.title()
        if (title.isEmpty()) {
            title = fileName
        }
        artist = player.artist()
        if (artist.isEmpty()) {
            artist = "未知艺术家"
        }
        duration = player.duration()
    }
}

// 歌词行
class LyricLine {
    public var timeMs: Int64
    public var text: String
    
    public init(timeMs: Int64, text: String) {
        this.timeMs = timeMs
        this.text = text
    }
}

// 全局状态
var mainWindow: ?QWidget = None
var player: ?QMediaPlayer = None
var audioOutput: ?QAudioOutput = None
var playList: ArrayList<MusicItem> = ArrayList<MusicItem>()
var currentIndex: Int32 = -1
var playMode: PlayMode = PlayMode.Sequential
var isPlaying: Bool = false
var isMuted: Bool = false
var currentVolume: Float32 = 0.7f32
var currentSpeed: Float32 = 1.0f32
var isUpdatingSlider: Bool = false  // 防止 slider 更新循环
let randomGen: Random = Random()

// 歌词状态
var lyricLines: ArrayList<LyricLine> = ArrayList<LyricLine>()
var currentLyricIndex: Int32 = -1

// 自定义图标路径
var iconFolder: String = ""
var useCustomIcons: Bool = false

// UI组件
var titleLabel: ?QLabel = None
var artistLabel: ?QLabel = None
var timeLabel: ?QLabel = None
var progressSlider: ?QSlider = None
var volumeSlider: ?QSlider = None
var playButton: ?QPushButton = None
var prevButton: ?QPushButton = None
var stopButton: ?QPushButton = None
var nextButton: ?QPushButton = None
var muteButton: ?QPushButton = None
var playModeButton: ?QPushButton = None
var speedButton: ?QPushButton = None
var speedLabel: ?QLabel = None
var volumeLabel: ?QLabel = None
var addButton: ?QPushButton = None
var folderButton: ?QPushButton = None
var removeButton: ?QPushButton = None
var clearButton: ?QPushButton = None
var lyricLabel: ?QLabel = None
var playlistWidget: ?QListWidget = None
var statusLabel: ?QLabel = None

// ============================================================
// 图标辅助函数
// ============================================================

// 现代深色主题样式常量
let QSS_WINDOW: String = "QWidget { background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #24262d, stop:1 #191b21); color: #e6e8ec; font-family: 'Microsoft YaHei UI', 'Microsoft YaHei', 'SimSun', sans-serif; font-size: 13px; } QLabel { background: transparent; color: #e6e8ec; } QPushButton { background: #2c2f38; border: 1px solid #3a3e49; border-radius: 8px; padding: 6px 14px; color: #d5d8e0; } QPushButton:hover { background: #3a3f4c; border-color: #4d9fff; } QPushButton:pressed { background: #22242b; } QPushButton:disabled { color: #5a5d66; background: #262931; } QMenuBar { background: transparent; } QMenuBar::item { background: transparent; padding: 5px 10px; border-radius: 6px; } QMenuBar::item:selected { background: #2f323d; } QMenu { background: #2c2f38; border: 1px solid #3a3e49; border-radius: 8px; padding: 4px; } QMenu::item { padding: 6px 24px; border-radius: 6px; color: #d5d8e0; } QMenu::item:selected { background: #4d9fff; color: #ffffff; } QMenu::separator { height: 1px; background: #3a3e49; margin: 4px 8px; } QSlider::groove:horizontal { height: 5px; background: #3a3e49; border-radius: 2px; } QSlider::sub-page:horizontal { background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #4d9fff, stop:1 #6fadff); border-radius: 2px; } QSlider::handle:horizontal { width: 14px; height: 14px; margin: -5px 0; background: #f2f3f5; border: 2px solid #4d9fff; border-radius: 7px; } QSlider::handle:horizontal:hover { background: #ffffff; } QListWidget { background: #232530; border: 1px solid #2f323d; border-radius: 10px; padding: 4px; outline: none; } QListWidget::item { padding: 7px 10px; border-radius: 6px; color: #c9cdd6; } QListWidget::item:hover { background: #2f323d; } QListWidget::item:selected { background: #3d7bfd; color: #ffffff; }"

// 圆形控制按钮（上一曲/停止/下一曲）
let QSS_BTN_TRANSPORT: String = "QPushButton { background: #2c2f38; border: none; border-radius: 20px; } QPushButton:hover { background: #3a3f4c; } QPushButton:pressed { background: #22242b; }"

// 播放主按钮（强调色圆形）
let QSS_BTN_PLAY: String = "QPushButton { background: qlineargradient(x1:0, y1:0, x2:1, y2:1, stop:0 #5b9dff, stop:1 #3d7bfd); border: none; border-radius: 28px; } QPushButton:hover { background: #6fadff; } QPushButton:pressed { background: #3d7bfd; }"

// 透明小图标按钮（静音/速度）
let QSS_BTN_ICON: String = "QPushButton { background: transparent; border: none; border-radius: 13px; } QPushButton:hover { background: #2f323d; } QPushButton:pressed { background: #232530; }"

func setButtonIcon(btn: QPushButton, iconName: String, stdIcon: Int32) {
    if (useCustomIcons && !iconFolder.isEmpty()) {
        // 尝试加载自定义图标
        let iconPath = "${iconFolder}/${iconName}.png"
        try {
            if (exists(Path(iconPath))) {
                btn.setIcon(iconPath)
                return
            }
        } catch (e: Exception) {
            // 忽略错误，使用标准图标
        }
    }
    // 使用标准图标
    btn.setStandardIcon(stdIcon)
}

// 设置纯图标按钮（无文本）：自定义图标优先，不可用时回退到标准图标或文本
func setIconOnlyButton(btn: QPushButton, iconName: String, stdIcon: Int32, fallbackText: String) {
    if (useCustomIcons && !iconFolder.isEmpty()) {
        let iconPath = "${iconFolder}/${iconName}.png"
        try {
            if (exists(Path(iconPath))) {
                btn.setIcon(iconPath)
                btn.setText("")
                return
            }
        } catch (e: Exception) {
            // 忽略错误，使用回退图标
        }
    }
    btn.setStandardIcon(stdIcon)
    if (stdIcon == StandardIcon.No) {
        btn.setText(fallbackText)
    } else {
        btn.setText("")
    }
}

// 自动探测自定义图标目录：优先当前目录下的 icons，其次是源码目录（相对 bin 运行时的 ../../../icons）
func detectIconFolder(): String {
    var candidates = ["icons", "../../../icons"]
    for (c in candidates) {
        try {
            if (exists(Path(c))) {
                return c
            }
        } catch (e: Exception) {
        }
    }
    return ""
}

func loadCustomIcons() {
    // 设置各按钮图标
    if (let Some(btn) <- prevButton) {
        setIconOnlyButton(btn, "prev", StandardIcon.MediaSkipBackward, "")
    }
    if (let Some(btn) <- playButton) {
        setIconOnlyButton(btn, if (isPlaying) { "pause" } else { "play" }, 
            if (isPlaying) { StandardIcon.MediaPause } else { StandardIcon.MediaPlay }, "")
    }
    if (let Some(btn) <- stopButton) {
        setIconOnlyButton(btn, "stop", StandardIcon.MediaStop, "")
    }
    if (let Some(btn) <- nextButton) {
        setIconOnlyButton(btn, "next", StandardIcon.MediaSkipForward, "")
    }
    if (let Some(btn) <- muteButton) {
        setIconOnlyButton(btn, if (isMuted) { "mute" } else { "volume" }, StandardIcon.No,
            if (isMuted) { "取消" } else { "静音" })
    }
    if (let Some(btn) <- speedButton) {
        setIconOnlyButton(btn, "speed", StandardIcon.No, "x1")
    }
    if (let Some(btn) <- addButton) {
        setButtonIcon(btn, "add", StandardIcon.No)
    }
    if (let Some(btn) <- folderButton) {
        setButtonIcon(btn, "folder", StandardIcon.No)
    }
    if (let Some(btn) <- removeButton) {
        setButtonIcon(btn, "remove", StandardIcon.No)
    }
    if (let Some(btn) <- clearButton) {
        setButtonIcon(btn, "clear", StandardIcon.No)
    }
}

func setIconFolder(path: String) {
    iconFolder = path
    useCustomIcons = !path.isEmpty()
    loadCustomIcons()
    updateStatus(if (useCustomIcons) { "已加载自定义图标: ${path}" } else { "使用标准图标" })
}

func chooseIconFolder() {
    let parentPtr = if (let Some(w) <- mainWindow) { w.getPtr() } else { 0 }
    let folder = QFileDialog.getExistingDirectory(parentPtr, "选择图标文件夹")
    if (!folder.isEmpty()) {
        setIconFolder(folder)
    }
}

// ============================================================
// 辅助函数
// ============================================================

func formatTime(ms: Int64): String {
    let totalSeconds = ms / 1000
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    if (seconds < 10) {
        return "${minutes}:0${seconds}"
    } else {
        return "${minutes}:${seconds}"
    }
}

// ============================================================
// 歌词（LRC）解析与显示
// ============================================================

// HTML 转义，防止歌词中的特殊字符破坏富文本
func escapeHtml(text: String): String {
    var result = text
    result = result.replace("&", "&amp;")
    result = result.replace("<", "&lt;")
    result = result.replace(">", "&gt;")
    return result
}

// 解析 LRC 时间标签 [mm:ss.xx]，返回毫秒数；解析失败返回 -1
func parseLrcTime(tag: String): Int64 {
    var s = tag
    // 去掉前后括号
    if (s.startsWith("[")) {
        s = s[1..s.size]
    }
    if (s.endsWith("]")) {
        s = s[0..s.size - 1]
    }
    if (let Some(colon) <- s.indexOf(":")) {
        if (colon <= 0) {
            return -1
        }
        let mmStr = s[0..colon]
        let rest = s[colon + 1..s.size]
        let minutes = Int64.parse(mmStr)
        if (minutes < 0) {
            return -1
        }
        let secPart = Float64.parse(rest)  // 支持 ss 或 ss.xx
        if (secPart < 0.0) {
            return -1
        }
        return minutes * 60000 + Int64(secPart * 1000.0)
    }
    return -1
}

// 尝试加载与当前音频同名的 .lrc 歌词文件
func loadLyrics(filePath: String) {
    lyricLines = ArrayList<LyricLine>()
    currentLyricIndex = -1
    
    // 将扩展名替换为 .lrc
    var lrcPath = filePath
    if (let Some(lastDot) <- filePath.lastIndexOf(".")) {
        if (lastDot > 0) {
            lrcPath = filePath[0..lastDot] + ".lrc"
        } else {
            lrcPath = filePath + ".lrc"
        }
    } else {
        lrcPath = filePath + ".lrc"
    }
    
    try {
        if (!exists(Path(lrcPath))) {
            resetLyrics()
            return
        }
        let bytes = File.readFrom(lrcPath)
        let content = String.fromUtf8(bytes)
        let lines = content.split("\n")
        
        // 第一遍：解析所有形如 [mm:ss.xx] 的时间标签行
        var temp: ArrayList<LyricLine> = ArrayList<LyricLine>()
        for (line in lines) {
            var rest = line
            var tags: ArrayList<String> = ArrayList<String>()
            // 收集行首的多个时间标签，如 [01:23][02:34]歌词
            while (rest.startsWith("[")) {
                if (let Some(closeIdx) <- rest.indexOf("]")) {
                    if (closeIdx <= 0) {
                        break
                    }
                    let tag = rest[0..closeIdx + 1]
                    tags.add(tag)
                    rest = rest[closeIdx + 1..rest.size]
                } else {
                    break
                }
            }
            let text = rest.trimAscii()
            for (tag in tags) {
                let timeMs = parseLrcTime(tag)
                if (timeMs >= 0 && !text.isEmpty()) {
                    temp.add(LyricLine(timeMs, text))
                }
            }
        }
        
        // 按时间排序（插入排序，保持稳定）
        for (i in 1..temp.size) {
            let key = temp[i]
            var j = i
            while (j > 0 && temp[j - 1].timeMs > key.timeMs) {
                temp[j] = temp[j - 1]
                j--
            }
            temp[j] = key
        }
        
        if (temp.size > 0) {
            lyricLines = temp
            renderLyrics()
            updateStatus("已加载歌词 (${lyricLines.size} 行)")
        } else {
            resetLyrics()
            updateStatus("未找到可用歌词")
        }
    } catch (e: Exception) {
        resetLyrics()
    }
}

// 重置歌词显示为占位符
func resetLyrics() {
    lyricLines = ArrayList<LyricLine>()
    currentLyricIndex = -1
    if (let Some(lbl) <- lyricLabel) {
        lbl.setText("<font color='#7a7e8a'>&lt;暂无歌词&gt;</font>")
    }
}

// 根据播放位置更新歌词高亮
func updateLyrics(pos: Int64) {
    if (lyricLines.size == 0) {
        return
    }
    
    // 找到最后一行 timeMs <= pos 的歌词
    var idx: Int32 = -1
    for (i in 0..lyricLines.size) {
        if (lyricLines[i].timeMs <= pos) {
            idx = Int32(i)
        } else {
            break
        }
    }
    
    if (idx != currentLyricIndex) {
        currentLyricIndex = idx
        renderLyrics()
    }
}

// 渲染当前歌词（高亮当前行，显示上下文）
func renderLyrics() {
    if (let Some(lbl) <- lyricLabel) {
        if (lyricLines.size == 0) {
            lbl.setText("<font color='#7a7e8a'>&lt;暂无歌词&gt;</font>")
            return
        }
        var sb = ""
        let idx = if (currentLyricIndex < 0) { Int32(0) } else { currentLyricIndex }
        
        // 前一行
        if (idx > 0) {
            sb += "<font color='#7a7e8a'>${escapeHtml(lyricLines[Int64(idx) - 1].text)}</font><br/>"
        }
        // 当前行
        sb += "<font color='#ffffff' size='4'><b>${escapeHtml(lyricLines[Int64(idx)].text)}</b></font>"
        // 后一行
        if (idx < Int32(lyricLines.size) - 1) {
            sb += "<br/><font color='#7a7e8a'>${escapeHtml(lyricLines[Int64(idx) + 1].text)}</font>"
        }
        lbl.setText(sb)
    }
}

func updateUI() {
    if (let Some(lbl) <- titleLabel) {
        if (let Some(item) <- getCurrentItem()) {
            lbl.setText("<font size='5' color='#ffffff'><b>${item.title}</b></font>")
        } else {
            lbl.setText("<font size='5' color='#ffffff'><b>欢迎使用音乐播放器</b></font>")
        }
    }
    
    if (let Some(lbl) <- artistLabel) {
        if (let Some(item) <- getCurrentItem()) {
            lbl.setText("<font color='#8b8e98'>${item.artist}</font>")
        } else {
            lbl.setText("<font color='#8b8e98'>双击列表开始播放</font>")
        }
    }
    
    // 播放按钮图标切换（优先自定义图标，回退标准图标）
    if (let Some(btn) <- playButton) {
        setIconOnlyButton(btn, if (isPlaying) { "pause" } else { "play" },
            if (isPlaying) { StandardIcon.MediaPause } else { StandardIcon.MediaPlay }, "")
    }
    
    if (let Some(lbl) <- speedLabel) {
        lbl.setText("${currentSpeed}x")
    }
    
    updatePlayModeButton()
}

func updatePlayModeButton() {
    if (let Some(btn) <- playModeButton) {
        match (playMode) {
            case PlayMode.Sequential => btn.setText("顺序")
            case PlayMode.Loop => btn.setText("循环")
            case PlayMode.LoopOne => btn.setText("单曲")
            case PlayMode.Random => btn.setText("随机")
        }
    }
}

func getCurrentItem(): ?MusicItem {
    if (currentIndex >= 0 && currentIndex < Int32(playList.size)) {
        return Some(playList[Int64(currentIndex)])
    }
    return None
}

func updateStatus(msg: String) {
    if (let Some(lbl) <- statusLabel) {
        lbl.setText(msg)
    }
}

// ============================================================
// 文件操作
// ============================================================

func addFiles() {
    let parentPtr = if (let Some(w) <- mainWindow) { w.getPtr() } else { 0 }
    let files = QFileDialog.getOpenFileNames(
        parentPtr,
        "添加音乐文件",
        "音频文件 (*.mp3 *.wav *.flac *.ogg *.m4a *.aac *.wma);;所有文件 (*)"
    )
    
    if (!files.isEmpty()) {
        var added: Int32 = 0
        var startIndex = playList.size
        for (file in files.split('\n')) {
            if (!file.isEmpty()) {
                let item = MusicItem(file)
                playList.add(item)
                added++
            }
        }
        
        // 添加到列表控件
        match (playlistWidget) {
            case Some(list) =>
                for (i in startIndex..playList.size) {
                    list.addItem(playList[i].fileName)
                }
            case None => ()
        }
        
        updateStatus("已添加 ${added} 首音乐")
        
        // 如果是第一次添加，自动选择第一首
        if (currentIndex < 0 && playList.size > 0) {
            currentIndex = 0
            match (playlistWidget) {
                case Some(list) => list.setCurrentRow(0)
                case None => ()
            }
        }
    }
}

func addFolder() {
    let parentPtr = if (let Some(w) <- mainWindow) { w.getPtr() } else { 0 }
    let folder = QFileDialog.getExistingDirectory(
        parentPtr,
        "选择音乐文件夹"
    )
    
    if (!folder.isEmpty()) {
        var added: Int32 = 0
        var startIndex = playList.size
        try {
            let entries = Directory.readFrom(Path(folder))
            for (entry in entries) {
                let name = entry.name
                // 检查是否是音频文件
                if (name.endsWith(".mp3") || name.endsWith(".wav") || 
                    name.endsWith(".flac") || name.endsWith(".ogg") ||
                    name.endsWith(".m4a") || name.endsWith(".aac") ||
                    name.endsWith(".wma")) {
                    let item = MusicItem(entry.path.toString())
                    playList.add(item)
                    added++
                }
            }
            
            // 添加到列表控件
            match (playlistWidget) {
                case Some(list) =>
                    for (i in startIndex..playList.size) {
                        list.addItem(playList[i].fileName)
                    }
                case None => ()
            }
            
            updateStatus("已添加 ${added} 首音乐")
            
            if (currentIndex < 0 && playList.size > 0) {
                currentIndex = 0
                match (playlistWidget) {
                    case Some(list) => list.setCurrentRow(0)
                    case None => ()
                }
            }
        } catch (e: Exception) {
            updateStatus("无法读取文件夹")
        }
    }
}

func clearPlaylist() {
    stop()
    playList = ArrayList<MusicItem>()
    currentIndex = -1
    match (playlistWidget) {
        case Some(list) => list.clear()
        case None => ()
    }
    updateUI()
    updateStatus("播放列表已清空")
}

// ============================================================
// 播放控制
// ============================================================

func play() {
    if (let Some(p) <- player) {
        if (let Some(item) <- getCurrentItem()) {
            if (p.playbackState() != PlaybackState.playing()) {
                // 如果是新文件或已停止，加载文件
                if (p.playbackState() == PlaybackState.stopped()) {
                    p.setSourceFile(item.filePath)
                    loadLyrics(item.filePath)
                }
                p.play()
                isPlaying = true
                updateUI()
                updateStatus("正在播放: ${item.fileName}")
            }
        } else {
            updateStatus("请先添加音乐文件")
        }
    }
}

func pause() {
    if (let Some(p) <- player) {
        p.pause()
        isPlaying = false
        updateUI()
        updateStatus("已暂停")
    }
}

func stop() {
    if (let Some(p) <- player) {
        p.stop()
        isPlaying = false
        if (let Some(slider) <- progressSlider) {
            slider.setValue(0)
        }
        if (let Some(lbl) <- timeLabel) {
            lbl.setText("0:00 / 0:00")
        }
        resetLyrics()
        updateUI()
        updateStatus("已停止")
    }
}

func togglePlay() {
    if (isPlaying) {
        pause()
    } else {
        play()
    }
}

func prev() {
    if (playList.size == 0) {
        return
    }
    
    match (playMode) {
        case PlayMode.Random =>
            // 随机选择
            currentIndex = Int32(randomGen.nextFloat64() * Float64(playList.size))
        case _ =>
            currentIndex--
            if (currentIndex < 0) {
                currentIndex = Int32(playList.size) - 1
            }
    }
    
    match (playlistWidget) {
        case Some(list) => list.setCurrentRow(currentIndex)
        case None => ()
    }
    loadAndPlay()
}

func next() {
    if (playList.size == 0) {
        return
    }
    
    match (playMode) {
        case PlayMode.Random =>
            currentIndex = Int32(randomGen.nextFloat64() * Float64(playList.size))
        case _ =>
            currentIndex++
            if (currentIndex >= Int32(playList.size)) {
                currentIndex = 0
            }
    }
    
    match (playlistWidget) {
        case Some(list) => list.setCurrentRow(currentIndex)
        case None => ()
    }
    loadAndPlay()
}

func loadAndPlay() {
    if (let Some(p) <- player) {
        p.stop()
        if (let Some(item) <- getCurrentItem()) {
            p.setSourceFile(item.filePath)
            loadLyrics(item.filePath)
            p.play()
            isPlaying = true
            updateUI()
            updateStatus("正在播放: ${item.fileName}")
        }
    }
}

func toggleMute() {
    if (let Some(out) <- audioOutput) {
        isMuted = !isMuted
        out.setMuted(isMuted)
        if (let Some(btn) <- muteButton) {
            setIconOnlyButton(btn, if (isMuted) { "mute" } else { "volume" }, StandardIcon.No,
                if (isMuted) { "取消" } else { "静音" })
        }
        updateStatus(if (isMuted) { "已静音" } else { "已取消静音" })
    }
}

func setVolume(value: Int32) {
    currentVolume = Float32(value) / 100.0f32
    if (let Some(audio) <- audioOutput) {
        audio.setVolume(currentVolume)
    }
    if (let Some(lbl) <- volumeLabel) {
        lbl.setText("${value}%")
    }
}

func setPosition(value: Int32) {
    // 如果正在从回调更新 slider，忽略此次调用
    if (isUpdatingSlider) {
        return
    }
    if (let Some(p) <- player) {
        let duration = p.duration()
        if (duration > 0) {
            let newPos = Int64(value) * duration / 100
            p.setPosition(newPos)
        }
    }
}

func changePlayMode() {
    match (playMode) {
        case PlayMode.Sequential => playMode = PlayMode.Loop
        case PlayMode.Loop => playMode = PlayMode.LoopOne
        case PlayMode.LoopOne => playMode = PlayMode.Random
        case PlayMode.Random => playMode = PlayMode.Sequential
    }
    updatePlayModeButton()
    
    var modeName = ""
    match (playMode) {
        case PlayMode.Sequential => modeName = "顺序播放"
        case PlayMode.Loop => modeName = "列表循环"
        case PlayMode.LoopOne => modeName = "单曲循环"
        case PlayMode.Random => modeName = "随机播放"
    }
    updateStatus("播放模式: ${modeName}")
}

func changeSpeed() {
    // 循环切换速度: 0.5x -> 0.75x -> 1.0x -> 1.25x -> 1.5x -> 2.0x -> 0.5x
    if (currentSpeed == 0.5f32) {
        currentSpeed = 0.75f32
    } else if (currentSpeed == 0.75f32) {
        currentSpeed = 1.0f32
    } else if (currentSpeed == 1.0f32) {
        currentSpeed = 1.25f32
    } else if (currentSpeed == 1.25f32) {
        currentSpeed = 1.5f32
    } else if (currentSpeed == 1.5f32) {
        currentSpeed = 2.0f32
    } else {
        currentSpeed = 0.5f32
    }
    
    if (let Some(p) <- player) {
        p.setPlaybackRate(currentSpeed)
    }
    updateUI()
}

// ============================================================
// 播放结束处理
// ============================================================

func onPlaybackFinished() {
    isPlaying = false
    
    match (playMode) {
        case PlayMode.Sequential =>
            // 顺序播放，播放下一首
            if (currentIndex < Int32(playList.size) - 1) {
                next()
            } else {
                // 播放完毕，复位界面
                if (let Some(slider) <- progressSlider) {
                    slider.setValue(0)
                }
                if (let Some(lbl) <- timeLabel) {
                    lbl.setText("0:00 / 0:00")
                }
                resetLyrics()
                updateUI()
                updateStatus("播放完毕")
            }
        case PlayMode.Loop =>
            next()
        case PlayMode.LoopOne =>
            // 单曲循环
            loadAndPlay()
        case PlayMode.Random =>
            next()
    }
}

// ============================================================
// 播放列表操作
// ============================================================

func onPlaylistDoubleClicked(row: Int32) {
    if (row >= 0 && row < Int32(playList.size)) {
        currentIndex = row
        loadAndPlay()
    }
}

func removeSelected() {
    match (playlistWidget) {
        case Some(list) =>
            let row = list.currentRow()
            if (row >= 0 && row < Int32(playList.size)) {
                playList.remove(at: Int64(row))
                list.removeItem(row)
                
                if (currentIndex == row) {
                    stop()
                    if (playList.size > 0) {
                        if (currentIndex >= Int32(playList.size)) {
                            currentIndex = Int32(playList.size) - 1
                        }
                        list.setCurrentRow(currentIndex)
                    } else {
                        currentIndex = -1
                    }
                    updateUI()
                } else if (currentIndex > row) {
                    currentIndex--
                }
                
                updateStatus("已移除")
            }
        case None => ()
    }
}

// ============================================================
// 关于
// ============================================================

func about() {
    let parentPtr = if (let Some(w) <- mainWindow) { w.getPtr() } else { 0 }
    QMessageBox.information(
        parentPtr,
        "关于音乐播放器",
        "CJQT6 音乐播放器示例\n\n版本: 1.0.0\n\n功能:\n• 支持多种音频格式\n• 播放列表管理\n• 播放模式切换\n• 播放速度调节\n• 音量控制\n\n使用仓颉语言和Qt6开发"
    )
}

// ============================================================
// 回调函数
// ============================================================

// CFunc 回调函数（必须是顶级函数，不能捕获外部变量，需要 @C 修饰）
@C
func cbPositionChanged(pos: Int64): Unit {
    // 忽略位置为 0 的回调（可能是加载中）
    if (pos <= 0) {
        return
    }
    if (let Some(p) <- player) {
        let dur = p.duration()
        if (dur > 0) {
            // 设置标志，防止 slider 的 valueChanged 回调触发 setPosition
            isUpdatingSlider = true
            if (let Some(slider) <- progressSlider) {
                slider.setValue(Int32(pos * 100 / dur))
            }
            isUpdatingSlider = false
            if (let Some(lbl) <- timeLabel) {
                lbl.setText("${formatTime(pos)} / ${formatTime(dur)}")
            }
        }
        updateLyrics(pos)
    }
}

@C
func cbDurationChanged(dur: Int64): Unit {
    if (dur > 0) {
        if (let Some(lbl) <- timeLabel) {
            if (let Some(p) <- player) {
                lbl.setText("${formatTime(p.position())} / ${formatTime(dur)}")
            }
        }
    }
}

@C
func cbMediaStatusChanged(status: Int32): Unit {
    // status: 0=NoMedia, 1=Loading, 2=Loaded, 3=Buffering, 4=Stalled, 5=Buffered, 6=EndOfMedia, 7=InvalidMedia
    // 媒体加载完成时读取元数据（标题/艺术家/时长）并刷新界面
    if (status == MediaStatus.loaded() || status == MediaStatus.buffered()) {
        if (let Some(p) <- player) {
            if (let Some(item) <- getCurrentItem()) {
                item.updateInfo(p)
                // 刷新播放列表行文本：文件名 + 时长
                if (let Some(list) <- playlistWidget) {
                    var rowText = item.fileName
                    if (item.duration > 0) {
                        rowText += "  [${formatTime(item.duration)}]"
                    }
                    list.setItemText(currentIndex, rowText)
                }
                updateUI()
                updateStatus("已加载: ${item.title} - ${item.artist}")
            }
        }
    }
}

@C
func cbPlaybackStateChanged(state: Int32): Unit {
    // state: 0=Stopped, 1=Playing, 2=Paused
    // 只有在播放中状态变为 Stopped 且 isPlaying 为 true 时才认为是播放结束
    if (state == 0 && isPlaying) {
        if (let Some(p) <- player) {
            let pos = p.position()
            let dur = p.duration()
            // 只有当位置接近结尾时才认为是真正结束
            if (dur > 0 && pos >= dur - 1000) {
                isPlaying = false
                onPlaybackFinished()
            }
        }
    }
}

let onTogglePlay: VoidCallback = { => togglePlay() }
let onStop: VoidCallback = { => stop() }
let onPrev: VoidCallback = { => prev() }
let onNext: VoidCallback = { => next() }
let onToggleMute: VoidCallback = { => toggleMute() }
let onChangePlayMode: VoidCallback = { => changePlayMode() }
let onChangeSpeed: VoidCallback = { => changeSpeed() }
let onAddFiles: VoidCallback = { => addFiles() }
let onAddFolder: VoidCallback = { => addFolder() }
let onClearPlaylist: VoidCallback = { => clearPlaylist() }
let onRemoveSelected: VoidCallback = { => removeSelected() }
let onExit: VoidCallback = { => 
    if (let Some(p) <- player) {
        p.stop()
        p.delete()
        player = None
    }
    if (let Some(out) <- audioOutput) {
        out.delete()
        audioOutput = None
    }
    QApp.quit()
}
let onAbout: VoidCallback = { => about() }
let onChooseIconFolder: VoidCallback = { => chooseIconFolder() }
let onResetIcons: VoidCallback = { => setIconFolder("") }

// ============================================================
// 主函数
// ============================================================
main(): Int32 {
    // 设置音频相关环境变量
    setVariable("QT_MEDIA_BACKEND", "windows")
    setVariable("QT_QUICK_BACKEND", "software")
    
    let app = QApplication()
    app.loadQtTranslation("zh_CN")
    
    // 创建媒体播放器和音频输出
    let mediaPlayer = QMediaPlayer()
    let audio = QAudioOutput()
    audio.setVolume(currentVolume)  // 先设置音量
    mediaPlayer.setAudioOutput(audio)  // 再设置输出
    
    // 注册信号回调（替代定时器轮询）
    mediaPlayer.onPositionChanged(cbPositionChanged)
    mediaPlayer.onDurationChanged(cbDurationChanged)
    mediaPlayer.onMediaStatusChanged(cbMediaStatusChanged)
    mediaPlayer.onPlaybackStateChanged(cbPlaybackStateChanged)
    
    player = mediaPlayer
    audioOutput = audio
    
    // 创建主窗口
    let window = QWidget()
    window.setTitle("音乐播放器 - CJQT6")
    window.resize(460, 640)
    window.setMinimumSize(420, 560)
    mainWindow = window
    
    // 现代深色主题样式
    window.setStyleSheet(QSS_WINDOW)
    
    // 主布局
    let mainLayout = QVBoxLayout()
    mainLayout.setSpacing(10)
    mainLayout.setMargin(14)
    
    // ========== 菜单栏（顶部） ==========
    let menuBar = QMenuBar()
    
    let fileMenu = menuBar.addMenu("文件")
    let addFilesAction = fileMenu.addAction("添加文件")
    addFilesAction.setShortcut("Ctrl+O")
    addFilesAction.setOnTriggered(onAddFiles)
    let addFolderAction = fileMenu.addAction("添加目录")
    addFolderAction.setOnTriggered(onAddFolder)
    fileMenu.addSeparator()
    let exitAction = fileMenu.addAction("退出")
    exitAction.setOnTriggered(onExit)
    
    let playMenu = menuBar.addMenu("播放")
    let playAction = playMenu.addAction("播放/暂停")
    playAction.setShortcut("Space")
    playAction.setOnTriggered(onTogglePlay)
    let stopAction = playMenu.addAction("停止")
    stopAction.setOnTriggered(onStop)
    playMenu.addSeparator()
    let prevAction = playMenu.addAction("上一曲")
    prevAction.setShortcut("Left")
    prevAction.setOnTriggered(onPrev)
    let nextAction = playMenu.addAction("下一曲")
    nextAction.setShortcut("Right")
    nextAction.setOnTriggered(onNext)
    playMenu.addSeparator()
    let modeAction = playMenu.addAction("播放模式")
    modeAction.setOnTriggered(onChangePlayMode)
    
    // 设置菜单
    let settingsMenu = menuBar.addMenu("设置")
    let iconFolderAction = settingsMenu.addAction("图标文件夹...")
    iconFolderAction.setOnTriggered(onChooseIconFolder)
    let resetIconsAction = settingsMenu.addAction("重置为标准图标")
    resetIconsAction.setOnTriggered(onResetIcons)
    
    let helpMenu = menuBar.addMenu("帮助")
    let aboutAction = helpMenu.addAction("关于")
    aboutAction.setOnTriggered(onAbout)
    
    mainLayout.addWidget(menuBar.getPtr())
    
    // ========== 头部：封面 + 曲目信息 ==========
    let headerWidget = QWidget()
    headerWidget.setStyleSheet("background: transparent;")
    let headerLayout = QHBoxLayout()
    headerLayout.setSpacing(14)
    headerLayout.setMargin(2)
    
    // 封面占位（圆形渐变）
    let cover = QLabel()
    cover.setMinimumSize(92, 92)
    cover.setMaximumSize(92, 92)
    cover.setAlignment(Alignment.Center.value)
    cover.setText("<span style='font-size:38px; color:#4d9fff;'>&#9835;</span>")
    cover.setStyleSheet("QLabel { background: qlineargradient(x1:0, y1:0, x2:1, y2:1, stop:0 #34384a, stop:1 #232530); border: 1px solid #3a3e49; border-radius: 46px; }")
    headerLayout.addWidget(cover.getPtr())
    
    // 右侧：标题 + 艺术家
    let infoLayout = QVBoxLayout()
    infoLayout.setSpacing(6)
    
    let title = QLabel()
    title.setText("<font size='5' color='#ffffff'><b>欢迎使用音乐播放器</b></font>")
    title.setAlignment((Alignment.Left | Alignment.VCenter).value)
    title.setWordWrap(true)
    titleLabel = title
    infoLayout.addWidget(title.getPtr())
    
    let artist = QLabel()
    artist.setText("<font color='#8b8e98'>双击列表开始播放</font>")
    artist.setAlignment((Alignment.Left | Alignment.VCenter).value)
    artistLabel = artist
    infoLayout.addWidget(artist.getPtr())
    
    headerLayout.addLayout(infoLayout.getPtr())
    headerWidget.setLayout(headerLayout.getPtr())
    mainLayout.addWidget(headerWidget.getPtr())
    
    // ========== 歌词显示区域 ==========
    let lyricWidget = QWidget()
    lyricWidget.setMinimumSize(0, 110)
    lyricWidget.setStyleSheet("QWidget { background: #232530; border: 1px solid #2f323d; border-radius: 10px; } QLabel { background: transparent; }")
    let lyricLayout = QVBoxLayout()
    lyricLayout.setMargin(10)
    let lyricLbl = QLabel()
    lyricLbl.setText("<font color='#7a7e8a'>&lt;歌词显示区域&gt;</font>")
    lyricLbl.setAlignment(Alignment.Center.value)
    lyricLbl.setWordWrap(true)
    lyricLayout.addWidget(lyricLbl.getPtr())
    lyricWidget.setLayout(lyricLayout.getPtr())
    mainLayout.addWidget(lyricWidget.getPtr())
    lyricLabel = lyricLbl
    
    // ========== 进度条区域 ==========
    let slider = QSlider()
    slider.setOrientation(0x01)
    slider.setRange(0, 100)
    slider.setValue(0)
    slider.setOnValueChanged({ pos => setPosition(pos) })
    progressSlider = slider
    mainLayout.addWidget(slider.getPtr())
    
    let time = QLabel()
    time.setText("00:00 / 00:00")
    time.setAlignment(Alignment.Right.value)
    time.setStyleSheet("color: #8b8e98; font-size: 12px;")
    timeLabel = time
    mainLayout.addWidget(time.getPtr())
    
    // ========== 播放控制（上一曲/播放/停止/下一曲） ==========
    let controlWidget = QWidget()
    controlWidget.setStyleSheet("background: transparent;")
    let controlLayout = QHBoxLayout()
    controlLayout.setSpacing(20)
    controlLayout.addStretch()
    
    // 上一曲
    let prevBtn = QPushButton()
    prevBtn.setMinimumSize(40, 40)
    prevBtn.setMaximumSize(40, 40)
    prevBtn.setIconSize(20, 20)
    prevBtn.setStyleSheet(QSS_BTN_TRANSPORT)
    prevBtn.setStandardIcon(StandardIcon.MediaSkipBackward)
    prevBtn.setOnClick(onPrev)
    prevButton = prevBtn
    controlLayout.addWidget(prevBtn.getPtr())
    
    // 播放/暂停 - 主按钮（强调色圆形）
    let playBtn = QPushButton()
    playBtn.setMinimumSize(56, 56)
    playBtn.setMaximumSize(56, 56)
    playBtn.setIconSize(30, 30)
    playBtn.setStyleSheet(QSS_BTN_PLAY)
    playBtn.setStandardIcon(StandardIcon.MediaPlay)
    playBtn.setOnClick(onTogglePlay)
    playButton = playBtn
    controlLayout.addWidget(playBtn.getPtr())
    
    // 停止
    let stopBtn = QPushButton()
    stopBtn.setMinimumSize(40, 40)
    stopBtn.setMaximumSize(40, 40)
    stopBtn.setIconSize(20, 20)
    stopBtn.setStyleSheet(QSS_BTN_TRANSPORT)
    stopBtn.setStandardIcon(StandardIcon.MediaStop)
    stopBtn.setOnClick(onStop)
    stopButton = stopBtn
    controlLayout.addWidget(stopBtn.getPtr())
    
    // 下一曲
    let nextBtn = QPushButton()
    nextBtn.setMinimumSize(40, 40)
    nextBtn.setMaximumSize(40, 40)
    nextBtn.setIconSize(20, 20)
    nextBtn.setStyleSheet(QSS_BTN_TRANSPORT)
    nextBtn.setStandardIcon(StandardIcon.MediaSkipForward)
    nextBtn.setOnClick(onNext)
    nextButton = nextBtn
    controlLayout.addWidget(nextBtn.getPtr())
    
    controlLayout.addStretch()
    controlWidget.setLayout(controlLayout.getPtr())
    mainLayout.addWidget(controlWidget.getPtr())
    
    // ========== 辅助控制（播放模式 / 速度 / 音量） ==========
    let utilWidget = QWidget()
    utilWidget.setStyleSheet("background: transparent;")
    let utilLayout = QHBoxLayout()
    utilLayout.setSpacing(8)
    
    // 播放模式
    let modeBtn = QPushButton()
    modeBtn.setText("顺序")
    modeBtn.setMinimumSize(52, 30)
    modeBtn.setOnClick(onChangePlayMode)
    playModeButton = modeBtn
    utilLayout.addWidget(modeBtn.getPtr())
    
    // 速度
    let speedBtn = QPushButton()
    speedBtn.setMinimumSize(30, 30)
    speedBtn.setMaximumSize(30, 30)
    speedBtn.setIconSize(18, 18)
    speedBtn.setStyleSheet(QSS_BTN_ICON)
    speedBtn.setText("x1")
    speedBtn.setOnClick(onChangeSpeed)
    speedButton = speedBtn
    utilLayout.addWidget(speedBtn.getPtr())
    
    let speed = QLabel()
    speed.setText("1.0x")
    speed.setStyleSheet("color: #8b8e98; font-size: 12px; min-width: 34px;")
    speedLabel = speed
    utilLayout.addWidget(speed.getPtr())
    
    utilLayout.addStretch()
    
    // 静音
    let muteBtn = QPushButton()
    muteBtn.setMinimumSize(40, 26)
    muteBtn.setIconSize(16, 16)
    muteBtn.setStyleSheet(QSS_BTN_ICON)
    muteBtn.setText("静音")
    muteBtn.setOnClick(onToggleMute)
    muteButton = muteBtn
    utilLayout.addWidget(muteBtn.getPtr())
    
    // 音量滑块
    let volSlider = QSlider()
    volSlider.setOrientation(0x01)
    volSlider.setRange(0, 100)
    volSlider.setValue(70)
    volSlider.setMinimumSize(90, 20)
    volSlider.setMaximumSize(120, 20)
    volSlider.setOnValueChanged({ value => setVolume(value) })
    volumeSlider = volSlider
    utilLayout.addWidget(volSlider.getPtr())
    
    let volPct = QLabel()
    volPct.setText("70%")
    volPct.setStyleSheet("color: #8b8e98; font-size: 12px; min-width: 32px;")
    volumeLabel = volPct
    utilLayout.addWidget(volPct.getPtr())
    
    utilWidget.setLayout(utilLayout.getPtr())
    mainLayout.addWidget(utilWidget.getPtr())
    
    // ========== 播放列表 ==========
    let listWidget = QListWidget()
    listWidget.setMinimumSize(0, 150)
    listWidget.setOnItemDoubleClicked({ row => onPlaylistDoubleClicked(row) })
    playlistWidget = listWidget
    mainLayout.addWidget(listWidget.getPtr(), 1)
    
    // ========== 列表操作按钮 ==========
    let listBtnWidget = QWidget()
    listBtnWidget.setStyleSheet("background: transparent;")
    let listBtnLayout = QHBoxLayout()
    listBtnLayout.setSpacing(8)
    
    let addFilesBtn = QPushButton()
    addFilesBtn.setIconSize(16, 16)
    addFilesBtn.setText("添加")
    addFilesBtn.setOnClick(onAddFiles)
    addButton = addFilesBtn
    listBtnLayout.addWidget(addFilesBtn.getPtr())
    
    let addFolderBtn = QPushButton()
    addFolderBtn.setIconSize(16, 16)
    addFolderBtn.setText("目录")
    addFolderBtn.setOnClick(onAddFolder)
    folderButton = addFolderBtn
    listBtnLayout.addWidget(addFolderBtn.getPtr())
    
    let removeBtn = QPushButton()
    removeBtn.setIconSize(16, 16)
    removeBtn.setText("移除")
    removeBtn.setOnClick(onRemoveSelected)
    removeButton = removeBtn
    listBtnLayout.addWidget(removeBtn.getPtr())
    
    let clearBtn = QPushButton()
    clearBtn.setIconSize(16, 16)
    clearBtn.setText("清空")
    clearBtn.setOnClick(onClearPlaylist)
    clearButton = clearBtn
    listBtnLayout.addWidget(clearBtn.getPtr())
    
    listBtnLayout.addStretch()
    listBtnWidget.setLayout(listBtnLayout.getPtr())
    mainLayout.addWidget(listBtnWidget.getPtr())
    
    // ========== 状态栏 ==========
    let status = QLabel()
    status.setText("就绪 - 点击「添加」添加音乐文件")
    status.setStyleSheet("color: #7a7e8a; font-size: 12px;")
    statusLabel = status
    mainLayout.addWidget(status.getPtr())
    
    // 自动加载自定义图标（icons 目录存在时）
    let detectedIcons = detectIconFolder()
    if (!detectedIcons.isEmpty()) {
        setIconFolder(detectedIcons)
    }
    
    window.setLayout(mainLayout.getPtr())
    window.show()
    
    let result = app.exec()
    
    // 清理
    mediaPlayer.delete()
    audio.delete()
    
    return result
}

