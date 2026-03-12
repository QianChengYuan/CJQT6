package menu_demo

import CJQT6.core.*
import CJQT6.menu.*
import CJQT6.widgets.*
import CJQT6.dialogs.*
import std.fs.*

// 全局变量存储控件引用
var g_textEdit: Option<QTextEdit> = None
var g_statusBar: Option<QStatusBar> = None
var g_app: Option<QApplication> = None
var g_window: Option<QMainWindow> = None
var g_currentFile: Option<String> = None
var g_currentFont: Option<QFontInfo> = None

// 回调函数 - 新建
func onNew(): Unit {
    if (let Some(textEdit) <- g_textEdit) {
        textEdit.clear()
    }
    g_currentFile = None
    if (let Some(statusBar) <- g_statusBar) {
        statusBar.showMessage("新建文档")
    }
}

// 回调函数 - 打开文件
func onOpen(): Unit {
    let fileName = QFileDialog.getOpenFileName(0, "打开文件", "文本文件 (*.txt);;所有文件 (*)")
    if (fileName.size > 0) {
        try {
            let content = File.readFrom(fileName)
            if (let Some(textEdit) <- g_textEdit) {
                let text = String.fromUtf8(content)
                textEdit.setText(text)
            }
            g_currentFile = Some(fileName)
            if (let Some(statusBar) <- g_statusBar) {
                statusBar.showMessage("已打开: ${fileName}")
            }
        } catch (e: Exception) {
            QMessageBox.warning(0, "错误", "无法打开文件: ${e.message}")
        }
    }
}

// 回调函数 - 保存文件
func onSave(): Unit {
    var fileName = ""
    
    if (let Some(f) <- g_currentFile) {
        fileName = f
    } else {
        fileName = QFileDialog.getSaveFileName(0, "保存文件", "文本文件 (*.txt)")
    }
    
    if (fileName.size > 0) {
        if (!fileName.endsWith(".txt")) {
            fileName = "${fileName}.txt"
        }
        
        if (let Some(textEdit) <- g_textEdit) {
            let content = textEdit.text()
            try {
                let bytes = content.toArray()
                File.writeTo(fileName, bytes)
                g_currentFile = Some(fileName)
                if (let Some(statusBar) <- g_statusBar) {
                    statusBar.showMessage("已保存: ${fileName}")
                }
            } catch (e: Exception) {
                QMessageBox.warning(0, "错误", "无法保存文件: ${e.message}")
            }
        }
    }
}

// 回调函数 - 另存为
func onSaveAs(): Unit {
    let fileName = QFileDialog.getSaveFileName(0, "另存为", "文本文件 (*.txt)")
    if (fileName.size > 0) {
        var finalName = fileName
        if (!fileName.endsWith(".txt")) {
            finalName = "${fileName}.txt"
        }
        
        if (let Some(textEdit) <- g_textEdit) {
            let content = textEdit.text()
            try {
                let bytes = content.toArray()
                File.writeTo(finalName, bytes)
                g_currentFile = Some(finalName)
                if (let Some(statusBar) <- g_statusBar) {
                    statusBar.showMessage("已保存: ${finalName}")
                }
            } catch (e: Exception) {
                QMessageBox.warning(0, "错误", "无法保存文件: ${e.message}")
            }
        }
    }
}

// 回调函数 - 退出
func onExit(): Unit {
    if (let Some(app) <- g_app) {
        app.quit()
    }
}

// 回调函数 - 剪切
func onCut(): Unit {
    if (let Some(textEdit) <- g_textEdit) {
        textEdit.cut()
    }
    if (let Some(statusBar) <- g_statusBar) {
        statusBar.showMessage("已剪切")
    }
}

// 回调函数 - 复制
func onCopy(): Unit {
    if (let Some(textEdit) <- g_textEdit) {
        textEdit.copy()
    }
    if (let Some(statusBar) <- g_statusBar) {
        statusBar.showMessage("已复制")
    }
}

// 回调函数 - 粘贴
func onPaste(): Unit {
    if (let Some(textEdit) <- g_textEdit) {
        textEdit.paste()
    }
    if (let Some(statusBar) <- g_statusBar) {
        statusBar.showMessage("已粘贴")
    }
}

// 回调函数 - 全选
func onSelectAll(): Unit {
    if (let Some(textEdit) <- g_textEdit) {
        textEdit.selectAll()
    }
    if (let Some(statusBar) <- g_statusBar) {
        statusBar.showMessage("已全选")
    }
}

// 回调函数 - 清空
func onClear(): Unit {
    if (let Some(textEdit) <- g_textEdit) {
        textEdit.clear()
    }
    if (let Some(statusBar) <- g_statusBar) {
        statusBar.showMessage("已清空")
    }
}

// 回调函数 - 设置字体
func onSetFont(): Unit {
    // 使用当前字体作为默认值
    var defaultFamily = "Sans Serif"
    var defaultSize: Int32 = 12
    var defaultBold = false
    var defaultItalic = false
    
    if (let Some(font) <- g_currentFont) {
        defaultFamily = font.family
        defaultSize = font.size
        defaultBold = font.bold
        defaultItalic = font.italic
    }
    
    let fontInfo = QFontDialog.getFontWithDefault(0, "选择字体", defaultFamily, defaultSize, defaultBold, defaultItalic)
    if (let Some(info) <- fontInfo) {
        g_currentFont = Some(info)
        // 应用样式到文本编辑器
        if (let Some(textEdit) <- g_textEdit) {
            let style = "font-family: '${info.family}'; font-size: ${info.size}pt;"
            textEdit.setWidgetStyleSheet(style)
        }
        if (let Some(statusBar) <- g_statusBar) {
            statusBar.showMessage("字体: ${info.family} ${info.size}pt")
        }
    }
}

