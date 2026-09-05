package all_controls_demo

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.dialogs.*
import cjqt6.views.*
import cjqt6.richwidgets.*

// -------- 页面6: 对话框 --------

func createPageDialogs(): QScrollArea {
    let (scrollArea, _, layout) = createPageContainer()

    let title = QLabel()
    title.setText("对话框演示")
    setLabelStyle(title, "font-size: 18px; font-weight: bold; color: #2c3e50; padding: 8px 0;")
    title.setAlignment(AlignCenter)
    layout.addWidget(title.getPtr())

    let desc = QLabel()
    desc.setText("点击下方按钮打开各种对话框")
    setLabelStyle(desc, "color: #7f8c8d; font-size: 13px; margin-bottom: 8px;")
    desc.setAlignment(AlignCenter)
    layout.addWidget(desc.getPtr())

    // QMessageBox
    layout.addWidget(sectionTitle("QMessageBox").getPtr())
    let msgRow1 = QHBoxLayout()
    msgRow1.setSpacing(8)
    let btnInfo = QPushButton()
    btnInfo.setText("📌 信息")
    btnInfo.setOnClick(onMsgInfo)
    msgRow1.addWidget(btnInfo.getPtr())
    let btnWarn = QPushButton()
    btnWarn.setText("! 警告")
    btnWarn.setOnClick(onMsgWarning)
    msgRow1.addWidget(btnWarn.getPtr())
    let btnQuest = QPushButton()
    btnQuest.setText("❓ 询问")
    btnQuest.setOnClick(onMsgQuestion)
    btnQuest.setStyleSheet("QPushButton { color: white; background-color: #f39c12; }")
    msgRow1.addWidget(btnQuest.getPtr())
    let btnErr = QPushButton()
    btnErr.setText("❌ 错误")
    btnErr.setOnClick(onMsgError)
    btnErr.setStyleSheet("QPushButton { color: white; background-color: #e74c3c; }")
    msgRow1.addWidget(btnErr.getPtr())
    layout.addLayout(msgRow1.getPtr())

    // QFileDialog
    layout.addWidget(sectionTitle("QFileDialog").getPtr())
    let fileRow = QHBoxLayout()
    fileRow.setSpacing(8)
    let btnOpen = QPushButton()
    btnOpen.setText("📂 打开文件")
    btnOpen.setOnClick(onFileOpen)
    fileRow.addWidget(btnOpen.getPtr())
    let btnSave = QPushButton()
    btnSave.setText("💾 保存文件")
    btnSave.setOnClick(onFileSave)
    fileRow.addWidget(btnSave.getPtr())
    layout.addLayout(fileRow.getPtr())

    // QInputDialog
    layout.addWidget(sectionTitle("QInputDialog").getPtr())
    let inputRow = QHBoxLayout()
    inputRow.setSpacing(8)
    let btnInputText = QPushButton()
    btnInputText.setText("📝 输入文本")
    btnInputText.setOnClick(onInputText)
    inputRow.addWidget(btnInputText.getPtr())
    let btnInputInt = QPushButton()
    btnInputInt.setText("🔢 输入整数")
    btnInputInt.setOnClick(onInputInt)
    inputRow.addWidget(btnInputInt.getPtr())
    layout.addLayout(inputRow.getPtr())

    // QColorDialog + QFontDialog
    layout.addWidget(sectionTitle("QColorDialog / QFontDialog").getPtr())
    let miscRow = QHBoxLayout()
    miscRow.setSpacing(8)
    let btnColor = QPushButton()
    btnColor.setText("🎨 选择颜色")
    btnColor.setOnClick(onColorPicker)
    miscRow.addWidget(btnColor.getPtr())
    let btnFont = QPushButton()
    btnFont.setText("🔤 选择字体")
    btnFont.setOnClick(onFontPicker)
    miscRow.addWidget(btnFont.getPtr())
    layout.addLayout(miscRow.getPtr())

    // QProgressDialog
    layout.addWidget(sectionTitle("QProgressDialog").getPtr())
    let progRow = QHBoxLayout()
    progRow.setSpacing(8)
    let btnProgressDlg = QPushButton()
    btnProgressDlg.setText("⏳ 进度对话框")
    btnProgressDlg.setOnClick({ =>
        if (let Some(w) <- gMainWindow) {
            let progressDlg = QProgressDialog(w.getPtr(), "正在处理...", "取消", 0, 100)
            progressDlg.setWindowTitle("进度")
            for (i in 0..101) {
                progressDlg.setValue(Int32(i))
                if (progressDlg.wasCanceled()) {
                    break
                }
                // 模拟耗时
                var x: Int32 = 0
                for (j in 0..1000000) {
                    x += Int32(j)
                }
            }
            progressDlg.delete()
            if (let Some(status) <- gStatusLabel) {
                status.setText("进度对话框已完成")
            }
        }
    })
    progRow.addWidget(btnProgressDlg.getPtr())
    layout.addLayout(progRow.getPtr())

    layout.addStretch()
    scrollArea
}