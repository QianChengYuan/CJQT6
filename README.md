# CJQT6 - 仓颉语言的Qt6封装库

CJQT6 是一个为仓颉(Cangjie)语言提供的Qt6封装库，通过FFI桥接技术让仓颉语言能够使用Qt6的GUI功能。

## 项目结构

```
CJQT6/
├── CMakeLists.txt              # CMake构建配置
├── README.md                   # 项目说明文档
├── cjpm.toml                   # 仓颉项目配置
│
├── doc/                        # 文档目录
│   ├── api/                    # API文档（已拆分）
│   │   ├── README.md           # API索引
│   │   ├── 01_core.md          # 核心模块
│   │   ├── 02_widgets_basic.md # 基础控件
│   │   ├── 03_widgets_selection.md
│   │   ├── 04_containers_layout.md
│   │   ├── 05_views.md
│   │   ├── 06_menu_dialogs.md
│   │   ├── 07_events.md
│   │   ├── 08_paint.md         # 绘图模块
│   │   ├── 09_process.md
│   │   ├── 10_datetime.md
│   │   ├── 11_qml.md
│   │   ├── 12_signal_slot.md
│   │   ├── 13_multimedia.md
│   │   ├── 14_print.md
│   │   └── 15_examples_faq.md  # 示例与FAQ
│   ├── 封装进度.md
│   ├── 环境检测报告.md
│   ├── 项目规划.md
│   ├── 重构总结.md
│   ├── cjpm_manual.md
│   ├── CJQT6仓颉基础窗口.md
│   ├── CODE_REVIEW.md
│   └── EXAMPLE_IDEAS.md
│
├── native/                     # C++原生桥接代码
│   ├── build/                  # CMake构建输出
│   │   └── lib/
│   │       └── libcjqt6_bridge.so  # FFI桥接库
│   ├── includes/               # C++头文件
│   │   ├── cj_string.h
│   │   ├── core.h
│   │   ├── gui.h
│   │   ├── types.h
│   │   ├── version.h
│   │   └── widgets.h
│   └── src/                    # C++实现
│       ├── core/               # 核心模块
│       │   ├── bridge_core.cpp
│       │   ├── bridge_events.cpp
│       │   ├── bridge_signal.cpp  # 信号槽桥接
│       │   └── string.cpp
│       ├── gui/                # GUI模块
│       ├── widgets/            # 部件模块
│       ├── views/              # 视图模块
│       ├── paint/              # 绘图模块
│       ├── process/            # 进程模块
│       └── qml/                # QML模块
│
├── src/                        # 仓颉源代码（模块化）
│   ├── main.cj                 # 主入口
│   ├── core/                   # 核心模块
│   │   ├── application.cj
│   │   ├── widget.cj
│   │   ├── timer.cj
│   │   ├── signal.cj           # 信号类型定义
│   │   ├── events.cj
│   │   └── process.cj
│   ├── widgets/                # 部件模块
│   │   ├── common.cj
│   │   ├── label.cj
│   │   ├── pushbutton.cj
│   │   ├── lineedit.cj
│   │   ├── textedit.cj
│   │   ├── checkbox.cj
│   │   ├── radiobutton.cj
│   │   ├── spinbox.cj
│   │   ├── slider.cj
│   │   ├── combobox.cj
│   │   ├── progressbar.cj
│   │   ├── containers.cj
│   │   └── datetime.cj
│   ├── gui/                    # GUI模块
│   │   ├── types.cj
│   │   └── layout.cj
│   ├── dialogs/                # 对话框模块
│   │   └── dialogs.cj
│   ├── menu/                   # 菜单模块
│   │   └── menu.cj
│   ├── views/                  # 视图模块
│   │   ├── tablewidget.cj
│   │   ├── listwidget.cj
│   │   └── treewidget.cj
│   ├── paint/                  # 绘图模块
│   │   └── painter.cj
│   └── qml/                    # QML模块
│       └── qml.cj
│
├── examples/                   # 示例程序
│   ├── run_example.sh          # 运行脚本
│   ├── lib/                    # 共享库目录
│   ├── widgets_demo/           # 常用控件演示
│   ├── analog_clock/           # 模拟时钟
│   ├── calculator/             # 计算器
│   ├── notepad/                # 记事本
│   ├── paint_app/              # 绘图应用
│   ├── todo_list/              # 待办事项
│   ├── expense_tracker/        # 记账应用
│   ├── music_player/           # 音乐播放器
│   ├── tank_battle/            # 坦克大战游戏
│   ├── snake_game/             # 贪吃蛇游戏
│   └── qml_test/               # QML测试
│
└── tests/                      # 测试代码
```

## 技术架构

```
┌─────────────────────────────────────────────────────┐
│                   仓颉应用程序                        │
│  ┌─────────────────────────────────────────────┐   │
│  │  CJQT6 仓颉封装类                             │   │
│  │  QApplication / QWidget / QTimer            │   │
│  │  QLabel / QPushButton / QLineEdit           │   │
│  │  QSpinBox / QSlider / QProgressBar          │   │
│  │  QTableWidget / QGroupBox / QTabWidget      │   │
│  │  QListWidget / QTreeWidget                  │   │
│  │  QMessageBox / QFileDialog / QInputDialog   │   │
│  │  QMenuBar / QMenu / QAction / QToolBar      │   │
│  └─────────────────────────────────────────────┘   │
│                        │                            │
│                   FFI调用 (foreign)                 │
│                        ▼                            │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│              libcjqt6_bridge.so                      │
│         C++桥接函数 (extern "C")                     │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│                    Qt6 框架                          │
│         QtCore | QtGui | QtWidgets                  │
└─────────────────────────────────────────────────────┘
```

## 已封装的Qt组件

### 核心组件
| 类 | Qt类 | 说明 |
|----|------|------|
| QApplication | QApplication | 应用程序主类 |
| QWidget | QWidget | 基础窗口 |
| QTimer | QTimer | 定时器 |

### 基础部件
| 类 | Qt类 | 说明 |
|----|------|------|
| QLabel | QLabel | 标签 |
| QPushButton | QPushButton | 按钮（支持图标） |
| QLineEdit | QLineEdit | 单行文本输入（支持掩码、密码切换） |
| QTextEdit | QTextEdit | 多行文本编辑 |

### 选择部件
| 类 | Qt类 | 说明 |
|----|------|------|
| QCheckBox | QCheckBox | 复选框 |
| QRadioButton | QRadioButton | 单选按钮 |
| QComboBox | QComboBox | 下拉框 |

### 数值部件
| 类 | Qt类 | 说明 |
|----|------|------|
| QSpinBox | QSpinBox | 整数旋转框 |
| QSlider | QSlider | 滑动条 |
| QProgressBar | QProgressBar | 进度条 |

### 日期时间
| 类 | Qt类 | 说明 |
|----|------|------|
| QCalendarWidget | QCalendarWidget | 日历部件 |
| QDateEdit | QDateEdit | 日期编辑器 |
| QTimeEdit | QTimeEdit | 时间编辑器 |
| QDateTimeEdit | QDateTimeEdit | 日期时间编辑器 |
| QDate | QDate | 日期类 |
| QTime | QTime | 时间类 |
| QDateTime | QDateTime | 日期时间类 |

### 容器部件
| 类 | Qt类 | 说明 |
|----|------|------|
| QGroupBox | QGroupBox | 分组框 |
| QTabWidget | QTabWidget | 标签页 |
| QScrollArea | QScrollArea | 滚动区域 |
| QFrame | QFrame | 边框容器 |

### 布局管理
| 类 | Qt类 | 说明 |
|----|------|------|
| QVBoxLayout | QVBoxLayout | 垂直布局 |
| QHBoxLayout | QHBoxLayout | 水平布局 |
| QGridLayout | QGridLayout | 网格布局 |

### 表格视图
| 类 | Qt类 | 说明 |
|----|------|------|
| QTableWidget | QTableWidget | 表格控件 |
| QListWidget | QListWidget | 列表控件 |
| QTreeWidget | QTreeWidget | 树形控件 |

### 菜单与工具栏
| 类 | Qt类 | 说明 |
|----|------|------|
| QMenuBar | QMenuBar | 菜单栏 |
| QMenu | QMenu | 菜单 |
| QAction | QAction | 动作 |
| QToolBar | QToolBar | 工具栏 |
| QStatusBar | QStatusBar | 状态栏 |
| QMainWindow | QMainWindow | 主窗口 |

### 对话框
| 类 | Qt类 | 说明 |
|----|------|------|
| QMessageBox | QMessageBox | 消息对话框 |
| QFileDialog | QFileDialog | 文件对话框 |
| QInputDialog | QInputDialog | 输入对话框 |
| QColorDialog | QColorDialog | 颜色对话框 |

