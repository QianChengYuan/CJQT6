# CJQT6 菜单与对话框模块

本模块包含当前源码中实际支持的菜单、工具栏、状态栏、主窗口与对话框 API。

## 主窗口与菜单

### QMainWindow

```cangjie
import cjqt6.menu.*

let window = QMainWindow()
window.setTitle("主窗口")
window.resize(800, 600)
window.show()
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `setTitle(title: String)` | 设置窗口标题 |
| `show()` / `hide()` | 显示/隐藏窗口 |
| `resize(width: Int32, height: Int32)` | 设置窗口大小 |
| `setMenuBar(menuBarPtr: Int64)` | 设置菜单栏 |
| `addToolBar(toolBarPtr: Int64)` | 添加工具栏 |
| `setStatusBar(statusBarPtr: Int64)` | 设置状态栏 |
| `setCentralWidget(widgetPtr: Int64)` | 设置中心控件 |
| `getPtr(): Int64` | 获取底层指针 |
| `delete()` | 释放资源 |

### QMenuBar

```cangjie
let menuBar = QMenuBar()
let fileMenu = menuBar.addMenu("文件(&F)")
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `addMenu(title: String): QMenu` | 添加顶层菜单 |
| `getPtr(): Int64` | 获取底层指针 |
| `delete()` | 释放资源 |

### QMenu

```cangjie
let fileMenu = QMenu("文件(&F)")
let newAction = QAction("新建(&N)")
newAction.setShortcut("Ctrl+N")
fileMenu.addActionPtr(newAction.getPtr())
fileMenu.addSeparator()
let recentMenu = fileMenu.addMenu("最近文件")
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init(title: String)` | 创建菜单 |
| `addAction(text: String): QAction` | 添加文本动作 |
| `addActionPtr(actionPtr: Int64)` | 添加已存在的动作 |
| `addSeparator()` | 添加分隔符 |
| `addMenu(title: String): QMenu` | 添加子菜单 |
| `setTitle(title: String)` | 设置菜单标题 |
| `getPtr(): Int64` | 获取底层指针 |
| `delete()` | 释放资源 |

### QAction

```cangjie
let openAction = QAction("打开(&O)...")
openAction.setShortcut("Ctrl+O")
openAction.setCheckable(true)
openAction.setOnTriggered({ => println("triggered") })
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init(text: String)` | 创建动作 |
| `setText(text: String)` / `text(): String` | 设置/获取文本 |
| `setShortcut(shortcut: String)` | 设置快捷键 |
| `setCheckable(checkable: Bool)` / `isCheckable(): Bool` | 设置/获取是否可勾选 |
| `setChecked(checked: Bool)` / `isChecked(): Bool` | 设置/获取勾选状态 |
| `setEnabled(enabled: Bool)` / `isEnabled(): Bool` | 设置/获取启用状态 |
| `setVisible(visible: Bool)` / `isVisible(): Bool` | 设置/获取可见性 |
| `setOnTriggered(callback: VoidCallback)` | 设置触发回调 |
| `disconnect()` | 断开触发信号 |
| `getPtr(): Int64` | 获取底层指针 |
| `delete()` | 释放资源 |

### QToolBar

```cangjie
let toolBar = QToolBar("工具栏")
toolBar.addAction(newAction.getPtr())
toolBar.addSeparator()
toolBar.addAction(openAction.getPtr())
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init(title: String)` / `init()` | 创建工具栏 |
| `addAction(actionPtr: Int64)` | 添加动作 |
| `addSeparator()` | 添加分隔符 |
| `addWidget(widgetPtr: Int64)` | 添加控件 |
| `setMovable(movable: Bool)` | 设置是否可移动 |
| `getPtr(): Int64` | 获取底层指针 |
| `delete()` | 释放资源 |

### QStatusBar

```cangjie
let statusBar = QStatusBar()
statusBar.showMessage("就绪")
statusBar.showMessageWithTimeout("保存成功", 2000)
statusBar.clearMessage()
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `showMessage(message: String)` | 显示消息 |
| `showMessageWithTimeout(message: String, timeout: Int32)` | 显示消息并指定超时 |
| `clearMessage()` | 清除消息 |
| `addWidget(widgetPtr: Int64)` | 添加控件 |
| `addWidgetWithStretch(widgetPtr: Int64, stretch: Int32)` | 添加控件并指定伸缩比例 |
| `getPtr(): Int64` | 获取底层指针 |
| `delete()` | 释放资源 |

---

## 对话框

### QMessageBox - 消息对话框

```cangjie
import cjqt6.dialogs.*

