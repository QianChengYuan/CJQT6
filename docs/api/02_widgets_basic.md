# CJQT6 基础控件模块

本模块包含基础部件和输入控件。

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

**对齐常量** (cjqt6.gui):
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
| `text(): String` | 获取按钮文本 |
| `setOnClick(callback: VoidCallback)` | 设置点击回调 |
| `disconnectClick()` | 断开点击信号 |
| `setIcon(path: String)` | 从文件加载图标 |
| `setIconSize(w: Int32, h: Int32)` | 设置图标大小 |
| `setStandardIcon(type: Int32)` | 使用 Qt 标准图标 |
| `setCheckable(checkable: Bool)` | 设置是否可切换（开关模式） |
| `setChecked(checked: Bool)` | 设置选中状态（开关模式） |
| `isChecked(): Bool` | 获取选中状态（开关模式） |
| `setDefault(isDefault: Bool)` | 设置是否为默认按钮 |
| `setFlat(flat: Bool)` | 设置是否为扁平按钮 |
| `setEnabled(enabled: Bool)` | 设置启用/禁用 |
| `isEnabled(): Bool` | 检查是否启用 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `close()` | 释放资源（实现 QtResource） |
| `isClosed(): Bool` | 是否已释放 |
| `isValid(): Bool` | 对象是否有效 |
| `resize(w: Int32, h: Int32)` | 调整按钮大小 |

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

---

## QTextEdit - 多行文本编辑器

支持富文本编辑、查找替换、撤销/重做等功能。

```cangjie
let editor = QTextEdit()
editor.setText("Hello,\nWorld!")
editor.setReadOnly(false)

// 编辑操作
editor.undo()
editor.redo()
editor.cut()
editor.copy()
editor.paste()
editor.selectAll()

// 字体设置
editor.setFontFamily("Arial")
editor.setFontSize(14)
editor.setFontBold(true)
editor.setFontItalic(false)

// 查找替换
editor.find("Hello", false)
editor.replace("Hi")

// 打印
editor.print(printerPtr)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建文本编辑器 |
| `setText(text: String)` | 设置文本 |
| `text(): String` | 获取文本 |
| `setReadOnly(readonly: Bool)` | 设置只读 |
| `clear()` | 清空内容 |
| `cut()` | 剪切选中文本 |
| `copy()` | 复制选中文本 |
| `paste()` | 粘贴文本 |
| `selectAll()` | 全选文本 |
| `canPaste(): Bool` | 是否可以粘贴 |
| `undo()` | 撤销 |
| `redo()` | 重做 |
| `canUndo(): Bool` | 是否可以撤销 |
| `canRedo(): Bool` | 是否可以重做 |
| `isModified(): Bool` | 内容是否被修改 |
| `setModified(modified: Bool)` | 设置修改状态 |
| `setLineWrapMode(mode: Int32)` | 设置换行模式（0=NoWrap, 1=WidgetWidth, 2=ManualWidth） |
| `lineWrapMode(): Int32` | 获取换行模式 |
| `setFontFamily(family: String)` | 设置字体 |
| `setFontSize(size: Int32)` | 设置字号 |
| `setFontBold(bold: Bool)` | 设置粗体 |
| `setFontItalic(italic: Bool)` | 设置斜体 |
| `find(text: String, caseSensitive: Bool): Bool` | 查找文本 |
| `findNext(text: String, caseSensitive: Bool)` | 查找下一个 |
| `findPrev(text: String, caseSensitive: Bool)` | 查找上一个 |
| `replace(newText: String)` | 替换选中文本 |
| `replaceAll(oldText, newText, caseSensitive): Int32` | 替换所有匹配项 |
| `lineCount(): Int32` | 获取总行数 |
| `currentLine(): Int32` | 获取当前行号 |
| `currentColumn(): Int32` | 获取当前列号 |
| `characterCount(): Int32` | 获取字符总数 |
| `goToLine(line: Int32)` | 跳转到指定行 |
| `print(printerPtr: Int64)` | 打印文档 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |
