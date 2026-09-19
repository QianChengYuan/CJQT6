// ============================================================
// 左侧播放列表 UI（搜索框 + QListWidget + 操作按钮）
// 设计文档 4.2/4.3 节
// ============================================================
package CjMusic

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.views.*
import cjqt6.dialogs.*
import std.collection.*

/// 创建左侧播放列表面板
/// 返回面板的 QWidget 和布局指针
public func createPlaylistPanel(): QWidget {
    let panel = QWidget()
    panel.setStyleSheet("QWidget { background: #232530; }")

    let layout = QVBoxLayout()
    layout.setSpacing(6)
    layout.setMargin(8)

    // 顶部行：标题 + 添加按钮
    let headerLayout = QHBoxLayout()
    headerLayout.setSpacing(4)

    let titleLabel = QLabel()
    titleLabel.setText("播放列表")
    titleLabel.setStyleSheet("QLabel { font-size: 15px; font-weight: bold; color: #e6e8ec; background: transparent; }")
    headerLayout.addWidget(titleLabel.getPtr())

    headerLayout.addStretch()

    let addBtn = QPushButton()
    addBtn.setText("添加")
    addBtn.setStyleSheet(QSS_BTN_ICON)
    addBtn.setOnClickCapture(
        {
            =>
                let parentPtr = if (let Some(w) <- gMainWindow) {
                    w.getPtr()
                } else {
                    0
                }
                let paths = QFileDialog.getOpenFileNames(parentPtr, "选择音频文件", AUDIO_FILTER)
                if (paths.isEmpty()) {
                    return
                }
                let pathList = paths.split("\n", removeEmpty: true)
                let added = playlistAddMany(pathList)
                if (added > 0) {
                    refreshPlaylistUI()
                    updateStatus("已添加 ${added} 首音乐")
                    if (gCurrentIndex < 0) {
                        playAt(0)
                    }
                }
        }
    )
    gOpenFileButton = Some(addBtn)
    headerLayout.addWidget(addBtn.getPtr())

    let folderBtn = QPushButton()
    folderBtn.setText("目录")
    folderBtn.setStyleSheet(QSS_BTN_ICON)
    folderBtn.setOnClickCapture(
        {
            =>
                let parentPtr = if (let Some(w) <- gMainWindow) {
                    w.getPtr()
                } else {
                    0
                }
                let folder = QFileDialog.getExistingDirectory(parentPtr, "选择音乐文件夹")
                if (folder.isEmpty()) {
                    return
                }
                let added = playlistAddFolder(folder)
                if (added > 0) {
                    refreshPlaylistUI()
                    if (added > 1000) {
                        updateStatus("已添加前 1000 首音乐（超出上限）")
                    } else {
                        updateStatus("已添加 ${added} 首音乐")
                    }
                    if (gCurrentIndex < 0) {
                        playAt(0)
                    }
                } else {
                    updateStatus("未找到音频文件")
                }
        }
    )
    gOpenFolderButton = Some(folderBtn)
    headerLayout.addWidget(folderBtn.getPtr())

    layout.addLayout(headerLayout.getPtr())

    // 播放列表
    let listWidget = QListWidget()
    listWidget.setOnItemClicked(onPlaylistItemClicked)
    gPlaylistWidget = Some(listWidget)
    layout.addWidget(listWidget.getPtr(), 1) // stretch=1 占满剩余空间

    // 底部搜索框
    let searchEdit = QLineEdit()
    searchEdit.setPlaceholder("🔍 搜索歌曲...")
    searchEdit.setOnTextChanged(onSearchTextChanged)
    gSearchEdit = Some(searchEdit)
    layout.addWidget(searchEdit.getPtr())

    panel.setLayout(layout.getPtr())
    panel
}

/// 刷新播放列表 UI（从 gPlaylist 和 gVisibleRows 重建）
public func refreshPlaylistUI(): Unit {
    rebuildVisibleRows()
    match (gPlaylistWidget) {
        case Some(list) =>
            list.clear()
            for (i in 0..gVisibleRows.size) {
                let origIdx = gVisibleRows[Int64(i)]
                let item = gPlaylist[Int64(origIdx)]
                list.addItem(item.displayText())
            }
            // 高亮当前播放项
            highlightCurrentItem()
        case None => ()
    }
    // 更新传输按钮状态
    updateTransportButtons()
}

/// 高亮当前播放项
public func highlightCurrentItem(): Unit {
    match (gPlaylistWidget) {
        case Some(list) =>
            if (gCurrentIndex < 0) {
                return
            }
            // 找到当前项在可见列表中的位置
            for (i in 0..gVisibleRows.size) {
                if (gVisibleRows[Int64(i)] == gCurrentIndex) {
                    list.setCurrentRow(Int32(i))
                    break
                }
            }
        case None => ()
    }
}

/// 更新指定项的显示文本
public func updatePlaylistItemDisplay(index: Int32): Unit {
    if (index < 0 || Int64(index) >= Int64(gPlaylist.size)) {
        return
    }
    match (gPlaylistWidget) {
        case Some(list) =>
            // 找到在可见列表中的位置
            for (i in 0..gVisibleRows.size) {
            if (gVisibleRows[Int64(i)] == index) {
                let item = gPlaylist[Int64(index)]
                list.setItemText(Int32(i), item.displayText())
                break
            }
        }
        case None => ()
    }
}

// ============================================================
// 回调函数
// ============================================================

@C
func onSearchTextChanged(text: CString): Unit {
    // 直接用信号传来的文本（fireText 已完成 QString→UTF-8 转换），回读 QLineEdit 有链路风险
    gSearchKeyword = text.toString()
    refreshPlaylistUI()
}

@C
func onPlaylistItemClicked(row: Int32): Unit {
    // row 是 UI 行号，需转为原始索引（文档 2.5 节）
    let origIdx = uiRowToOriginal(row)
    if (origIdx >= 0) {
        playAt(origIdx)
    }
}
