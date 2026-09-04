package notepad

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.menu.*
import cjqt6.dialogs.*
import cjqt6.print.*
import cjqt6.gui.*
import std.fs.*
import std.time.*

// ============================================================
// CJQT6 记事本示例 - 完整功能演示
// ============================================================

// 全局状态
var currentFile: String = ""
var textEdit: ?QTextEdit = None
var mainWindow: ?QMainWindow = None
var statusBar: ?QStatusBar = None
var lineWrapEnabled: Bool = true
var currentFontFamily: String = "Sans Serif"
var currentFontSize: Int32 = 12
var gApp: ?QApplication = None
var findDialog: ?QWidget = None
var findLineEdit: ?QLineEdit = None
var replaceLineEdit: ?QLineEdit = None
var caseSensitiveCheck: ?QCheckBox = None
var lastFindText: String = ""
var currentLanguage: String = "zh_CN"

// 最近文件（固定大小数组，最多5个）
let MAX_RECENT_FILES: Int64 = 5
var recentFileCount: Int64 = 0
var recentFile0: String = ""
var recentFile1: String = ""
var recentFile2: String = ""
var recentFile3: String = ""
var recentFile4: String = ""
var gPendingRecentFile: String = ""
var gFontCombo: ?QFontComboBox = None
var gSizeCombo: ?QComboBox = None
var gBoldEnabled: Bool = false

func getRecentFile(index: Int64): String {
    if (index == 0) { return recentFile0 }
    if (index == 1) { return recentFile1 }
    if (index == 2) { return recentFile2 }
    if (index == 3) { return recentFile3 }
    return recentFile4
}

func setRecentFile(index: Int64, value: String) {
    if (index == 0) { recentFile0 = value }
    if (index == 1) { recentFile1 = value }
    if (index == 2) { recentFile2 = value }
    if (index == 3) { recentFile3 = value }
    return if (index == 4) { recentFile4 = value } else { () }
}

// ============================================================
// 辅助函数
// ============================================================

func addToRecentFiles(filePath: String) {
    var existingIndex: Int64 = -1
    var i: Int64 = 0
    while (i < recentFileCount) {
        if (getRecentFile(i) == filePath) {
            existingIndex = i
            break
        }
        i++
    }
    if (existingIndex >= 0) {
        var j = existingIndex
        while (j > 0) {
            setRecentFile(j, getRecentFile(j - 1))
            j--
        }
        setRecentFile(0, filePath)
    } else {
        var count = if (recentFileCount < MAX_RECENT_FILES) { recentFileCount } else { MAX_RECENT_FILES - 1 }
        var k = count
        while (k > 0) {
            setRecentFile(k, getRecentFile(k - 1))
            k--
        }
        setRecentFile(0, filePath)
        if (recentFileCount < MAX_RECENT_FILES) {
            recentFileCount++
        }
    }
}

func updateTitle() {
    if (let Some(window) <- mainWindow) {
        var title = "记事本"
        if (!currentFile.isEmpty()) {
            let path = Path(currentFile)
            title = "${path.fileName} - 记事本"
        }
        if (let Some(edit) <- textEdit) {
            if (edit.isModified()) {
                title = "*${title}"
            }
        }
        window.setTitle(title)
    }
}

func updateDocumentStats() {
    if (let Some(edit) <- textEdit) {
        let lines = edit.lineCount()
        let chars = edit.characterCount()
        let line = edit.currentLine()
        let col = edit.currentColumn()
        updateStatus("第 ${line}/${lines} 行, 第 ${col} 列 | 字符数: ${chars}")
    }
}

func updateStatus(message: String) {
    if (let Some(status) <- statusBar) {
        status.showMessage(message)
    }
}

func updateCursorPosition() {
    if (let Some(edit) <- textEdit) {
        let line = edit.currentLine()
        let col = edit.currentColumn()
        let chars = edit.characterCount()
        let lines = edit.lineCount()
        updateStatus("行 ${line}/${lines}, 列 ${col} | 字符数: ${chars}")
    }
}

func checkSave(): Bool {
    if (let Some(edit) <- textEdit) {
        if (edit.isModified()) {
            let result = QMessageBox.question(
                if (let Some(w) <- mainWindow) { w.getPtr() } else { 0 },
                "保存确认",
                "文件已修改，是否保存？"
            )
            if (result) {
                saveFile()
            }
            return true
        }
    }
    return true
}

// ============================================================
// 文件操作
// ============================================================

