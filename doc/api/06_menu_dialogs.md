# CJQT6 菜单与对话框模块

本模块包含菜单、工具栏和对话框控件。

## 主窗口与菜单

### QMainWindow

主窗口，提供菜单栏、工具栏、状态栏的标准布局。

```cangjie
import cjqt6.menu.*

let window = QMainWindow()
window.setWindowTitle("主窗口")
window.resize(800, 600)

// 设置中心控件
window.setCentralWidget(textEdit.getPtr())

// 设置菜单栏
window.setMenuBar(menuBar.getPtr())

// 设置状态栏
window.setStatusBar(statusBar.getPtr())

// 添加工具栏
window.addToolBar(toolBar.getPtr())
```

**QMainWindow 方法**:
| 方法 | 说明 |
|------|------|
| `setWindowTitle(title: String)` | 设置窗口标题 |
| `setCentralWidget(ptr: Int64)` | 设置中心控件 |
| `setMenuBar(ptr: Int64)` | 设置菜单栏 |
| `setStatusBar(ptr: Int64)` | 设置状态栏 |
| `addToolBar(ptr: Int64)` | 添加工具栏 |
| `resize(width: Int32, height: Int32)` | 设置大小 |
| `show()` | 显示窗口 |

### QMenuBar

菜单栏，包含多个菜单。

```cangjie
let menuBar = QMenuBar()

// 添加菜单
let fileMenu = menuBar.addMenu("文件(&F)")
let editMenu = menuBar.addMenu("编辑(&E)")
let helpMenu = menuBar.addMenu("帮助(&H)")
```

### QMenu

菜单，包含多个菜单项。

```cangjie
let fileMenu = QMenu("文件(&F)")

// 添加动作
let newAction = QAction("新建(&N)")
newAction.setShortcut("Ctrl+N")
fileMenu.addActionPtr(newAction.getPtr())

// 添加分隔符
fileMenu.addSeparator()

// 添加子菜单
let recentMenu = fileMenu.addMenu("最近文件")
```

**QMenu 方法**:
| 方法 | 说明 |
|------|------|
| `init(title: String)` | 创建菜单 |
| `addActionPtr(ptr: Int64)` | 添加动作 |
| `addSeparator()` | 添加分隔符 |
| `addMenu(title: String): QMenu` | 添加子菜单 |
| `clear()` | 清空菜单 |

### QAction

菜单动作，表示一个菜单项或工具栏按钮。

```cangjie
let openAction = QAction("打开(&O)...")
openAction.setShortcut("Ctrl+O")
openAction.setOnTriggered({ _: Int64 =>
    // 打开文件逻辑
})
```

**QAction 方法**:
| 方法 | 说明 |
|------|------|
| `init(text: String)` | 创建动作 |
| `setText(text: String)` | 设置文本 |
| `setShortcut(key: String)` | 设置快捷键 |
| `setCheckable(checkable: Bool)` | 设置可勾选 |
| `setChecked(checked: Bool)` | 设置勾选状态 |
| `isEnabled(): Bool` | 是否启用 |
| `setEnabled(enabled: Bool)` | 设置启用状态 |
| `setOnTriggered(callback: VoidCallback)` | 设置触发回调 |
| `disconnect()` | 断开信号连接 |
| `getPtr(): Int64` | 获取指针 |

### QToolBar

工具栏，包含快捷操作按钮。

```cangjie
let toolBar = QToolBar()
toolBar.addAction(newAction.getPtr())
toolBar.addAction(openAction.getPtr())
toolBar.addSeparator()
toolBar.addAction(saveAction.getPtr())
```

### QStatusBar

状态栏，显示状态信息。

```cangjie
let statusBar = QStatusBar()
statusBar.showMessage("就绪")
window.setStatusBar(statusBar.getPtr())
```

**QStatusBar 方法**:
| 方法 | 说明 |
|------|------|
| `showMessage(text: String)` | 显示临时消息 |
| `showMessage(text: String, timeout: Int32)` | 显示消息指定毫秒 |
| `clearMessage()` | 清除消息 |

---

## 对话框

### QMessageBox - 消息对话框

```cangjie
import cjqt6.dialogs.*

// 信息提示
QMessageBox.information(0, "提示", "操作成功！")

// 警告
QMessageBox.warning(0, "警告", "请注意！")

// 错误
QMessageBox.critical(0, "错误", "发生错误！")

// 询问
let result = QMessageBox.question(0, "确认", "确定要删除吗？")
if (result) {
    // 用户点击了"是"
}
```

### QFileDialog - 文件对话框

```cangjie
// 打开文件
let filePath = QFileDialog.getOpenFileName(0, "选择文件", "所有文件 (*.*)")
if (filePath.isNotEmpty()) {
    println("选择了: ${filePath}")
}

// 打开多个文件
let filePaths = QFileDialog.getOpenFileNames(0, "选择文件", "音频文件 (*.mp3 *.wav)")
for (path in filePaths) {
    println("文件: ${path}")
}

// 保存文件
let savePath = QFileDialog.getSaveFileName(0, "保存文件", "*.txt")

// 选择目录
let dirPath = QFileDialog.getExistingDirectory(0, "选择目录")
```

**方法**:
| 方法 | 说明 |
|------|------|
| `getOpenFileName(parent, title, filter): String` | 选择单个文件 |
| `getOpenFileNames(parent, title, filter): Array<String>` | 选择多个文件 |
| `getSaveFileName(parent, title, filter): String` | 保存文件对话框 |
| `getExistingDirectory(parent, title): String` | 选择目录 |

