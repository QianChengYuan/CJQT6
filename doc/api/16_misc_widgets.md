# CJQT6 其他控件模块

本模块包含 LCD 数字显示、工具按钮等控件。

## QLCDNumber - LCD 数字显示

模拟 LCD 数字显示屏，可显示数字（支持十进制、十六进制、八进制、二进制）。

```cangjie
import cjqt6.widgets.*

// 创建默认6位LCD
let lcd = QLCDNumber()

// 创建指定位数的LCD
let lcd4 = QLCDNumber(8)  // 8位

// 显示数值
lcd.display(123.45)
lcd.displayInt(42)

// 设置显示模式
lcd.setMode(LCDMode.hex())    // 十六进制
lcd.setMode(LCDMode.dec())    // 十进制（默认）
lcd.setMode(LCDMode.oct())    // 八进制
lcd.setMode(LCDMode.bin())    // 二进制

// 设置段样式
lcd.setSegmentStyle(LCDSegmentStyle.filled())  // 填充样式
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建 LCD（默认6位） |
| `init(numDigits: Int32)` | 创建指定位数的 LCD |
| `display(value: Float64)` | 显示浮点数值 |
| `displayInt(value: Int32)` | 显示整数值 |
| `setMode(mode: Int32)` | 设置显示模式 |
| `mode(): Int32` | 获取显示模式 |
| `setSegmentStyle(style: Int32)` | 设置段样式 |
| `segmentStyle(): Int32` | 获取段样式 |
| `setSmallDecimalPoint(small: Bool)` | 设置小数点样式 |
| `smallDecimalPoint(): Bool` | 获取小数点样式 |
| `digitCount(): Int32` | 获取数字位数 |
| `setDigitCount(numDigits: Int32)` | 设置数字位数 |
| `checkOverflow(value: Float64): Bool` | 检查是否溢出 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

**显示模式常量** (`LCDMode`):
| 常量 | 说明 |
|------|------|
| `LCDMode.hex()` | 十六进制 (0) |
| `LCDMode.dec()` | 十进制 (1) |
| `LCDMode.oct()` | 八进制 (2) |
| `LCDMode.bin()` | 二进制 (3) |

**段样式常量** (`LCDSegmentStyle`):
| 常量 | 说明 |
|------|------|
| `LCDSegmentStyle.outline()` | 轮廓 (0) |
| `LCDSegmentStyle.filled()` | 填充 (1) |
| `LCDSegmentStyle.flat()` | 平面 (2) |

---

## QToolButton - 工具按钮

通常用于工具栏，支持图标、文字、弹出菜单等模式。

```cangjie
let toolBtn = QToolButton()
toolBtn.setText("工具")
toolBtn.setIcon(iconPtr)                    // 设置图标
toolBtn.setIconSize(24, 24)                 // 设置图标大小
toolBtn.setToolButtonStyle(ToolButtonTextBesideIcon)  // 图标旁显示文字

// 点击回调
toolBtn.setOnClick({ =>
    println("工具按钮被点击")
})

// 弹出菜单
toolBtn.setPopupMode(ToolButtonInstantPopup)
toolBtn.setMenu(menuPtr)
toolBtn.showMenu()

// 箭头按钮
toolBtn.setArrowType(ArrowDown)
toolBtn.setAutoRaise(true)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建工具按钮 |
| `setText(text: String)` | 设置文本 |
| `setIcon(iconPtr: Int64)` | 设置图标 |
| `setIconSize(width: Int32, height: Int32)` | 设置图标大小 |
| `setToolButtonStyle(style: Int32)` | 设置按钮样式 |
| `setPopupMode(mode: Int32)` | 设置弹出模式 |
| `setAutoRaise(enabled: Bool)` | 设置自动凸起 |
| `autoRaise(): Bool` | 获取自动凸起状态 |
| `setArrowType(arrowType: Int32)` | 设置箭头类型 |
| `setMenu(menuPtr: Int64)` | 设置关联菜单 |
| `showMenu()` | 显示菜单 |
| `setOnClick(callback: VoidCallback)` | 设置点击回调 |
| `disconnectClicked()` | 断开点击信号 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

**工具按钮样式常量**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `ToolButtonIconOnly` | 0 | 只显示图标 |
| `ToolButtonTextOnly` | 1 | 只显示文本 |
| `ToolButtonTextBesideIcon` | 2 | 文本在图标旁边 |
| `ToolButtonTextUnderIcon` | 3 | 文本在图标下方 |
| `ToolButtonFollowStyle` | 4 | 跟随样式 |

**弹出模式常量**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `ToolButtonInstantPopup` | 0 | 立即弹出 |
| `ToolButtonMenuButtonPopup` | 1 | 菜单按钮弹出 |
| `ToolButtonDelayedPopup` | 2 | 延迟弹出 |

**箭头类型常量**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `ArrowNoArrow` | 0 | 无箭头 |
| `ArrowUp` | 1 | 上箭头 |
| `ArrowDown` | 2 | 下箭头 |
| `ArrowLeft` | 3 | 左箭头 |
| `ArrowRight` | 4 | 右箭头 |
