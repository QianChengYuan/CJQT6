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
| `setEnabled(enabled: Bool)` | 设置启用/禁用 |
| `isEnabled(): Bool` | 检查是否启用 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` | 设置最小尺寸 |
| `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最大尺寸 |
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
| `setEnabled(enabled: Bool)` | 设置启用/禁用 |
| `isEnabled(): Bool` | 检查是否启用 |
| `setStyleSheet(style: String)` | 设置样式表 |
| `setMinimumSize(minw: Int32, minh: Int32)` | 设置最小尺寸 |
| `setMaximumSize(maxw: Int32, maxh: Int32)` | 设置最大尺寸 |
| `setOnClick(callback: VoidCallback)` | 设置点击回调 |
| `disconnectClicked()` | 断开点击信号 |
| `show()` | 显示控件 |
| `hide()` | 隐藏控件 |
| `resize(width: Int32, height: Int32)` | 调整大小 |
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

---

## QScrollBar - 滚动条

独立的滚动条部件，支持水平/垂直方向、范围、步长与多种信号回调。

```cangjie
let scrollBar = QScrollBar(ScrollBarOrientation.Vertical)
scrollBar.setRange(0, 100)
scrollBar.setValue(50)
scrollBar.setSingleStep(1)
scrollBar.setPageStep(10)

scrollBar.setOnValueChanged({ value: Int32 =>
    println("滚动值: ${value}")
})
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(orientation: Int32)` | 创建滚动条（Horizontal=1 / Vertical=2） |
| `setRange(min, max)` | 设置范围 |
| `setValue(value)` | 设置当前值 |
| `value(): Int32` | 获取当前值 |
| `setSingleStep(step)` | 设置单步步长（箭头点击） |
| `setPageStep(step)` | 设置翻页步长（点击滑块空白区域） |
| `setOrientation(orientation)` | 设置方向 |
| `setMinimum(value)` / `minimum(): Int32` | 设置/获取最小值 |
| `setMaximum(value)` / `maximum(): Int32` | 设置/获取最大值 |
| `setSliderPosition(value)` / `sliderPosition(): Int32` | 设置/获取滑块位置 |
| `setTracking(tracking)` / `isTracking(): Bool` | 设置/获取跟踪（拖动时实时触发 valueChanged） |
| `setInvertedAppearance(value)` / `invertedAppearance(): Bool` | 设置/获取反向外观 |
| `setInvertedControls(value)` / `invertedControls(): Bool` | 设置/获取反向控制 |
| `setRepeatAction(action)` / `repeatAction(): Int32` | 设置/获取重复动作策略 |
| `triggerAction(action)` | 触发指定动作 |
| `setOnValueChanged(callback)` | 值变化回调 |
| `setOnSliderPressed(callback)` | 滑块按下回调 |
| `setOnSliderMoved(callback)` | 滑块拖动回调 |
| `setOnSliderReleased(callback)` | 滑块释放回调 |
| `setOnRangeChanged(callback)` | 范围变化回调 (min, max) |
| `setOnActionTriggered(callback)` | 动作触发回调 |
| `setEnabled(enabled)` | 设置启用/禁用 |
| `setStyleSheet(style)` | 设置样式表 |
| `show()` / `hide()` / `resize(w, h)` | 控件显示控制 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

**ScrollBarOrientation 方向常量**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `Horizontal` | 1 | 水平 |
| `Vertical` | 2 | 垂直 |

**ScrollBarRepeatAction 重复动作常量**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `SingleStep` | 1 | 单步 |
| `PageStep` | 2 | 翻页 |
| `ToMinimum` | 3 | 到最小值 |
| `ToMaximum` | 4 | 到最大值 |
| `SliderToMinimum` | 5 | 滑块到最小值 |
| `SliderToMaximum` | 6 | 滑块到最大值 |

---

## QSizeGrip - 窗口尺寸手柄

显示在窗口右下角的调整大小手柄。

```cangjie
let sizeGrip = QSizeGrip(window)
sizeGrip.setVisible(true)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(parent: QWidget)` | 创建手柄（指定父窗口） |
| `setVisible(visible: Bool)` | 设置可见性 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

---

## QSplashScreen - 启动画面

应用启动时显示的窗口，可显示消息文本。实现 `QtResource`，支持 try-with-resources。