### 绘图模块
| 类 | Qt类 | 说明 |
|----|------|------|
| QColor | QColor | 颜色 |
| QPen | QPen | 画笔 |
| QBrush | QBrush | 画刷 |
| QLinearGradient | QLinearGradient | 线性渐变 |
| QFont | QFont | 绘图字体 |
| QPainterPath | QPainterPath | 绘图路径 |
| QPixmap | QPixmap | 图像 |
| QPainter | QPainter | 绘图器 |

### 进程管理
| 类 | Qt类 | 说明 |
|----|------|------|
| QProcess | QProcess | 进程管理 |
| QProcessEnvironment | QProcessEnvironment | 环境变量 |

### QML模块
| 类 | Qt类 | 说明 |
|----|------|------|
| QQmlApplicationEngine | QQmlApplicationEngine | QML应用引擎 |
| QQuickView | QQuickView | QML视图窗口 |
| QQuickWidget | QQuickWidget | QML嵌入控件 |
| QQuickItem | QQuickItem | QML项操作 |

## 构建和运行

### 环境要求

- CMake 3.20+
- Qt6.4+
- GCC 13+ 或 Clang 10+
- 仓颉编译器 cjc 1.0.5+
- C++17 支持

### 构建步骤

```bash
# 1. 构建C++桥接库
cd native/build
cmake ../..
make cjqt6_bridge

# 2. 编译仓颉库
cd ../..
cjpm build

# 3. 编译示例
cd examples/widget_demo
cjpm build
```

### 运行示例

使用 `run_example.sh` 脚本运行示例，会自动设置库路径和输入法支持：

```bash
cd examples

# 运行常用控件演示
./run_example.sh ./widgets_demo/target/release/bin/main
```

脚本会自动：
- 复制最新的桥接库到 `examples/lib/`
- 设置仓颉运行时库路径
- 配置输入法支持（IBus/Fcitx）

### 示例代码

```cangjie
package demo

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*

// 全局变量（用于回调中访问，CFunc 闭包不能捕获局部变量）
var infoLabel: ?QLabel = None

// 回调函数（必须在顶层定义）
let clickCallback: VoidCallback = { =>
    if (let Some(label) <- infoLabel) {
        label.setText("按钮被点击了！")
    }
}

main(): Int32 {
    let app = QApplication()  // 必须最先创建
    let window = QWidget()
    window.setTitle("CJQT6 示例")
    window.resize(400, 300)
    
    let layout = QVBoxLayout()
    
    let label = QLabel()
    label.setText("欢迎使用CJQT6！")
    infoLabel = label  // 保存到全局变量
    layout.addWidget(label.getPtr())
    
    // 带图标的按钮
    let btn = QPushButton()
    btn.setStandardIcon(StandardIcon.Open)
    btn.setText("打开")
    btn.setOnClick(clickCallback)
    layout.addWidget(btn.getPtr())
    
    // 输入框 - IP地址掩码
    let ipEdit = QLineEdit()
    ipEdit.setInputMask(InputMask.IP)
    ipEdit.setPlaceholder("000.000.000.000")
    layout.addWidget(ipEdit.getPtr())
    
    // 密码输入框（带切换按钮）
    let pwdEdit = QLineEdit()
    pwdEdit.setEchoMode(2)  // Password
    pwdEdit.addPasswordToggleAction({ =>
        // 切换密码可见性逻辑
    })
    layout.addWidget(pwdEdit.getPtr())
    
    window.setLayout(layout.getPtr())
    window.show()
    
    // 不需要手动 delete，终结器会自动清理资源
    let result = app.exec()
    return result
}
```

## 资源管理

### 控件类（终结器已禁用）

**重要**：QWidget、QLabel、QPushButton 等控件类的终结器已被禁用，因为仓颉 GC 可能在对象仍被引用时提前调用终结器，导致 Qt 对象被错误释放。

```cangjie
main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    // ... 创建控件 ...
    window.show()
    let result = app.exec()
    // 控件会随窗口关闭自动释放
    return result
}
```

### 绘图类（已实现终结器）

QColor、QPen、QBrush、QFont、QPixmap 等绘图类已实现 `~init()` 终结器：

```cangjie
// 自动释放
{
    let color = QColor(255, 0, 0)
    // 使用 color...
}  // 自动调用终结器

// 手动释放（推荐用于游戏/高频渲染）
let pen = QPen(Colors.black())
// 使用 pen...
pen.delete()
```

### 手动释放（可选）

如果需要立即释放资源，可以调用 `close()` 或 `delete()`：

