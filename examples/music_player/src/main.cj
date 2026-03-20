package music_player

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.menu.*
import CJQT6.dialogs.*
import CJQT6.gui.*
import CJQT6.multimedia.*
import CJQT6.views.*
import std.fs.*
import std.env.*
import std.collection.*
import std.random.*

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
var positionTimer: ?QTimer = None
var isUpdatingSlider: Bool = false  // 防止 slider 更新循环
let randomGen: Random = Random()

// UI组件
var titleLabel: ?QLabel = None
var artistLabel: ?QLabel = None
var timeLabel: ?QLabel = None
var progressSlider: ?QSlider = None
var volumeSlider: ?QSlider = None
var playButton: ?QPushButton = None
var playModeButton: ?QPushButton = None
var speedLabel: ?QLabel = None
var playlistWidget: ?QListWidget = None
var statusLabel: ?QLabel = None

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

func updateUI() {
    if (let Some(lbl) <- titleLabel) {
        if (let Some(item) <- getCurrentItem()) {
            lbl.setText("<h2>${item.title}</h2>")
        } else {
            lbl.setText("<h2>未选择音乐</h2>")
        }
    }
    
    if (let Some(lbl) <- artistLabel) {
        if (let Some(item) <- getCurrentItem()) {
            lbl.setText(item.artist)
        } else {
            lbl.setText("")
        }
    }
    
    if (let Some(btn) <- playButton) {
        if (isPlaying) {
            btn.setText("暂停")
        } else {
            btn.setText("播放")
        }
    }
    
    if (let Some(lbl) <- speedLabel) {
        lbl.setText("速度: ${currentSpeed}x")
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
        updateStatus(if (isMuted) { "已静音" } else { "已取消静音" })
    }
}