```cangjie
let splash = QSplashScreen(pixmap)
splash.show()
splash.showMessage("加载中...")
splash.finish(mainWindow)  // 主窗口就绪后关闭
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空启动画面 |
| `init(pixmap: QPixmap)` | 使用图像创建 |
| `show()` | 显示 |
| `finish(window: QWidget)` | 主窗口就绪后结束启动画面 |
| `showMessage(message: String)` | 显示消息 |
| `showMessage(message, alignment: Int32)` | 显示消息并指定对齐方式 |
| `clearMessage()` | 清除消息 |
| `message(): String` | 获取当前消息 |
| `setPixmap(pixmap: QPixmap)` | 设置图像 |
| `setEnabled(enabled)` | 设置启用/禁用 |
| `setStyleSheet(style)` | 设置样式表 |
| `getPtr(): Int64` | 获取原生指针 |
| `isClosed(): Bool` / `isValid(): Bool` | 状态查询 |
| `close()` / `delete()` | 释放资源 |

---

## QSystemTrayIcon - 系统托盘图标

在系统托盘中显示图标、消息气泡和上下文菜单。注意：**不是 QWidget**，无 show/hide/resize 之外的控件方法。

```cangjie
let tray = QSystemTrayIcon()
tray.setIcon("/path/to/icon.png")
tray.setToolTip("我的应用")
tray.setContextMenu(menu.getPtr())
tray.show()

tray.showMessage("标题", "消息内容", MessageIcon.Info, 3000)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(parent!: Int64 = 0)` | 创建托盘图标 |
| `setIcon(iconPath: String)` | 设置图标（文件路径） |
| `setToolTip(tip: String)` | 设置工具提示 |
| `show()` / `hide()` / `isVisible(): Bool` | 显示/隐藏/查询 |
| `showMessage(title, message, iconType!: Int32, duration!: Int32)` | 显示消息气泡 |
| `setContextMenu(menuPtr: Int64)` | 设置上下文菜单（QMenu 指针） |
| `setOnActivated(callback)` | 激活回调（0=Unknown,1=Context,2=DoubleClick,3=Trigger,4=MiddleClick） |
| `setOnMessageClicked(callback)` | 消息气泡点击回调 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

**MessageIcon 消息图标类型**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `Info` | 0 | 信息 |
| `Warning` | 1 | 警告 |
| `Critical` | 2 | 严重 |

---

## QFontComboBox - 字体选择下拉框

列出系统可用字体族，支持按书写系统与字体筛选器过滤。

```cangjie
let fontCombo = QFontComboBox()
fontCombo.setCurrentFont("Arial")
fontCombo.setWritingSystem(FontWritingSystem.Chinese)
fontCombo.setFontFilters(FontFilters.ScalableFonts)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(parent!: Int64 = 0)` | 创建字体下拉框 |
| `setCurrentFont(family: String)` | 设置当前字体 |
| `currentFont(): String` | 获取当前字体 |
| `setWritingSystem(ws: Int32)` | 设置书写系统过滤 |
| `writingSystem(): Int32` | 获取书写系统 |
| `setFontFilters(filters: Int32)` | 设置字体筛选器（可按位或组合） |
| `fontFilters(): Int32` | 获取字体筛选器 |
| `setStyleSheet(style)` | 设置样式表 |
| `show()` / `hide()` / `resize(w, h)` | 控件显示控制 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

**FontFilters 字体筛选器**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `None` | 0 | 无过滤 |
| `ScalableFonts` | 1 | 可缩放字体 |
| `NonScalableFonts` | 2 | 不可缩放字体 |
| `MonospacedFonts` | 4 | 等宽字体 |
| `ProportionalFonts` | 8 | 比例字体 |

**FontWritingSystem 书写系统**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `Any` | 0 | 任意 |
| `Latin` | 1 | 拉丁 |
| `Greek` | 2 | 希腊 |
| `Cyrillic` | 3 | 西里尔 |
| `Arabic` | 4 | 阿拉伯 |
| `Hebrew` | 5 | 希伯来 |
| `Japanese` | 6 | 日文 |
| `Korean` | 7 | 韩文 |
| `Chinese` | 8 | 中文 |
| `SimplifiedChinese` | 9 | 简体中文 |
| `TraditionalChinese` | 10 | 繁体中文 |

---

## QProgressBar - 进度条

显示任务进度，支持方向、文本格式、对齐方式与值变化回调。实现 `QtResource`。

```cangjie
let progress = QProgressBar()
progress.setRange(0, 100)
progress.setValue(50)
progress.setFormat("%p%")       // 显示百分比
progress.setTextVisible(true)
progress.setOnValueChanged({ value: Int32 => ... })
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建进度条 |
| `setValue(value)` / `value(): Int32` | 设置/获取进度值 |
| `setRange(min, max)` | 设置范围 |
| `setMinimum(value)` / `minimum(): Int32` | 设置/获取最小值 |
| `setMaximum(value)` / `maximum(): Int32` | 设置/获取最大值 |
| `setTextVisible(visible)` / `isTextVisible(): Bool` | 设置/获取文本可见性 |
| `setFormat(format)` / `format(): String` | 设置/获取显示格式（如 `%p%`） |
| `text(): String` | 获取当前显示文本 |
| `setOrientation(orientation)` | 设置方向 |
| `setInvertedAppearance(invert)` / `invertedAppearance(): Bool` | 设置/获取反向外观 |
| `setTextDirection(direction)` / `textDirection(): Int32` | 设置/获取文本方向 |
| `setAlignment(alignment)` | 设置文本对齐方式 |
| `reset()` | 重置进度条 |
| `setOnValueChanged(callback)` | 值变化回调 |
| `setEnabled(enabled)` / `isEnabled(): Bool` | 启用/禁用 |
| `setStyleSheet(style)` | 设置样式表 |
| `setMinimumSize(w, h)` / `setMaximumSize(w, h)` | 设置尺寸限制 |
| `show()` / `hide()` / `resize(w, h)` | 控件显示控制 |
| `getPtr(): Int64` | 获取原生指针 |
| `isClosed(): Bool` / `isValid(): Bool` | 状态查询 |
| `close()` / `delete()` | 释放资源 |

