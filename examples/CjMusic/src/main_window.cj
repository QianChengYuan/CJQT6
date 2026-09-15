// ============================================================
// 主窗口（QSplitter 左右分栏）
// 设计文档 4.2 节
// ============================================================
package CjMusic

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.menu.*

/// 创建主窗口
public func createMainWindow(): QMainWindow {
    let window = QMainWindow()
    window.setTitle("CjMusic - 仓颉音乐播放器")
    // 控制区内部最小需求 200+600+150+48≈998px，默认宽 1000 时右栏(667)放不下会溢出裁切，
    // 表现为左右比失衡；默认加宽到 1366 保证右栏足够容纳控制区
    window.resize(1366, 800)
    unsafe {
        var styleCstr = LibC.mallocCString(QSS_WINDOW)
        qWidgetSetStyleSheet(window.getPtr(), styleCstr)
        LibC.free(styleCstr)
    }

    // 创建左右分栏
    let splitter = QSplitter.createHorizontal(0)
    gSplitter = Some(splitter)

    // 左栏：播放列表面板
    let playlistPanel = createPlaylistPanel()
    unsafe { qWidgetSetMinimumSize(playlistPanel.getPtr(), 280, 0) }
    splitter.addWidget(playlistPanel.getPtr())

    // 右栏：垂直布局（歌词区 + 控制区）
    let rightWidget = QWidget()
    let rightLayout = QVBoxLayout()
    rightLayout.setMargin(0)
    rightLayout.setSpacing(0)

    // 1. 歌词区
    let lyricWidget = createLyricWidget()
    gLyricWidget = Some(lyricWidget)
    rightLayout.addWidget(lyricWidget.getPtr(), 1)

    // 2. 控制区（含歌名歌手 + 进度条 + 按钮 + 音量）
    let controlBar = createControlBar()
    rightLayout.addWidget(controlBar.getPtr())

    rightWidget.setLayout(rightLayout.getPtr())
    splitter.addWidget(rightWidget.getPtr())

    // 设置左右比例（左 1/3，右 2/3）
    splitter.setSizes([333, 667])
    splitter.setStretchFactor(0, 1)
    splitter.setStretchFactor(1, 2)
    splitter.setChildrenCollapsible(false)

    // 设置中央控件
    window.setCentralWidget(splitter.getPtr())
    gCentralWidget = Some(playlistPanel)

    gMainWindow = Some(window)
    window
}


