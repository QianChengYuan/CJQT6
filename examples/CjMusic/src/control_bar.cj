
// ============================================================
// 右下控制区（三段式：左:歌名歌手 / 中:进度条+按钮 / 右:模式+音量）
// 设计文档 4.2/4.3 节
// ============================================================
package CjMusic

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

/// 创建右下控制区面板（三段式布局）
public func createControlBar(): QWidget {
    let panel = QWidget()
    panel.setStyleSheet(QSS_CONTROL_AREA)

    // 三段式水平布局：左(弹性) + 中(固定600px) + 右(弹性)
    let mainLayout = QHBoxLayout()
    mainLayout.setSpacing(0)
    mainLayout.setMargin(24)

    // ===== 左区：歌名 + 歌手（弹性，最小宽度 200px）=====
    let leftWidget = QWidget()
    leftWidget.setStyleSheet("QWidget { background: transparent; }")
    let leftLayout = QVBoxLayout()
    leftLayout.setSpacing(2)
    leftLayout.setMargin(0)

    let titleLabel = QLabel()
    titleLabel.setText("未播放")
    titleLabel.setStyleSheet("QLabel { font-size: 14px; font-weight: bold; color: #ffffff; background: transparent; }")
    gTitleLabel = Some(titleLabel)
    leftLayout.addWidget(titleLabel.getPtr())

    let artistLabel = QLabel()
    artistLabel.setStyleSheet("QLabel { font-size: 12px; color: #9097a3; background: transparent; }")
    gArtistLabel = Some(artistLabel)
    leftLayout.addWidget(artistLabel.getPtr())

    leftWidget.setLayout(leftLayout.getPtr())
    unsafe { qWidgetSetMinimumSize(leftWidget.getPtr(), 200, 60) }
    mainLayout.addWidget(leftWidget.getPtr(), 1)

    // ===== 中区：进度条 + 按钮组（固定宽度 600px，绝对居中）=====
    let centerWidget = QWidget()
    centerWidget.setStyleSheet("QWidget { background: transparent; }")
    let centerLayout = QVBoxLayout()
    centerLayout.setSpacing(6)
    centerLayout.setMargin(0)

    // 上层：进度条行（左时间戳 + 进度条 + 右时间戳）
    let progressLayout = QHBoxLayout()
    progressLayout.setSpacing(8)

    let curTimeLabel = QLabel()
    curTimeLabel.setText("0:00")
    curTimeLabel.setStyleSheet(
        "QLabel { font-size: 12px; color: #9097a3; background: transparent; font-family: 'Consolas', 'Courier New', monospace; min-width: 36px; }")
    // 单设水平位标志会冲掉默认的垂直居中，须与 VCenter 组合才能与进度条同线
    curTimeLabel.setAlignment(Alignment.Right.value + Alignment.VCenter.value)
    gTimeLabel = Some(curTimeLabel)
    progressLayout.addWidget(curTimeLabel.getPtr())

    let progressSlider = QSlider()
    progressSlider.setOrientation(1)
    progressSlider.setRange(0, 100)
    progressSlider.setValue(0)
    progressSlider.setEnabled(false)
    progressSlider.setOnSliderMoved(onProgressSliderMoved)
    progressSlider.setOnSliderPressed(onProgressSliderPressed)
    progressSlider.setOnSliderReleased(onProgressSliderReleased)
    gProgressSlider = Some(progressSlider)
    progressLayout.addWidget(progressSlider.getPtr(), 1)

    let totalTimeLabel = QLabel()
    totalTimeLabel.setText("0:00")
    totalTimeLabel.setStyleSheet(
        "QLabel { font-size: 12px; color: #9097a3; background: transparent; font-family: 'Consolas', 'Courier New', monospace; min-width: 36px; }")
    totalTimeLabel.setAlignment(Alignment.Left.value + Alignment.VCenter.value)
    gTotalTimeLabel = Some(totalTimeLabel)
    progressLayout.addWidget(totalTimeLabel.getPtr())

    centerLayout.addLayout(progressLayout.getPtr())

    // 下层：按钮组（居中）
    let btnLayout = QHBoxLayout()
    btnLayout.setSpacing(12)
    btnLayout.addStretch()

    let prevBtn = QPushButton()
    prevBtn.setIcon(gIconDir + "/prev.svg")
    prevBtn.setIconSize(20, 20)
    prevBtn.setStyleSheet(QSS_BTN_TRANSPORT)
    unsafe { qWidgetSetFixedSize(prevBtn.getPtr(), 32, 32) }
    prevBtn.setOnClickCapture({=> prevTrack()})
    prevBtn.setEnabled(false)
    gPrevButton = Some(prevBtn)
    btnLayout.addWidget(prevBtn.getPtr())

    let playBtn = QPushButton()
    playBtn.setIcon(gIconDir + "/play.svg")
    playBtn.setIconSize(28, 28)
    playBtn.setStyleSheet(QSS_BTN_PLAY)
    unsafe { qWidgetSetFixedSize(playBtn.getPtr(), 44, 44) }
    playBtn.setOnClickCapture({=> togglePlay()})
    playBtn.setEnabled(false)
    gPlayButton = Some(playBtn)
    btnLayout.addWidget(playBtn.getPtr())

    let nextBtn = QPushButton()
    nextBtn.setIcon(gIconDir + "/next.svg")
    nextBtn.setIconSize(20, 20)
    nextBtn.setStyleSheet(QSS_BTN_TRANSPORT)
    unsafe { qWidgetSetFixedSize(nextBtn.getPtr(), 32, 32) }
    nextBtn.setOnClickCapture({=> nextTrack()})
    nextBtn.setEnabled(false)
    gNextButton = Some(nextBtn)
    btnLayout.addWidget(nextBtn.getPtr())

    btnLayout.addStretch()

    centerLayout.addLayout(btnLayout.getPtr())

    centerWidget.setLayout(centerLayout.getPtr())
    unsafe { qWidgetSetFixedSize(centerWidget.getPtr(), 600, 80) }
    mainLayout.addWidget(centerWidget.getPtr())

    // ===== 右区：播放模式 + 音量（弹性，右对齐）=====
    let rightWidget = QWidget()
    rightWidget.setStyleSheet("QWidget { background: transparent; }")
    let rightLayout = QHBoxLayout()
    rightLayout.setSpacing(12)
    rightLayout.setMargin(0)
    rightLayout.addStretch()

    let modeBtn = QPushButton()
    modeBtn.setIcon(gIconDir + "/loop.svg")
    modeBtn.setIconSize(18, 18)
    modeBtn.setStyleSheet(QSS_BTN_ICON)
    unsafe { qWidgetSetFixedSize(modeBtn.getPtr(), 30, 30) }
    unsafe {
        var tipCstr = LibC.mallocCString("播放模式: 列表循环")
        qWidgetSetToolTip(modeBtn.getPtr(), tipCstr)
        LibC.free(tipCstr)
    }
    modeBtn.setOnClickCapture({=> cyclePlayMode()})
    gModeButton = Some(modeBtn)
    rightLayout.addWidget(modeBtn.getPtr())

    let muteBtn = QPushButton()
    muteBtn.setIcon(gIconDir + "/volume.svg")
    muteBtn.setIconSize(18, 18)
    muteBtn.setStyleSheet(QSS_BTN_ICON)
    unsafe { qWidgetSetFixedSize(muteBtn.getPtr(), 30, 30) }
    muteBtn.setOnClickCapture(
        {
            =>
                gIsMuted = !gIsMuted
                if (let Some(out) <- gAudioOutput) {
                    out.setMuted(gIsMuted)
                }
                if (let Some(btn) <- gMuteButton) {
                    if (gIsMuted) {
                        btn.setIcon(gIconDir + "/mute.svg")
                    } else {
                        btn.setIcon(gIconDir + "/volume.svg")
                    }
                }
        }
    )
    gMuteButton = Some(muteBtn)
    rightLayout.addWidget(muteBtn.getPtr())

    let volumeSlider = QSlider()
    volumeSlider.setOrientation(1)
    volumeSlider.setRange(0, 100)
    volumeSlider.setValue(70)

    unsafe { qWidgetSetFixedSize(volumeSlider.getPtr(), 120, 20) }
    volumeSlider.setOnValueChanged(onVolumeChanged)
    gVolumeSlider = Some(volumeSlider)
    rightLayout.addWidget(volumeSlider.getPtr())

    // 音量百分比标签（初始值与滑块初值一致；setValue 在连接回调前执行，初始不触发回调）
    let volumeLabel = QLabel()
    volumeLabel.setText("70")
    volumeLabel.setStyleSheet(
        "QLabel { font-size: 12px; color: #9097a3; background: transparent; font-family: 'Consolas', 'Courier New', monospace; min-width: 32px; padding-left: 4px; }")
    volumeLabel.setAlignment(Alignment.Left.value + Alignment.VCenter.value)
    gVolumeLabel = Some(volumeLabel)
    rightLayout.addWidget(volumeLabel.getPtr())

    rightWidget.setLayout(rightLayout.getPtr())
    unsafe { qWidgetSetMinimumSize(rightWidget.getPtr(), 150, 60) }
    mainLayout.addWidget(rightWidget.getPtr(), 1)

    panel.setLayout(mainLayout.getPtr())
    unsafe { qWidgetSetMinimumSize(panel.getPtr(), 0, 80) }
    panel
}