func setVolume(value: Int32) {
    currentVolume = Float32(value) / 100.0f32
    if (let Some(audio) <- audioOutput) {
        audio.setVolume(currentVolume)
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
// 位置定时器
// ============================================================

func startPositionTimer() {
    if (let Some(timer) <- positionTimer) {
        timer.setInterval(500)
        timer.start()
    }
}

func stopPositionTimer() {
    if (let Some(timer) <- positionTimer) {
        timer.stop()
    }
}

func updatePosition() {
    if (let Some(p) <- player) {
        let pos = p.position()
        let dur = p.duration()
        
        if (dur > 0) {
            // 更新进度条
            if (let Some(slider) <- progressSlider) {
                let percent = Int32(pos * 100 / dur)
                slider.setValue(percent)
            }
            
            // 更新时间显示
            if (let Some(lbl) <- timeLabel) {
                lbl.setText("${formatTime(pos)} / ${formatTime(dur)}")
            }
        }
    }
}

func onPlaybackFinished() {
    isPlaying = false
    
    match (playMode) {
        case PlayMode.Sequential =>
            // 顺序播放，播放下一首
            if (currentIndex < Int32(playList.size) - 1) {
                next()
            } else {
                // 播放完毕
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
    // 暂时禁用此回调，改用 playbackStateChanged
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
    if (let Some(t) <- positionTimer) {
        t.delete()
        positionTimer = None
    }
    QApp.quit()
}
let onAbout: VoidCallback = { => about() }

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
    window.setTitle("音乐播放器")
    window.resize(700, 550)
    mainWindow = window
    
    // 主布局
    let mainLayout = QVBoxLayout()
    mainLayout.setSpacing(10)
    mainLayout.setMargin(15)
    
    // ========== 信息显示区域 ==========
    let infoWidget = QWidget()
    let infoLayout = QVBoxLayout()
    
    let title = QLabel()
    title.setText("<h2>未选择音乐</h2>")
    title.setAlignment(0x04 | 0x01)  // AlignHCenter | AlignVCenter
    titleLabel = title
    infoLayout.addWidget(title.getPtr())
    
    let artist = QLabel()
    artist.setText("")
    artist.setAlignment(0x04)  // AlignHCenter
    artistLabel = artist
    infoLayout.addWidget(artist.getPtr())
    
    infoWidget.setLayout(infoLayout.getPtr())
    mainLayout.addWidget(infoWidget.getPtr())
    
    // ========== 进度条区域 ==========
    let progressWidget = QWidget()
    let progressLayout = QHBoxLayout()
    
    let time = QLabel()
    time.setText("0:00 / 0:00")
    timeLabel = time
    progressLayout.addWidget(time.getPtr())
    
    let slider = QSlider()
    slider.setOrientation(0x01)  // Horizontal
    slider.setRange(0, 100)
    slider.setValue(0)
    slider.setOnValueChanged({ pos => setPosition(pos) })
    progressSlider = slider
    progressLayout.addWidget(slider.getPtr())
    
    progressWidget.setLayout(progressLayout.getPtr())
    mainLayout.addWidget(progressWidget.getPtr())
    
    // ========== 控制按钮区域 ==========
    let controlWidget = QWidget()
    let controlLayout = QHBoxLayout()
    
    // 上一曲
    let prevBtn = QPushButton()
    prevBtn.setText("上一曲")
    prevBtn.setOnClick(onPrev)
    controlLayout.addWidget(prevBtn.getPtr())
    
    // 播放/暂停
    let playBtn = QPushButton()
    playBtn.setText("播放")
    playBtn.setOnClick(onTogglePlay)
    playButton = playBtn
    controlLayout.addWidget(playBtn.getPtr())
    
    // 停止
    let stopBtn = QPushButton()
    stopBtn.setText("停止")
    stopBtn.setOnClick(onStop)
    controlLayout.addWidget(stopBtn.getPtr())
    
    // 下一曲
    let nextBtn = QPushButton()
    nextBtn.setText("下一曲")
    nextBtn.setOnClick(onNext)
    controlLayout.addWidget(nextBtn.getPtr())
    
    // 播放模式
    let modeBtn = QPushButton()
    modeBtn.setText("顺序")
    modeBtn.setOnClick(onChangePlayMode)
    playModeButton = modeBtn
    controlLayout.addWidget(modeBtn.getPtr())
    
    // 速度
    let speedBtn = QPushButton()
    speedBtn.setText("速度")
    speedBtn.setOnClick(onChangeSpeed)
    controlLayout.addWidget(speedBtn.getPtr())
    
    let speed = QLabel()
    speed.setText("速度: 1.0x")
    speedLabel = speed
    controlLayout.addWidget(speed.getPtr())
    
    controlWidget.setLayout(controlLayout.getPtr())
    mainLayout.addWidget(controlWidget.getPtr())
    
    // ========== 音量控制区域 ==========
    let volumeWidget = QWidget()
    let volumeLayout = QHBoxLayout()
    
    let volumeIcon = QLabel()
    volumeIcon.setText("音量:")
    volumeLayout.addWidget(volumeIcon.getPtr())
    
    let volSlider = QSlider()
    volSlider.setOrientation(0x01)  // Horizontal
    volSlider.setRange(0, 100)
    volSlider.setValue(70)
    volSlider.setOnValueChanged({ value => setVolume(value) })
    volumeSlider = volSlider
    volumeLayout.addWidget(volSlider.getPtr())
    
    let muteBtn = QPushButton()
    muteBtn.setText("静音")
    muteBtn.setOnClick(onToggleMute)
    volumeLayout.addWidget(muteBtn.getPtr())
    
    volumeWidget.setLayout(volumeLayout.getPtr())
    mainLayout.addWidget(volumeWidget.getPtr())
    
    // ========== 播放列表 ==========
    let listLabel = QLabel()
    listLabel.setText("播放列表:")
    mainLayout.addWidget(listLabel.getPtr())
    
    let listWidget = QListWidget()
    listWidget.setOnItemDoubleClicked({ row => onPlaylistDoubleClicked(row) })
    playlistWidget = listWidget
    mainLayout.addWidget(listWidget.getPtr())
    
    // ========== 列表操作按钮 ==========
    let listBtnWidget = QWidget()
    let listBtnLayout = QHBoxLayout()
    
    let addFilesBtn = QPushButton()
    addFilesBtn.setText("添加文件")
    addFilesBtn.setOnClick(onAddFiles)
    listBtnLayout.addWidget(addFilesBtn.getPtr())
    
    let addFolderBtn = QPushButton()
    addFolderBtn.setText("添加文件夹")
    addFolderBtn.setOnClick(onAddFolder)
    listBtnLayout.addWidget(addFolderBtn.getPtr())
    
    let removeBtn = QPushButton()
    removeBtn.setText("移除选中")
    removeBtn.setOnClick(onRemoveSelected)
    listBtnLayout.addWidget(removeBtn.getPtr())
    
    let clearBtn = QPushButton()
    clearBtn.setText("清空列表")
    clearBtn.setOnClick(onClearPlaylist)
    listBtnLayout.addWidget(clearBtn.getPtr())
    
    listBtnWidget.setLayout(listBtnLayout.getPtr())
    mainLayout.addWidget(listBtnWidget.getPtr())
    
    // ========== 状态栏 ==========
    let status = QLabel()
    status.setText("就绪 - 点击\"添加文件\"添加音乐")
    statusLabel = status
    mainLayout.addWidget(status.getPtr())
    
    // ========== 菜单栏 ==========
    let menuBar = QMenuBar()
    
    // 文件菜单
    let fileMenu = menuBar.addMenu("文件(&F)")
    
    let addFilesAction = fileMenu.addAction("添加文件(&A)")
    addFilesAction.setShortcut("Ctrl+O")
    addFilesAction.setOnTriggered(onAddFiles)
    
    let addFolderAction = fileMenu.addAction("添加文件夹(&D)")
    addFolderAction.setShortcut("Ctrl+Shift+O")
    addFolderAction.setOnTriggered(onAddFolder)
    
    fileMenu.addSeparator()
    
    let exitAction = fileMenu.addAction("退出(&X)")
    exitAction.setShortcut("Alt+F4")
    exitAction.setOnTriggered(onExit)
    
    // 播放菜单
    let playMenu = menuBar.addMenu("播放(&P)")
    
    let playAction = playMenu.addAction("播放/暂停(&P)")
    playAction.setShortcut("Space")
    playAction.setOnTriggered(onTogglePlay)
    
    let stopAction = playMenu.addAction("停止(&S)")
    stopAction.setShortcut("Ctrl+S")
    stopAction.setOnTriggered(onStop)
    
    playMenu.addSeparator()
    
    let prevAction = playMenu.addAction("上一曲(&P)")
    prevAction.setShortcut("Ctrl+Left")
    prevAction.setOnTriggered(onPrev)
    
    let nextAction = playMenu.addAction("下一曲(&N)")
    nextAction.setShortcut("Ctrl+Right")
    nextAction.setOnTriggered(onNext)
    
    playMenu.addSeparator()
    
    let modeAction = playMenu.addAction("切换播放模式(&M)")
    modeAction.setShortcut("Ctrl+M")
    modeAction.setOnTriggered(onChangePlayMode)
    
    let speedAction = playMenu.addAction("切换播放速度(&R)")
    speedAction.setShortcut("Ctrl+R")
    speedAction.setOnTriggered(onChangeSpeed)
    
    // 帮助菜单
    let helpMenu = menuBar.addMenu("帮助(&H)")
    
    let aboutAction = helpMenu.addAction("关于(&A)")
    aboutAction.setOnTriggered(onAbout)
    
    mainLayout.addWidget(menuBar.getPtr())
    
    window.setLayout(mainLayout.getPtr())
    window.show()
    
    let result = app.exec()
    
    // 清理
    mediaPlayer.delete()
    audio.delete()
    
    return result
}

