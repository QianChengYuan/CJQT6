# UI2CJ — Qt Designer .ui → CJQT6 仓颉代码生成器

> 配套仓库：`https://gitcode.com/yuan_1992/CJQT6`（Qt6 版，v1.7.0+）
> 本文档所有 API 引用均以该仓库 README 的「5 分钟最小示例」及 `src/` 实际导出名为唯一真相源。
> **不要参考** `Cangjie-TPC/CJQT`（旧版 Qt5.14.2）以及任何 CSDN / DevPress 文章——
> 它们混用 `QApplication.create()`、`QPushButton(win)` 构造传参、`button.connect{...}` 等旧 API，
> 在 CJQT6 上会编译失败。

---

## 1. 目标与非目标

### 1.1 目标
将 Qt Designer 保存的 `.ui`（XML，根 `<ui version="4.0">`）**静态翻译**为符合 CJQT6 风格的仓颉源码文件 `xxx_ui.cj`，
使开发者可以 `import` 后直接使用，无需在运行时依赖 `QUiLoader`。

### 1.2 非目标（明确不做）
- ❌ 不做运行时动态加载（那是 `QUiLoader` 的事，仓库已支持）
- ❌ 不做 `.cj → .ui` 反向生成
- ❌ 不为 Designer 里**未封装到 CJQT6 的控件**做兜底（遇到即报错退出，见 §4）
- ❌ 不生成 `main()` / `app.exec()`，入口由开发者自己写
- ❌ 不生成 `delete` / `close` 调用（内存管理由 CJQT6 封装类负责）
- ❌ 不处理自定义 `Q_OBJECT` 子类（roadmap 反方向清单明确禁止）

---

## 2. 输入：`.ui` 文件固定格式

`.ui` 是 Qt Designer 输出的 XML，Schema 由 Qt 定义，格式固定。生成器只需解析以下节点：

| XML 节点 | 含义 | 出现位置 |
|---------|------|---------|
| `<ui version="4.0">` | 根元素，固定版本号 | 根 |
| `<class>Name</class>` | Designer 里的类名，用作生成类名的提示 | 根下 |
| `<widget class="Qxxx" name="objName">` | 控件实例 | 任意层级 |
| `<layout class="Qxxx" name="objName">` | 布局实例 | 控件或布局内 |
| `<property name="xxx"><type>val</type></property>` | 属性设置 | widget/layout 内 |
| `<item>` | 布局子项 | layout 内 |
| `<connections><connection>` | 信号槽连接 | 根下 |
| `<customwidget>` / `<customwidgets>` | 自定义控件声明 | 根下（本项目忽略） |

**类型标签**（`<property>` 的子节点）：
`string`、`bool`、`number`、`double`、`enum`、`rect`、`size`、`font`、`stylesheet`、`set`（flags 集合）。

---

## 3. 输出：仓颉源码形态

### 3.1 生成文件模板

输入 `mainwindow.ui`（`<class>MainWindow</class>`）→ 输出 `mainwindow_ui.cj`：

```cangjie
package myproj.ui

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

/*
 * 本文件由 ui2cj 从 mainwindow.ui 自动生成，请勿手工修改。
 * 信号回调请通过 setupSignals(handler) 注入。
 */

public class MainWindowUi {
    // —— 由 <widget name="xxx"> 生成的字段，全部 let + 私有化 ——
    let mainWindow: QMainWindow
    let centralWidget: QWidget
    let labelTitle: QLabel
    let btnOk: QPushButton
    let mainLayout: QVBoxLayout

    // —— 构造：按 .ui 里的父子关系与属性顺序还原 ——
    public init() {
        mainWindow = QMainWindow.new()
        mainWindow.setWindowTitle("MainWindow")
        mainWindow.resize(800, 600)

        centralWidget = QWidget.new()
        mainWindow.setCentralWidget(centralWidget)

        mainLayout = QVBoxLayout.new(centralWidget)

        labelTitle = QLabel.new("")
        labelTitle.setText("Hello CJQT6")
        labelTitle.setAlignment(Alignment.Center.value)
        mainLayout.addWidget(labelTitle.getPtr())

        btnOk = QPushButton.new("")
        btnOk.setText("OK")
        mainLayout.addWidget(btnOk.getPtr())
    }

    // —— 信号连接：由 <connections> 翻译而来 ——
    public func setupSignals(handler: MainWindowHandler): Unit {
        btnOk.setOnClicked(|| handler.onBtnOkClicked())
    }

    // —— 暴露给外部的访问器 ——
    public func getMainWindow(): QMainWindow { mainWindow }
    public func show(): Unit { mainWindow.show() }
}

// —— 信号处理器接口，使用者自行实现 ——
public interface MainWindowHandler {
    func onBtnOkClicked(): Unit
}
```

