# CJQT6 基础控件模块

本模块包含当前源码中实际暴露出来的基础控件与输入控件 API。

## 基础部件

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
