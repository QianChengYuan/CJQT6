package menu_demo

import CJQT6.core.*
import CJQT6.menu.*
import CJQT6.widgets.*
import CJQT6.dialogs.*
import std.fs.*

// 全局变量存储控件引用（使用Option延迟初始化）
var g_textEdit: Option<QTextEdit> = None
var g_statusBar: Option<QStatusBar> = None
var g_app: Option<QApplication> = None
var g_window: Option<QMainWindow> = None
var g_currentFile: Option<String> = None  // 当前文件路径

// 回调函数 - 新建
func onNew(_: Int64): Unit {
    if (let Some(textEdit) <- g_textEdit) {
        textEdit.clear()
    }
    g_currentFile = None
    if (let Some(statusBar) <- g_statusBar) {
        statusBar.showMessage("新建文档")
    }
}

// 回调函数 - 打开文件
func onOpen(_: Int64): Unit {
    let fileName = QFileDialog.getOpenFileName(0, "打开文件", "文本文件 (*.txt);;所有文件 (*)")
    if (fileName.size > 0) {
        // 读取文件内容
        try {
            let content = File.readFrom(fileName)
            if (let Some(textEdit) <- g_textEdit) {
                // 将Array<UInt8>转为String
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
func onSave(_: Int64): Unit {
    var fileName = ""
    
    // 如果没有当前文件，弹出保存对话框
    if (let Some(f) <- g_currentFile) {
        fileName = f
    } else {
        fileName = QFileDialog.getSaveFileName(0, "保存文件", "文本文件 (*.txt)")
    }
    
    if (fileName.size > 0) {
        // 确保文件名有.txt后缀
        if (!fileName.endsWith(".txt")) {
            fileName = "${fileName}.txt"
        }
        
        // 获取文本内容并保存
        if (let Some(textEdit) <- g_textEdit) {
            let content = textEdit.text()
            try {
                // 将String转为Array<UInt8>写入文件
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
func onSaveAs(_: Int64): Unit {
    let fileName = QFileDialog.getSaveFileName(0, "另存为", "文本文件 (*.txt)")
    if (fileName.size > 0) {
        // 确保文件名有.txt后缀
        var finalName = fileName
        if (!fileName.endsWith(".txt")) {
            finalName = "${fileName}.txt"
        }
        
        // 获取文本内容并保存
        if (let Some(textEdit) <- g_textEdit) {
            let content = textEdit.text()
            try {
                // 将String转为Array<UInt8>写入文件
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
func onExit(_: Int64): Unit {
    if (let Some(app) <- g_app) {
        app.quit()
    }
}

// 回调函数 - 剪切
func onCut(_: Int64): Unit {
    if (let Some(textEdit) <- g_textEdit) {
        textEdit.cut()
    }
    if (let Some(statusBar) <- g_statusBar) {
        statusBar.showMessage("已剪切")
    }
}

// 回调函数 - 复制
func onCopy(_: Int64): Unit {
    if (let Some(textEdit) <- g_textEdit) {
        textEdit.copy()
    }
    if (let Some(statusBar) <- g_statusBar) {
        statusBar.showMessage("已复制")
    }
}

// 回调函数 - 粘贴
func onPaste(_: Int64): Unit {
    if (let Some(textEdit) <- g_textEdit) {
        textEdit.paste()
    }
    if (let Some(statusBar) <- g_statusBar) {
        statusBar.showMessage("已粘贴")
    }
}

// 回调函数 - 全选
func onSelectAll(_: Int64): Unit {
    if (let Some(textEdit) <- g_textEdit) {
        textEdit.selectAll()
    }
    if (let Some(statusBar) <- g_statusBar) {
        statusBar.showMessage("已全选")
    }
}

// 回调函数 - 清空
func onClear(_: Int64): Unit {
    if (let Some(textEdit) <- g_textEdit) {
        textEdit.clear()
    }
    if (let Some(statusBar) <- g_statusBar) {
        statusBar.showMessage("已清空")
    }
}

// 回调函数 - 关于
func onAbout(_: Int64): Unit {
    QMessageBox.information(0, "关于", "CJQT6 记事本 v1.0\n\n仓颉语言 Qt6 封装库示例程序\n\n功能:\n- 文件: 新建、打开、保存、另存为、退出\n- 编辑: 剪切、复制、粘贴、全选、清空\n- 帮助: 关于")
}

main(): Int32 {
    // 创建应用 (必须先创建)
    let app = QApplication()
    g_app = Some(app)
    
    // 创建主窗口
    let window = QMainWindow()
    g_window = Some(window)
    
    // 创建文本编辑区
    let textEdit = QTextEdit()
    g_textEdit = Some(textEdit)
    window.setCentralWidget(textEdit.getPtr())
    
    // 创建状态栏
    let statusBar = QStatusBar()
    g_statusBar = Some(statusBar)
    statusBar.showMessage("就绪 - CJQT6 记事本")
    window.setStatusBar(statusBar.getPtr())
    
    // 创建菜单栏
    let menuBar = QMenuBar()
    
    // ========== 文件菜单 ==========
    let fileMenu = menuBar.addMenu("文件(&F)")
    
    let newAction = QAction("新建(&N)")
    newAction.setShortcut("Ctrl+N")
    newAction.setOnTriggered({ _: Int64 => onNew(0) })
    
    let openAction = QAction("打开(&O)...")
    openAction.setShortcut("Ctrl+O")
    openAction.setOnTriggered({ _: Int64 => onOpen(0) })
    
    let saveAction = QAction("保存(&S)")
    saveAction.setShortcut("Ctrl+S")
    saveAction.setOnTriggered({ _: Int64 => onSave(0) })
    
    let saveAsAction = QAction("另存为(&A)...")
    saveAsAction.setOnTriggered({ _: Int64 => onSaveAs(0) })
    
    let exitAction = QAction("退出(&X)")
    exitAction.setShortcut("Ctrl+Q")
    exitAction.setOnTriggered({ _: Int64 => onExit(0) })
    
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
    cutAction.setOnTriggered({ _: Int64 => onCut(0) })
    
    let copyAction = QAction("复制(&C)")
    copyAction.setShortcut("Ctrl+C")
    copyAction.setOnTriggered({ _: Int64 => onCopy(0) })
    
    let pasteAction = QAction("粘贴(&V)")
    pasteAction.setShortcut("Ctrl+V")
    pasteAction.setOnTriggered({ _: Int64 => onPaste(0) })
    
    let selectAllAction = QAction("全选(&A)")
    selectAllAction.setShortcut("Ctrl+A")
    selectAllAction.setOnTriggered({ _: Int64 => onSelectAll(0) })
    
    let clearAction = QAction("清空")
    clearAction.setOnTriggered({ _: Int64 => onClear(0) })
    
    editMenu.addActionPtr(cutAction.getPtr())
    editMenu.addActionPtr(copyAction.getPtr())
    editMenu.addActionPtr(pasteAction.getPtr())
    editMenu.addSeparator()
    editMenu.addActionPtr(selectAllAction.getPtr())
    editMenu.addActionPtr(clearAction.getPtr())
    
    // ========== 帮助菜单 ==========
    let helpMenu = menuBar.addMenu("帮助(&H)")
    
    let aboutAction = QAction("关于(&A)...")
    aboutAction.setOnTriggered({ _: Int64 => onAbout(0) })
    
    helpMenu.addActionPtr(aboutAction.getPtr())
    
    // 设置菜单栏到主窗口
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
    window.addToolBar(toolBar.getPtr())
    
    // 设置窗口属性
    window.resize(800, 600)
    
    // 显示窗口
    window.show()
    
    // 运行应用
    let result = app.exec()
    
    // 清理资源
    textEdit.delete()
    window.delete()
    
    return result
}