// ============================================================
// 回调函数
// ============================================================

@C
func onVolumeChanged(value: Int32): Unit {
    gCurrentVolume = Float32(value) / 100.0f32
    if (let Some(lbl) <- gVolumeLabel) {
        lbl.setText("${value}")
    }
    if (!gIsMuted) {
        if (let Some(out) <- gAudioOutput) {
            out.setVolume(gCurrentVolume)
        }
    }
}

@C
func onProgressSliderPressed(_dummy: Int64): Unit {
    // 按下滑块：标记用户正在拖动，阻止定时器覆盖 slider 值
    gIsSeeking = true
}

@C
func onProgressSliderMoved(value: Int32): Unit {
    gIsSeeking = true
    if (let Some(p) <- gPlayer) {
        let dur = p.duration()
        if (dur > 0) {
            let pos = Int64(value) * dur / 100
            if (let Some(lbl) <- gTimeLabel) {
                lbl.setText(formatTime(pos))
            }
            if (let Some(lbl) <- gTotalTimeLabel) {
                lbl.setText(formatTime(dur))
            }
        }
    }
}

@C
func onProgressSliderReleased(_dummy: Int64): Unit {
    if (let Some(slider) <- gProgressSlider) {
        if (let Some(p) <- gPlayer) {
            let dur = p.duration()
            if (dur > 0) {
                let pos = Int64(slider.value()) * dur / 100
                p.setPosition(pos)
            }
        }
    }
    gIsSeeking = false
}
