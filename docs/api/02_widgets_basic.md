# CJQT6 基础控件模块

本模块包含当前源码中实际暴露出来的基础控件与输入控件 API。

## 基础部件

### QPushButton - 按钮

```cangjie
import cjqt6.widgets.*

let button = QPushButton()
button.setText("点击我")
button.setShortcut("Ctrl+S")
button.setCheckable(true)
button.setChecked(false)
button.setDefault(true)
button.setFlat(false)
button.setOnClick({ =>
    println("按钮被点击")
})
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建按钮 |
| `setText(text: String)` / `text(): String` | 设置/获取按钮文本 |
| `setIcon(iconPath: String)` | 从文件路径设置图标 |
| `setIconSize(width: Int32, height: Int32)` | 设置图标大小 |
| `setStandardIcon(iconType: Int32)` | 设置 Qt 标准图标（StandardIcon 常量） |
| `setShortcut(key: String)` / `shortcut(): String` | 设置/获取快捷键 |
| `setCheckable(checkable: Bool)` / `isCheckable(): Bool` | 设置/获取是否可勾选 |
| `setChecked(checked: Bool)` / `isChecked(): Bool` | 设置/获取勾选状态 |
| `setDefault(isDefault: Bool)` / `isDefault(): Bool` | 设置/获取默认按钮（回车触发） |
| `setAutoDefault(autoDefault: Bool)` / `isAutoDefault(): Bool` | 设置/获取自动默认按钮 |
| `setFlat(flat: Bool)` / `isFlat(): Bool` | 设置/获取扁平样式 |
| `setAutoRepeat(autoRepeat: Bool)` / `isAutoRepeat(): Bool` | 设置/获取自动重复触发 |
| `setOnClick(callback: VoidCallback)` / `disconnectClick()` | 点击回调/断开 |
| `setOnClickCapture(callback: () -> Unit): SignalConnection` | 点击回调（可捕获局部变量） |
| `setOnPressed(callback: VoidCallback): SignalConnection` / `disconnectPressed()` | 按下回调/断开 |
| `setOnPressedCapture(callback: () -> Unit): SignalConnection` | 按下回调（可捕获局部变量） |
| `setOnReleased(callback: VoidCallback): SignalConnection` / `disconnectReleased()` | 释放回调/断开 |
| `setOnReleasedCapture(callback: () -> Unit): SignalConnection` | 释放回调（可捕获局部变量） |
| `setOnToggled(callback: Int32Callback)` / `disconnectToggled()` | 切换状态回调（传 0/1） |
| `setOnClickedChecked(callback: Int32Callback)` / `disconnectClickedChecked()` | 带勾选状态的点击回调 |
| `disconnect()` | 断开全部信号 |
| `setEnabled(enabled: Bool)` / `isEnabled(): Bool` | 启用/禁用状态 |
| `setStyleSheet(style: String)` / `setMinimumSize(minw, minh)` / `setMaximumSize(maxw, maxh)` | 样式与尺寸 |
| `show()` / `hide()` / `resize(width, height)` | 控件显示与尺寸 |
| `isClosed(): Bool` / `isValid(): Bool` | 资源状态检查 |
| `getPtr(): Int64` / `close()` / `delete()` | 获取指针与释放资源 |

**标准图标常量** (`StandardIcon`):
```cangjie
StandardIcon.Open
StandardIcon.Save
StandardIcon.Close
StandardIcon.Apply
StandardIcon.Cancel
StandardIcon.Help
StandardIcon.File
StandardIcon.Folder
StandardIcon.NewFolder
StandardIcon.Link
StandardIcon.Reload
StandardIcon.Stop
StandardIcon.MediaPlay
StandardIcon.MediaPause
StandardIcon.MediaStop
StandardIcon.MediaForward
StandardIcon.MediaBackward
StandardIcon.MediaSkipForward
StandardIcon.MediaSkipBackward
StandardIcon.ArrowUp
StandardIcon.ArrowDown
StandardIcon.ArrowLeft
StandardIcon.ArrowRight
StandardIcon.Yes
StandardIcon.No
```

### QLabel - 标签

```cangjie
import cjqt6.widgets.*