### 3.2 命名规则
- `<widget name="btnOk">` → 字段名 `btnOk`（保持 Designer 原名，首字母已小写的不变）
- Designer 里首字母大写的名字（如 `BtnOk`）→ 字段名 `btnOk`（首字母强制小写）
- 与仓颉关键字冲突时追加下划线：`class` → `class_`
- 生成类名 = `<class>` 标签值 + `Ui` 后缀：`MainWindow` → `MainWindowUi`
- 处理器接口名 = 生成类名去掉 `Ui` + `Handler`：`MainWindowHandler`

---

## 4. 控件映射表（Qt 类名 → CJQT6 导出名）

**只列 CJQT6 实际已封装的控件**。遇到下表没有的控件，**生成器立即报错并退出**，
绝不猜测或 fallback 到 `QWidget` 万能类型（roadmap 明确 CJQT6 无反射，不能动态兜底）。

| .ui `class` | CJQT6 类型 | 所在包 | 备注 |
|-------------|-----------|-------|------|
| `QMainWindow` | `QMainWindow` | `cjqt6.widgets` | 顶层窗口 |
| `QWidget` | `QWidget` | `cjqt6.widgets` | 通用容器 |
| `QPushButton` | `QPushButton` | `cjqt6.widgets` | |
| `QLabel` | `QLabel` | `cjqt6.widgets` | |
| `QLineEdit` | `QLineEdit` | `cjqt6.widgets` | |
| `QTextEdit` | `QTextEdit` | `cjqt6.widgets` | |
| `QPlainTextEdit` | `QPlainTextEdit` | `cjqt6.widgets` | |
| `QCheckBox` | `QCheckBox` | `cjqt6.widgets` | |
| `QRadioButton` | `QRadioButton` | `cjqt6.widgets` | |
| `QComboBox` | `QComboBox` | `cjqt6.widgets` | |
| `QSpinBox` | `QSpinBox` | `cjqt6.widgets` | |
| `QSlider` | `QSlider` | `cjqt6.widgets` | |
| `QProgressBar` | `QProgressBar` | `cjqt6.widgets` | |
| `QTabWidget` | `QTabWidget` | `cjqt6.widgets` | |
| `QMenuBar` | `QMenuBar` | `cjqt6.widgets` | |
| `QStatusBar` | `QStatusBar` | `cjqt6.widgets` | |
| `QGroupBox` | `QGroupBox` | `cjqt6.widgets` | |
| `QFrame` | `QFrame` | `cjqt6.widgets` | |
| `QScrollArea` | `QScrollArea` | `cjqt6.widgets` | |
| `QListView` | `QListView` | `cjqt6.widgets` | |
| `QTableView` | `QTableView` | `cjqt6.widgets` | |
| `QTreeView` | `QTreeView` | `cjqt6.widgets` | |
| `QVBoxLayout` | `QVBoxLayout` | `cjqt6.widgets` | 布局 |
| `QHBoxLayout` | `QHBoxLayout` | `cjqt6.widgets` | 布局 |
| `QGridLayout` | `QGridLayout` | `cjqt6.widgets` | 布局 |
| `QFormLayout` | `QFormLayout` | `cjqt6.widgets` | 布局 |

> 完整清单以仓库 `src/widgets/` 下实际 `.cj` 文件导出名为准。
> 若后续 CJQT6 新增控件，只需往本表追加一行，生成器无需改动逻辑。

---

## 5. 属性转换规则

`<property name="xxx">` 的子标签 → 调用对应 setter。

| 子标签类型 | 转换示例 | 说明 |
|-----------|---------|------|
| `string` | `<string>Hello</string>` → `setText("Hello")` | 按属性名映射 setter |
| `bool` | `<bool>true</bool>` → `setVisible(true)` | 直接转字面量 |
| `number` | `<number>42</number>` → `setValue(42)` | `Int32` |
| `double` | `<double>3.14</double>` → `setFactor(3.14)` | `Float64` |
| `enum` | `<enum>Qt::AlignCenter</enum>` → `Alignment.Center.value` | 见 §5.1 枚举映射 |
| `rect` | `x/y/w/h` → `setGeometry(x, y, w, h)` | 或拆 `resize` + `move` |
| `size` | `w/h` → `resize(w, h)` | |
| `font` | 拆 `setFontFamily` / `setFontSize` / `setBold` | |
| `stylesheet` | `setStyleSheet("QPushButton{...}")` | 透传字符串 |
| `set`（flags） | 按位或组合 → `setWindowFlags(flag1 | flag2)` | 见 §5.2 |

