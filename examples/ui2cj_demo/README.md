# uic2cj —— Qt Designer → 仓颉代码脚手架

把 Qt Designer 生成的 `.ui` 文件一键转换成 CJQT6 仓颉源码，免去手写控件创建/属性/布局/信号连接。

## 用法

**一键（推荐）**：自动探测 `cjpm.toml` 包名、默认输出 `src/main.cj`、自动 `cjpm build`：

```bash
# Windows（仓库根执行）
.\scripts\gen-ui.ps1 examples\ui2cj_test\login_form.ui

# 可选参数：指定输出文件 / 跳过编译 / 指定工程目录
.\scripts\gen-ui.ps1 .\form.ui -Out form_gen.cj -NoBuild
.\scripts\gen-ui.ps1 .\form.ui -ProjectDir examples\my_app
```

**直接调用脚本**：自动探测包名 + 默认输出到工程 `src/main.cj`（有 `src/` 时）：

```bash
python uic2cj.py form.ui                 # 自动填 package + 输出 src/main.cj
python uic2cj.py form.ui --build         # 生成后自动 cjpm build
python uic2cj.py form.ui out.cj --package my_app   # 手动指定输出/包名
```

> 生成代码不含 `.ui` 里的资源（icon/stylesheet 文件），如需使用请在生成后自行补充。

## 支持范围

**控件**（`WIDGET_MAP`，可自行扩展）：QWidget/QPushButton/QToolButton/QLabel/QLineEdit/
QTextEdit/QPlainTextEdit/QTextBrowser/QCheckBox/QRadioButton/QComboBox/QSpinBox/QDoubleSpinBox/
QSlider/QProgressBar/QGroupBox/QTabWidget/QScrollArea/QFrame/QSplitter/QCalendarWidget/
QDateEdit/QTimeEdit/QDateTimeEdit/QListWidget/QTableWidget/QTreeWidget/QMainWindow/
QMenuBar/QMenu/QAction/QToolBar/QStatusBar/QStackedWidget/QDockWidget。

**布局**：QVBoxLayout / QHBoxLayout / QGridLayout / QFormLayout（支持嵌套，控件自动 `getPtr()` 挂载）。

**属性**：通用（windowTitle/enabled/toolTip/styleSheet/minimumSize/maximumSize）+ 各控件常用
（text/placeholderText/echoMode/alignment/checked/value/range/orientation/currentIndex 等）。

**信号**（`SIGNAL_MAP`）：clicked/toggled/textChanged/returnPressed/editingFinished/
valueChanged/currentIndexChanged/currentTextChanged/stateChanged/sliderMoved/activated，
自动生成顶层 `let` 回调骨架 + 连接语句。

**两种 .ui 形态**：带 `<layout>` 的生成布局挂载；无布局（绝对定位）的生成
`setWidgetGeometry` + `setWidgetParent`。

## 生成物结构

```
package <name>            # 仅 --package 指定时输出
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

- `untitled.ui` + 生成物（`src/main.cj` 当前版本）：绝对定位形态；
- `login_form.ui` + 生成物见 `login_form_gen.cj`（本目录示例，含 QFormLayout 嵌套 + 信号回调）。

`src/main.cj` 由 `uic2cj.py` 生成，`cjpm build` 可编译运行。

## 二次开发

- 新增控件：`WIDGET_MAP` 加一项（Qt 类名 → (CJQT6 类, import 模块)）；
- 新增属性：`handle_property()` 里按控件类型补分支；
- 新增信号：`SIGNAL_MAP` 加一项（信号签名 → (setOnXxx 方法, 回调类型)）。