let label = QLabel()
label.setText("文本内容")
label.setAlignment(Alignment.Center)
label.setWordWrap(true)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` | 设置文本 |
| `text(): String` | 获取文本 |
| `setAlignment(alignment: Int32)` | 设置对齐方式 |
| `alignment(): Int32` | 获取对齐方式 |
| `setPixmap(pixmapPtr: Int64)` | 设置图片 |
| `setPixmapByPath(path: String)` | 通过文件路径设置图片 |
| `setScaledContents(scaled: Bool)` | 设置是否缩放内容 |
| `isScaledContents(): Bool` | 是否缩放内容 |
| `setIndent(indent: Int32)` / `indent(): Int32` | 设置/获取缩进 |
| `setMargin(margin: Int32)` / `margin(): Int32` | 设置/获取边距 |
| `setOpenExternalLinks(open: Bool)` | 设置是否允许打开外部链接 |
| `setTextFormat(format: Int32)` | 设置文本格式 |
| `setBuddy(buddyPtr: Int64)` | 设置伙伴控件 |
| `setWordWrap(wrap: Bool)` / `wordWrap(): Bool` | 设置/获取自动换行 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `show()` / `hide()` / `resize(width, height)` | 控件显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

**文本格式常量** (`LabelTextFormat`，对应 Qt::TextFormat，用于 `setTextFormat(format: Int32)`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `LabelTextFormat.PlainText` | 0 | 纯文本 |
| `LabelTextFormat.RichText` | 1 | 富文本（HTML） |
| `LabelTextFormat.AutoText` | 2 | 自动检测 |
| `LabelTextFormat.MarkdownText` | 3 | Markdown 文本 |

---

## QCommandLinkButton - 命令链接按钮

Vista 风格的大按钮，包含主标题和副标题描述文字。

```cangjie
let cmdBtn = QCommandLinkButton()
cmdBtn.setText("连接到服务器")
cmdBtn.setDescription("使用默认设置连接到远程服务器")
cmdBtn.setIcon("/path/to/icon.png")
cmdBtn.setFlat(false)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` / `init(parent: QWidget)` | 创建命令链接按钮 |
| `setText(text: String)` | 设置主标题文本 |
| `setDescription(desc: String)` / `description(): String` | 设置/获取描述文字 |
| `setIcon(path: String)` | 从文件路径加载图标 |
| `setFlat(flat: Bool)` / `isFlat(): Bool` | 设置/获取扁平样式 |
| `setEnabled(enabled: Bool)` / `setStyleSheet(style: String)` | 启用/样式 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

---

## QKeySequenceEdit - 快捷键输入控件

允许用户输入键盘快捷键组合（如 Ctrl+C, Alt+Shift+X）。

```cangjie
let keyEdit = QKeySequenceEdit()
keyEdit.setKeySequence("Ctrl+S")
let seq = keyEdit.keySequence()
keyEdit.setOnKeySequenceChanged({ text: String => println("新快捷键: ${text}") })
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(parent: Int64)` | 创建快捷键输入控件 |
| `keySequence(): String` | 获取当前快捷键序列文本 |
| `setKeySequence(text: String)` | 设置快捷键序列（如 "Ctrl+C"） |
| `clear()` | 清空快捷键 |
| `setOnKeySequenceChanged(callback: CStringCallback)` | 快捷键序列变化回调 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

---

## QTextBrowser - 富文本浏览器

支持 HTML 内容显示、超链接导航、前进/后退浏览历史。适合帮助文档、日志浏览等只读场景。

```cangjie
let browser = QTextBrowser()
browser.setHtml("<h1>标题</h1><p>段落内容</p>")
browser.setSource("help://page1")
browser.setOpenLinks(true)
browser.setOpenExternalLinks(false)

// 导航历史
browser.backward()
browser.forward()
browser.home()
browser.reload()
browser.clearHistory()