func newFile() {
    if (!checkSave()) {
        return
    }
    if (let Some(edit) <- textEdit) {
        edit.clear()
        edit.setModified(false)
    }
    currentFile = ""
    updateTitle()
    updateStatus("新建文件")
}

func openFile() {
    if (!checkSave()) {
        return
    }
    
    let filePath = QFileDialog.getOpenFileName(
        if (let Some(w) <- mainWindow) { w.getPtr() } else { 0 },
        "打开文件",
        "文本文件 (*.txt);;所有文件 (*)"
    )
    
    if (!filePath.isEmpty()) {
        try {
            let data = File.readFrom(Path(filePath))
            let content = String.fromUtf8(data)
            if (let Some(edit) <- textEdit) {
                edit.setText(content)
                edit.setModified(false)
            }
            currentFile = filePath
            addToRecentFiles(filePath)
            updateTitle()
            updateCursorPosition()
        } catch (e: Exception) {
            QMessageBox.critical(
                if (let Some(w) <- mainWindow) { w.getPtr() } else { 0 },
                "错误",
                "无法打开文件: ${filePath}"
            )
        }
    }
}

func saveFile() {
    if (currentFile.isEmpty()) {
        saveFileAs()
    } else {
        doSave(currentFile)
    }
}

func saveFileAs() {
    let filePath = QFileDialog.getSaveFileName(
        if (let Some(w) <- mainWindow) { w.getPtr() } else { 0 },
        "保存文件",
        "文本文件 (*.txt);;所有文件 (*)"
    )
    
    if (!filePath.isEmpty()) {
        doSave(filePath)
    }
}

func doSave(filePath: String) {
    if (let Some(edit) <- textEdit) {
        try {
            var finalPath = filePath
            let path = Path(filePath)
            let fileName = path.fileName
            var hasExtension = false
            for (c in fileName) {
                if (c == 46) {
                    hasExtension = true
                    break
                }
            }
            if (!hasExtension && !fileName.isEmpty()) {
                finalPath = "${filePath}.txt"
            }
            
            let content = edit.text()
            File.writeTo(Path(finalPath), content.toArray())
            edit.setModified(false)
            currentFile = finalPath
            addToRecentFiles(finalPath)
            updateTitle()
            updateStatus("已保存: ${finalPath}")
        } catch (e: Exception) {
            QMessageBox.critical(
                if (let Some(w) <- mainWindow) { w.getPtr() } else { 0 },
                "错误",
                "无法保存文件: ${filePath}"
            )
        }
    }
}

func openRecentFile() {
    if (gPendingRecentFile.isEmpty()) {
        return
    }
    if (!checkSave()) {
        return
    }
    try {
        let data = File.readFrom(Path(gPendingRecentFile))
        let content = String.fromUtf8(data)
        if (let Some(edit) <- textEdit) {
            edit.setText(content)
            edit.setModified(false)
        }
        currentFile = gPendingRecentFile
        addToRecentFiles(gPendingRecentFile)
        updateTitle()
        updateCursorPosition()
    } catch (e: Exception) {
        QMessageBox.critical(0, "错误", "无法打开文件: ${gPendingRecentFile}")
    }
}

// ============================================================
// 编辑操作
// ============================================================

func undo() {
    if (let Some(edit) <- textEdit) {
        edit.undo()
        updateStatus("撤销")
    }
}

func redo() {
    if (let Some(edit) <- textEdit) {
        edit.redo()
        updateStatus("重做")
    }
}

func cut() {
    if (let Some(edit) <- textEdit) {
        edit.cut()
        updateStatus("剪切")
    }
}

func copy() {
    if (let Some(edit) <- textEdit) {
        edit.copy()
        updateStatus("复制")
    }
}

func paste() {
    if (let Some(edit) <- textEdit) {
        edit.paste()
        updateStatus("粘贴")
    }
}

func selectAll() {
    if (let Some(edit) <- textEdit) {
        edit.selectAll()
        updateStatus("全选")
    }
}

func deleteSelected() {
    if (let Some(edit) <- textEdit) {
        edit.cut()
        updateStatus("删除")
    }
}

// ============================================================
// 查找替换
// ============================================================

let onCloseFindDialog: VoidCallback = { =>
    if (let Some(dialog) <- findDialog) {
        dialog.hide()
    }
}

