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
var currentLanguage: String = "zh_CN"  // 当前语言：zh_CN 或 en_US

// ============================================================
// 辅助函数
// ============================================================

func updateTitle() {
    if (let Some(window) <- mainWindow) {
        var title = "记事本"
        if (!currentFile.isEmpty()) {
            // 只显示文件名
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

// 检查是否需要保存
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
            // 检查文件是否有后缀名，没有则自动添加.txt
            var finalPath = filePath
            let path = Path(filePath)
            let fileName = path.fileName
            var hasExtension = false
            for (c in fileName) {
                if (c == 46) {  // '.' 的ASCII码
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
        edit.cut()  // 使用cut实现删除
        updateStatus("删除")
    }
}

// ============================================================
// 查找替换
// ============================================================

// 关闭查找对话框回调
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
    
    // 创建查找对话框
    let dialog = QWidget()
    dialog.setTitle("查找和替换")
    dialog.resize(400, 180)
    findDialog = dialog
    
    let layout = QVBoxLayout()
    layout.setSpacing(10)
    layout.setMargin(15)
    
    // 查找输入
    let findRow = QHBoxLayout()
    let findLabel = QLabel()
    findLabel.setText("查找:")
    findRow.addWidget(findLabel.getPtr())
    let findEdit = QLineEdit()
    findEdit.setPlaceholder("输入查找内容...")
    findLineEdit = findEdit
    findRow.addWidget(findEdit.getPtr())
    layout.addLayout(findRow.getPtr())
    
    // 替换输入
    let replaceRow = QHBoxLayout()
    let replaceLabel = QLabel()
    replaceLabel.setText("替换:")
    replaceRow.addWidget(replaceLabel.getPtr())
    let replaceEdit = QLineEdit()
    replaceEdit.setPlaceholder("输入替换内容...")
    replaceLineEdit = replaceEdit
    replaceRow.addWidget(replaceEdit.getPtr())
    layout.addLayout(replaceRow.getPtr())
    
    // 选项
    let caseCheck = QCheckBox()
    caseCheck.setText("区分大小写")
    caseSensitiveCheck = caseCheck
    layout.addWidget(caseCheck.getPtr())
    
    // 按钮
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
    
    // 关闭按钮
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

func toggleLineWrap() {
    lineWrapEnabled = !lineWrapEnabled
    if (let Some(edit) <- textEdit) {
        if (lineWrapEnabled) {
            edit.setLineWrapMode(1)  // WidgetWidth
            updateStatus("自动换行: 开启")
        } else {
            edit.setLineWrapMode(0)  // NoWrap
            updateStatus("自动换行: 关闭")
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
            edit.setFontFamily(info.family)
            edit.setFontSize(info.size)
            edit.setFontBold(info.bold)
            edit.setFontItalic(info.italic)
        }
        updateStatus("字体: ${info.family}, 大小: ${info.size}")
    }
}

// ============================================================
// 插入操作
// ============================================================

func insertDateTime() {
    let now = DateTime.now()
    // 使用默认格式
    let dateStr = now.toString()
    if (let Some(edit) <- textEdit) {
        // 由于没有直接的insertText，我们通过替换选中文本实现
        edit.replace(dateStr)
        updateStatus("插入日期时间: ${dateStr}")
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
        // 解析行号
        var lineNum: Int32 = 0
        for (c in lineStr) {
            if (c >= 48 && c <= 57) {  // '0'-'9'
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
    if (result == 1) {  // Accepted
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
// 帮助
// ============================================================

func about() {
    QMessageBox.information(
        if (let Some(w) <- mainWindow) { w.getPtr() } else { 0 },
        "关于记事本",
        "CJQT6 记事本示例\n\n版本: 1.0.0\n\n使用仓颉语言和Qt6开发\n\n功能:\n• 文件操作: 新建/打开/保存/另存为\n• 编辑操作: 撤销/重做/剪切/复制/粘贴\n• 查找替换: 查找/替换/全部替换\n• 格式设置: 自动换行/字体\n• 打印功能: 打印/打印预览\n• 跳转功能: 跳转到指定行"
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
let onInsertDateTime: VoidCallback = { => insertDateTime() }
let onPrint: VoidCallback = { => printDocument() }
let onPrintPreview: VoidCallback = { => printPreview() }
let onAbout: VoidCallback = { => about() }
let onAboutQt: VoidCallback = { => aboutQt() }
let onSwitchToChinese: VoidCallback = { => switchToChinese() }
let onSwitchToEnglish: VoidCallback = { => switchToEnglish() }
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
    
    // 加载Qt中文翻译（使打印对话框等显示中文）
    app.loadQtTranslation("zh_CN")
    
    // 创建主窗口
    let window = QMainWindow()
    window.setTitle("记事本")
    window.resize(900, 650)
    mainWindow = window
    
    // 创建菜单栏
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
    
    // 语言子菜单
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
    
    // ========== 创建状态栏 ==========
    let status = QStatusBar()
    status.showMessage("就绪")
    window.setStatusBar(status.getPtr())
    statusBar = status
    
    // ========== 创建文本编辑区 ==========
    let edit = QTextEdit()
    edit.setLineWrapMode(1)  // WidgetWidth
    edit.setFontFamily(currentFontFamily)
    edit.setFontSize(currentFontSize)
    textEdit = edit
    
    window.setCentralWidget(edit.getPtr())
    
    // 显示窗口
    window.show()
    updateStatus("就绪 - 按 Ctrl+N 新建, Ctrl+O 打开文件")
    
    let result = app.exec()
    return result
}