# 更新日志

所有重要的变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.1.0] - 2026-07-18

### 新增

**C++ 桥接层**
- `qVBoxLayoutAddWidgetStretch` / `qHBoxLayoutAddWidgetStretch` — 布局 addWidget 支持 stretch 权重参数
- `qWidgetSetEnabled` / `qWidgetIsEnabled` — 控件启用/禁用
- `qWidgetSetMinimumSize` / `qWidgetSetMaximumSize` — 控件最小/最大尺寸约束
- `qWidgetSetVisible` / `qWidgetIsVisible` — 控件可见性控制
- `qWidgetSetToolTip` — 控件工具提示
- `qWidgetSetStyleSheet` — 控件级样式表

**仓颉公开 API**
- `QVBoxLayout.addWidget(ptr, stretch)` / `QHBoxLayout.addWidget(ptr, stretch)` — 带权重的 addWidget 重载
- `QLabel.setStyleSheet()` — 标签样式表
- `QPushButton.setEnabled()` / `isEnabled()` — 按钮开关控制
- `QTabWidget.setMinimumSize()` / `QTextEdit.setMinimumSize()` / `QPlainTextEdit.setMinimumSize()`
- `QTextBrowser.setMinimumSize()` / `QToolBox.setMinimumSize()` / `QFontComboBox.getPtr()`
- `QTableView` / `QListWidget` / `QTreeWidget` — 补充 setMinimumSize/setMaximumSize/setStyleSheet

**新模块文件**
- `src/core/` — clipboard, desktopservices, filewatcher, propertyanimation, screen, settings, shortcut, standardpaths
- `src/widgets/` — buttongroup, completer, dockwidget, fontcombobox, graphiceffect, graphicsview, keysequenceedit, mdiarea, plaintextedit, stackedwidget, systemtrayicon, textbrowser, toolbox
- `src/multimedia/soundeffect.cj`
- `src/paint/fontdb.cj`

**示例程序**
- `examples/all_controls_demo/` — 全控件演示示例（7 分类页面 + 侧边栏导航），覆盖基础控件、文本输入、数值控件、选择控件、容器布局、高级控件、对话框

### 改进
- 布局系统支持 stretch 权重，解决状态栏占窗口一半高度的问题
- Linux x86_64 bridge 在 WSL Ubuntu 24.04 / Qt 6.4.2 / GCC 13.3 编译验证通过
- `.gitignore` 排除 `build_linux/`，保留 releases/ 下 .so/.dll/.dll.a

### 已知问题
- QML 模块 `load/loadData()` 在仓颉运行时卡住（2026-03-20 已记录）
- `cjpm run` 在新终端需要手动设 PATH 或重启终端

---

## [1.0.1] - 2026-07-17

### 新增

**C++ 桥接层**
- `qWidgetSetParent` — 设置控件父窗口，支持绝对坐标独立布局
- `qWidgetMove`、`qWidgetX`、`qWidgetY` — 控件位置查询与移动
- `qWidgetSetFixedSize` — 固定控件尺寸
- `qWidgetSetWindowIcon` — 窗口图标设置
- `qLabelText` — QLabel 文本获取
- `qLabelSetWordWrap`、`qLabelWordWrap` — QLabel 自动换行
- `qButtonSetCheckable`、`qButtonSetChecked`、`qButtonIsChecked` — QPushButton 开关模式
- `qButtonSetDefault`、`qButtonSetFlat` — QPushButton 外观选项
- `qComboBoxCount`、`qComboBoxItemText` — QComboBox 列表查询
- `qComboBoxSetEditable`、`qComboBoxRemoveItem` — QComboBox 编辑与删除

**仓颉公开 API**
- `QWidget.setGeometry()` / `move()` / `x()` / `y()` / `setFixedSize()` / `setWindowIcon()`
- `setWidgetGeometry()` / `setWidgetParent()` — 对任意控件设置几何与父窗口
- `QLabel.text()` / `setWordWrap()` / `wordWrap()`
- `QPushButton.setCheckable()` / `setChecked()` / `isChecked()` / `setDefault()` / `setFlat()`
- `QComboBox.count()` / `itemText()` / `setEditable()` / `removeItem()`

**工具链**
- `scripts/update-bridge.ps1` — 一键重编译 bridge 并同步到 releases 目录
- 用户 PATH 环境变量支持

### 改进
- README 中 Qt/DLL 路径改为 `/path/to/` 通用占位符
- `Alignment` 冲突问题解决

### 已知问题
- QML 模块 `load/loadData()` 在仓颉运行时卡住（2026-03-20 已记录）
- `cjpm run` 在新终端需要手动设 PATH 或重启终端
- 缺少 `setFont` 等高级属性方法（下一版本计划）

---

## [1.0.0] - 2026-05-07

### 新增
- 首次发布到仓颉中心仓
- 支持 Linux x86_64、Windows x86_64、macOS x86_64/arm64 多平台
- 15 个模块：core、widgets、gui、dialogs、menu、views、paint、process、qml、multimedia、sql、print、resource、network
- 100+ 控件/类封装
- Qt6 信号槽机制（12 对 connect/disconnect，5 种回调类型）
- 资源管理接口（QtResource + try-with-resources + 异常层级）
- 11 个可编译示例程序（计算器、记事本、绘图、音乐播放器、贪吃蛇、坦克大战等）

---

## 版本说明

- **主版本号 (MAJOR)**: 不兼容的 API 变更
- **次版本号 (MINOR)**: 向后兼容的功能新增
- **修订号 (PATCH)**: 向后兼容的问题修复