func showFindDialog() {
    if (let Some(dialog) <- findDialog) {
        dialog.show()
        if (let Some(edit) <- findLineEdit) {
            edit.setFocus()
        }
        return
    }
    
    let dialog = QWidget()
    dialog.setTitle("查找和替换")
    dialog.resize(400, 180)
    findDialog = dialog
    
    let layout = QVBoxLayout()
    layout.setSpacing(10)
    layout.setMargin(15)
    
    let findRow = QHBoxLayout()
    let findLabel = QLabel()
    findLabel.setText("查找:")
    findRow.addWidget(findLabel.getPtr())
    let findEdit = QLineEdit()
    findEdit.setPlaceholder("输入查找内容...")
    findLineEdit = findEdit
    findRow.addWidget(findEdit.getPtr())
    layout.addLayout(findRow.getPtr())
    
    let replaceRow = QHBoxLayout()
    let replaceLabel = QLabel()
    replaceLabel.setText("替换:")
    replaceRow.addWidget(replaceLabel.getPtr())
    let replaceEdit = QLineEdit()
    replaceEdit.setPlaceholder("输入替换内容...")
    replaceLineEdit = replaceEdit
    replaceRow.addWidget(replaceEdit.getPtr())
    layout.addLayout(replaceRow.getPtr())
    
    let caseCheck = QCheckBox()
    caseCheck.setText("区分大小写")
    caseSensitiveCheck = caseCheck
    layout.addWidget(caseCheck.getPtr())
    
    let btnRow = QHBoxLayout()
    
    let findNextBtn = QPushButton()
    findNextBtn.setText("查找下一个")
    findNextBtn.setOnClick({ =>
        doFindNext()
    })
    btnRow.addWidget(findNextBtn.getPtr())
    
    let findPrevBtn = QPushButton()
    findPrevBtn.setText("查找上一个")
    findPrevBtn.setOnClick({ =>
        doFindPrev()
    })
    btnRow.addWidget(findPrevBtn.getPtr())
    
    let replaceBtn = QPushButton()
    replaceBtn.setText("替换")
    replaceBtn.setOnClick({ =>
        doReplace()
    })
    btnRow.addWidget(replaceBtn.getPtr())
    
    let replaceAllBtn = QPushButton()
    replaceAllBtn.setText("全部替换")
    replaceAllBtn.setOnClick({ =>
        doReplaceAll()
    })
    btnRow.addWidget(replaceAllBtn.getPtr())
    
    layout.addLayout(btnRow.getPtr())
    
    let closeBtn = QPushButton()
    closeBtn.setText("关闭")
    closeBtn.setOnClick(onCloseFindDialog)
    layout.addWidget(closeBtn.getPtr())
    
    dialog.setLayout(layout.getPtr())
    dialog.show()
}

func doFindNext() {
    if (let Some(edit) <- findLineEdit) {
        let text = edit.text()
        if (text.isEmpty()) {
            return
        }
        lastFindText = text
        let caseSensitive = if (let Some(check) <- caseSensitiveCheck) { check.isChecked() } else { false }
        if (let Some(textEdit) <- textEdit) {
            let found = textEdit.find(text, caseSensitive)
            if (!found) {
                updateStatus("未找到: ${text}")
            } else {
                updateStatus("找到: ${text}")
            }
        }
    }
}

func doFindPrev() {
    if (let Some(edit) <- findLineEdit) {
        let text = edit.text()
        if (text.isEmpty()) {
            return
        }
        lastFindText = text
        let caseSensitive = if (let Some(check) <- caseSensitiveCheck) { check.isChecked() } else { false }
        if (let Some(textEdit) <- textEdit) {
            textEdit.findPrev(text, caseSensitive)
            updateStatus("查找上一个: ${text}")
        }
    }
}

func doReplace() {
    if (let Some(edit) <- findLineEdit) {
        let findText = edit.text()
        if (findText.isEmpty()) {
            return
        }
        let replaceText = if (let Some(r) <- replaceLineEdit) { r.text() } else { "" }
        if (let Some(textEdit) <- textEdit) {
            textEdit.replace(replaceText)
            updateStatus("已替换")
        }
    }
}

func doReplaceAll() {
    if (let Some(edit) <- findLineEdit) {
        let findText = edit.text()
        if (findText.isEmpty()) {
            return
        }
        let replaceText = if (let Some(r) <- replaceLineEdit) { r.text() } else { "" }
        let caseSensitive = if (let Some(check) <- caseSensitiveCheck) { check.isChecked() } else { false }
        if (let Some(textEdit) <- textEdit) {
            let count = textEdit.replaceAll(findText, replaceText, caseSensitive)
            updateStatus("已替换 ${count} 处")
        }
    }
}