```cangjie
// 方式1：close() - 实现 QtResource 接口
widget.close()

// 方式2：delete() - 直接释放
widget.delete()
```

## 信号与槽

使用CFunc回调实现信号槽：

### 回调类型

```cangjie
// 无参数回调
public type VoidCallback = CFunc<() -> Unit>

// Int32参数回调
public type Int32Callback = CFunc<(Int32) -> Unit>

// CString参数回调
public type CStringCallback = CFunc<(CString) -> Unit>
```

### 使用示例

```cangjie
// 按钮点击
let clickCallback: VoidCallback = { =>
    println("按钮被点击！")
}
btn.setOnClick(clickCallback)

// 值变化
let valueCallback: Int32Callback = { value: Int32 =>
    println("值: ${value}")
}
spinBox.setOnValueChanged(valueCallback)

// 文本变化
let textCallback: CStringCallback = { text: CString =>
    println("文本: ${text}")
}
lineEdit.setOnTextChanged(textCallback)

// 断开信号连接
btn.disconnect()
spinBox.disconnect()
```

### 支持信号的控件

| 控件 | 方法 | 回调类型 |
|------|------|----------|
| QPushButton | setOnClick | VoidCallback |
| QLineEdit | setOnTextChanged | CStringCallback |
| QSpinBox | setOnValueChanged | Int32Callback |
| QSlider | setOnValueChanged | Int32Callback |
| QCheckBox | setOnStateChanged | Int32Callback |
| QRadioButton | setOnToggled | VoidCallback |
| QComboBox | setOnCurrentIndexChanged | Int32Callback |
| QAction | setOnTriggered | VoidCallback |
| QTimer | setTimeout | VoidCallback |

## 布局使用

```cangjie
// 垂直布局
let vLayout = QVBoxLayout()
vLayout.addWidget(label.getPtr())
vLayout.addWidget(btn.getPtr())
vLayout.setSpacing(10)
vLayout.setMargin(20)

// 水平布局
let hLayout = QHBoxLayout()
hLayout.addWidget(btn1.getPtr())
hLayout.addWidget(btn2.getPtr())

// 网格布局
let grid = QGridLayout()
grid.addWidget(label.getPtr(), 0, 0)
grid.addWidget(edit.getPtr(), 0, 1)
```

## 表格使用

```cangjie
import CJQT6.views.*

let table = QTableWidget(5, 3)
table.setHorizontalHeaderLabel(0, "姓名")
table.setHorizontalHeaderLabel(1, "年龄")
table.setItem(0, 0, "张三")
table.setItem(0, 1, "25")
table.setAutoFillWidth()  // 自动填充宽度
table.setAlternatingRowColors(true)
```

## 运行时设置

运行程序时需要设置库路径：

```bash
# 方式1：使用运行脚本
./examples/run_example.sh ./examples/widget_demo/target/release/bin/main

# 方式2：设置环境变量
LD_LIBRARY_PATH=./native/build/lib:$LD_LIBRARY_PATH ./your_program
```

## 输入法支持

程序支持中文输入，需安装输入法：

```bash
# 安装ibus
sudo apt install ibus ibus-pinyin

# 启动ibus
ibus-daemon -drx
ibus engine pinyin
```

## 开发指南

### 添加新组件

1. 在 `native/src/tools/bridge.cpp` 添加FFI函数
2. 在 `src/widgets/` 添加仓颉封装类
3. 更新 `CMakeLists.txt`（如需要）
4. 编译验证

### 代码规范

- C++使用 extern "C" 导出函数
- 仓颉使用 `foreign` 声明外部函数
- FFI调用需在 `unsafe` 块中
- 字符串使用 `LibC.mallocCString` 转换

## 项目特点

1. **仓颉原生风格** - API设计符合仓颉语言习惯
2. **模块化设计** - 代码按功能模块组织
3. **FFI桥接** - 高效的仓颉与Qt6交互
4. **类型安全** - 使用CType约束确保安全
5. **自动资源管理** - 终结器自动释放，无需手动清理
6. **线程安全** - 回调映射使用互斥锁保护
7. **完整文档** - 提供API文档和示例

## 参考资源

- [Qt6官方文档](https://doc.qt.io/qt-6/)
- [仓颉语言文档](https://developer.huawei.com/consumer/cn/forum/home)

## 许可证

MIT License

## 联系方式

QQ群：1023882445

欢迎加入QQ群交流讨论！

## 贡献

欢迎提交Issue和Pull Request!