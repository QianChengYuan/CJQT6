# ui2cj —— Qt Designer (.ui) → CJQT6 仓颉源码 转换工具（纯仓颉实现）

把 Qt Designer 生成的 `.ui` 文件一键转换成 CJQT6 仓颉源码，免去手写控件创建/属性/布局/信号连接。
本工具为**纯仓颉实现**（含自研轻量 XML 解析器），零第三方依赖，是 `examples/ui2cj_test/uic2cj.py`（Python 脚手架）的仓颉版，生成逻辑与之一致。

## 构建

```bash
cd tools/ui2cj
cjpm build          # 产物: tools/ui2cj/target/release/bin/main.exe
```

## 用法

```bash
# 转换到 stdout 效果预览（实际写入文件）
# 用法: ui2cj <form.ui> [output.cj] [--package <name>] [--project-dir <dir>] [--output <file>]

# ① 指定输出文件
tools/ui2cj/target/release/bin/main.exe login.ui login_gen.cj

# ② 自动探测 cjpm 工程（推荐）：向上查找 cjpm.toml 读包名；工程有 src/ 则默认输出 src/main.cj
tools/ui2cj/target/release/bin/main.exe login.ui

# ③ 只放 .ui 文件、目录下没有 cjpm.toml（无工程）：
#    自动生成最小可运行工程（cjpm.toml + src/main.cj），可直接 cjpm build / run
tools/ui2cj/target/release/bin/main.exe examples/ui2cj_demo/ui2cj_demo.ui

# ④ 显式指定包名 / 输出
tools/ui2cj/target/release/bin/main.exe login.ui --package my_app --output out.cj
```

### 参数

| 参数 | 说明 |
|------|------|
| `<form.ui>` | 必填，Qt Designer 导出的 `.ui` 文件 |
| `[output.cj]` | 可选位置参数，输出文件路径 |
| `--package <name>` | 首行生成 `package <name>`；缺省时从最近 `cjpm.toml` 的 `[package] name` 自动探测 |
| `--project-dir <dir>` | 指定 cjpm 工程根目录（默认取 `.ui` 所在目录向上查找） |
| `--output <file>` | 等价于位置参数，指定输出文件 |

### 自动探测行为

- **包名**：`--package` 显式指定 > 沿 `.ui` 目录向上找最近 `cjpm.toml` 读 `[package] name` > 不生成 `package` 行。
- **默认输出**：工程根有 `src/` 目录时输出 `src/main.cj`，否则输出 `<base>_ui.cj`（与 `.ui` 同目录）。
- **无工程引导**：目录上下均无 `cjpm.toml` 时，自动在 `.ui` 所在目录生成最小可运行工程：
  `cjpm.toml`（依赖自动指向 CJQT6 库根，`link-option` 指向 `releases/windows-x64`）+ `src/main.cj`，
  生成后即可 `cjpm build` / `cjpm run`。
- **库自身工程豁免**：向上探测时遇到包名 `cjqt6` 的 `cjpm.toml`（即 CJQT6 库本身，如仓库根），
  视为"非用户工程"，记为库根后继续向上；避免误把生成代码写进仓库源码。

## 支持范围

**控件**（`WIDGET_MAP`，可自行扩展）：QWidget/QPushButton/QToolButton/QLabel/QLineEdit/
QTextEdit/QPlainTextEdit/QTextBrowser/QCheckBox/QRadioButton/QComboBox/QSpinBox/QDoubleSpinBox/
QSlider/QProgressBar/QGroupBox/QTabWidget/QScrollArea/QFrame/QSplitter/QCalendarWidget/
QDateEdit/QTimeEdit/QDateTimeEdit/QListWidget/QTableWidget/QTreeWidget/QMainWindow/
QMenuBar/QMenu/QAction/QToolBar/QStatusBar/QStackedWidget/QDockWidget。

**布局**：QVBoxLayout / QHBoxLayout / QGridLayout / QFormLayout（支持嵌套，控件自动 `getPtr()` 挂载）。
布局变量名取自 `.ui` 中布局元素的 `name` 属性（如 `verticalLayout_4`），保证同名兄弟布局不冲突。

**属性**：通用（windowTitle/enabled/toolTip/styleSheet/minimumSize/maximumSize）+ 各控件常用
（text/placeholderText/echoMode/alignment/checked/value/range/orientation/currentIndex 等）。

**信号**（`SIGNAL_MAP`）：clicked/toggled/textChanged/returnPressed/editingFinished/
valueChanged/currentIndexChanged/currentTextChanged/stateChanged/sliderMoved/activated，
自动生成顶层 `let` 回调骨架 + 连接语句。

**两种 .ui 形态**：带 `<layout>` 的生成布局挂载；无布局（绝对定位）的生成
`setWidgetGeometry` + `setWidgetParent`；`QMainWindow` 自动生成 centralwidget 布局 +
菜单栏/状态栏挂载。

> 生成代码不含 `.ui` 里的资源（icon/stylesheet 引用的图片文件），如需使用请在生成后自行补充。

## 生成物结构

```cangjie
package <name>            # 仅自动探测或 --package 指定时输出
import cjqt6.core.*       # 按需合并
import cjqt6.gui.*
import cjqt6.widgets.*

let on_xxx_clicked: VoidCallback = { =>   // 回调骨架（可捕获顶层全局 ?T 状态）
    // TODO: 处理 xxx 的 clicked() 事件
}

main(): Int64 {
    let app = QApplication()
    // 控件创建 + 属性 + 布局 + 信号连接
    ...
    Form.show()
    let result = app.exec()
    return Int64(result)
}
```

## 验证示例

- `examples/ui2cj_test/untitled.ui`：绝对定位形态（`setWidgetGeometry` + `setWidgetParent`）；
- `examples/ui2cj_test/login_form.ui`：QFormLayout 嵌套 + 信号回调（参考输出 `login_form_gen.cj`）；
- `mainwindow.ui`（QMainWindow + 菜单栏/状态栏）：生成 `setCentralWidget`/`setMenuBar`/`setStatusBar` 与 `import cjqt6.menu.*`。

以上用例已端到端验证：生成代码在独立 cjpm 工程中 `cjpm build` 编译通过并可运行（窗口正常显示）。

## 目录结构

```
tools/ui2cj/
├── cjpm.toml          # 独立 cjpm 工程（executable）
└── src/
    ├── main.cj        # CLI 入口：参数解析、cjpm 工程自动探测、默认输出路径
    ├── gen.cj         # 生成器：控件/布局/信号映射、属性分派、import 合并、main 组装
    └── xml_parser.cj  # 自研轻量 XML 解析器（无外部依赖）
```

## 二次开发

- 新增控件：`gen.cj` 的 `initMaps()` 里 `WIDGET_MAP`/`WIDGET_MOD` 加一项（Qt 类名 → (CJQT6 类, import 模块)）；
- 新增布局：`initLayoutMaps()` 加一项（标签 → (CJQT6 布局类, 模块)）；
- 新增属性：`handleProperty()` 里按控件类型补分支；
- 新增信号：`initSignalMaps()` 加一项（信号签名 → (setOnXxx 方法, 回调类型)）；
- 通用属性/取值辅助见 `getString`/`getBool`/`getEnum`/`getNumber`/`rectValue` 等函数。

## 与 Python 脚手架的关系

- 本工具生成逻辑移植自 `examples/ui2cj_test/uic2cj.py`，命令行参数与自动探测行为保持一致；
- 区别：纯仓颉可执行文件，无需 Python 环境；XML 解析不依赖任何第三方库。