func findNext() {
    if (lastFindText.isEmpty()) {
        showFindDialog()
    } else {
        if (let Some(textEdit) <- textEdit) {
            let found = textEdit.find(lastFindText, false)
            if (!found) {
                updateStatus("未找到: ${lastFindText}")
            }
        }
    }
}

// ============================================================
// 格式操作
// ============================================================

func zoomIn() {
    if (let Some(edit) <- textEdit) {
        edit.zoomIn(2)
        updateStatus("放大")
    }
}

func zoomOut() {
    if (let Some(edit) <- textEdit) {
        edit.zoomOut(2)
        updateStatus("缩小")
    }
}

func zoomReset() {
    if (let Some(edit) <- textEdit) {
        currentFontSize = 12
        edit.setFontSize(currentFontSize)
        syncFontToolbar()
        updateStatus("缩放已重置")
    }
}

func toggleLineWrap() {
    lineWrapEnabled = !lineWrapEnabled
    if (let Some(edit) <- textEdit) {
        if (lineWrapEnabled) {
            edit.setLineWrapMode(1)
            updateStatus("自动换行: 开启")
        } else {
            edit.setLineWrapMode(0)
            updateStatus("自动换行: 关闭")
        }
    }
}

func syncFontToolbar() {
    if (let Some(combo) <- gFontCombo) {
        combo.setCurrentFont(currentFontFamily)
    }
    if (let Some(combo) <- gSizeCombo) {
        let idx = combo.findText(currentFontSize.toString())
        if (idx >= 0) {
            combo.setCurrentIndex(idx)
        }
    }
}

func setFont() {
    let fontInfo = QFontDialog.getFontWithDefault(
        if (let Some(w) <- mainWindow) { w.getPtr() } else { 0 },
        "选择字体",
        currentFontFamily,
        currentFontSize,
        false,
        false
    )
    
    if (let Some(info) <- fontInfo) {
        currentFontFamily = info.family
        currentFontSize = info.size
        if (let Some(edit) <- textEdit) {
            // 保留已有格式：只应用字体族和字号，不动粗体/斜体（避免覆盖工具栏 B 按钮等设置）
            edit.setFontFamily(info.family)
            edit.setFontSize(info.size)
        }
        syncFontToolbar()
        updateStatus("字体: ${info.family}, 大小: ${info.size}")
    }
}

// ============================================================
// 插入操作
// ============================================================

func insertDateTime() {
    let now = DateTime.now()
    let dateStr = now.toString()
    if (let Some(edit) <- textEdit) {
        edit.replace(dateStr)
        updateStatus("插入日期时间: ${dateStr}")
    }
}

func toggleBold() {
    gBoldEnabled = !gBoldEnabled
    if (let Some(edit) <- textEdit) {
        edit.setFontBold(gBoldEnabled)
    }
}

func pickTextColor() {
    let color = QColorDialog.getColor(
        if (let Some(w) <- mainWindow) { w.getPtr() } else { 0 },
        "选择文字颜色"
    )
    if (!color.isEmpty()) {
        var r: Int32 = 0
        var g: Int32 = 0
        var b: Int32 = 0
        var ci: Int64 = 0
        for (ch in color) {
            if (ch == 35) { continue }
            var val: Int32 = 0
            if (ch >= 48 && ch <= 57) { val = Int32(ch - 48) }
            else if (ch >= 65 && ch <= 70) { val = Int32(ch - 55) }
            else if (ch >= 97 && ch <= 102) { val = Int32(ch - 87) }
            else { continue }
            if (ci == 0 || ci == 1) { r = r * 16 + val }
            if (ci == 2 || ci == 3) { g = g * 16 + val }
            if (ci == 4 || ci == 5) { b = b * 16 + val }
            ci++
        }
        if (let Some(edit) <- textEdit) {
            edit.setTextColor(r, g, b)
        }
        updateStatus("文字颜色: ")
    }
}

func goToLine() {
    let lineStr = QInputDialog.getText(
        if (let Some(w) <- mainWindow) { w.getPtr() } else { 0 },
        "跳转到行",
        "行号:",
        "1"
    )
    if (!lineStr.isEmpty()) {
        var lineNum: Int32 = 0
        for (c in lineStr) {
            if (c >= 48 && c <= 57) {
                lineNum = lineNum * 10 + Int32(c - 48)
            }
        }
        if (lineNum > 0) {
            if (let Some(edit) <- textEdit) {
                edit.goToLine(lineNum)
                updateStatus("跳转到第 ${lineNum} 行")
            }
        }
    }
}