**ProgressBarDirection 文本方向常量**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `TopToBottom` | 0 | 从上到下 |
| `BottomToTop` | 1 | 从下到上 |

---

## QRubberBand - 橡皮筋选框

在父控件上绘制矩形（或直线）选择区域，常用于框选。

```cangjie
let rubberBand = QRubberBand(RubberBandShape.Rectangle, parentWidget)
rubberBand.setGeometry(10, 10, 100, 80)
rubberBand.show()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(shape: Int32, parent: QWidget)` | 创建选框（Line=0 / Rectangle=1） |
| `setGeometry(x, y, w, h)` | 设置几何范围 |
| `move(x, y)` | 移动位置 |
| `resize(w, h)` | 调整大小 |
| `show()` / `hide()` | 显示/隐藏 |
| `x(): Int32` / `y(): Int32` / `width(): Int32` / `height(): Int32` | 获取几何值 |
| `setShape(shape)` / `shape(): Int32` | 设置/获取形状 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

**RubberBandShape 形状常量**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `Line` | 0 | 直线 |
| `Rectangle` | 1 | 矩形 |

---

## 输入验证器（Validators）

验证器可绑定到 QLineEdit 限制输入内容。通过顶层函数 `setLineEditValidator` 绑定。

```cangjie
// 整数验证器
let intValidator = QIntValidator(0, 100)
setLineEditValidator(lineEdit, intValidator)

// 浮点验证器（含小数位）
let doubleValidator = QDoubleValidator(0.0, 1.0, 2)
setLineEditValidator(lineEdit, doubleValidator)

// 正则表达式验证器
let regexValidator = QRegExpValidator("^[A-Za-z]+$")
setLineEditValidator(lineEdit, regexValidator)
```

### QIntValidator - 整数验证器

| 方法 | 说明 |
|------|------|
| `init(min, max)` | 创建验证器（范围） |
| `init()` | 创建全范围验证器 |
| `setRange(min, max)` | 设置验证范围 |
| `bottom(): Int32` / `setBottom(value)` | 获取/设置下限 |
| `top(): Int32` / `setTop(value)` | 获取/设置上限 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

### QDoubleValidator - 浮点验证器

| 方法 | 说明 |
|------|------|
| `init(min: Float64, max: Float64, decimals: Int32)` | 创建验证器 |
| `setRange(min, max, decimals)` | 设置验证范围 |
| `bottom(): Float64` / `setBottom(value)` | 获取/设置下限 |
| `top(): Float64` / `setTop(value)` | 获取/设置上限 |
| `decimals(): Int32` / `setDecimals(value)` | 获取/设置小数位数 |
| `notation(): Int32` / `setNotation(value)` | 获取/设置记数法 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