### 5.1 枚举映射（部分高频）
| Qt 枚举值 | CJQT6 写法 |
|-----------|-----------|
| `Qt::AlignCenter` | `Alignment.Center.value` |
| `Qt::AlignLeft` | `Alignment.Left.value` |
| `Qt::AlignRight` | `Alignment.Right.value` |
| `Qt::Horizontal` | `Orientation.Horizontal` |
| `Qt::Vertical` | `Orientation.Vertical` |
| `Qt::Checked` | `CheckState.Checked` |
| `Qt::Unchecked` | `CheckState.Unchecked` |

> 取值后缀 `.value` 是 CJQT6 把 Qt 枚举包成仓颉 `enum` 后的通用访问方式，
> 与 README 示例 `Alignment.Center.value` 一致。

### 5.2 属性名 → setter 映射（部分高频）
| 属性名 | setter |
|--------|--------|
| `windowTitle` | `setWindowTitle(String)` |
| `text` | `setText(String)` |
| `geometry` | `setGeometry(x, y, w, h)` |
| `minimumSize` / `maximumSize` | `setMinimumSize(w,h)` / `setMaximumSize(w,h)` |
| `enabled` | `setEnabled(Bool)` |
| `visible` | `setVisible(Bool)` |
| `styleSheet` | `setStyleSheet(String)` |
| `currentIndex` | `setCurrentIndex(Int32)` |
| `value` | `setValue(Int32)` / `setValue(Float64)`（按控件） |

---

## 6. 信号槽转换规则

### 6.1 `<connections>` 翻译

`.ui` 片段：
```xml
<connection>
  <sender>btnOk</sender>
  <signal>clicked()</signal>
  <receiver>MainWindow</receiver>
  <slot>onBtnOkClicked()</slot>
</connection>
```

→ 生成代码（放进 `setupSignals`）：
```cangjie
btnOk.setOnClicked(|| handler.onBtnOkClicked())
```

### 6.2 信号 → setter 映射

| 信号签名 | CJQT6 连接 API | 闭包形参 |
|---------|---------------|---------|
| `clicked()` | `setOnClicked(|| ...)` | 无 |
| `clicked(bool)` | `setOnClickedChecked(|checked| ...)` | `Bool` |
| `toggled(bool)` | `setOnToggled(|checked| ...)` | `Bool` |
| `textChanged(const QString&)` | `setOnTextChanged(|s| ...)` | `String` |
| `valueChanged(int)` | `setOnValueChanged(|v| ...)` | `Int32` |
| `currentIndexChanged(int)` | `setOnCurrentIndexChanged(|i| ...)` | `Int32` |
| `stateChanged(int)` | `setOnStateChanged(|s| ...)` | `Int32`（转 `CheckState`） |

> 所有 `setOnXxx` 返回 `SignalConnection`，可用于 `disconnect()`。
> 这是 CJQT6 的真实 API（见仓库 commit 记录「P0/P1/P2 信号槽完成」），
> 与旧版 `button.connect{...}` 完全不同。

### 6.3 不支持的信号
遇到映射表里没有的信号（如 `customSignal(int, QString)`）→ 生成器报错：
```
ui2cj: unsupported signal 'customSignal(int,QString)' on 'QMyWidget'
       (only signals listed in §6.2 are supported; extend the table if needed)
```

---

## 7. 布局与父子关系

- `<layout>` 生成的布局对象在构造时**必须传入父控件指针**，
  对齐 CJQT6 真实用法：`QVBoxLayout.new(centralWidget)`。
- `<item>` 子项按出现顺序调用：
  - 子项是 `<widget>` → `layout.addWidget(child.getPtr())`
  - 子项是 `<layout>` → `layout.addLayout(childLayout.getPtr())`
  - 子项带 `stretch` → `addWidget(ptr, stretch, alignment)`
- `QMainWindow` 的 `centralWidget` 通过 `setCentralWidget(widget.getPtr())` 设置。
- `QMenuBar` / `QStatusBar` 通过 `setMenuBar(bar.getPtr())` / `setStatusBar(bar.getPtr())`。

---

## 8. 项目落点（对齐仓库结构）

```
CJQT6/
└── tools/
    └── ui2cj/                 ← 新增独立仓颉工具项目
        ├── cjpm.toml          # package name = "ui2cj"，依赖 cjqt6（仅编译期类型参考，运行时不依赖）
        ├── src/
        │   ├── main.cj        # CLI 入口：解析参数、读 .ui、写 .cj
        │   ├── parse_ui.cj    # XML → WidgetNode 树
        │   ├── emit_cj.cj     # WidgetNode 树 → 仓颉源码字符串
        │   ├── type_map.cj    # §4 控件映射表 + §6.2 信号映射表
        │   ├── prop_map.cj    # §5.2 属性名 → setter 映射
        │   └── enum_map.cj    # §5.1 枚举映射
        └── test/
            ├── mainwindow.ui                  # 输入样例
            ├── mainwindow_ui.cj.snapshot      # 期望输出（快照测试）
            └── *.ui                           # 更多覆盖用例
```