// ============================================================
// 打印功能
// ============================================================

func printDocument() {
    let printer = QPrinter()
    let printDialog = QPrintDialog(printer)
    let result = printDialog.exec()
    if (result == 1) {
        if (let Some(edit) <- textEdit) {
            edit.print(printer.getPtr())
            updateStatus("打印完成")
        }
    }
    printDialog.delete()
    printer.delete()
}

func printPreview() {
    let printer = QPrinter()
    if (let Some(edit) <- textEdit) {
        let previewDialog = QPrintPreviewDialog(printer, edit)
        previewDialog.exec()
        previewDialog.delete()
    }
    printer.delete()
}

// ============================================================
// 文档统计
// ============================================================

func showStats() {
    if (let Some(edit) <- textEdit) {
        let lines = edit.lineCount()
        let chars = edit.characterCount()
        var filename = if (currentFile.isEmpty()) { "未命名" } else { currentFile }
        QMessageBox.information(0, "文档统计",
            "文件: ${filename}\n总行数: ${lines}\n总字符数: ${chars}")
    }
}

// ============================================================
// 帮助
// ============================================================

func about() {
    QMessageBox.information(
        if (let Some(w) <- mainWindow) { w.getPtr() } else { 0 },
        "关于记事本",
        "CJQT6 记事本示例\n\n版本: 1.1.0\n\n使用仓颉语言和 Qt6 开发\n\n新功能:\n• 文档实时统计\n• Ctrl+= 放大, Ctrl+- 缩小\n• 最近打开文件列表"
    )
}

func aboutQt() {
    QMessageBox.information(
        if (let Some(w) <- mainWindow) { w.getPtr() } else { 0 },
        "关于 Qt",
        "Qt 是一个跨平台的 C++ 图形用户界面应用程序开发框架。\n\n本程序使用 Qt 6.x 版本。"
    )
}

// ============================================================
// 语言切换
// ============================================================

func switchLanguage(lang: String) {
    currentLanguage = lang
    if (let Some(app) <- gApp) {
        let success = app.switchLanguage(lang)
        if (success) {
            updateStatus("语言已切换，部分界面需要重启生效")
        } else {
            updateStatus("语言切换: ${lang}")
        }
    }
}

func switchToChinese() {
    switchLanguage("zh_CN")
}

func switchToEnglish() {
    switchLanguage("en_US")
}

// ============================================================
// 回调函数
// ============================================================

let onTextChanged: VoidCallback = { => updateDocumentStats() }
let onZoomIn: VoidCallback = { => zoomIn() }
let onZoomOut: VoidCallback = { => zoomOut() }
let onZoomReset: VoidCallback = { => zoomReset() }

let onOpenRecentFile0: VoidCallback = { => gPendingRecentFile = recentFile0; openRecentFile() }
let onOpenRecentFile1: VoidCallback = { => gPendingRecentFile = recentFile1; openRecentFile() }
let onOpenRecentFile2: VoidCallback = { => gPendingRecentFile = recentFile2; openRecentFile() }
let onOpenRecentFile3: VoidCallback = { => gPendingRecentFile = recentFile3; openRecentFile() }
let onOpenRecentFile4: VoidCallback = { => gPendingRecentFile = recentFile4; openRecentFile() }

let onNewFile: VoidCallback = { => newFile() }
let onOpenFile: VoidCallback = { => openFile() }
let onSaveFile: VoidCallback = { => saveFile() }
let onSaveFileAs: VoidCallback = { => saveFileAs() }
let onUndo: VoidCallback = { => undo() }
let onRedo: VoidCallback = { => redo() }
let onCut: VoidCallback = { => cut() }
let onCopy: VoidCallback = { => copy() }
let onPaste: VoidCallback = { => paste() }
let onSelectAll: VoidCallback = { => selectAll() }
let onDelete: VoidCallback = { => deleteSelected() }
let onFind: VoidCallback = { => showFindDialog() }
let onFindNext: VoidCallback = { => findNext() }
let onGoToLine: VoidCallback = { => goToLine() }
let onToggleLineWrap: VoidCallback = { => toggleLineWrap() }
let onSetFont: VoidCallback = { => setFont() }
let onApplyFormat: VoidCallback = { => if (let Some(combo) <- gFontCombo) { let family = combo.currentFont(); if (!family.isEmpty()) { currentFontFamily = family; if (let Some(edit) <- textEdit) { edit.setFontFamily(family) } } } }
let onSizeChanged: Int32Callback = { _ => if (let Some(combo) <- gSizeCombo) { let sizeStr = combo.currentText(); var size: Int32 = 12; for (c in sizeStr) { if (c >= 48 && c <= 57) { size = size * 10 + Int32(c - 48) } }; if (size > 0) { currentFontSize = size; if (let Some(edit) <- textEdit) { edit.setFontSize(size) } } } }
let onToggleBold: VoidCallback = { => toggleBold() }
let onPickColor: VoidCallback = { => pickTextColor() }
let onInsertDateTime: VoidCallback = { => insertDateTime() }
let onPrint: VoidCallback = { => printDocument() }
let onPrintPreview: VoidCallback = { => printPreview() }
let onAbout: VoidCallback = { => about() }
let onAboutQt: VoidCallback = { => aboutQt() }
let onSwitchToChinese: VoidCallback = { => switchToChinese() }
let onSwitchToEnglish: VoidCallback = { => switchToEnglish() }
let onShowStats: VoidCallback = { => showStats() }
let onExit: VoidCallback = { =>
    if (!checkSave()) {
        return
    }
    if (let Some(app) <- gApp) {
        app.quit()
    }
}

