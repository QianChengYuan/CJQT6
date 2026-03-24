# CJQT6 示例应用建议

基于 CJQT6 库当前提供的功能，以下是推荐的示例应用：

---

## 一、现有示例

| 示例 | 位置 | 功能 |
|------|------|------|
| music_player | `examples/music_player` | 音乐播放器（QMediaPlayer） |
| notepad | `examples/notepad` | 记事本（文本编辑） |
| tank_battle | `examples/tank_battle` | 坦克大战游戏（QPainter 绘图） |
| widgets_demo | `examples/widgets_demo` | 控件演示 |
| qml_test | `examples/qml_test` | QML 测试 |

---

## 二、推荐的新示例

### 🎨 绘图类（使用 QPainter/QPixmap）

#### 1. 画图板 - PaintApp
**难度：中等**

功能：
- 画笔、橡皮擦、形状工具（矩形、圆形、直线）
- 颜色选择、画笔粗细调节
- 保存/加载图片
- 撤销/重做

使用模块：
- `QEventWidget`（鼠标事件）
- `QPainter`、`QPen`、`QBrush`、`QColor`
- `QPixmap`（画布）
- `QFileDialog`（保存/加载）
- `QSlider`（画笔粗细）
- `QColorDialog`（颜色选择）

---

#### 2. 时钟应用 - AnalogClock
**难度：简单**

功能：
- 模拟时钟（时针、分针、秒针）
- 数字时间显示
- 可选：闹钟功能

使用模块：
- `QEventWidget`、`QTimer`（每秒刷新）
- `QPainter`（绘制表盘和指针）
- `QDateTime`（获取时间）

---

#### 3. 贪吃蛇游戏 - SnakeGame
**难度：中等**

功能：
- 经典贪吃蛇玩法
- 分数、速度递增
- 暂停/继续

使用模块：
- `QEventWidget`（键盘控制）
- `QTimer`（游戏循环）
- `QPainter`（绘制蛇和食物）

---

### 📊 数据/列表类（使用 QTableWidget/QTreeWidget）

#### 4. 通讯录管理 - ContactManager
**难度：中等**

功能：
- 添加/编辑/删除联系人
- 搜索功能
- 导入/导出 CSV

使用模块：
- `QTableWidget`（联系人列表）
- `QLineEdit`（搜索框）
- `QDialog`（添加/编辑对话框）
- `QFileDialog`（导入导出）

---

#### 5. 文件浏览器 - FileExplorer
**难度：中等**

功能：
- 目录树导航
- 文件列表
- 基本文件操作（重命名、删除）

使用模块：
- `QTreeWidget`（目录树）
- `QTableWidget`（文件列表）
- `QSplitter`（分割窗口）

---

#### 6. 待办事项 - TodoList
**难度：简单**

功能：
- 添加/删除任务
- 勾选完成
- 优先级排序

使用模块：
- `QTreeWidget` 或 `QListWidget`
- `QCheckBox`
- `QDateTimeEdit`（截止日期）

---

### 🛠️ 工具类

#### 7. 计算器 - Calculator
**难度：简单**

功能：
- 基本四则运算
- 历史记录
- 科学计算模式（可选）

使用模块：
- `QPushButton`（数字和运算符按钮）
- `QLineEdit` 或 `QLCDNumber`（显示屏）
- `QGridLayout`（布局）

---

#### 8. 单位换算器 - UnitConverter
**难度：简单**

功能：
- 长度、重量、温度等单位换算
- 实时计算

使用模块：
- `QComboBox`（选择单位）
- `QLineEdit`（输入数值）
- `QDoubleSpinBox`

---

#### 9. 密码生成器 - PasswordGenerator
**难度：简单**

功能：
- 自定义长度、字符类型
- 复制到剪贴板
- 密码强度指示

使用模块：
- `QLineEdit`（显示密码）
- `QSlider`（长度）
- `QCheckBox`（字符类型选项）
- `QProgressBar`（强度指示）

---

### 📱 界面类（使用 QMainWindow/QTabWidget）

#### 10. 设置面板 - SettingsPanel
**难度：简单**

功能：
- 多标签页设置界面
- 保存/加载设置

使用模块：
- `QMainWindow`、`QTabWidget`
- `QGroupBox`、`QCheckBox`、`QComboBox`
- `QSlider`、`QSpinBox`

---

#### 11. 多文档编辑器 - TabbedEditor
**难度：中等**

功能：
- 多标签页文本编辑
- 文件打开/保存
- 语法高亮（可选）

使用模块：
- `QTabWidget`
- `QTextEdit`
- `QMenuBar`、`QToolBar`

---

### 🎵 多媒体类

#### 12. 视频播放器 - VideoPlayer
**难度：中等**

功能：
- 播放本地视频文件
- 进度条、音量控制
- 播放/暂停/停止

使用模块：
- `QMediaPlayer`
- `QSlider`（进度条）
- `QPushButton`

---

### 💾 数据库类

#### 13. 图书管理系统 - LibraryManager
**难度：较难**

功能：
- 图书增删改查
- 借阅记录管理
- 搜索功能

使用模块：
- `QSqlDatabase`（SQLite）
- `QSqlQuery`
- `QTableWidget`
- `QLineEdit`（搜索）

---

#### 14. ~~个人记账本 - ExpenseTracker~~ ✅ 已完成
**难度：中等**
**位置：** `examples/expense_tracker/`

功能：
- ✅ 收支记录（添加/删除）
- ✅ 分类统计（本月支出/收入/结余）
- ✅ SQLite 数据持久化
- ✅ 表格展示

使用模块：
- `QSqlDatabase`、`QSqlQuery`
- `QTableWidget`
- `QComboBox`、`QLineEdit`、`QPushButton`
- `QLabel`、`QVBoxLayout`、`QHBoxLayout`、`QGridLayout`

---

## 三、示例优先级建议

| 优先级 | 示例 | 理由 |
|--------|------|------|
| P1 | 计算器 | 最简单，验证基础功能 |
| P1 | 模拟时钟 | 简单，展示 QPainter 能力 |
| P2 | 贪吃蛇 | 经典游戏，展示游戏开发模式 |
| P2 | 待办事项 | 实用，展示列表控件 |
| P2 | 画图板 | 综合性强，展示绘图能力 |
| P3 | 通讯录管理 | 展示表格和对话框 |
| P3 | 图书管理系统 | 展示数据库能力 |

---

## 四、开发建议

1. **修复内存问题后再开发复杂示例**：tank_battle 的渲染内存泄漏需要先修复
2. **禁用终结器**：确保 QWidget/QLabel 等类的终结器已注释，避免崩溃
3. **资源管理**：示例中记得显式调用 `delete()` 释放 Qt 对象

---

*本文档由 AI 生成，可根据实际需求调整*