### QInputDialog - 输入对话框

```cangjie
// 获取文本输入
let name = QInputDialog.getText(0, "输入姓名", "请输入姓名:", "")
if (name.size > 0) {
    println("输入了: ${name}")
}

// 获取整数输入 (返回Int32最小值表示取消)
let age = QInputDialog.getInt(0, "输入年龄", "请输入年龄:", 18, 0, 150)

// 获取浮点数输入 (返回NaN表示取消)
let price = QInputDialog.getDouble(0, "输入价格", "请输入价格:", 0.0, 0, 10000)

// 带确认状态的输入
let (text, ok) = QInputDialog.getTextWithResult(0, "输入", "请输入:", "")
if (ok) {
    println("输入了: ${text}")
}

let (age, okAge) = QInputDialog.getIntWithResult(0, "年龄", "请输入年龄:", 18, 0, 150)
if (okAge) {
    println("年龄: ${age}")
}
```

**QInputDialog 方法**:
| 方法 | 说明 |
|------|------|
| `getText(parent, title, label, defaultText): String` | 获取文本输入，空字符串表示取消 |
| `getTextWithResult(parent, title, label, defaultText): (String, Bool)` | 获取文本输入，返回(文本, 是否确认) |
| `getInt(parent, title, label, value, min, max): Int32` | 获取整数输入，最小值表示取消 |
| `getIntWithResult(parent, title, label, value, min, max): (Int32, Bool)` | 获取整数输入，返回(值, 是否确认) |
| `getDouble(parent, title, label, value, min, max): Float64` | 获取浮点数输入，NaN表示取消 |

### QColorDialog - 颜色选择对话框

```cangjie
let color = QColorDialog.getColor(0, "选择颜色")
if (color.isNotEmpty()) {
    println("选择了颜色: ${color}")  // 返回十六进制颜色字符串，如 "#FF0000"
}
```

**QColorDialog 方法**:
| 方法 | 说明 |
|------|------|
| `getColor(parent: Int64, title: String): String` | 获取颜色，返回十六进制字符串(如"#FF0000")，空字符串表示取消 |

### QFontDialog - 字体选择对话框

```cangjie
// 获取字体名称
let fontName = QFontDialog.getFontName(0, "选择字体")
if (fontName.isNotEmpty()) {
    println("选择了字体: ${fontName}")
}

// 获取字体大小
let fontSize = QFontDialog.getFontSize(0, "选择字号")
if (fontSize > 0) {
    println("字号: ${fontSize}")
}

// 获取完整字体信息
let fontInfo = QFontDialog.getFont(0, "选择字体")
match (fontInfo) {
    case Some(info) =>
        println("字体: ${info.family}, 大小: ${info.size}, 粗体: ${info.bold}, 斜体: ${info.italic}")
    case None =>
        println("用户取消了选择")
}

// 使用默认值
let result = QFontDialog.getFontWithDefault(0, "选择字体", "Arial", 12, false, false)
```

**QFontDialog 方法**:
| 方法 | 说明 |
|------|------|
| `getFontName(parent: Int64, title: String): String` | 获取字体名称，空字符串表示取消 |
| `getFontSize(parent: Int64, title: String): Int32` | 获取字体大小，-1表示取消 |
| `getFont(parent: Int64, title: String): Option<QFontInfo>` | 获取完整字体信息（返回QFontInfo对象） |
| `getFontWithDefault(parent, title, defaultFamily, defaultSize, defaultBold, defaultItalic): Option<QFontInfo>` | 使用默认值获取字体信息 |

**QFontInfo 属性**:
| 属性 | 类型 | 说明 |
|------|------|------|
| `family` | `String` | 字体名称 |
| `size` | `Int32` | 字体大小 |
| `bold` | `Bool` | 是否粗体 |
| `italic` | `Bool` | 是否斜体 |

### QProgressDialog - 进度对话框

```cangjie
let progress = QProgressDialog(0, "正在处理...", "取消", 0, 100)
progress.setWindowTitle("进度")
progress.setValue(50)

if (progress.wasCanceled()) {
    println("用户取消了操作")
}

progress.reset()   // 重置进度
progress.cancel()  // 取消操作
progress.delete()  // 释放资源
```

**QProgressDialog 方法**:
| 方法 | 说明 |
|------|------|
| `init(parent, labelText, cancelButtonText, minimum, maximum)` | 创建进度对话框 |
| `setValue(value: Int32)` | 设置当前进度 |
| `value(): Int32` | 获取当前进度 |
| `setMinimum(minimum: Int32)` | 设置最小值 |
| `setMaximum(maximum: Int32)` | 设置最大值 |
| `setLabelText(text: String)` | 设置提示文本 |
| `setCancelButtonText(text: String)` | 设置取消按钮文本 |
| `setWindowTitle(title: String)` | 设置窗口标题 |
| `setAutoClose(autoClose: Bool)` | 设置是否自动关闭 |
| `setAutoReset(autoReset: Bool)` | 设置是否自动重置 |
| `wasCanceled(): Bool` | 用户是否点击了取消 |
| `show()` | 显示对话框 |
| `hide()` | 隐藏对话框 |
| `cancel()` | 取消操作 |
| `reset()` | 重置进度 |
| `delete()` | 释放资源 |