// 信号
browser.setOnBackwardAvailable({ available: Bool => println("可后退: ${available}") })
browser.setOnSourceChanged({ url: String => println("跳转到: ${url}") })
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(parent: Int64)` | 创建文本浏览器 |
| `setText(text: String)` | 设置纯文本内容 |
| `toPlainText(): String` | 获取纯文本内容 |
| `setHtml(html: String)` / `toHtml(): String` | 设置/获取 HTML 内容 |
| `setPlainText(text: String)` | 设置纯文本（替代 setText） |
| `clear()` | 清空内容 |
| `setSource(url: String)` / `source(): String` | 设置/获取源 URL |
| `backward()` / `forward()` | 后退/前进 |
| `home()` / `reload()` | 首页/重新加载 |
| `clearHistory()` / `historyBack()` / `historyForward()` | 历史管理 |
| `setOpenLinks(open: Bool)` / `isOpenLinks(): Bool` | 设置/获取是否允许打开链接 |
| `setOpenExternalLinks(open: Bool)` / `isOpenExternalLinks(): Bool` | 设置/获取是否允许打开外部链接 |
| `setOnBackwardAvailable(callback: BoolCallback)` | 后退可用性变化回调 |
| `setOnForwardAvailable(callback: BoolCallback)` | 前进可用性变化回调 |
| `setOnSourceChanged(callback: CStringCallback)` | 源变化回调 |
| `setOnTextChanged(callback: VoidCallback)` | 文本内容变化回调 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` | 设置最小尺寸 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

---

## QPlainTextEdit - 纯文本编辑器

比 QTextEdit 更轻量，适合代码编辑、日志查看等大文本场景。支持文本操作、撤销/重做、缩放等。

```cangjie
let editor = QPlainTextEdit()
editor.setPlainText("第一行\n第二行")
editor.appendPlainText("追加内容")
editor.setReadOnly(false)
editor.setLineWrapMode(PlainTextLineWrap.WidgetWidth)
editor.setTabStopDistance(40.0)
editor.setMaximumBlockCount(1000)
editor.zoomIn(1)
editor.zoomOut(1)
```

**换行模式常量**:
```cangjie
PlainTextLineWrap.NoWrap       // 0 - 不换行
PlainTextLineWrap.WidgetWidth  // 1 - 按控件宽度换行
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(parent: Int64)` | 创建纯文本编辑器 |
| `setPlainText(text: String)` / `toPlainText(): String` | 设置/获取纯文本 |
| `appendPlainText(text: String)` | 追加文本 |
| `appendHtml(html: String)` | 追加 HTML 片段 |
| `setReadOnly(readonly: Bool)` / `isReadOnly(): Bool` | 设置/获取只读 |
| `clear()` | 清空内容 |
| `cut()` / `copy()` / `paste()` / `selectAll()` | 编辑操作 |
| `undo()` / `redo()` | 撤销/重做 |
| `canUndo(): Bool` / `canRedo(): Bool` | 是否可撤销/重做 |
| `isModified(): Bool` / `setModified(modified: Bool)` | 修改状态 |
| `setLineWrapMode(mode: Int32)` / `lineWrapMode(): Int32` | 设置/获取换行模式 |
| `setTabStopDistance(distance: Float64)` | 设置制表符距离 |
| `lineCount(): Int64` / `blockCount(): Int32` | 获取行数/块数 |
| `setMaximumBlockCount(maxBlocks: Int32)` | 设置最大文本块数（日志截断） |
| `zoomIn(range: Int32)` / `zoomOut(range: Int32)` | 放大/缩小字体 |
| `setOnTextChanged(callback: VoidCallback)` | 文本变化回调 |
| `setOnBlockCountChanged(callback: Int32Callback)` | 块数变化回调 |
| `setOnModificationChanged(callback: BoolCallback)` | 修改状态变化回调 |
| `setOnCopyAvailable(callback: BoolCallback)` | 复制可用性变化回调 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` | 设置最小尺寸 |
| `show()` / `hide()` / `resize(width, height)` | 显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

---

## QCompleter - 自动补全器

为 QLineEdit 等输入控件提供自动补全功能。

```cangjie
// 从字符串数组创建
let completer = QCompleter.fromArray(["苹果", "香蕉", "樱桃", "草莓"])
completer.setCaseSensitivity(false)
completer.setFilterMode(FilterMode.StartsWith)
completer.setCompletionMode(CompletionMode.Popup)
completer.setMaxVisibleItems(10)

// 绑定到 QLineEdit
lineEdit.setCompleter(completer.getPtr())

