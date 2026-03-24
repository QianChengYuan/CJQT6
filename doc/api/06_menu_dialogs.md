# CJQT6 菜单与对话框模块

本模块包含菜单、工具栏和对话框控件。

## 主窗口与菜单

### QMainWindow

主窗口，提供菜单栏、工具栏、状态栏的标准布局。

```cangjie
import CJQT6.menu.*

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
import CJQT6.dialogs.*

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
```