### QRegExpValidator - 正则表达式验证器

| 方法 | 说明 |
|------|------|
| `init(pattern: String)` | 创建验证器（Qt6 使用 QRegularExpression） |
| `setPattern(pattern)` | 重新设置正则表达式 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

---

## QGraphicsView - 图形视图

在窗口中显示 QGraphicsScene 的可滚动视口，支持缩放、旋转、平移与渲染提示。实现 `QtResource`。

```cangjie
let view = QGraphicsView()
let scene = QGraphicsScene()
view.setScene(scene)

view.setRenderHint(GraphicsViewRenderHint.Antialiasing)
view.setDragMode(GraphicsViewDragMode.RubberBandDrag)
view.scale(1.5, 1.5)
view.show()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(parent!: Int64 = 0)` | 创建图形视图 |
| `setScene(scene: QGraphicsScene)` | 设置场景 |
| `scene(): Int64` | 获取场景指针 |
| `setRenderHint(hint, enabled!: Bool)` | 设置单个渲染提示 |
| `setRenderHints(hints: Int32)` | 批量设置渲染提示 |
| `setDragMode(mode)` / `dragMode(): Int32` | 设置/获取拖拽模式 |
| `setViewportUpdateMode(mode)` | 设置视口更新模式 |
| `centerOn(x, y)` | 视图中心对准场景点 |
| `fitInView(x, y, w, h)` | 缩放使指定区域适配视口 |
| `scale(fx, fy)` | 缩放视图 |
| `rotate(angle)` | 旋转视图 |
| `translate(dx, dy)` | 平移视图 |
| `resetTransform()` | 重置变换 |
| `setInteractive(interactive)` / `isInteractive(): Bool` | 设置/获取交互性 |
| `setSceneRect(x, y, w, h)` | 设置场景矩形 |
| `setBackgroundBrush(r, g, b)` | 设置背景画刷颜色 |
| `setForegroundBrush(r, g, b)` | 设置前景画刷颜色 |
| `mapToScene(x, y): String` | 视口坐标映射到场景坐标（返回 "x,y" 字符串） |
| `show()` / `hide()` / `resize(w, h)` | 控件显示控制 |
| `getPtr(): Int64` | 获取原生指针 |
| `isClosed(): Bool` / `isValid(): Bool` | 状态查询 |
| `close()` / `delete()` | 释放资源 |

**常量类**:
| 常量类 | 值 | 说明 |
|--------|-----|------|
| `GraphicsViewAnchor.NoAnchor` | 0 | 无锚点 |
| `GraphicsViewAnchor.AnchorViewCenter` | 1 | 视图中心锚点 |
| `GraphicsViewAnchor.AnchorUnderMouse` | 2 | 鼠标位置锚点 |
| `GraphicsViewDragMode.NoDrag` | 0 | 禁止拖拽 |
| `GraphicsViewDragMode.ScrollHandDrag` | 1 | 抓手拖拽 |
| `GraphicsViewDragMode.RubberBandDrag` | 2 | 橡皮筋框选 |
| `GraphicsViewRenderHint.Antialiasing` | 0x01 | 抗锯齿 |
| `GraphicsViewRenderHint.TextAntialiasing` | 0x02 | 文字抗锯齿 |
| `GraphicsViewRenderHint.SmoothPixmapTransform` | 0x10 | 平滑像素变换 |
| `GraphicsViewRenderHint.LosslessImageRendering` | 0x40 | 无损图像渲染 |
| `GraphicsViewViewportUpdateMode.FullViewportUpdate` | 0 | 全视口更新 |
| `GraphicsViewViewportUpdateMode.MinViewportUpdate` | 1 | 最小视口更新 |
| `GraphicsViewViewportUpdateMode.SmartViewportUpdate` | 2 | 智能视口更新 |
| `GraphicsViewViewportUpdateMode.BoundingRectViewportUpdate` | 3 | 包围盒更新 |
| `GraphicsViewViewportUpdateMode.NoViewportUpdate` | 4 | 不更新 |

---

## QGraphicsScene - 图形场景