// 手动弹出补全
completer.complete()
```

**补全模式常量**:
```cangjie
CompletionMode.Popup          // 0 - 弹出补全列表
CompletionMode.Inline         // 1 - 内联补全
CompletionMode.UnfilteredPopup // 2 - 弹出并内联
```

**过滤模式常量**:
```cangjie
FilterMode.StartsWith  // 0 - 前缀匹配
FilterMode.Contains    // 1 - 包含匹配
FilterMode.Fuzzy       // 2 - 模糊匹配
```

**模型排序常量**:
```cangjie
ModelSorting.UnsortedModel                // 0
ModelSorting.CaseSensitivelySortedModel   // 1
ModelSorting.CaseInsensitivelySortedModel // 2
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空补全器 |
| `init(items: String)` | 从换行符分隔的字符串列表创建 |
| `fromArray(items: Array<String>): QCompleter` | 从字符串数组创建（静态方法） |
| `setModel(items: String)` | 更新候选词列表 |
| `setCaseSensitivity(caseSensitive: Bool)` / `caseSensitivity(): Int32` | 设置/获取大小写敏感 |
| `setFilterMode(mode: Int32)` | 设置过滤模式 |
| `setCompletionMode(mode: Int32)` / `completionMode(): Int32` | 设置/获取补全模式 |
| `setMaxVisibleItems(maxItems: Int32)` / `maxVisibleItems(): Int32` | 设置/获取最大可见项数 |
| `setCompletionPrefix(prefix: String)` / `completionPrefix(): String` | 设置/获取补全前缀 |
| `completionCount(): Int32` | 获取补全候选数量 |
| `complete()` | 弹出补全列表 |
| `setModelSorting(sorting: Int32)` | 设置模型排序方式 |
| `setCompletionColumn(column: Int32)` | 设置匹配列 |
| `setCompletionRole(role: Int32)` | 设置匹配 data role |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

---

## 输入控件

### QLineEdit - 单行文本输入

```cangjie
import cjqt6.widgets.*

let edit = QLineEdit()
edit.setPlaceholder("请输入...")
edit.setMaxLength(100)
edit.setEchoMode(LineEditEchoMode.Password)
edit.setInputMask(InputMask.IP)
edit.setAlignment(Alignment.Center)
edit.setOnTextChanged({ text: String => println(text) })
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` / `text(): String` | 设置/获取文本 |
| `setPlaceholder(text: String)` | 设置占位文本 |
| `setMaxLength(length: Int32)` / `maxLength(): Int32` | 设置/获取最大长度 |
| `setReadOnly(readonly: Bool)` / `isReadOnly(): Bool` | 设置/获取只读状态 |
| `setEchoMode(mode: Int32)` / `echoMode(): Int32` | 设置/获取回显模式 |
| `setInputMask(mask: String)` | 设置输入掩码 |
| `setFrame(enabled: Bool)` / `hasFrame(): Bool` | 设置/获取边框显示 |
| `setAlignment(alignment: Int32)` | 设置文本对齐 |
| `setStyleSheet(styleSheet: String)` | 设置样式表 |
| `clear()` | 清空文本 |
| `selectAll()` | 全选文本 |
| `hasSelectedText(): Bool` | 是否有选中文本 |
| `selectedText(): String` | 获取选中文本 |
| `setFocus()` | 设置焦点 |
| `setCursorPosition(pos: Int32)` / `cursorPosition(): Int32` | 设置/获取光标位置 |
| `setSelection(start: Int32, length: Int32)` | 设置选中区域 |
| `setClearButtonEnabled(enabled: Bool)` / `isClearButtonEnabled(): Bool` | 设置/获取清除按钮 |
| `setCompleter(completerPtr: Int64)` | 设置自动完成器 |
| `displayText(): String` | 获取显示文本 |
| `addPasswordToggleAction(callback: VoidCallback)` | 添加密码切换按钮 |
| `setPasswordToggleIcon(visible: Bool)` | 设置密码切换按钮图标 |
| `setOnTextChanged(callback: CStringCallback)` | 文本变化回调 |
| `setOnReturnPressed(callback: VoidCallback)` | 回车回调 |
| `setOnEditingFinished(callback: VoidCallback)` | 编辑完成回调 |
| `setOnCursorPositionChanged(callback: Int32Int32Callback)` | 光标位置变化回调 |
| `setOnSelectionChanged(callback: VoidCallback)` | 选区变化回调 |
| `setOnInputRejected(callback: VoidCallback)` | 无效输入回调 |
| `show()` / `hide()` / `resize(width, height)` | 控件显示与尺寸 |
| `close()` / `delete()` | 释放资源 |

**回显模式常量**:
```cangjie
LineEditEchoMode.Normal
LineEditEchoMode.NoEcho
LineEditEchoMode.Password
LineEditEchoMode.PasswordEchoOnEdit
```

