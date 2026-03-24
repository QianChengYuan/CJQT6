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