### 8.1 CLI 用法
```bash
# 进入工具目录
cd tools/ui2cj

# 构建
cjpm build

# 运行：把 .ui 翻译成 .cj
cjpm run -- mainwindow.ui -o ../../examples/myapp/mainwindow_ui.cj

# 批量
cjpm run -- src/ui/*.ui -o ../../examples/myapp/ui/
```

---

## 9. 核心数据结构（仓颉侧）

```cangjie
// parse_ui.cj

public enum UiNode {
    | Widget(name: String, className: String, props: ArrayList<Prop>,
            children: ArrayList<UiNode>, layout: ?Layout)
    | LayoutItem(widget: UiNode, stretch: Int32, alignment: ?String)
}

public struct Prop {
    let name: String        // 属性名，如 "text"、"geometry"
    let type: String        // 子标签类型："string"|"bool"|"number"|"enum"|"rect"|...
    let raw: String         // 原始文本，交给 emit 阶段解释
}

public struct Connection {
    let sender: String      // widget name
    let signal: String      // 含括号，如 "clicked()"
    let receiver: String    // 通常是顶层 widget 名
    let slot: String        // 如 "onBtnOkClicked()"
}
```

---

## 10. 错误处理策略

| 情况 | 行为 |
|------|------|
| `.ui` 根不是 `<ui version="4.0">` | 报错退出：`unsupported .ui version: X.X` |
| 控件类不在 §4 映射表 | 报错退出：列出未知类 + 提示「请先给 CJQT6 封装该控件」 |
| 属性名不在 §5.2 映射表 | **警告**并跳过（不阻断），因为部分属性是 Qt 私有/不常用 |
| 信号不在 §6.2 映射表 | 报错退出：防止生成不可编译的代码 |
| `<connections>` 里 `receiver` 不是顶层 widget | 报错退出：当前只支持 receiver = 窗口自身 |
| XML 解析失败 | 报错并附行号 |

---

## 11. 与仓库 roadmap 的衔接

roadmap §6.1「Designer → 仓颉代码流水线」原文：
> 写一个仓颉工具（解析 `.ui` XML → 生成 `import cjqt6.*` 的布局+信号连接代码）；
> 依赖仓颉 `std.json`/`std.ast` 或直接字符串处理即可，无需 C++。

本文档是该条目的落地设计：
- ✅ 纯仓颉实现，零 C++ 改动
- ✅ 输出严格使用 CJQT6 真实 API（`QMainWindow.new()`、`setTitle`、`setLayout(ptr)`、`setOnClicked`）
- ✅ 不依赖运行时反射（仓颉无反射，roadmap 已确认）
- ✅ 输出文件可直接被 `cjpm build` 编译进业务项目
- ✅ 与现有 `QUiLoader` 静态加载互补：一个运行时、一个编译期，互不替代

---

## 12. 演进路径（建议顺序）

1. **MVP**：支持 `QMainWindow` + `QWidget` + `QPushButton` + `QLabel` + `QVBoxLayout`/`QHBoxLayout` + `text`/`windowTitle`/`geometry` 属性 + `clicked()` 信号 → 能跑通 README 那个最小示例的 `.ui` 版
2. **扩展控件**：按 §4 表逐个加，每加一个补一个 `test/*.ui` 快照
3. **扩展属性**：按 §5.2 表补，未知属性走「警告跳过」通道收集真实项目需求
4. **扩展信号**：按 §6.2 表补，并支持 `setOnClickedChecked` 重载消歧（对齐 roadmap P1）
5. **批量 + 目录递归**：支持 `ui2cj dir/` 一键转换整个 Designer 工程
6. **QSS 提取**：把 `styleSheet` 属性抽到独立 `.qss` 文件并 `setStyleSheet(readFile(...))`

---

## 附录 A：校验清单（生成代码必须可编译）

- [ ] 所有 `import` 路径以 `cjqt6.` 开头，不出现 `qt.` / `cjqt.`
- [ ] 构造统一用 `.new()` 或 `.new(parentPtr)`，不出现 `QPushButton(win)` 旧式构造
- [ ] 布局/控件加入布局前调用 `.getPtr()`
- [ ] 信号连接用 `setOnXxx(||...)` 闭包，不出现 `QObject::connect` 字符串
- [ ] 不生成任何 `delete` / `free` / `close` 调用
- [ ] 不生成 `main()`，入口留给业务代码
- [ ] 文件头有「自动生成、请勿手工修改」注释

---

*文档版本：v0.1  |  基于 CJQT6 仓库 README（v1.7.0，2026-08-08）及 roadmap.md 校对  |  最后更新：2026-08-09*