**输入掩码预设**:
```cangjie
InputMask.IP
InputMask.MAC
InputMask.Date
InputMask.Time
InputMask.Phone
InputMask.LicenseKey
```

---

## QTextEdit - 多行文本编辑器

当前封装集中在文本编辑、撤销/重做、查找替换和样式设置等常用能力。

```cangjie
import cjqt6.widgets.*

let editor = QTextEdit()
editor.setText("Hello,\nWorld!")
editor.setReadOnly(false)
editor.setFontFamily("Arial")
editor.setFontSize(14)
editor.setFontBold(true)
```

**当前支持方法**:
| 方法 | 说明 |
|------|------|
| `setText(text: String)` / `text(): String` | 设置/获取文本 |
| `setReadOnly(readonly: Bool)` / `isReadOnly(): Bool` | 设置/获取只读状态 |
| `clear()` | 清空内容 |
| `cut()` / `copy()` / `paste()` | 剪切/复制/粘贴 |
| `selectAll()` | 全选文本 |
| `canPaste(): Bool` | 是否可粘贴 |
| `undo()` / `redo()` | 撤销/重做 |
| `canUndo(): Bool` / `canRedo(): Bool` | 是否可撤销/重做 |
| `isModified(): Bool` / `setModified(modified: Bool)` | 设置/读取修改状态 |
| `setLineWrapMode(mode: Int32)` / `lineWrapMode(): Int32` | 设置/获取换行模式 |
| `setFontFamily(family: String)` | 设置字体族 |
| `setFontSize(size: Int32)` | 设置字号 |
| `setFontBold(bold: Bool)` | 设置粗体 |
| `setFontItalic(italic: Bool)` | 设置斜体 |
| `find(text: String, caseSensitive: Bool): Bool` | 查找文本 |
| `findNext(text: String, caseSensitive: Bool)` | 查找下一个 |
| `findPrev(text: String, caseSensitive: Bool)` | 查找上一个 |
| `replace(newText: String)` | 替换选中文本 |
| `replaceAll(oldText: String, newText: String, caseSensitive: Bool): Int32` | 替换所有匹配项 |
| `lineCount(): Int32` | 获取总行数 |
| `currentLine(): Int32` | 获取当前行号 |
| `currentColumn(): Int32` | 获取当前列号 |
| `characterCount(): Int32` | 获取字符总数 |
| `goToLine(line: Int32)` | 跳转到指定行 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(width: Int32, height: Int32)` / `setMaximumSize(width: Int32, height: Int32)` | 设置最小/最大尺寸 |
| `show()` / `hide()` / `resize(width, height)` | 控件显示与尺寸 |
| `getPtr(): Int64` / `delete()` | 获取指针与释放资源 |

---

## QTextDocument - 富文本文档

独立的富文本文档，支持纯文本与 HTML，提供块数、行数、字符数等统计，可与编辑器协同。

```cangjie
import cjqt6.gui.*

let doc = QTextDocument()
doc.setPlainText("Hello CJQT6")
doc.setHtml("<b>粗体</b> 文本")

println("块数: ${doc.blockCount()}")
println("行数: ${doc.lineCount()}")
println("字符数: ${doc.characterCount()}")
println("是否为空: ${doc.isEmpty()}")

doc.setDefaultFont("Microsoft YaHei", 12)
doc.clear()
doc.close()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空文档 |
| `init(text: String)` | 创建并设置纯文本 |
| `setPlainText(text)` / `toPlainText(): String` | 设置/获取纯文本 |
| `setHtml(html)` / `toHtml(): String` | 设置/获取 HTML |
| `blockCount(): Int32` | 获取块（段落）数量 |
| `lineCount(): Int32` | 获取行数 |
| `characterCount(): Int32` | 获取字符数 |
| `pageCount(): Int32` | 获取页数 |
| `isEmpty(): Bool` | 是否为空 |
| `isModified(): Bool` / `setModified(modified: Bool)` | 获取/设置修改状态 |
| `setDefaultFont(family: String, pointSize: Int32)` | 设置默认字体 |
| `clear()` | 清空文档 |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

---

## QTextCursor - 文本光标

在文档中定位、选择、插入和删除文本的光标对象。