管理图形项的容器，可添加矩形、椭圆、线段、文本、自定义项及普通 Widget。

```cangjie
let scene = QGraphicsScene()
let itemPtr = scene.addRect(0.0, 0.0, 100.0, 50.0, 0, 0, 0, 2.0, 200, 200, 255)
scene.setBackgroundBrush(255, 255, 255)
scene.update()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建场景 |
| `addRect(x, y, w, h, penR, penG, penB, penW, brushR, brushG, brushB): Int64` | 添加矩形，返回项指针 |
| `addEllipse(x, y, w, h, penR, penG, penB, penW, brushR, brushG, brushB): Int64` | 添加椭圆，返回项指针 |
| `addLine(x1, y1, x2, y2, penR, penG, penB, penW): Int64` | 添加线段，返回项指针 |
| `addText(text: String): Int64` | 添加文本项，返回项指针 |
| `addItem(itemPtr: Int64)` | 添加图形项 |
| `addWidget(widgetPtr: Int64): Int64` | 添加普通 Widget，返回项指针 |
| `removeItem(itemPtr: Int64)` | 移除图形项 |
| `clear()` | 清空场景 |
| `items(): String` | 获取项列表（字符串形式） |
| `itemAt(x, y): Int64` | 获取指定位置项指针 |
| `setSceneRect(x, y, w, h)` | 设置场景矩形 |
| `sceneRect(): String` | 获取场景矩形 |
| `setBackgroundBrush(r, g, b)` | 设置背景画刷 |
| `update()` | 请求重绘 |
| `getPtr(): Int64` | 获取原生指针 |
| `isClosed(): Bool` / `isValid(): Bool` | 状态查询 |
| `close()` / `delete()` | 释放资源 |

---

## 图形项（QGraphicsItem 体系）

场景中的可绘制对象基类。通用方法（位置、旋转、缩放、可见性、透明度等）定义在 `QGraphicsItem`，子类继承。

### QGraphicsItem - 图形项基类

| 方法 | 说明 |
|------|------|
| `init(ptr: Int64)` | 由子类传入底层指针创建 |
| `setPos(x, y)` | 设置位置（场景坐标） |
| `pos(): String` | 获取位置（"x,y" 字符串） |
| `posX(): Float64` / `posY(): Float64` | 获取 X/Y 坐标 |
| `setZValue(z)` / `zValue(): Float64` | 设置/获取 Z 值（大者在上） |
| `setRotation(angle)` / `rotation(): Float64` | 设置/获取旋转角度 |
| `setScale(scale)` / `scale(): Float64` | 设置/获取缩放比例 |
| `setVisible(visible)` / `isVisible(): Bool` | 设置/获取可见性 |
| `setEnabled(enabled)` / `isEnabled(): Bool` | 设置/获取启用状态 |
| `setSelected(selected)` / `isSelected(): Bool` | 设置/获取选中状态 |
| `setOpacity(opacity)` / `opacity(): Float64` | 设置/获取不透明度（0.0~1.0） |
| `update()` | 请求重绘 |
| `sceneBoundingRectX/Y/W/H(): Float64` | 获取场景包围盒 |
| `scene(): Int64` | 获取所属场景指针 |
| `setParentItem(parentPtr)` | 设置父图形项 |
| `setToolTip(tip)` | 设置悬浮提示 |
| `setCursor(shape)` | 设置悬停光标形状 |
| `itemType(): Int32` | 获取图形项类型 |
| `getPtr(): Int64` | 获取原生指针 |

### QGraphicsRectItem - 矩形图形项

| 方法 | 说明 |
|------|------|
| `init()` / `init(x, y, w, h)` | 创建矩形项 |
| `setRect(x, y, w, h)` / `rect(): String` | 设置/获取矩形范围 |
| `setPen(r, g, b, width)` | 设置边框画笔 |
| `setBrush(r, g, b)` | 设置填充画刷 |
| `close()` | 释放资源 |

### QGraphicsEllipseItem - 椭圆图形项

| 方法 | 说明 |
|------|------|
| `init()` / `init(x, y, w, h)` | 创建椭圆项 |
| `setRect(x, y, w, h)` / `rect(): String` | 设置/获取外接矩形 |
| `setStartAngle(angle)` | 设置扇形起始角（0 为三点钟方向） |
| `setSpanAngle(angle)` | 设置扇形跨度角 |
| `setPen(r, g, b, width)` | 设置边框画笔 |
| `setBrush(r, g, b)` | 设置填充画刷 |
| `close()` | 释放资源 |

### QGraphicsLineItem - 线段图形项

| 方法 | 说明 |
|------|------|
| `init()` / `init(x1, y1, x2, y2)` | 创建线段项 |
| `setLine(x1, y1, x2, y2)` / `line(): String` | 设置/获取线段端点 |
| `setPen(r, g, b, width)` | 设置画笔 |
| `close()` | 释放资源 |

### QGraphicsTextItem - 文本图形项

| 方法 | 说明 |
|------|------|
| `init()` / `init(text: String)` | 创建文本项 |
| `setText(text)` / `text(): String` | 设置/获取文本 |
| `setHtml(html)` | 设置 HTML 富文本 |
| `setFont(family, pointSize: Float64, bold)` | 设置字体 |
| `setTextWidth(width)` | 设置文本宽度（自动换行） |
| `setDefaultTextColor(r, g, b)` | 设置默认文本颜色 |
| `close()` | 释放资源 |

### QGraphicsPixmapItem - 图像图形项

| 方法 | 说明 |
|------|------|
| `init()` / `init(pixmapPtr: Int64)` | 创建图像项 |
| `setPixmap(pixmapPtr)` | 设置图像（QPixmap 指针） |
| `setOffset(x, y)` | 设置图像偏移 |
| `close()` | 释放资源 |

### QGraphicsPathItem - 路径图形项

| 方法 | 说明 |
|------|------|
| `init()` | 创建路径项 |
| `setPen(r, g, b, width)` | 设置路径画笔 |
| `setBrush(r, g, b)` | 设置路径填充 |
| `close()` | 释放资源 |

### QGraphicsItemGroup - 图形项组

| 方法 | 说明 |
|------|------|
| `init()` | 创建组 |
| `addToGroup(itemPtr)` | 将项加入组 |
| `removeFromGroup(itemPtr)` | 将项移出组 |
| `close()` | 释放资源 |

> 说明：图形项的资源释放统一使用 `close()`；`QGraphicsItem` 基类本身无 `close()`，由各子类提供。

---

## QGraphicsOpacityEffect - 透明度特效

为控件设置整体不透明度（0.0 全透明 - 1.0 不透明），方法返回自身支持链式调用。

```cangjie
let effect = QGraphicsOpacityEffect()
effect.setOpacity(0.5).setEnabled(true)
println("当前不透明度: ${effect.opacity()}")
effect.delete()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建透明度特效 |
| `setOpacity(opacity: Float64): QGraphicsOpacityEffect` | 设置不透明度（0.0-1.0），返回自身 |
| `opacity(): Float64` | 获取当前不透明度 |
| `setEnabled(enabled: Bool): QGraphicsOpacityEffect` | 启用/禁用特效，返回自身 |
| `delete()` | 释放资源 |