// ============================================================
// 主函数
// ============================================================
main(): Int32 {
    let app = QApplication()
    gApp = app

    app.loadQtTranslation("zh_CN")
    
    let window = QMainWindow()
    window.setTitle("记事本")
    window.resize(900, 650)
    mainWindow = window
    
    let menuBar = QMenuBar()
    
    // ========== 文件菜单 ==========
    let fileMenu = menuBar.addMenu("文件(&F)")
    
    let newAction = fileMenu.addAction("新建(&N)")
    newAction.setShortcut("Ctrl+N")
    newAction.setOnTriggered(onNewFile)
    
    let openAction = fileMenu.addAction("打开(&O)")
    openAction.setShortcut("Ctrl+O")
    openAction.setOnTriggered(onOpenFile)
    
    let saveAction = fileMenu.addAction("保存(&S)")
    saveAction.setShortcut("Ctrl+S")
    saveAction.setOnTriggered(onSaveFile)
    
    let saveAsAction = fileMenu.addAction("另存为(&A)...")
    saveAsAction.setShortcut("Ctrl+Shift+S")
    saveAsAction.setOnTriggered(onSaveFileAs)
    
    fileMenu.addSeparator()
    
    // 最近文件
    if (recentFileCount > 0) {
        let r0 = fileMenu.addAction(recentFile0)
        r0.setOnTriggered(onOpenRecentFile0)
    }
    if (recentFileCount > 1) {
        let r1 = fileMenu.addAction(recentFile1)
        r1.setOnTriggered(onOpenRecentFile1)
    }
    if (recentFileCount > 2) {
        let r2 = fileMenu.addAction(recentFile2)
        r2.setOnTriggered(onOpenRecentFile2)
    }
    if (recentFileCount > 3) {
        let r3 = fileMenu.addAction(recentFile3)
        r3.setOnTriggered(onOpenRecentFile3)
    }
    if (recentFileCount > 4) {
        let r4 = fileMenu.addAction(recentFile4)
        r4.setOnTriggered(onOpenRecentFile4)
    }
    if (recentFileCount > 0) {
        fileMenu.addSeparator()
    }
    
    let printAction = fileMenu.addAction("打印(&P)...")
    printAction.setShortcut("Ctrl+P")
    printAction.setOnTriggered(onPrint)
    
    let printPreviewAction = fileMenu.addAction("打印预览(&V)")
    printPreviewAction.setOnTriggered(onPrintPreview)
    
    fileMenu.addSeparator()
    
    let exitAction = fileMenu.addAction("退出(&X)")
    exitAction.setShortcut("Alt+F4")
    exitAction.setOnTriggered(onExit)
    
    // ========== 编辑菜单 ==========
    let editMenu = menuBar.addMenu("编辑(&E)")
    
    let undoAction = editMenu.addAction("撤销(&U)")
    undoAction.setShortcut("Ctrl+Z")
    undoAction.setOnTriggered(onUndo)
    
    let redoAction = editMenu.addAction("重做(&R)")
    redoAction.setShortcut("Ctrl+Y")
    redoAction.setOnTriggered(onRedo)
    
    editMenu.addSeparator()
    
    let cutAction = editMenu.addAction("剪切(&X)")
    cutAction.setShortcut("Ctrl+X")
    cutAction.setOnTriggered(onCut)
    
    let copyAction = editMenu.addAction("复制(&C)")
    copyAction.setShortcut("Ctrl+C")
    copyAction.setOnTriggered(onCopy)
    
    let pasteAction = editMenu.addAction("粘贴(&V)")
    pasteAction.setShortcut("Ctrl+V")
    pasteAction.setOnTriggered(onPaste)
    
    let deleteAction = editMenu.addAction("删除(&D)")
    deleteAction.setShortcut("Delete")
    deleteAction.setOnTriggered(onDelete)
    
    editMenu.addSeparator()
    
    let selectAllAction = editMenu.addAction("全选(&A)")
    selectAllAction.setShortcut("Ctrl+A")
    selectAllAction.setOnTriggered(onSelectAll)
    
    editMenu.addSeparator()
    
    let findAction = editMenu.addAction("查找和替换(&F)...")
    findAction.setShortcut("Ctrl+F")
    findAction.setOnTriggered(onFind)
    
    let findNextAction = editMenu.addAction("查找下一个(&N)")
    findNextAction.setShortcut("F3")
    findNextAction.setOnTriggered(onFindNext)
    
    let goToLineAction = editMenu.addAction("跳转到行(&G)...")
    goToLineAction.setShortcut("Ctrl+G")
    goToLineAction.setOnTriggered(onGoToLine)
    
    // ========== 查看菜单 ==========
    let viewMenu = menuBar.addMenu("查看(&V)")
    
    let zoomInAction = viewMenu.addAction("放大(&I)")
    zoomInAction.setShortcut("Ctrl+=")
    zoomInAction.setOnTriggered(onZoomIn)
    
    let zoomOutAction = viewMenu.addAction("缩小(&O)")
    zoomOutAction.setShortcut("Ctrl+-")
    zoomOutAction.setOnTriggered(onZoomOut)
    
    let zoomResetAction = viewMenu.addAction("重置缩放(&R)")
    zoomResetAction.setShortcut("Ctrl+0")
    zoomResetAction.setOnTriggered(onZoomReset)
    
    viewMenu.addSeparator()
    
    let statsAction = viewMenu.addAction("文档统计(&S)")
    statsAction.setOnTriggered(onShowStats)
    
    // ========== 格式菜单 ==========
    let formatMenu = menuBar.addMenu("格式(&O)")
    
    let lineWrapAction = formatMenu.addAction("自动换行(&W)")
    lineWrapAction.setCheckable(true)
    lineWrapAction.setChecked(true)
    lineWrapAction.setOnTriggered(onToggleLineWrap)
    
    let fontAction = formatMenu.addAction("字体(&F)...")
    fontAction.setOnTriggered(onSetFont)
    
    // ========== 插入菜单 ==========
    let insertMenu = menuBar.addMenu("插入(&I)")
    
    let dateTimeAction = insertMenu.addAction("日期/时间(&D)")
    dateTimeAction.setShortcut("F5")
    dateTimeAction.setOnTriggered(onInsertDateTime)
    
    // ========== 帮助菜单 ==========
    let helpMenu = menuBar.addMenu("帮助(&H)")
    
    let languageMenu = helpMenu.addMenu("语言(&L)")
    
    let chineseAction = languageMenu.addAction("中文简体")
    chineseAction.setCheckable(true)
    chineseAction.setChecked(true)
    chineseAction.setOnTriggered(onSwitchToChinese)
    
    let englishAction = languageMenu.addAction("English")
    englishAction.setCheckable(true)
    englishAction.setOnTriggered(onSwitchToEnglish)
    
    helpMenu.addSeparator()
    
    let aboutAction = helpMenu.addAction("关于记事本(&A)")
    aboutAction.setOnTriggered(onAbout)
    
    let aboutQtAction = helpMenu.addAction("关于 Qt(&Q)")
    aboutQtAction.setOnTriggered(onAboutQt)
    
    window.setMenuBar(menuBar.getPtr())
    
    // ========== 创建工具栏 ==========
    let toolBar = QToolBar("主工具栏")
    
    let newBtn = QAction("新建")
    newBtn.setOnTriggered(onNewFile)
    toolBar.addAction(newBtn.getPtr())
    
    let openBtn = QAction("打开")
    openBtn.setOnTriggered(onOpenFile)
    toolBar.addAction(openBtn.getPtr())
    
    let saveBtn = QAction("保存")
    saveBtn.setOnTriggered(onSaveFile)
    toolBar.addAction(saveBtn.getPtr())
    
    toolBar.addSeparator()
    
    let cutBtn = QAction("剪切")
    cutBtn.setOnTriggered(onCut)
    toolBar.addAction(cutBtn.getPtr())
    
    let copyBtn = QAction("复制")
    copyBtn.setOnTriggered(onCopy)
    toolBar.addAction(copyBtn.getPtr())
    
    let pasteBtn = QAction("粘贴")
    pasteBtn.setOnTriggered(onPaste)
    toolBar.addAction(pasteBtn.getPtr())
    
    toolBar.addSeparator()
    
    let undoBtn = QAction("撤销")
    undoBtn.setOnTriggered(onUndo)
    toolBar.addAction(undoBtn.getPtr())
    
    let redoBtn = QAction("重做")
    redoBtn.setOnTriggered(onRedo)
    toolBar.addAction(redoBtn.getPtr())
    
    toolBar.addSeparator()
    
    let findBtn = QAction("查找")
    findBtn.setOnTriggered(onFind)
    toolBar.addAction(findBtn.getPtr())
    
    let printBtn = QAction("打印")
    printBtn.setOnTriggered(onPrint)
    toolBar.addAction(printBtn.getPtr())
    
    window.addToolBar(toolBar.getPtr())

    // ========== 格式工具栏 ==========
    let formatBar = QToolBar("格式工具栏")

    // 字体选择
    let fontCombo = QFontComboBox()
    fontCombo.setCurrentFont(currentFontFamily)
    fontCombo.setStyleSheet("min-width: 140px;")
    gFontCombo = fontCombo
    formatBar.addWidget(fontCombo.getPtr())

    // 字号选择
    let sizeCombo = QComboBox()
    let sizes = ["8", "9", "10", "11", "12", "14", "16", "18", "20", "22", "24", "28", "32", "36", "48", "72"]
    for (sz in sizes) {
        sizeCombo.addItem(sz)
    }

    gSizeCombo = sizeCombo
    
    sizeCombo.setMaxVisibleItems(16)
    sizeCombo.setStyleSheet("QComboBox { min-width: 60px; } QComboBox QAbstractItemView { min-height: 200px; }")
    // 字号变化时自动应用
    sizeCombo.setOnCurrentIndexChanged(onSizeChanged)
    formatBar.addWidget(sizeCombo.getPtr())

    // 应用格式按钮
    let applyBtn = QPushButton()
    applyBtn.setText("应用")
    applyBtn.setStyleSheet("QPushButton { border: 1px solid #999; border-radius: 2px; padding: 2px 8px; font-size: 12px; } QPushButton:hover { background: #E0E8F0; }")
    applyBtn.setOnClick(onApplyFormat)
    formatBar.addWidget(applyBtn.getPtr())

    formatBar.addSeparator()

    // 加粗按钮
    let boldBtn = QPushButton()
    boldBtn.setText("B")
    boldBtn.setCheckable(true)
    boldBtn.setStyleSheet("QPushButton { font-weight: bold; font-size: 14px; min-width: 28px; min-height: 24px; } QPushButton:checked { background-color: #D0D8E0; }")
    boldBtn.setOnClick(onToggleBold)
    formatBar.addWidget(boldBtn.getPtr())

    // 颜色按钮
    let colorBtn = QPushButton()
    colorBtn.setText("A")
    colorBtn.setStyleSheet("QPushButton { color: #CC0000; font-weight: bold; font-size: 14px; text-decoration: underline; min-width: 28px; min-height: 24px; } QPushButton:hover { background-color: #F0F0F0; }")
    colorBtn.setOnClick(onPickColor)
    formatBar.addWidget(colorBtn.getPtr())

    window.addToolBar(formatBar.getPtr())
    
    // ========== 创建状态栏 ==========
    let status = QStatusBar()
    status.showMessage("就绪")
    window.setStatusBar(status.getPtr())
    statusBar = status
    
    // ========== 创建文本编辑区 ==========
    let edit = QTextEdit()
    edit.setLineWrapMode(1)
    edit.setFontFamily(currentFontFamily)
    edit.setFontSize(currentFontSize)
    textEdit = edit

    // 实时更新状态栏（字数、行数等）
    edit.setOnTextChanged(onTextChanged)
    
    window.setCentralWidget(edit.getPtr())
    
    window.show()
    // 启动焦点落在文本编辑区，而非工具栏第一个可聚焦控件（QFontComboBox 字体下拉框）
    edit.setFocus()
    updateDocumentStats()
    updateStatus("就绪 - Ctrl+N 新建, Ctrl+O 打开, Ctrl+= 放大, Ctrl+- 缩小")
    
    let result = app.exec()
    return result
}