```cangjie
let doc = QTextDocument("Hello World")
let cursor = QTextCursor(doc)

// 移动与插入
cursor.movePosition(MoveOperation.end())
cursor.insertText("!")

// 选择
cursor.movePosition(MoveOperation.start())
cursor.movePositionEx(MoveOperation.endOfWord(), MoveMode.keepAnchor(), 1)
if (cursor.hasSelection()) {
    println("选中: ${cursor.selectedText()}")
    cursor.removeSelectedText()
}

// 定位信息
println("位置: ${cursor.position()}，块: ${cursor.blockNumber()}，列: ${cursor.columnNumber()}")
cursor.close()
doc.close()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(doc: QTextDocument)` | 在指定文档上创建光标 |
| `position(): Int32` / `setPosition(pos: Int32)` | 获取/设置位置 |
| `anchor(): Int32` | 获取锚点位置 |
| `insertText(text: String)` | 插入文本 |
| `movePosition(operation: Int32): Bool` | 移动光标（默认 moveAnchor 模式，1 次） |
| `movePositionEx(operation, mode: Int32, count: Int32): Bool` | 移动光标（指定模式和次数） |
| `select(operation: Int32)` | 按操作选择文本 |
| `selectedText(): String` | 获取选中文本 |
| `clearSelection()` | 清除选区 |
| `hasSelection(): Bool` | 是否有选区 |
| `removeSelectedText()` | 删除选中文本 |
| `deleteChar()` | 删除当前字符 |
| `deletePreviousChar()` | 删除前一字符 |
| `insertNewBlock()` | 插入新块（换行） |
| `isNull(): Bool` | 光标是否无效 |
| `blockNumber(): Int32` / `columnNumber(): Int32` | 块号 / 列号 |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

**MoveOperation 移动操作常量**（常用部分）:
| 常量 | 值 | 说明 |
|------|-----|------|
| `MoveOperation.start()` | 1 | 文档开头 |
| `MoveOperation.up()` | 2 | 上移 |
| `MoveOperation.startOfLine()` | 3 | 行首 |
| `MoveOperation.startOfBlock()` | 4 | 块首 |
| `MoveOperation.previousCharacter()` | 7 | 前一字符 |
| `MoveOperation.left()` | 9 | 左移 |
| `MoveOperation.wordLeft()` | 10 | 左移一词 |
| `MoveOperation.end()` | 11 | 文档末尾 |
| `MoveOperation.down()` | 12 | 下移 |
| `MoveOperation.endOfLine()` | 13 | 行尾 |
| `MoveOperation.endOfWord()` | 14 | 词尾 |
| `MoveOperation.nextCharacter()` | 17 | 下一字符 |
| `MoveOperation.right()` | 19 | 右移 |
| `MoveOperation.wordRight()` | 20 | 右移一词 |

**MoveMode 移动模式常量**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `MoveMode.moveAnchor()` | 0 | 移动锚点（取消选区） |
| `MoveMode.keepAnchor()` | 1 | 保留锚点（扩展选区） |

---

## QSyntaxHighlighter - 语法高亮

为 QTextDocument 提供基于回调的语法高亮（用于代码编辑器）。高亮回调为 `CFunc<(Int64, CString) -> Unit>` 类型。

```cangjie
import cjqt6.gui.*

let doc = QTextDocument()
let highlighter = QSyntaxHighlighter(doc.getPtr())

// 设置高亮回调：收到文本块内容后，用 setFormat 应用格式
highlighter.setOnHighlight(CFunc { (selfId: Int64, text: CString) =>
    let line = text.toString()
    if (line.startsWith("//")) {
        highlighter.setFormat(0, line.size, 0xFF00AA00)  // 注释绿色
    }
})

highlighter.rehighlight()  // 重新高亮整个文档
highlighter.close()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(docPtr: Int64)` | 创建语法高亮器（关联 QTextDocument 指针） |
| `setOnHighlight(callback: CFunc<(Int64, CString) -> Unit>)` | 设置高亮回调（收到文本块内容） |
| `setFormat(start: Int32, count: Int32, color: Int64, bold: Bool, italic: Bool, underline: Bool)` | 设置文本格式（颜色/粗体/斜体/下划线） |
| `setFormat(start: Int32, count: Int32, color: Int64)` | 设置文本格式（仅颜色） |
| `rehighlight()` | 重新高亮整个文档 |
| `document(): Int64` | 获取关联文档指针 |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

> 说明：`setFormat` 的 `color` 为 ARGB 值（如 `0xFF00AA00` 表示不透明绿色）；回调内通过 `highlighter` 捕获引用调用 `setFormat` 应用格式。