// 回调函数 - 设置颜色
func onSetColor(): Unit {
    let color = QColorDialog.getColor(0, "选择文本颜色")
    if (color.size > 0) {
        if (let Some(textEdit) <- g_textEdit) {
            let currentStyle = textEdit.widgetStyleSheet()
            let newStyle = "${currentStyle} color: ${color};"
            textEdit.setWidgetStyleSheet(newStyle)
        }
        if (let Some(statusBar) <- g_statusBar) {
            statusBar.showMessage("颜色: ${color}")
        }
    }
}

// 回调函数 - 关于
func onAbout(): Unit {
    QMessageBox.information(0, "关于", "CJQT6 记事本 v2.0\n\n仓颉语言 Qt6 封装库示例程序\n\n功能:\n- 文件: 新建、打开、保存、另存为、退出\n- 编辑: 剪切、复制、粘贴、全选、清空\n- 格式: 字体、颜色\n- 帮助: 关于")
}

main(): Int32 {
    let app = QApplication()
    g_app = Some(app)
    
    let window = QMainWindow()
    g_window = Some(window)
    window.setTitle("CJQT6 记事本")
    
    let textEdit = QTextEdit()
    g_textEdit = Some(textEdit)
    window.setCentralWidget(textEdit.getPtr())
    
    let statusBar = QStatusBar()
    g_statusBar = Some(statusBar)
    statusBar.showMessage("就绪 - CJQT6 记事本")
    window.setStatusBar(statusBar.getPtr())
    
    let menuBar = QMenuBar()
    
    // ========== 文件菜单 ==========
    let fileMenu = menuBar.addMenu("文件(&F)")
    
    let newAction = QAction("新建(&N)")
    newAction.setShortcut("Ctrl+N")
    newAction.setOnTriggered({ => onNew() })
    
    let openAction = QAction("打开(&O)...")
    openAction.setShortcut("Ctrl+O")
    openAction.setOnTriggered({ => onOpen() })
    
    let saveAction = QAction("保存(&S)")
    saveAction.setShortcut("Ctrl+S")
    saveAction.setOnTriggered({ => onSave() })
    
    let saveAsAction = QAction("另存为(&A)...")
    saveAsAction.setOnTriggered({ => onSaveAs() })
    
    let exitAction = QAction("退出(&X)")
    exitAction.setShortcut("Ctrl+Q")
    exitAction.setOnTriggered({ => onExit() })
    
    fileMenu.addActionPtr(newAction.getPtr())
    fileMenu.addActionPtr(openAction.getPtr())
    fileMenu.addActionPtr(saveAction.getPtr())
    fileMenu.addActionPtr(saveAsAction.getPtr())
    fileMenu.addSeparator()
    fileMenu.addActionPtr(exitAction.getPtr())
    
    // ========== 编辑菜单 ==========
    let editMenu = menuBar.addMenu("编辑(&E)")
    
    let cutAction = QAction("剪切(&X)")
    cutAction.setShortcut("Ctrl+X")
    cutAction.setOnTriggered({ => onCut() })
    
    let copyAction = QAction("复制(&C)")
    copyAction.setShortcut("Ctrl+C")
    copyAction.setOnTriggered({ => onCopy() })
    
    let pasteAction = QAction("粘贴(&V)")
    pasteAction.setShortcut("Ctrl+V")
    pasteAction.setOnTriggered({ => onPaste() })
    
    let selectAllAction = QAction("全选(&A)")
    selectAllAction.setShortcut("Ctrl+A")
    selectAllAction.setOnTriggered({ => onSelectAll() })
    
    let clearAction = QAction("清空")
    clearAction.setOnTriggered({ => onClear() })
    
    editMenu.addActionPtr(cutAction.getPtr())
    editMenu.addActionPtr(copyAction.getPtr())
    editMenu.addActionPtr(pasteAction.getPtr())
    editMenu.addSeparator()
    editMenu.addActionPtr(selectAllAction.getPtr())
    editMenu.addActionPtr(clearAction.getPtr())
    
    // ========== 格式菜单 ==========
    let formatMenu = menuBar.addMenu("格式(&O)")
    
    let fontAction = QAction("字体(&F)...")
    fontAction.setOnTriggered({ => onSetFont() })
    
    let colorAction = QAction("颜色(&C)...")
    colorAction.setOnTriggered({ => onSetColor() })
    
    formatMenu.addActionPtr(fontAction.getPtr())
    formatMenu.addActionPtr(colorAction.getPtr())
    
    // ========== 帮助菜单 ==========
    let helpMenu = menuBar.addMenu("帮助(&H)")
    
    let aboutAction = QAction("关于(&A)...")
    aboutAction.setOnTriggered({ => onAbout() })
    
    helpMenu.addActionPtr(aboutAction.getPtr())
    
    window.setMenuBar(menuBar.getPtr())
    
    // ========== 工具栏 ==========
    let toolBar = QToolBar()
    toolBar.addAction(newAction.getPtr())
    toolBar.addAction(openAction.getPtr())
    toolBar.addAction(saveAction.getPtr())
    toolBar.addSeparator()
    toolBar.addAction(cutAction.getPtr())
    toolBar.addAction(copyAction.getPtr())
    toolBar.addAction(pasteAction.getPtr())
    toolBar.addSeparator()
    toolBar.addAction(fontAction.getPtr())
    toolBar.addAction(colorAction.getPtr())
    window.addToolBar(toolBar.getPtr())
    
    window.resize(800, 600)
    window.show()
    
    let result = app.exec()
    
    textEdit.delete()
    window.delete()
    
    return result
}