---

## QGraphicsDropShadowEffect - 投影特效

为控件绘制带模糊的阴影，支持偏移、模糊半径与颜色设置。方法返回自身支持链式调用。

```cangjie
let effect = QGraphicsDropShadowEffect()
effect.setOffset(4.0, 4.0)
      .setBlurRadius(8.0)
      .setColor(0, 0, 0, 128)
      .setEnabled(true)
println("模糊半径: ${effect.blurRadius()}")
effect.delete()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建投影特效 |
| `setOffset(dx: Float64, dy: Float64): QGraphicsDropShadowEffect` | 设置阴影偏移（像素），返回自身 |
| `setBlurRadius(radius: Float64): QGraphicsDropShadowEffect` | 设置阴影模糊半径（像素），返回自身 |
| `blurRadius(): Float64` | 获取模糊半径 |
| `setColor(r: Int32, g: Int32, b: Int32, a: Int32): QGraphicsDropShadowEffect` | 设置阴影颜色（RGBA 0-255），返回自身 |
| `xOffset(): Float64` / `setXOffset(v: Float64)` | 获取/设置水平偏移 |
| `yOffset(): Float64` / `setYOffset(v: Float64)` | 获取/设置垂直偏移 |
| `setEnabled(enabled: Bool): QGraphicsDropShadowEffect` | 启用/禁用特效，返回自身 |
| `delete()` | 释放资源 |
