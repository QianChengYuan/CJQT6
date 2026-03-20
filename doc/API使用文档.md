# CJQT6 控件API使用文档

## 目录

1. [应用程序核心](#应用程序核心)
2. [基础部件](#基础部件)
3. [输入控件](#输入控件)
4. [选择控件](#选择控件)
5. [数值控件](#数值控件)
6. [容器控件](#容器控件)
7. [布局管理](#布局管理)
8. [表格控件](#表格控件)
9. [列表控件](#列表控件)
10. [树形控件](#树形控件)
11. [菜单与工具栏](#菜单与工具栏)
12. [对话框](#对话框)
13. [事件处理](#事件处理)
14. [绘图模块](#绘图模块)
15. [进程管理](#进程管理)
16. [QML模块](#qml模块)
17. [多媒体模块](#多媒体模块)
18. [打印模块](#打印模块)
19. [信号与槽](#信号与槽)
20. [资源管理](#资源管理)

---

## 资源管理

### 自动清理机制

所有控件类都实现了终结器 `~init`，垃圾回收时会自动释放资源。**无需手动调用 `delete()`**。

```cangjie
main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    let label = QLabel()
    let btn = QPushButton()
    // ... 创建更多控件 ...
    window.show()
    let result = app.exec()
    // 不需要手动清理，终结器自动处理
    return result
}
```

### 手动释放（可选）

如果需要**立即释放**资源，可以调用 `close()` 或 `delete()`：

```cangjie
// 方式1：close() - 实现 QtResource 接口
widget.close()

// 方式2：delete() - 直接释放
widget.delete()
```

### try-with-resources 模式

对于需要精确控制资源生命周期的场景：

```cangjie
try (widget = QWidget()) {
    widget.show()
    // ... 使用 widget ...
}  // 自动调用 close()
```

### QtResource 接口

```cangjie
interface QtResource {
    func isClosed(): Bool    // 检查资源是否已释放
    func close(): Unit       // 释放资源
}
```

### 异常处理

```cangjie
import CJQT6.core.*

// 安全执行操作
let result = safeExecute(widget, { w =>
    w.setText("Hello")  // 如果 widget 已释放，返回 false
})

// 安全运行代码块
let success = safeRun({ =>
    // 可能抛出异常的代码
})
```

**异常类型**：
| 异常 | 说明 |
|------|------|
| `QtException` | 基类异常 |
| `ResourceDisposedException` | 资源已释放 |
| `NullPointerException` | 空指针 |
| `CreateFailedException` | 创建失败 |

---

## 应用程序核心

### QApplication

应用程序主类，每个Qt程序必须有且仅有一个实例。

```cangjie
import CJQT6.core.*

main(): Int32 {
    let app = QApplication()
    
    // 加载Qt内置翻译（中文）
    app.loadQtTranslation("zh_CN")
    
    // 或切换语言
    app.switchLanguage("zh_CN")  // 中文
    // app.switchLanguage("en_US")  // 英文
    
    // 创建窗口和控件...
    
    let result = app.exec()  // 进入事件循环
    // 不需要手动清理，终结器自动处理
    return result
}
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建应用程序实例 |
| `exec(): Int32` | 进入事件循环，返回退出码 |
| `quit()` | 退出应用程序 |
| `close()` | 释放资源（实现 QtResource 接口） |
| `loadQtTranslation(locale: String)` | 加载Qt内置翻译文件 |
| `switchLanguage(locale: String)` | 切换语言环境 |
| `locale(): String` | 获取当前语言环境 |
| `systemLocale(): String` | 获取系统语言环境 |

**常用语言代码** (Language类):
```cangjie
Language.ChineseSimplified   // "zh_CN" - 简体中文
Language.ChineseTraditional  // "zh_TW" - 繁体中文
Language.English             // "en_US" - 英语
Language.Japanese            // "ja_JP" - 日语
Language.Korean              // "ko_KR" - 韩语
Language.German              // "de_DE" - 德语
Language.French              // "fr_FR" - 法语
Language.Spanish             // "es_ES" - 西班牙语
```

### QApp 静态类

提供静态方法访问应用程序功能。

```cangjie
import CJQT6.core.*

// 静态退出应用
QApp.quit()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `quit()` | 静态方法退出应用程序 |

### QWidget

基础窗口部件，所有控件的基类。

```cangjie
let window = QWidget()
window.setTitle("窗口标题")
window.resize(800, 600)
window.setLayout(layout.getPtr())
window.show()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setTitle(title: String)` | 设置窗口标题 |
| `resize(width: Int32, height: Int32)` | 设置窗口大小 |
| `setGeometry(x, y, width, height)` | 设置位置和大小 |
| `setLayout(layoutPtr: Int64)` | 设置布局 |
| `show()` | 显示窗口 |
| `hide()` | 隐藏窗口 |
| `getPtr(): Int64` | 获取指针（用于布局） |
| `close()` | 释放资源 |
| `isClosed(): Bool` | 检查是否已释放 |

### QTimer

定时器，用于周期性执行任务。

```cangjie
let timer = QTimer()
timer.setInterval(1000)  // 1秒

let timerCallback: VoidCallback = { =>
    println("定时器触发！")
}
timer.setTimeout(timerCallback)
timer.start()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setInterval(ms: Int32)` | 设置间隔（毫秒） |
| `start()` | 启动定时器 |
| `stop()` | 停止定时器 |
| `setTimeout(callback: VoidCallback)` | 设置超时回调 |
| `disconnect()` | 断开信号连接 |
| `delete()` | 释放资源 |

---

## 基础部件

### QLabel - 标签

```cangjie
let label = QLabel()
label.setText("文本内容")
label.setAlignment(AlignCenter)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` | 设置文本 |
| `setAlignment(alignment: Int32)` | 设置对齐方式 |

**对齐常量** (CJQT6.gui):
```cangjie
AlignLeft      // 左对齐
AlignRight     // 右对齐
AlignHCenter   // 水平居中
AlignTop       // 顶部对齐
AlignBottom    // 底部对齐
AlignVCenter   // 垂直居中
AlignCenter    // 居中
```

### QPushButton - 按钮

```cangjie
let btn = QPushButton()
btn.setText("点击我")

// 设置点击回调
let callback: VoidCallback = { =>
    println("按钮被点击！")
}
btn.setOnClick(callback)

// 设置图标
btn.setIcon("/path/to/icon.png")  // 从文件加载
btn.setIconSize(24, 24)           // 设置图标大小

// 使用 Qt 标准图标
btn.setStandardIcon(StandardIcon.Open)
btn.setStandardIcon(StandardIcon.Save)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` | 设置按钮文本 |
| `setOnClick(callback: VoidCallback)` | 设置点击回调 |
| `setIcon(path: String)` | 从文件加载图标 |
| `setIconSize(w: Int32, h: Int32)` | 设置图标大小 |
| `setStandardIcon(type: Int32)` | 使用 Qt 标准图标 |
| `disconnect()` | 断开信号连接 |

**标准图标常量** (StandardIcon):
```cangjie
Open          // 打开
Save          // 保存
Close         // 关闭
Apply         // 应用
Cancel        // 取消
Help          // 帮助
File          // 文件
Folder        // 文件夹
ArrowUp       // 向上箭头
ArrowDown     // 向下箭头
ArrowLeft     // 向左箭头
ArrowRight    // 向右箭头
MediaPlay     // 播放
MediaPause    // 暂停
MediaStop     // 停止
Yes           // 是
No            // 否
```

---

## 输入控件

### QLineEdit - 单行文本输入

```cangjie
let edit = QLineEdit()
edit.setPlaceholder("请输入...")
edit.setMaxLength(100)
edit.setEchoMode(Password)  // 密码模式

// 输入掩码 - 格式化输入
edit.setInputMask(InputMask.IP)        // IP地址: 000.000.000.000
edit.setInputMask(InputMask.MAC)       // MAC地址: HH:HH:HH:HH:HH:HH
edit.setInputMask(InputMask.Date)      // 日期: 9999-99-99
edit.setInputMask(InputMask.LicenseKey) // 密钥: XXXXX-XXXXX-...

// 自定义掩码
edit.setInputMask("(999) 999-9999;_")  // 电话号码

// 样式设置
edit.setFrame(false)                   // 无边框
edit.setAlignment(Alignment.Center)    // 居中对齐
edit.setStyleSheet("background-color: #f0f0f0;")

// 文本选择
edit.selectAll()
if (edit.hasSelectedText()) {
    let selected = edit.selectedText()
}

// 密码切换按钮（嵌入输入框内部）
edit.setEchoMode(2)  // Password 模式
edit.addPasswordToggleAction({ =>
    // 切换密码可见性
})
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` | 设置文本 |
| `text(): String` | 获取文本 |
| `setPlaceholder(text: String)` | 设置占位文本 |
| `setMaxLength(len: Int32)` | 设置最大长度 |
| `setReadOnly(readonly: Bool)` | 设置只读 |
| `setEchoMode(mode: Int32)` | 设置回显模式 |
| `setInputMask(mask: String)` | 设置输入掩码 |
| `setFrame(visible: Bool)` | 设置边框显示 |
| `setAlignment(alignment: Int32)` | 设置文本对齐 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `selectAll()` | 全选文本 |
| `hasSelectedText(): Bool` | 是否有选中文本 |
| `selectedText(): String` | 获取选中文本 |
| `setFocus()` | 设置焦点 |
| `addPasswordToggleAction(callback)` | 添加密码切换按钮 |
| `setPasswordToggleIcon(visible: Bool)` | 设置密码切换按钮图标 |
| `clear()` | 清空 |
| `setOnTextChanged(callback: CStringCallback)` | 文本变化回调 |
| `disconnect()` | 断开信号连接 |

**回显模式常量**:
```cangjie
Normal             // 正常
NoEcho             // 不显示
Password           // 密码
PasswordEchoOnEdit // 编辑时显示
```

**输入掩码预设** (InputMask):
```cangjie
IP          // "000.000.000.000;_" - IP地址
MAC         // "HH:HH:HH:HH:HH:HH;_" - MAC地址
Date        // "9999-99-99;_" - 日期
Time        // "99:99:99;_" - 时间
Phone       // "(999) 999-9999;_" - 电话
LicenseKey  // ">AAAAA-AAAAA-AAAAA-AAAAA-AAAAA;#" - 软件密钥
```

**掩码字符说明**:
| 字符 | 说明 |
|------|------|
| `0` | 数字，必填 |
| `9` | 数字，可选 |
| `A` | 字母，必填 |
| `a` | 字母，可选 |
| `H` | 十六进制字符，必填 |
| `h` | 十六进制字符，可选 |
| `>` | 后续字符转大写 |
| `<` | 后续字符转小写 |
| `!` | 取消大小写转换 |
| `;` | 分隔符，后跟占位字符 |
| `setReadOnly(readonly: Bool)` | 设置只读 |
| `setEchoMode(mode: Int32)` | 设置回显模式 |
| `clear()` | 清空 |
| `setOnTextChanged(callback: CStringCallback)` | 文本变化回调 |
| `disconnect()` | 断开信号连接 |

**回显模式常量**:
```cangjie
Normal      // 正常
NoEcho      // 不显示
Password    // 密码
PasswordEchoOnEdit  // 编辑时显示
```

### QTextEdit - 多行文本编辑

```cangjie
let textEdit = QTextEdit()
textEdit.setText("多行文本\n第二行")
textEdit.setReadOnly(true)
```

**基础方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` | 设置文本 |
| `text(): String` | 获取文本 |
| `setReadOnly(readonly: Bool)` | 设置只读 |
| `clear()` | 清空 |

**扩展功能** (2026-03-18新增):
| 方法 | 说明 |
|------|------|
| `find(text: String, caseSensitive: Bool): Bool` | 查找文本 |
| `findNext(text: String, caseSensitive: Bool): Bool` | 查找下一个 |
| `findPrev(text: String, caseSensitive: Bool): Bool` | 查找上一个 |
| `replace(text: String)` | 替换当前选中 |
| `replaceAll(oldText: String, newText: String, caseSensitive: Bool): Int32` | 替换全部，返回替换数量 |
| `currentLine(): Int32` | 获取当前行号 |
| `currentColumn(): Int32` | 获取当前列号 |
| `lineCount(): Int32` | 获取总行数 |
| `characterCount(): Int64` | 获取总字符数 |
| `goToLine(line: Int32): Bool` | 跳转到指定行 |
| `print(printerPtr: Int64)` | 打印文档 |
| `undo()` | 撤销 |
| `redo()` | 重做 |
| `canUndo(): Bool` | 是否可撤销 |
| `canRedo(): Bool` | 是否可重做 |
| `isModified(): Bool` | 文档是否已修改 |
| `setModified(modified: Bool)` | 设置修改状态 |
| `setLineWrapMode(mode: Int32)` | 设置自动换行模式 |
| `lineWrapMode(): Int32` | 获取自动换行模式 |
| `setFontFamily(family: String)` | 设置字体 |
| `setFontSize(size: Int32)` | 设置字号 |
| `setFontBold(bold: Bool)` | 设置粗体 |
| `setFontItalic(italic: Bool)` | 设置斜体 |

**自动换行模式常量**:
```cangjie
NoWrap        // 不换行
WidgetWidth   // 按控件宽度换行
```

**查找替换示例**:
```cangjie
// 查找
if (textEdit.find("关键词", false)) {
    println("找到!")
}

// 替换全部
let count = textEdit.replaceAll("old", "new", false)
println("替换了 ${count} 处")

// 跳转到行
textEdit.goToLine(100)

// 获取光标位置
let line = textEdit.currentLine()
let col = textEdit.currentColumn()
println("位置: 第${line}行, 第${col}列")
```

---

## 选择控件

### QCheckBox - 复选框

```cangjie
let checkbox = QCheckBox()
checkbox.setText("选项A")
checkbox.setChecked(true)

if (checkbox.isChecked()) {
    println("已选中")
}

// 状态变化回调
let stateCallback: Int32Callback = { state: Int32 =>
    println("状态: ${state}")
}
checkbox.setOnStateChanged(stateCallback)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` | 设置文本 |
| `setChecked(checked: Bool)` | 设置选中状态 |
| `isChecked(): Bool` | 获取选中状态 |
| `setOnStateChanged(callback: Int32Callback)` | 状态变化回调 |
| `disconnect()` | 断开信号连接 |

### QRadioButton - 单选按钮

```cangjie
let radio1 = QRadioButton()
radio1.setText("选项1")
radio1.setChecked(true)

let radio2 = QRadioButton()
radio2.setText("选项2")

// 切换回调
let toggleCallback: VoidCallback = { =>
    println("单选按钮切换")
}
radio1.setOnToggled(toggleCallback)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` | 设置文本 |
| `setChecked(checked: Bool)` | 设置选中状态 |
| `isChecked(): Bool` | 获取选中状态 |
| `setOnToggled(callback: VoidCallback)` | 切换回调 |
| `disconnect()` | 断开信号连接 |

### QComboBox - 下拉框

```cangjie
let combo = QComboBox()
combo.addItem("选项1")
combo.addItem("选项2")
combo.addItem("选项3")

let currentText = combo.currentText()
let currentIndex = combo.currentIndex()

// 索引变化回调
let indexCallback: Int32Callback = { index: Int32 =>
    println("选中索引: ${index}")
}
combo.setOnCurrentIndexChanged(indexCallback)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `addItem(text: String)` | 添加项 |
| `clear()` | 清空所有项 |
| `currentText(): String` | 获取当前文本 |
| `currentIndex(): Int32` | 获取当前索引 |
| `setCurrentIndex(index: Int32)` | 设置当前索引 |
| `setOnCurrentIndexChanged(callback: Int32Callback)` | 索引变化回调 |
| `disconnect()` | 断开信号连接 |

---

## 数值控件

### QSpinBox - 整数旋转框

```cangjie
let spinBox = QSpinBox()
spinBox.setRange(0, 100)
spinBox.setValue(50)
spinBox.setSingleStep(5)

let value = spinBox.value()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setValue(value: Int32)` | 设置值 |
| `value(): Int32` | 获取值 |
| `setRange(min: Int32, max: Int32)` | 设置范围 |
| `setSingleStep(step: Int32)` | 设置步长 |
| `setOnValueChanged(callback: Int32Callback)` | 值变化回调 |
| `disconnect()` | 断开信号连接 |

### QSlider - 滑动条

```cangjie
let slider = QSlider()
slider.setRange(0, 100)
slider.setValue(50)
slider.setOrientation(Horizontal)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setValue(value: Int32)` | 设置值 |
| `value(): Int32` | 获取值 |
| `setRange(min: Int32, max: Int32)` | 设置范围 |
| `setOrientation(orientation: Int32)` | 设置方向 |
| `setOnValueChanged(callback: Int32Callback)` | 值变化回调 |
| `disconnect()` | 断开信号连接 |

**方向常量**:
```cangjie
Horizontal  // 水平
Vertical    // 垂直
```

### QProgressBar - 进度条

```cangjie
let progress = QProgressBar()
progress.setRange(0, 100)
progress.setValue(75)
progress.setTextVisible(true)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setValue(value: Int32)` | 设置值 |
| `value(): Int32` | 获取值 |
| `setRange(min: Int32, max: Int32)` | 设置范围 |
| `setTextVisible(visible: Bool)` | 是否显示文本 |

---

## 容器控件

### QGroupBox - 分组框

```cangjie
let groupBox = QGroupBox()
groupBox.setTitle("分组标题")

let innerLayout = QVBoxLayout()
// 添加控件到innerLayout...
groupBox.setLayout(innerLayout.getPtr())
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setTitle(title: String)` | 设置标题 |
| `setCheckable(checkable: Bool)` | 设置可勾选 |
| `setChecked(checked: Bool)` | 设置勾选状态 |
| `setLayout(layoutPtr: Int64)` | 设置内部布局 |

### QTabWidget - 标签页

```cangjie
let tabWidget = QTabWidget()

let page1 = QWidget()
// 配置page1...
tabWidget.addTab(page1.getPtr(), "标签1")

let page2 = QWidget()
// 配置page2...
tabWidget.addTab(page2.getPtr(), "标签2")
```

**方法**:
| 方法 | 说明 |
|------|------|
| `addTab(widgetPtr: Int64, title: String)` | 添加标签页 |
| `removeTab(index: Int32)` | 移除标签页 |
| `currentIndex(): Int32` | 获取当前索引 |
| `setCurrentIndex(index: Int32)` | 设置当前标签页 |
| `count(): Int32` | 获取标签页数量 |

### QScrollArea - 滚动区域

```cangjie
let scrollArea = QScrollArea()
scrollArea.setWidget(contentWidget.getPtr())
scrollArea.setWidgetResizable(true)
```

### QFrame - 边框容器

```cangjie
let frame = QFrame()
frame.setFrameShape(StyledPanel)
frame.setFrameShadow(Raised)
frame.setLineWidth(2)
```

**边框形状常量**:
```cangjie
NoFrame      // 无边框
Box          // 矩形框
Panel        // 面板
StyledPanel  // 样式面板
HLine        // 水平线
VLine        // 垂直线
```

**边框阴影常量**:
```cangjie
Plain   // 平面
Raised  // 凸起
Sunken  // 凹陷
```

---

## 布局管理

### QVBoxLayout - 垂直布局

```cangjie
let layout = QVBoxLayout()
layout.addWidget(label.getPtr())
layout.addWidget(button.getPtr())
layout.setSpacing(10)
layout.setMargin(20)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `addWidget(ptr: Int64)` | 添加控件 |
| `addLayout(ptr: Int64)` | 添加子布局 |
| `addStretch()` | 添加弹性空间 |
| `setSpacing(spacing: Int32)` | 设置间距 |
| `setMargin(margin: Int32)` | 设置边距 |
| `getPtr(): Int64` | 获取指针 |

### QHBoxLayout - 水平布局

```cangjie
let hLayout = QHBoxLayout()
hLayout.addWidget(btn1.getPtr())
hLayout.addWidget(btn2.getPtr())
hLayout.addStretch()
```

### QGridLayout - 网格布局

```cangjie
let grid = QGridLayout()
grid.addWidget(label1.getPtr(), 0, 0)  // 第0行第0列
grid.addWidget(edit1.getPtr(), 0, 1)   // 第0行第1列
grid.addWidget(label2.getPtr(), 1, 0)  // 第1行第0列
grid.addWidget(edit2.getPtr(), 1, 1)   // 第1行第1列

// 跨行跨列
grid.addWidgetWidgetSpan(bigWidget.getPtr(), 2, 0, 2, 2)  // 从第2行第0列开始，占2行2列
```

**方法**:
| 方法 | 说明 |
|------|------|
| `addWidget(ptr, row, col)` | 添加控件到指定位置 |
| `addWidgetSpan(ptr, row, col, rowSpan, colSpan)` | 跨行跨列添加 |
| `setSpacing(spacing: Int32)` | 设置间距 |
| `setMargin(margin: Int32)` | 设置边距 |

---

## 表格控件

### QTableWidget

```cangjie
import CJQT6.views.*

// 创建表格 (5行3列)
let table = QTableWidget(5, 3)

// 设置表头
table.setHorizontalHeaderLabel(0, "姓名")
table.setHorizontalHeaderLabel(1, "年龄")
table.setHorizontalHeaderLabel(2, "城市")

// 填充数据
table.setItem(0, 0, "张三")
table.setItem(0, 1, "25")
table.setItem(0, 2, "北京")

// 自动填充窗口宽度
table.setAutoFillWidth()

// 设置选择行为
table.setSelectionBehavior(SelectRows)
table.setSelectionMode(SingleSelection)

// 显示交替行颜色
table.setAlternatingRowColors(true)
```

**常用方法**:
| 方法 | 说明 |
|------|------|
| `setRowCount(rows: Int32)` | 设置行数 |
| `setColumnCount(cols: Int32)` | 设置列数 |
| `setHorizontalHeaderLabel(col, label)` | 设置列表头 |
| `setItem(row, col, text)` | 设置单元格内容 |
| `itemText(row, col): String` | 获取单元格内容 |
| `insertRow(row)` | 插入行 |
| `removeRow(row)` | 删除行 |
| `currentRow(): Int32` | 获取当前行 |
| `currentColumn(): Int32` | 获取当前列 |
| `clear()` | 清空表格 |
| `clearContents()` | 清空内容（保留表头） |

**列宽调整模式**:
```cangjie
table.setAutoFillWidth()                    // 所有列自动拉伸填充
table.setHorizontalHeaderStretchLastSection(true)  // 最后一列拉伸
table.setColumnResizeMode(0, Interactive)   // 指定列用户可调整
table.setColumnResizeMode(1, ResizeToContents)     // 指定列根据内容
```

**调整模式常量**:
```cangjie
Interactive        // 用户可调整
Fixed              // 固定大小
Stretch            // 自动拉伸
ResizeToContents   // 根据内容调整
```

**选择行为常量**:
```cangjie
SelectItems    // 选择项
SelectRows     // 选择行
SelectColumns  // 选择列
```

**选择模式常量**:
```cangjie
NoSelection          // 不可选择
SingleSelection      // 单选
MultiSelection       // 多选
ExtendedSelection    // 扩展选择（Ctrl/Shift）
ContiguousSelection  // 连续选择
```

---

## 列表控件

### QListWidget

列表控件，用于显示一系列可选择的项。

```cangjie
import CJQT6.views.*

let listWidget = QListWidget()
listWidget.setAlternatingRowColors(true)

// 添加项
listWidget.addItem("苹果")
listWidget.addItem("香蕉")
listWidget.addItem("橙子")

// 设置可勾选
listWidget.setItemCheckable(0, true)
listWidget.setChecked(0, true)

// 获取当前选中
let row = listWidget.currentRow()
let text = listWidget.currentItemText()
```

**常用方法**:
| 方法 | 说明 |
|------|------|
| `addItem(text: String)` | 添加项 |
| `insertItem(row: Int32, text: String)` | 在指定位置插入项 |
| `removeItem(row: Int32)` | 移除指定行 |
| `clear()` | 清空所有项 |
| `count(): Int32` | 获取项数量 |
| `currentRow(): Int32` | 获取当前选中行（-1表示无选中） |
| `setCurrentRow(row: Int32)` | 设置当前选中行 |
| `currentItemText(): String` | 获取当前选中项文本 |
| `itemText(row: Int32): String` | 获取指定行文本 |
| `setItemText(row: Int32, text: String)` | 设置指定行文本 |
| `setItemData(row: Int32, data: Int64)` | 设置项用户数据 |
| `getItemData(row: Int32): Int64` | 获取项用户数据 |

**勾选相关**:
| 方法 | 说明 |
|------|------|
| `setItemCheckable(row: Int32, checkable: Bool)` | 设置项是否可勾选 |
| `isChecked(row: Int32): Bool` | 获取项是否被勾选 |
| `setChecked(row: Int32, checked: Bool)` | 设置项勾选状态 |

**外观设置**:
| 方法 | 说明 |
|------|------|
| `setSelectionMode(mode: Int32)` | 设置选择模式 |
| `setAlternatingRowColors(enable: Bool)` | 设置交替行颜色 |
| `setSortingEnabled(enable: Bool)` | 设置是否可排序 |
| `setItemIcon(row: Int32, iconType: Int32)` | 设置项图标 |

**选择模式常量** (ListSelectionMode):
```cangjie
NoSelection          // 不可选择
SingleSelection      // 单选
MultiSelection       // 多选
ExtendedSelection    // 扩展选择（Ctrl/Shift）
ContiguousSelection  // 连续选择
```

**图标类型常量** (ListIconType):
```cangjie
None         // 无图标
Folder       // 文件夹图标
File         // 文件图标
Warning      // 警告图标
Information  // 信息图标
Critical     // 错误图标
```

---

## 树形控件

### QTreeWidget

树形控件，用于显示层次结构数据。

```cangjie
import CJQT6.views.*

let treeWidget = QTreeWidget()
treeWidget.setColumnCount(3)
treeWidget.setHeaderLabel(0, "名称")
treeWidget.setHeaderLabel(1, "类型")
treeWidget.setHeaderLabel(2, "大小")

// 添加顶级项
let root = treeWidget.addTopLevelItem("项目文件夹")
root.setText(1, "文件夹")
root.setText(2, "-")

// 添加子项
let child = root.addChild("src")
child.setText(1, "文件夹")

let file = child.addChild("main.cj")
file.setText(1, "源码")
file.setText(2, "2KB")

// 展开所有
treeWidget.expandAll()
```

**QTreeWidget 方法**:
| 方法 | 说明 |
|------|------|
| `setColumnCount(columns: Int32)` | 设置列数 |
| `setHeaderLabel(column: Int32, label: String)` | 设置表头标签 |
| `setHeaderHidden(hidden: Bool)` | 隐藏/显示表头 |
| `addTopLevelItem(text: String): QTreeWidgetItem` | 添加顶级项 |
| `insertTopLevelItem(index: Int32, item: QTreeWidgetItem)` | 插入顶级项 |
| `takeTopLevelItem(index: Int32)` | 移除顶级项 |
| `topLevelItemCount(): Int32` | 获取顶级项数量 |
| `topLevelItem(index: Int32): QTreeWidgetItem` | 获取顶级项 |
| `currentItem(): ?QTreeWidgetItem` | 获取当前选中项 |
| `setCurrentItem(item: QTreeWidgetItem)` | 设置当前选中项 |
| `expandItem(item: QTreeWidgetItem)` | 展开项 |
| `collapseItem(item: QTreeWidgetItem)` | 折叠项 |
| `expandAll()` | 展开所有 |
| `collapseAll()` | 折叠所有 |
| `clear()` | 清空 |

### QTreeWidgetItem

树形项，表示树中的一个节点。

```cangjie
// 创建项
let item = QTreeWidgetItem("节点名称")
item.setText(1, "附加信息")

// 添加子项
let child = item.addChild("子节点")

// 获取父项
let parent = item.parent()

// 用户数据
item.setData(0, 12345)
let data = item.getData(0)
```

**QTreeWidgetItem 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空项 |
| `init(text: String)` | 创建带文本的项 |
| `setText(column: Int32, text: String)` | 设置列文本 |
| `text(column: Int32): String` | 获取列文本 |
| `addChild(text: String): QTreeWidgetItem` | 添加子项并返回 |
| `addChildItem(child: QTreeWidgetItem)` | 添加子项对象 |
| `childCount(): Int32` | 获取子项数量 |
| `child(index: Int32): QTreeWidgetItem` | 获取子项 |
| `takeChild(index: Int32)` | 移除子项 |
| `parent(): ?QTreeWidgetItem` | 获取父项 |
| `setData(column: Int32, data: Int64)` | 设置用户数据 |
| `getData(column: Int32): Int64` | 获取用户数据 |
| `setExpanded(expanded: Bool)` | 设置展开状态 |
| `isExpanded(): Bool` | 是否展开 |
| `setSelected(selected: Bool)` | 设置选中状态 |
| `isSelected(): Bool` | 是否选中 |
| `setHidden(hidden: Bool)` | 设置隐藏状态 |
| `isHidden(): Bool` | 是否隐藏 |
| `setCheckState(column: Int32, state: Int32)` | 设置勾选状态 |
| `checkState(column: Int32): Int32` | 获取勾选状态 |

**勾选状态常量** (CheckState):
```cangjie
Unchecked          // 未勾选
PartiallyChecked   // 部分勾选
Checked            // 已勾选
```

---

## 菜单与工具栏

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
    // 打���文件逻辑
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
let price = QInputDialog.getDouble(0, "输入价格", "请输入价格:", 0.0, 0.0, 10000.0)
```

**QInputDialog 方法**:
| 方法 | 说明 |
|------|------|
| `getText(parent, title, label, defaultText): String` | 获取文本输入 |
| `getInt(parent, title, label, value, min, max): Int32` | 获取整数输入 |
| `getDouble(parent, title, label, value, min, max): Float64` | 获取浮点数输入 |

### QColorDialog - 颜色对话框

```cangjie
// 获取颜色 (返回十六进制字符串如 "#FF0000"，空字符串表示取消)
let color = QColorDialog.getColor(0, "选择颜色")
if (color.size > 0) {
    println("选择了颜色: ${color}")
}
```

---

## 绘图模块

绘图模块提供绑定Qt的绘图功能，包括颜色、画笔、画刷、渐变、绘图路径和绘图器。

```cangjie
import CJQT6.paint.*
```

### QColor - 颜色

```cangjie
// 创建颜色
let red = QColor(255, 0, 0)           // RGB
let transparent = QColor.rgba(255, 0, 0, 128)  // RGBA
let blue = QColor.fromName("blue")    // 从名称

// 预定义颜色
let white = Colors.white()
let black = Colors.black()
let red = Colors.red()
let green = Colors.green()
let blue = Colors.blue()
let yellow = Colors.yellow()
let cyan = Colors.cyan()
let magenta = Colors.magenta()
let gray = Colors.gray()
let lightGray = Colors.lightGray()
let darkGray = Colors.darkGray()
let transparent = Colors.transparent()
```

**QColor 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空颜色 |
| `init(r, g, b)` | 创建RGB颜色 |
| `rgba(r, g, b, a)` | 创建RGBA颜色（静态方法） |
| `fromName(name)` | 从名称创建颜色（静态方法） |
| `red(): Int32` | 获取红色分量 |
| `green(): Int32` | 获取绿色分量 |
| `blue(): Int32` | 获取蓝色分量 |
| `alpha(): Int32` | 获取透明度 |
| `setRed(r)` | 设置红色分量 |
| `setGreen(g)` | 设置绿色分量 |
| `setBlue(b)` | 设置蓝色分量 |
| `setAlpha(a)` | 设置透明度 |

### QPen - 画笔

画笔用于绘制线条和边框。

```cangjie
let pen = QPen(Colors.black())
pen.setWidth(2)
pen.setStyle(PenStyle.DashLine)
```

**QPen 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建默认画笔 |
| `init(color: QColor)` | 创建指定颜色画笔 |
| `setColor(c: QColor)` | 设置颜色 |
| `setWidth(w: Int32)` | 设置宽度 |
| `width(): Int32` | 获取宽度 |
| `setStyle(s: Int32)` | 设置样式 |

**画笔样式常量** (PenStyle):
```cangjie
NoPen      // 无线条
SolidLine  // 实线
DashLine   // 虚线
DotLine    // 点线
```

### QBrush - 画刷

画刷用于填充形状。

```cangjie
let brush = QBrush(Colors.red())

// 渐变画刷
let gradient = QLinearGradient.fromInt(0, 0, 100, 100)
gradient.setColorAt(0.0, Colors.red())
gradient.setColorAt(1.0, Colors.blue())
let gradientBrush = QBrush(gradient)
```

**QBrush 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建默认画刷 |
| `init(color: QColor)` | 创建纯色画刷 |
| `init(gradient: QLinearGradient)` | 创建渐变画刷 |
| `setColor(c: QColor)` | 设置颜色 |
| `setStyle(s: Int32)` | 设置样式 |

**画刷样式常量** (BrushStyle):
```cangjie
NoBrush       // 无填充
SolidPattern  // 纯色填充
```

### QLinearGradient - 线性渐变

```cangjie
let gradient = QLinearGradient.fromInt(0, 0, 200, 0)  // 水平渐变
gradient.setColorAt(0.0, Colors.red())     // 起点：红色
gradient.setColorAt(0.5, Colors.yellow())  // 中间：黄色
gradient.setColorAt(1.0, Colors.blue())    // 终点：蓝色
```

**QLinearGradient 方法**:
| 方法 | 说明 |
|------|------|
| `init(x1, y1, x2, y2)` | 创建渐变（Float32坐标） |
| `fromInt(x1, y1, x2, y2)` | 创建渐变（Int32坐标，静态方法） |
| `setColorAt(pos, color)` | 设置位置颜色（pos: 0.0~1.0） |

### QFont - 绘图字体

```cangjie
let font = QFont("Arial", 16)
font.setBold(true)
font.setItalic(true)
```

**QFont 方法**:
| 方法 | 说明 |
|------|------|
| `init(family: String)` | 创建字体（默认12号） |
| `init(family: String, pointSize: Int32)` | 创建指定大小字体 |
| `setPointSize(n: Int32)` | 设置字号 |
| `setBold(b: Bool)` | 设置粗体 |
| `setItalic(b: Bool)` | 设置斜体 |

### QPainterPath - 绘图路径

用于创建复杂形状。

```cangjie
let path = QPainterPath()
path.moveTo(100.0, 20.0)
path.lineTo(180.0, 80.0)
path.lineTo(140.0, 160.0)
path.closeSubpath()

// 预定义形状
let ellipsePath = QPainterPath()
ellipsePath.addEllipse(50.0, 50.0, 100.0, 80.0)

let rectPath = QPainterPath()
rectPath.addRect(20.0, 20.0, 150.0, 100.0)
```

**QPainterPath 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空路径 |
| `moveTo(x, y)` | 移动到点 |
| `lineTo(x, y)` | 画线到点 |
| `addRect(x, y, w, h)` | 添加矩形 |
| `addEllipse(x, y, w, h)` | 添加椭圆 |
| `closeSubpath()` | 闭合路径 |
| `isEmpty(): Bool` | 是否为空 |

### QPixmap - 图像

```cangjie
// 创建空白图像
let pixmap = QPixmap.withSize(400, 300)
pixmap.fill(Colors.white())

// 从文件加载
let loadedPixmap = QPixmap.load("/path/to/image.png")

// 获取信息
let w = pixmap.width()
let h = pixmap.height()
let isNull = pixmap.isNull()
```

**QPixmap 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空图像 |
| `withSize(w, h)` | 创建指定大小图像（静态方法） |
| `load(path: String)` | 从文件加载（静态方法） |
| `width(): Int32` | 获取宽度 |
| `height(): Int32` | 获取高度 |
| `isNull(): Bool` | 是否为空 |
| `fill(c: QColor)` | 填充颜色 |

### QPainter - 绘图器

核心绘图类，用于在设备上绘图。

```cangjie
let pixmap = QPixmap.withSize(400, 300)
pixmap.fill(Colors.white())

let painter = QPainter(pixmap.getPtr())
painter.setRenderHint(RenderHint.Antialiasing)

// 设置画笔和画刷
painter.setPen(QPen(Colors.black()).setWidth(2))
painter.setBrush(QBrush(Colors.cyan()))

// 绘制形状
painter.drawRect(20, 20, 100, 80)
painter.drawCircle(200, 100, 40)
painter.drawEllipse(280, 20, 100, 60)

// 绘制线条
painter.drawLine(20, 150, 380, 150)

// 绘制文字
let font = QFont("Arial", 16).setBold(true)
painter.setFont(font)
painter.setPenColor(Colors.black())
painter.drawText(50, 250, "Hello QPainter!")

// 绘制饼图
painter.drawPie(20, 200, 100, 100, 0, 90*16)  // 90度

painter.end()

// 显示在标签上
label.setPixmap(pixmap.getPtr())
```

**QPainter 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建绘图器 |
| `init(device: Int64)` | 在设备上创建绘图器 |
| `begin(device: Int64): Bool` | 开始绘图 |
| `end(): Bool` | 结束绘图 |
| `isActive(): Bool` | 是否活动 |
| `setPen(pen: QPen)` | 设置画笔 |
| `setPenColor(c: QColor)` | 设置画笔颜色 |
| `setBrush(b: QBrush)` | 设置画刷 |
| `setFont(f: QFont)` | 设置字体 |
| `setRenderHint(h: Int32)` | 设置渲染提示 |
| `setOpacity(o: Float32)` | 设置透明度 |
| `drawLine(x1, y1, x2, y2)` | 绘制线条 |
| `drawRect(x, y, w, h)` | 绘制矩形 |
| `drawEllipse(x, y, w, h)` | 绘制椭圆 |
| `drawCircle(cx, cy, r)` | 绘制圆 |
| `drawArc(x, y, w, h, start, span)` | 绘制弧 |
| `drawPie(x, y, w, h, start, span)` | 绘制饼 |
| `drawText(x, y, text)` | 绘制文字 |
| `drawTextRect(x, y, w, h, flags, text)` | 在矩形内绘制文字 |
| `drawPixmap(x, y, pixmap)` | 绘制图像 |
| `drawPath(path)` | 绘制路径 |
| `fillPath(path, brush)` | 填充路径 |
| `fillRect(x, y, w, h, brush)` | 填充矩形 |
| `fillRectColor(x, y, w, h, color)` | 用颜色填充矩形 |
| `translate(dx, dy)` | 平移 |
| `scale(sx, sy)` | 缩放 |
| `rotate(a)` | 旋转（角度） |
| `save()` | 保存状态 |
| `restore()` | 恢复状态 |

**渲染提示常量** (RenderHint):
```cangjie
Antialiasing       // 抗锯齿
TextAntialiasing   // 文字抗锯齿
```

**文字对齐常量** (TextFlag):
```cangjie
AlignLeft      // 左对齐
AlignRight     // 右对齐
AlignHCenter   // 水平居中
AlignTop       // 顶部对齐
AlignBottom    // 底部对齐
AlignVCenter   // 垂直居中
AlignCenter    // 居中
```

### 绘图示例

```cangjie
import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.paint.*
import CJQT6.gui.*

// 全局变量保存标签指针
var labelPtr: Int64 = 0

func drawShapes(): Unit {
    let pixmap = QPixmap.withSize(400, 300)
    pixmap.fill(Colors.white())
    
    let painter = QPainter(pixmap.getPtr())
    painter.setRenderHint(RenderHint.Antialiasing)
    
    // 彩色矩形
    painter.fillRectColor(20, 20, 80, 50, Colors.red())
    painter.fillRectColor(120, 20, 80, 50, Colors.green())
    painter.fillRectColor(220, 20, 80, 50, Colors.blue())
    
    // 渐变椭圆
    let gradient = QLinearGradient.fromInt(20, 100, 200, 180)
    gradient.setColorAt(0.0, Colors.cyan())
    gradient.setColorAt(1.0, Colors.magenta())
    painter.setBrush(QBrush(gradient))
    painter.drawEllipse(20, 100, 180, 80)
    
    // 文字
    let font = QFont("Arial", 16).setBold(true)
    painter.setFont(font)
    painter.drawText(50, 250, "CJQT6 绘图演示")
    
    painter.end()
    
    // 显示在标签上
    unsafe { qLabelSetPixmap(labelPtr, pixmap.getPtr()) }
}

foreign func qLabelSetPixmap(ptr: Int64, pixmapPtr: Int64): Unit

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("绘图示例")
    window.resize(450, 380)
    
    let layout = QVBoxLayout()
    
    let label = QLabel()
    labelPtr = label.getPtr()
    layout.addWidget(label.getPtr())
    
    let btn = QPushButton()
    btn.setText("绘制")
    btn.setOnClick({ _: Int64 => drawShapes() })
    layout.addWidget(btn.getPtr())
    
    window.setLayout(layout.getPtr())
    
    // 初始绘图
    drawShapes()
    
    window.show()
    
    let result = app.exec()
    
    label.delete()
    btn.delete()
    window.delete()
    app.delete()
    
    return result
}
```

---

## 进程管理

### QProcess - 进程管理类

QProcess 用于启动外部程序并与之通信。

```cangjie
import CJQT6.core.*

// 创建进程
let process = QProcess()

// 启动进程
process.startWithArgs("ls", "-la /home")

// 等待完成
if (process.waitForFinished(5000)) {
    // 读取输出
    let output = process.readAllStandardOutput()
    let error = process.readAllStandardError()
    println("输出: ${output}")
    println("错误: ${error}")
    println("退出码: ${process.exitCode()}")
}

process.delete()
```

**启动进程方法**:
| 方法 | 说明 |
|------|------|
| `start(program)` | 启动程序（无参数） |
| `startWithArgs(program, args)` | 启动程序带参数（空格分隔） |
| `startCommand(command)` | 启动命令字符串 |
| `startDetached(): Int32` | 启动分离进程，返回PID |

**静态方法**:
| 方法 | 说明 |
|------|------|
| `startDetachedProcess(program, args, workingDir)` | 静态方法启动分离进程 |
| `executeCommand(program, args)` | 执行命令并等待，返回退出码 |
| `systemEnvironment()` | 获取系统环境变量 |

**进程控制**:
| 方法 | 说明 |
|------|------|
| `kill()` | 强制终止进程 |
| `terminate()` | 终止进程 |
| `waitForStarted(msecs)` | 等待进程启动 |
| `waitForFinished(msecs)` | 等待进程完成 |

**状态查询**:
| 方法 | 说明 |
|------|------|
| `state(): Int32` | 获取进程状态 |
| `isRunning(): Bool` | 是否正在运行 |
| `exitCode(): Int32` | 获取退出码 |
| `exitStatus(): Int32` | 获取退出状态 |
| `error(): Int32` | 获取错误类型 |
| `processId(): Int64` | 获取进程ID |

**输入输出**:
| 方法 | 说明 |
|------|------|
| `write(data)` | 写入数据到进程标准输入 |
| `readAllStandardOutput(): String` | 读取标准输出 |
| `readAllStandardError(): String` | 读取标准错误 |
| `closeWriteChannel()` | 关闭写入通道 |
| `closeReadChannel(channel)` | 关闭读取通道 |

**配置**:
| 方法 | 说明 |
|------|------|
| `setProgram(program)` | 设置程序路径 |
| `setArguments(args)` | 设置参数 |
| `setWorkingDirectory(dir)` | 设置工作目录 |
| `setProcessEnvironment(env)` | 设置环境变量 |
| `setProcessChannelMode(mode)` | 设置通道模式 |

**进程状态常量** (ProcessState):
```cangjie
ProcessState.NotRunning  // 未运行
ProcessState.Starting    // 正在启动
ProcessState.Running     // 正在运行
```

**退出状态常量** (ExitStatus):
```cangjie
ExitStatus.NormalExit  // 正常退出
ExitStatus.CrashExit   // 崩溃退出
```

**错误类型常量** (ProcessError):
```cangjie
ProcessError.FailedToStart  // 启动失败
ProcessError.Crashed        // 崩溃
ProcessError.Timedout       // 超时
ProcessError.ReadError      // 读取错误
ProcessError.WriteError     // 写入错误
ProcessError.UnknownError   // 未知错误
```

**通道模式常量** (ProcessChannelMode):
```cangjie
ProcessChannelMode.SeparateChannels     // 分离通道（默认）
ProcessChannelMode.MergedChannels       // 合并标准输出和错误
ProcessChannelMode.ForwardedChannels    // 转发到主进程
```

### 信号回调

```cangjie
// 进程完成回调
let finishedCallback: CFunc<(Int32, Int32) -> Unit> = { exitCode: Int32, exitStatus: Int32 =>
    println("进程完成，退出码: ${exitCode}")
}
process.setOnFinished(finishedCallback)

// 进程启动回调
let startedCallback: CFunc<() -> Unit> = { =>
    println("进程已启动")
}
process.setOnStarted(startedCallback)

// 标准输出就绪
let readyOutCallback: CFunc<() -> Unit> = { =>
    let output = process.readAllStandardOutput()
    println("输出: ${output}")
}
process.setOnReadyReadStandardOutput(readyOutCallback)

// 错误输出就绪
let readyErrCallback: CFunc<() -> Unit> = { =>
    let error = process.readAllStandardError()
    println("错误: ${error}")
}
process.setOnReadyReadStandardError(readyErrCallback)

// 错误发生
let errorCallback: CFunc<(Int32) -> Unit> = { error: Int32 =>
    println("进程错误: ${error}")
}
process.setOnErrorOccurred(errorCallback)

// 状态变化
let stateCallback: CFunc<(Int32) -> Unit> = { state: Int32 =>
    println("进程状态变化: ${state}")
}
process.setOnStateChanged(stateCallback)
```

### QProcessEnvironment - 环境变量

```cangjie
// 获取系统环境
let env = QProcessEnvironment.system()

// 创建空环境
let env2 = QProcessEnvironment()

// 设置环境变量
env2.insert("PATH", "/usr/bin:/bin")
env2.insert("HOME", "/home/user")
env2.insert("LANG", "zh_CN.UTF-8")

// 移除环境变量
env2.remove("OLDPWD")

// 检查是否存在
if (env2.contains("HOME")) {
    println("HOME: ${env2.value("HOME")}")
}

// 应用到进程
process.setProcessEnvironment(env2)
```

**QProcessEnvironment 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空环境 |
| `system()` | 获取系统环境（静态方法） |
| `insert(name, value)` | 设置环境变量 |
| `remove(name)` | 移除环境变量 |
| `value(name): String` | 获取环境变量值 |
| `contains(name): Bool` | 检查是否存在 |
| `clear()` | 清空所有变量 |
| `isEmpty(): Bool` | 是否为空 |
| `delete()` | 释放资源 |

---

## 日期时间模块

日期时间模块提供日历、日期编辑、时间编辑和日期时间编辑控件。

```cangjie
import CJQT6.widgets.*
```

### QDate - 日期类

```cangjie
// 创建日期
let date = QDate(2026, 3, 11)  // 年、月、日
let today = QDate.currentDate()  // 当前日期

// 获取日期信息
let year = date.year()      // 2026
let month = date.month()    // 3
let day = date.day()        // 11
let str = date.toString()   // "2026-03-11"

// 日期运算
let tomorrow = date.addDays(1)
let nextMonth = date.addMonths(1)
let nextYear = date.addYears(1)
```

**QDate 方法**:
| 方法 | 说明 |
|------|------|
| `init(year, month, day)` | 创建日期 |
| `currentDate()` | 获取当前日期（静态方法） |
| `year(): Int32` | 获取年份 |
| `month(): Int32` | 获取月份 |
| `day(): Int32` | 获取日期 |
| `toString(): String` | 转为字符串 |
| `addDays(days: Int32): QDate` | 添加天数 |
| `addMonths(months: Int32): QDate` | ���加月份 |
| `addYears(years: Int32): QDate` | 添加年份 |
| `isValid(): Bool` | 是否有效 |

### QTime - 时间类

```cangjie
// 创建时间
let time = QTime(14, 30, 0)  // 时、分、秒
let now = QTime.currentTime()  // 当前时间

// 获取时间信息
let hour = time.hour()       // 14
let minute = time.minute()   // 30
let second = time.second()   // 0
let str = time.toString()    // "14:30:00"

// 时间运算
let later = time.addSecs(3600)  // 加1小时
```

**QTime 方法**:
| 方法 | 说明 |
|------|------|
| `init(h, m, s)` | 创建时间（时、分、秒） |
| `init(h, m, s, ms)` | 创建时间（时、分、秒、毫秒） |
| `currentTime()` | 获取当前时间（静态方法） |
| `hour(): Int32` | 获取小时 |
| `minute(): Int32` | 获取分钟 |
| `second(): Int32` | 获取秒 |
| `msec(): Int32` | 获取毫秒 |
| `toString(): String` | 转为字符串 |
| `addSecs(secs: Int32): QTime` | 添加秒数 |
| `addMSecs(ms: Int32): QTime` | 添加毫秒 |
| `isValid(): Bool` | 是否有效 |

### QDateTime - 日期时间类

```cangjie
// 创建日期时间
let dt = QDateTime(2026, 3, 11, 14, 30, 0)
let now = QDateTime.currentDateTime()  // 当前日期时间

// 获取日期时间信息
let date = dt.date()        // QDate
let time = dt.time()        // QTime
let str = dt.toString()     // "2026-03-11 14:30:00"

// 日期时间运算
let tomorrow = dt.addDays(1)
let later = dt.addSecs(3600)
```

**QDateTime 方法**:
| 方法 | 说明 |
|------|------|
| `init(year, month, day, h, m, s)` | 创建日期时间 |
| `currentDateTime()` | 获取当前日期时间（静态方法） |
| `date(): QDate` | 获取日期部分 |
| `time(): QTime` | 获取时间部分 |
| `toString(): String` | 转为字符串 |
| `addDays(days: Int32): QDateTime` | 添加天数 |
| `addMonths(months: Int32): QDateTime` | 添加月份 |
| `addSecs(secs: Int32): QDateTime` | 添加秒数 |
| `isValid(): Bool` | 是否有效 |

### QCalendarWidget - 日历部件

```cangjie
let calendar = QCalendarWidget()
calendar.setGridVisible(true)           // 显示网格
calendar.setFirstDayOfWeek(DayOfWeek.Monday)  // 周一为每周首日

let today = QDate.currentDate()
calendar.setSelectedDate(today)         // 设置选中日期

// 获取选中的日期
let selected = calendar.selectedDate()
```

**QCalendarWidget 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建日历部件 |
| `setGridVisible(visible: Bool)` | 设置网格可见 |
| `setFirstDayOfWeek(day: Int32)` | 设置每周首日 |
| `setSelectedDate(date: QDate)` | 设置选中日期 |
| `selectedDate(): QDate` | 获取选中日期 |
| `setMinimumDate(date: QDate)` | 设置最小日期 |
| `setMaximumDate(date: QDate)` | 设置最大日期 |

**DayOfWeek 常量**:
```cangjie
DayOfWeek.Monday     // 周一
DayOfWeek.Tuesday    // 周二
DayOfWeek.Wednesday  // 周三
DayOfWeek.Thursday   // 周四
DayOfWeek.Friday     // 周五
DayOfWeek.Saturday   // 周六
DayOfWeek.Sunday     // 周日
```

### QDateEdit - 日期编辑器

```cangjie
let dateEdit = QDateEdit()
dateEdit.setDisplayFormat("yyyy-MM-dd")  // 显示格式
dateEdit.setCalendarPopup(true)           // 允许弹出日历

let today = QDate.currentDate()
dateEdit.setDate(today)                   // 设置日期

// 获取日期
let date = dateEdit.date()
```

**QDateEdit 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建日期编辑器 |
| `setDate(date: QDate)` | 设置日期 |
| `date(): QDate` | 获取日期 |
| `setDisplayFormat(format: String)` | 设置显示格式 |
| `setCalendarPopup(enable: Bool)` | 设置日历弹出 |
| `setMinimumDate(date: QDate)` | 设置最小日期 |
| `setMaximumDate(date: QDate)` | 设置最大日期 |

### QTimeEdit - 时间编辑器

```cangjie
let timeEdit = QTimeEdit()
timeEdit.setDisplayFormat("hh:mm:ss")  // 显示格式

let now = QTime.currentTime()
timeEdit.setTime(now)                   // 设置时间

// 获取时间
let time = timeEdit.time()
```

**QTimeEdit 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建时间编辑器 |
| `setTime(time: QTime)` | 设置时间 |
| `time(): QTime` | 获取时间 |
| `setDisplayFormat(format: String)` | 设置显示格式 |

### QDateTimeEdit - 日期时间编辑器

```cangjie
let datetimeEdit = QDateTimeEdit()
datetimeEdit.setDisplayFormat("yyyy-MM-dd hh:mm:ss")  // 显示格式
datetimeEdit.setCalendarPopup(true)                    // 允许弹出日历

let now = QDateTime.currentDateTime()
datetimeEdit.setDateTime(now)  // 设置日期时间

// 获取日期时间
let dt = datetimeEdit.dateTime()
```

**QDateTimeEdit 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建日期时间编辑器 |
| `setDateTime(dt: QDateTime)` | 设置日期时间 |
| `dateTime(): QDateTime` | 获取日期时间 |
| `setDate(date: QDate)` | 设置日期 |
| `setTime(time: QTime)` | 设置时间 |
| `setDisplayFormat(format: String)` | 设置显示格式 |
| `setCalendarPopup(enable: Bool)` | 设置日历弹出 |

### 显示格式

常用格式占位符：
| 占位符 | 说明 |
|--------|------|
| `yyyy` | 4位年份 |
| `yy` | 2位年份 |
| `MM` | 2位月份 |
| `M` | 月份 |
| `dd` | 2位日期 |
| `d` | 日期 |
| `hh` | 2位小时(24小时制) |
| `h` | 小时 |
| `mm` | 2位分钟 |
| `m` | 分钟 |
| `ss` | 2位秒 |
| `s` | 秒 |

示例：
```cangjie
dateEdit.setDisplayFormat("yyyy年MM月dd日")      // 2026年03月11日
timeEdit.setDisplayFormat("hh:mm")               // 14:30
datetimeEdit.setDisplayFormat("yyyy-MM-dd hh:mm:ss")  // 2026-03-11 14:30:00
```

### 日期时间示例

```cangjie
import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("日期时间示例")
    window.resize(500, 400)
    
    let layout = QVBoxLayout()
    
    // 日历
    let calendar = QCalendarWidget()
    calendar.setGridVisible(true)
    calendar.setFirstDayOfWeek(DayOfWeek.Monday)
    calendar.setSelectedDate(QDate.currentDate())
    layout.addWidget(calendar.getPtr())
    
    // 日期编辑
    let dateEdit = QDateEdit()
    dateEdit.setDisplayFormat("yyyy-MM-dd")
    dateEdit.setCalendarPopup(true)
    dateEdit.setDate(QDate.currentDate())
    layout.addWidget(dateEdit.getPtr())
    
    // 时间编辑
    let timeEdit = QTimeEdit()
    timeEdit.setDisplayFormat("hh:mm:ss")
    timeEdit.setTime(QTime.currentTime())
    layout.addWidget(timeEdit.getPtr())
    
    // 日期时间编辑
    let datetimeEdit = QDateTimeEdit()
    datetimeEdit.setDisplayFormat("yyyy-MM-dd hh:mm:ss")
    datetimeEdit.setCalendarPopup(true)
    datetimeEdit.setDateTime(QDateTime.currentDateTime())
    layout.addWidget(datetimeEdit.getPtr())
    
    window.setLayout(layout.getPtr())
    window.show()
    
    let result = app.exec()
    
    calendar.delete()
    dateEdit.delete()
    timeEdit.delete()
    datetimeEdit.delete()
    window.delete()
    app.delete()
    
    return result
}
```

---

## QML模块

QML模块提供Qt Quick/QML支持，允许使用声明式QML语言构建现代UI。

### QQmlApplicationEngine - QML应用引擎

```cangjie
import CJQT6.qml.*

// 创建引擎
let engine = QQmlApplicationEngine()

// 加载内联QML代码
let qmlCode = """
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "QML Demo"
    
    Button {
        text: "Click Me"
        anchors.centerIn: parent
        onClicked: console.log("Clicked!")
    }
}
"""
engine.loadData(qmlCode)
```

**QQmlApplicationEngine 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建QML引擎 |
| `loadFile(path: String)` | 加载QML文件 |
| `loadUrl(url: String)` | 加载QML URL |
| `loadData(qmlCode: String)` | 加载内联QML代码 |
| `setContextProperty(name: String, value: Int64)` | 设置上下文对象 |
| `setContextPropertyString(name, value)` | 设置上下文字符串 |
| `setContextPropertyInt(name, value)` | 设置上下文整数 |
| `setContextPropertyDouble(name, value)` | 设置上下文浮点数 |
| `setContextPropertyBool(name, value)` | 设置上下文布尔值 |
| `rootObjects(): Int64` | 获取根对象列表 |
| `rootObjectsCount(): Int32` | 获取根对象数量 |
| `clearComponentCache()` | 清除组件缓存 |
| `addImportPath(path: String)` | 添加导入路径 |
| `delete()` | 释放资源 |

### QQuickView - QML视图窗口

```cangjie
let view = QQuickView()
view.setTitle("QML View")
view.resize(400, 300)
view.setResizeMode(ResizeMode.SizeRootObjectToView)
view.setSourceUrl("qrc:/main.qml")  // 或内联QML
view.show()
```

**QQuickView 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建QML视图 |
| `setSource(path: String)` | 设置QML源文件 |
| `setSourceUrl(url: String)` | 设置QML URL |
| `show()` | 显示窗口 |
| `hide()` | 隐藏窗口 |
| `setTitle(title: String)` | 设置标题 |
| `resize(width, height)` | 设置大小 |
| `setResizeMode(mode: Int32)` | 设置调整模式 |
| `rootObject(): Int64` | 获取根对象 |
| `delete()` | 释放资源 |

**ResizeMode 常量**:
```cangjie
ResizeMode.SizeViewToRootObject    // 视图跟随根项
ResizeMode.SizeRootObjectToView    // 根项跟随视图
```

### QQuickItem - QML项操作

```cangjie
// 获取QML项
let item = QQuickItem(itemPtr)

// 设置属性
item.setPropertyString("text", "Hello")
item.setPropertyInt("value", 42)
item.setPropertyBool("visible", true)

// 获取属性
let text = item.getPropertyString("text")
let value = item.getPropertyInt("value")
```

**QQuickItem 方法**:
| 方法 | 说明 |
|------|------|
| `setVisible(visible: Bool)` | 设置可见性 |
| `isVisible(): Bool` | 是否可见 |
| `setEnabled(enabled: Bool)` | 设置启用状态 |
| `isEnabled(): Bool` | 是否启用 |
| `setX(x: Float32)` | 设置X坐标 |
| `setY(y: Float32)` | 设置Y坐标 |
| `setWidth(w: Float32)` | 设置宽度 |
| `setHeight(h: Float32)` | 设置高度 |
| `x(): Float32` | 获取X坐标 |
| `y(): Float32` | 获取Y坐标 |
| `width(): Float32` | 获取宽度 |
| `height(): Float32` | 获取高度 |
| `findChild(name: String): Int64` | 查找子项 |
| `setProperty(name, value: String)` | 设置字符串属性 |
| `setPropertyInt(name, value: Int32)` | 设置整数属性 |
| `setPropertyDouble(name, value: Float64)` | 设置浮点属性 |
| `setPropertyBool(name, value: Bool)` | 设置布尔属性 |
| `getPropertyString(name): String` | 获取字符串属性 |
| `getPropertyInt(name): Int32` | 获取整数属性 |
| `getPropertyDouble(name): Float64` | 获取浮点属性 |
| `getPropertyBool(name): Bool` | 获取布尔属性 |

### QML示例

```cangjie
package qml_demo

import CJQT6.core.*
import CJQT6.qml.*

main(): Int32 {
    let app = QApplication()
    let engine = QQmlApplicationEngine()
    
    let qmlCode = """
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "CJQT6 QML Demo"
    
    Column {
        anchors.centerIn: parent
        spacing: 20
        
        Text {
            id: title
            text: "Hello QML!"
            font.pixelSize: 28
        }
        
        Button {
            text: "Click Me"
            onClicked: title.text = "Clicked!"
        }
    }
}
"""
    
    engine.loadData(qmlCode)
    
    let result = app.exec()
    
    engine.delete()
    app.delete()
    
    return result
}
```

### 已知限制

**QML 模块状态**: ⚠️ 部分功能不可用（2026-03-20 测试）

**QQmlApplicationEngine**: 
- ✅ 创建引擎成功
- ❌ `loadFile()` 和 `loadData()` 调用后程序卡住无响应
- 可能原因：Qt Quick 插件与仓颉运行时兼容性问题

**QQuickView**: 
- ❌ 创建时程序崩溃
- 暂时不可用

**QWidget**: ✅ 正常工作，可作为替代方案

**运行环境**: 运行 QML 应用需要设置 `QML2_IMPORT_PATH` 环境变量：
```bash
# Windows
set QML2_IMPORT_PATH=C:\Qt\6.10.2\mingw_64\qml

# Linux
export QML2_IMPORT_PATH=/usr/lib/x86_64-linux-gnu/qt6/qml
```

**临时解决方案**: 如需 QML 功能，建议使用 QWidget + QQuickWidget 嵌入方式，或等待后续修复。

---

## 信号与槽

CJQT6使用CFunc回调实现信号槽机制。

### 回调类型

```cangjie
// 无参数回调
public type VoidCallback = CFunc<() -> Unit>

// Int32参数回调
public type Int32Callback = CFunc<(Int32) -> Unit>

// CString参数回调
public type CStringCallback = CFunc<(CString) -> Unit>

// Float64参数回调
public type Float64Callback = CFunc<(Float64) -> Unit>
```

### 重要说明：CFunc 的限制

**CFunc 闭包不能捕获局部变量**，只能：
- 使用全局变量
- 使用参数

因此，如果需要在回调中访问其他控件，必须使用全局变量：

```cangjie
// ❌ 错误：不能捕获局部变量
main(): Int32 {
    let label = QLabel()
    let callback: VoidCallback = { =>
        label.setText("clicked")  // 编译错误！
    }
}

// ✅ 正确：使用全局变量
var globalLabel: ?QLabel = None

let callback: VoidCallback = { =>
    if (let Some(label) <- globalLabel) {
        label.setText("clicked")
    }
}

main(): Int32 {
    let app = QApplication()
    let label = QLabel()
    globalLabel = label  // 保存到全局变量
    // ...
}
```

### 基本用法

```cangjie
// 按钮点击回调
let clickCallback: VoidCallback = { =>
    println("按钮被点击！")
}
btn.setOnClick(clickCallback)

// 滑块值变化回调
let valueCallback: Int32Callback = { value: Int32 =>
    println("值改变了: ${value}")
}
slider.setOnValueChanged(valueCallback)

// 文本变化回调
let textCallback: CStringCallback = { text: CString =>
    println("文本: ${text}")
}
lineEdit.setOnTextChanged(textCallback)
```

### 支持信号的控件

| 控件 | 方法 | 回调类型 | 说明 |
|------|------|----------|------|
| QPushButton | `setOnClick(callback)` | VoidCallback | 点击 |
| QLineEdit | `setOnTextChanged(callback)` | CStringCallback | 文本变化 |
| QSpinBox | `setOnValueChanged(callback)` | Int32Callback | 值变化 |
| QSlider | `setOnValueChanged(callback)` | Int32Callback | 值变化 |
| QCheckBox | `setOnStateChanged(callback)` | Int32Callback | 状态变化 |
| QRadioButton | `setOnToggled(callback)` | VoidCallback | 切换 |
| QComboBox | `setOnCurrentIndexChanged(callback)` | Int32Callback | 索引变化 |
| QAction | `setOnTriggered(callback)` | VoidCallback | 触发 |
| QTimer | `setTimeout(callback)` | VoidCallback | 超时 |

### 断开信号连接

所有支持信号的控件都提供了 `disconnect()` 方法：

```cangjie
// 断开信号连接
button.disconnect()
slider.disconnect()
checkBox.disconnect()
radioButton.disconnect()
comboBox.disconnect()
lineEdit.disconnect()
timer.disconnect()
```

### 回调中访问控件

由于CFunc不能捕获外部变量，如需在回调中访问其他控件，可使用全局变量：

```cangjie
// 使用全局变量
var globalLabel: ?QLabel = None

let callback: VoidCallback = { =>
    if (let Some(label) <- globalLabel) {
        label.setText("已点击")
    }
}
```

### 定时器示例

```cangjie
let timer = QTimer()
timer.setInterval(1000)  // 1秒

let timerCallback: VoidCallback = { =>
    println("定时器触发！")
}
timer.setTimeout(timerCallback)
timer.start()

// 停止并断开连接
timer.stop()
timer.disconnect()
```

---

## 多媒体模块

多媒体模块提供音频播放功能。

```cangjie
import CJQT6.multimedia.*
```

### QMediaPlayer - 媒体播放器

```cangjie
let player = QMediaPlayer()
let audioOutput = QAudioOutput()

// 设置音频输出
player.setAudioOutput(audioOutput.getPtr())

// 加载文件
player.setSourceFile("/path/to/music.mp3")

// 播放控制
player.play()
player.pause()
player.stop()

// 音量控制
audioOutput.setVolume(50)  // 0-100

// 播放速度
player.setPlaybackRate(1.5)  // 1.5倍速
```

**播放控制方法**:
| 方法 | 说明 |
|------|------|
| `play()` | 播放 |
| `pause()` | 暂停 |
| `stop()` | 停止 |
| `setSource(url: String)` | 设置媒体源（URL） |
| `setSourceFile(path: String)` | 设置本地文件 |

**播放状态**:
| 方法 | 说明 |
|------|------|
| `isPlaying(): Bool` | 是否正在播放 |
| `isPaused(): Bool` | 是否暂停 |
| `isStopped(): Bool` | 是否停止 |
| `position(): Int64` | 获取播放位置（毫秒） |
| `duration(): Int64` | 获取总时长（毫秒） |
| `setPosition(pos: Int64)` | 设置播放位置 |
| `playbackRate(): Float64` | 获取播放速度 |
| `setPlaybackRate(rate: Float64)` | 设置播放速度 |

**媒体信息**:
| 方法 | 说明 |
|------|------|
| `title(): String` | 获取标题 |
| `artist(): String` | 获取艺术家 |
| `album(): String` | 获取专辑 |
| `metaData(key: String): String` | 获取元数据 |

**状态查询**:
| 方法 | 说明 |
|------|------|
| `isSeekable(): Bool` | 是否可跳转 |
| `hasAudio(): Bool` | 是否有音频 |
| `mediaStatus(): Int32` | 媒体状态 |
| `error(): Int32` | 错误类型 |
| `errorString(): String` | 错误描述 |

**信号回调**（使用 CFunc 回调函数）:

回调函数必须是顶级函数，使用 `@C` 修饰，参数类型为 `CFunc<(参数类型) -> Unit>`:

```cangjie
// 定义 @C 回调函数
@C
func onPositionChanged(pos: Int64): Unit {
    println("播放位置: ${pos}ms")
}

@C
func onDurationChanged(dur: Int64): Unit {
    println("总时长: ${dur}ms")
}

@C
func onPlaybackStateChanged(state: Int32): Unit {
    // state: 0=Stopped, 1=Playing, 2=Paused
    match (state) {
        case 1 => println("开始播放")
        case 2 => println("已暂停")
        case 0 => println("已停止")
        case _ => ()
    }
}

@C
func onMediaStatusChanged(status: Int32): Unit {
    // status == 6 表示 EndOfMedia
    if (status == 6) {
        println("播放结束")
    }
}

// 注册回调
player.onPositionChanged(onPositionChanged)
player.onDurationChanged(onDurationChanged)
player.onPlaybackStateChanged(onPlaybackStateChanged)
player.onMediaStatusChanged(onMediaStatusChanged)
```

**信号回调方法**:
| 方法 | 回调类型 | 说明 |
|------|----------|------|
| `onPositionChanged(callback)` | `CFunc<(Int64) -> Unit>` | 播放位置变化 |
| `onDurationChanged(callback)` | `CFunc<(Int64) -> Unit>` | 媒体时长变化 |
| `onPlaybackStateChanged(callback)` | `CFunc<(Int32) -> Unit>` | 播放状态变化 |
| `onMediaStatusChanged(callback)` | `CFunc<(Int32) -> Unit>` | 媒体状态变化 |

**注意事项**:
- 回调函数必须是顶级函数，不能是嵌套函数或类方法
- 回调函数需要 `@C` 修饰符
- 使用信号回调比定时器轮询更高效，避免音频卡顿
- 更新 UI 控件时注意防止循环触发（如 slider.setValue 触发 valueChanged）
```

**媒体状态常量** (MediaStatus):
```cangjie
NoMedia         // 无媒体
LoadingMedia    // 加载中
LoadedMedia     // 已加载
BufferingMedia  // 缓冲中
StalledMedia    // 停滞
BufferedMedia   // 已缓冲
EndOfMedia      // 播放结束
InvalidMedia    // 无效媒体
```

### QAudioOutput - 音频输出

```cangjie
let audioOutput = QAudioOutput()
audioOutput.setVolume(80)  // 音量 0-100
audioOutput.setMuted(true) // 静音

if (audioOutput.isMuted()) {
    audioOutput.setMuted(false)
}
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建音频输出 |
| `setVolume(volume: Int32)` | 设置音量（0-100） |
| `volume(): Int32` | 获取音量 |
| `setMuted(muted: Bool)` | 设置静音 |
| `isMuted(): Bool` | 是否静音 |
| `getPtr(): Int64` | 获取指针 |

---

## 打印模块

打印模块提供打印和打印预览功能。

```cangjie
import CJQT6.print.*
```

### QPrinter - 打印机

```cangjie
let printer = QPrinter()

// 设置输出格式
printer.setOutputFormat(OutputFormat.NativeFormat)  // 打印到打印机
printer.setOutputFormat(OutputFormat.PdfFormat)     // 输出PDF

// 设置PDF文件名
printer.setOutputFileName("/path/to/output.pdf")

// 页面设置
printer.setPageSize(PageSize.A4)
printer.setOrientation(PageOrientation.Portrait)

// 打印份数
printer.setNumCopies(2)

// 双面打印
printer.setDoubleSidedPrinting(true)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建打印机 |
| `init(mode: Int32)` | 创建打印机（高分辨率/屏幕分辨率） |
| `setOutputFormat(format: Int32)` | 设置输出格式 |
| `outputFormat(): Int32` | 获取输出格式 |
| `setOutputFileName(name: String)` | 设置输出文件名 |
| `outputFileName(): String` | 获取输出文件名 |
| `setPageSize(size: Int32)` | 设置页面大小 |
| `pageSize(): Int32` | 获取页面大小 |
| `setOrientation(orientation: Int32)` | 设置页面方向 |
| `orientation(): Int32` | 获取页面方向 |
| `setPageMargins(left, top, right, bottom)` | 设置页边距 |
| `setNumCopies(copies: Int32)` | 设置打印份数 |
| `numCopies(): Int32` | 获取打印份数 |
| `setDoubleSidedPrinting(enabled: Bool)` | 设置双面打印 |
| `doubleSidedPrinting(): Bool` | 是否双面打印 |
| `setColorMode(mode: Int32)` | 设置颜色模式 |
| `colorMode(): Int32` | 获取颜色模式 |
| `setResolution(dpi: Int32)` | 设置分辨率 |
| `resolution(): Int32` | 获取分辨率 |
| `setPrinterName(name: String)` | 设置打印机名称 |
| `printerName(): String` | 获取打印机名称 |
| `setDocName(name: String)` | 设置文档名称 |
| `docName(): String` | 获取文档名称 |
| `setFromTo(from, to)` | 设置打印页范围 |
| `fromPage(): Int32` | 获取起始页 |
| `toPage(): Int32` | 获取结束页 |
| `newPage(): Bool` | 新建一页 |
| `width(): Int32` | 获取页面宽度 |
| `height(): Int32` | 获取页面高度 |

**输出格式常量** (OutputFormat):
```cangjie
NativeFormat   // 打印机
PdfFormat      // PDF文件
```

**页面大小常量** (PageSize):
```cangjie
A3      // A3
A4      // A4
A5      // A5
Letter  // Letter
Legal   // Legal
B4      // B4
B5      // B5
```

**页面方向常量** (PageOrientation):
```cangjie
Portrait   // 纵向
Landscape  // 横向
```

**颜色模式常量** (ColorMode):
```cangjie
GrayScale  // 灰度
Color      // 彩色
```

### QPrintDialog - 打印对话框

```cangjie
let printer = QPrinter()
let dialog = QPrintDialog(printer)

let result = dialog.exec()
if (result == 1) {  // Accepted
    // 用户点击了打印
    textEdit.print(printer.getPtr())
}

dialog.delete()
printer.delete()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(printer: QPrinter)` | 创建打印对话框 |
| `exec(): Int32` | 执行对话框（1=接受，0=取消） |
| `printer(): QPrinter` | 获取关联的打印机 |

### QPrintPreviewDialog - 打印预览对话框

```cangjie
let printer = QPrinter()

// 创建预览对话框（关联QTextEdit）
let previewDialog = QPrintPreviewDialog(printer, textEdit)
previewDialog.exec()

previewDialog.delete()
printer.delete()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(printer: QPrinter)` | 创建预览对话框 |
| `init(printer: QPrinter, textEdit: QTextEdit)` | 创建预览对话框（关联文本编辑器） |
| `exec(): Int32` | 执行预览对话框 |

---

## 完整示例

```cangjie
package demo

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*
import CJQT6.views.*
import CJQT6.dialogs.*

// 全局变量（用于回调中访问，CFunc 闭包不能捕获局部变量）
var label: ?QLabel = None

// 回调函数（必须在顶层定义）
let clickCallback: VoidCallback = { =>
    if (let Some(l) <- label) {
        l.setText("按钮被点击了！")
    }
}

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("CJQT6 完整示例")
    window.resize(600, 400)
    
    // 主布局
    let mainLayout = QVBoxLayout()
    
    // 标签
    let lbl = QLabel()
    lbl.setText("欢迎使用CJQT6")
    label = lbl  // 保存到全局变量
    mainLayout.addWidget(lbl.getPtr())
    
    // 按钮
    let btn = QPushButton()
    btn.setText("点击我")
    btn.setOnClick(clickCallback)
    mainLayout.addWidget(btn.getPtr())
    
    // 表格
    let table = QTableWidget(3, 2)
    table.setHorizontalHeaderLabel(0, "项目")
    table.setHorizontalHeaderLabel(1, "值")
    table.setItem(0, 0, "名称")
    table.setItem(0, 1, "CJQT6")
    table.setItem(1, 0, "版本")
    table.setItem(1, 1, "1.0.0")
    table.setAutoFillWidth()
    mainLayout.addWidget(table.getPtr())
    
    window.setLayout(mainLayout.getPtr())
    window.show()
    
    // 不需要手动清理，终结器自动处理
    let result = app.exec()
    return result
}
```

---

## 常见问题

### Q: 如何让控件自动填充布局？

A: 使用布局管理器，并添加弹性空间：
```cangjie
let layout = QVBoxLayout()
layout.addWidget(topWidget.getPtr())
layout.addStretch()  // 添加弹性空间
layout.addWidget(bottomWidget.getPtr())
```

### Q: 如何实现控件之间的联动？

A: 使用信号槽机制：
```cangjie
let sliderCallback: Int32Callback = { value: Int32 =>
    progressBar.setValue(value)
}
slider.setOnValueChanged(sliderCallback)
```

### Q: 为什么CFunc回调不能访问外部变量？

A: 这是仓颉语言的安全限制。解决方案：
1. 使用全局变量存储需要访问的对象
2. 在回调中重新读取控件状态

### Q: 如何在布局中嵌套布局？

A: 使用`addLayout`方法：
```cangjie
let mainLayout = QVBoxLayout()
let topLayout = QHBoxLayout()
topLayout.addWidget(btn1.getPtr())
topLayout.addWidget(btn2.getPtr())
mainLayout.addLayout(topLayout.getPtr())
```