QMessageBox.information(0, "提示", "操作成功！")
QMessageBox.warning(0, "警告", "请注意！")
QMessageBox.critical(0, "错误", "发生错误！")
let result = QMessageBox.question(0, "确认", "确定要删除吗？")
if (result) {
    println("用户点击了是")
}
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `information(parent: Int64, title: String, text: String)` | 信息对话框 |
| `warning(parent: Int64, title: String, text: String)` | 警告对话框 |
| `critical(parent: Int64, title: String, text: String)` | 错误对话框 |
| `question(parent: Int64, title: String, text: String): Bool` | 确认对话框 |

### QFileDialog - 文件对话框

```cangjie
import cjqt6.dialogs.*

let filePath = QFileDialog.getOpenFileName(0, "选择文件", "所有文件 (*.*)")
let filePaths = QFileDialog.getOpenFileNames(0, "选择文件", "音频文件 (*.mp3 *.wav)")
let savePath = QFileDialog.getSaveFileName(0, "保存文件", "*.txt")
let dirPath = QFileDialog.getExistingDirectory(0, "选择目录")
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `getOpenFileName(parent: Int64, title: String, filter: String): String` | 选择单个文件 |
| `getOpenFileNames(parent: Int64, title: String, filter: String): String` | 选择多个文件，返回用换行符分隔的字符串 |
| `getSaveFileName(parent: Int64, title: String, filter: String): String` | 保存文件对话框 |
| `getExistingDirectory(parent: Int64, title: String): String` | 选择目录 |

### QInputDialog - 输入对话框

```cangjie
import cjqt6.dialogs.*

let name = QInputDialog.getText(0, "输入姓名", "请输入姓名:", "")
let (text, ok) = QInputDialog.getTextWithResult(0, "输入", "请输入:", "")
let age = QInputDialog.getInt(0, "输入年龄", "请输入年龄:", 18, 0, 150)
let (value, okAge) = QInputDialog.getIntWithResult(0, "年龄", "请输入年龄:", 18, 0, 150)
let price = QInputDialog.getDouble(0, "输入价格", "请输入价格:", 0.0, 0, 10000)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `getText(parent: Int64, title: String, label: String, defaultText: String): String` | 获取文本输入 |
| `getTextWithResult(parent: Int64, title: String, label: String, defaultText: String): (String, Bool)` | 获取文本输入，并返回确认状态 |
| `getInt(parent: Int64, title: String, label: String, value: Int32, min: Int32, max: Int32): Int32` | 获取整数输入 |
| `getIntWithResult(parent: Int64, title: String, label: String, value: Int32, min: Int32, max: Int32): (Int32, Bool)` | 获取整数输入，并返回确认状态 |
| `getDouble(parent: Int64, title: String, label: String, value: Float64, min: Float64, max: Float64): Float64` | 获取浮点数输入 |

### QColorDialog - 颜色选择对话框

```cangjie
import cjqt6.dialogs.*

let color = QColorDialog.getColor(0, "选择颜色")
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `getColor(parent: Int64, title: String): String` | 获取颜色，返回十六进制颜色字符串 |

### QFontDialog - 字体选择对话框

```cangjie
import cjqt6.dialogs.*

let fontName = QFontDialog.getFontName(0, "选择字体")
let fontSize = QFontDialog.getFontSize(0, "选择字号")
let fontInfo = QFontDialog.getFont(0, "选择字体")
let fontInfoWithDefault = QFontDialog.getFontWithDefault(0, "选择字体", "Arial", 12, false, false)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `getFontName(parent: Int64, title: String): String` | 获取字体名称 |
| `getFontSize(parent: Int64, title: String): Int32` | 获取字体大小 |
| `getFont(parent: Int64, title: String): Option<QFontInfo>` | 获取完整字体信息 |
| `getFontWithDefault(parent: Int64, title: String, defaultFamily: String, defaultSize: Int32, defaultBold: Bool, defaultItalic: Bool): Option<QFontInfo>` | 使用默认值获取字体信息 |

**QFontInfo 属性**:
| 属性 | 类型 | 说明 |
|------|------|------|
| `family` | `String` | 字体名称 |
| `size` | `Int32` | 字体大小 |
| `bold` | `Bool` | 是否粗体 |
| `italic` | `Bool` | 是否斜体 |

### QProgressDialog - 进度对话框

```cangjie
import cjqt6.dialogs.*

let progress = QProgressDialog(0, "正在处理...", "取消", 0, 100)
progress.setValue(50)
progress.setWindowTitle("进度")
progress.show()
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init(parent: Int64, labelText: String, cancelButtonText: String, minimum: Int32, maximum: Int32)` | 创建进度对话框 |
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
| `show()` / `hide()` | 显示/隐藏对话框 |
| `cancel()` | 取消操作 |
| `reset()` | 重置进度 |
| `delete()` | 释放资源 |
