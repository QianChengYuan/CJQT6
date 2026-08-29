# CJQT6 未封装控件分析报告

> 生成日期：2026-07-18
> 最后更新：2026-08-29（QVideoSink 封装完成）

## 一、整体架构模式

每个控件封装涉及 **3 层**：

```
C++ 桥接头文件  →  native/includes/*.h        (FFI导出函数签名)
C++ 桥接实现    →  native/src/*/bridge_*.cpp   (extern "C" FFI函数实现)
仓颉封装类      →  src/*/*.cj                  (foreign + class API)
```

构建涉及：
- `native/CMakeLists.txt` + 重新编译 → 产出新 `CJQT6_bridge.dll`
- `cjpm build` → 编译仓颉侧代码

## 二、现状概览

| 模块 | 已封装 | 常用未封装 | 覆盖率 |
|------|--------|-----------|--------|
| 基础控件 (widgets) | 37 | 0 | ~100% |
| 容器/布局 | 10 | 0 | 100% |
| 视图 (views) | 10 | 0 | ~100% |
| 对话框 | 9 | 0 | 100% |
| 菜单/工具栏 | 6 | 0 | 100% |
| 绘图 | 9 | 0 | 100% |
| 多媒体 | 5 | 0 | ~100% |
| 网络 | 3 | 0 | 100% |
| 核心/工具 | 22 | 0 | ~95% |
| 动画/特效 | 7 | 0 | ~100% |
| **合计** | **~118** | **0** | **~98%** |

## 三、已封装控件完整清单

### core/ — 22 文件
| 文件 | 控件/类 | 状态 |
|------|---------|------|
| application.cj | QApplication | ✅ 较完整（含多语言/翻译支持） |
| widget.cj | QWidget | ✅ 较完整（几何/样式/启用/工具提示/父窗口） |
| timer.cj | QTimer | ✅ 完整 |
| process.cj | QProcess | ✅ 较完整 |
| signal.cj | 回调类型系统 + SignalConnection 句柄 | ✅ 完整（5种回调类型，含 P0/P1/P2） |
| emitter.cj | SignalEmitter（自定义信号发射） | ✅ P2 新增（含跨线程 QueuedConnection） |
| callback.cj | 闭包捕获辅助类型 | ✅ P2 新增 |
| common.cj | 公共 FFI 声明 | ✅ 集中管理 |
| events.cj | 事件系统 | ✅ 较完整（鼠标/键盘/绘制事件） |
| dragdrop.cj | 拖放支持 | ✅ 基础 |
| resource.cj | 资源管理 | ✅ 较完整 |
| gui_test_env.cj | 测试环境 | ✅ |
| clipboard.cj | QClipboard | ✅ P2 新增 |
| desktopservices.cj | QDesktopServices | ✅ P2 新增 |
| shortcut.cj | QShortcut | ✅ P2 新增 |
| standardpaths.cj | QStandardPaths | ✅ P2 新增 |
| filewatcher.cj | QFileSystemWatcher | ✅ P2 新增 |
| settings.cj | QSettings | ✅ P2 新增 |
| propertyanimation.cj | QPropertyAnimation | ✅ P2 新增 |
| screen.cj | QScreen | ✅ P2 新增 |
| animation.cj | QAbstractAnimation / QParallelAnimationGroup | ✅ P3 新增 |
| undostack.cj | QUndoCommand / QUndoStack | ✅ P3 新增 |

### widgets/ — 37 文件
| 文件 | 控件 | 状态 |
|------|------|------|
| label.cj | QLabel | ✅ 完整 |
| pushbutton.cj | QPushButton | ✅ 完整 |
| lineedit.cj | QLineEdit | ✅ 非常完整 |
| textedit.cj | QTextEdit | ✅ 非常完整 |
| checkbox.cj | QCheckBox | ✅ 完整 |
| radiobutton.cj | QRadioButton | ✅ 完整 |
| combobox.cj | QComboBox | ✅ 较完整 |
| slider.cj | QSlider | ✅ 完整 |
| spinbox.cj | QSpinBox | ✅ 完整 |
| doublespinbox.cj | QDoubleSpinBox | ✅ 较完整 |
| progressbar.cj | QProgressBar | ✅ 基础 |
| toolbutton.cj | QToolButton | ✅ 较完整 |
| dial.cj | QDial | ✅ 完整 |
| lcdnumber.cj | QLCDNumber | ✅ 完整 |
| datetime.cj | QCalendarWidget | ✅ 较完整 |
| datetime.cj | QDateEdit/QTimeEdit/QDateTimeEdit | ✅ 较完整 |
| containers.cj | QGroupBox/QTabWidget/QScrollArea/QFrame/QSplitter | ✅ 较完整 |
| buttongroup.cj | QButtonGroup | ✅ P0 新增 |
| stackedwidget.cj | QStackedWidget | ✅ P0 新增 |
| plaintextedit.cj | QPlainTextEdit | ✅ P0 新增 |
| completer.cj | QCompleter | ✅ P0 新增 |
| textbrowser.cj | QTextBrowser | ✅ P1 新增 |
| keysequenceedit.cj | QKeySequenceEdit | ✅ P1 新增 |
| systemtrayicon.cj | QSystemTrayIcon | ✅ P1 新增 |
| toolbox.cj | QToolBox | ✅ P1 新增 |
| mdiarea.cj | QMdiArea/QMdiSubWindow | ✅ P1 新增 |
| dockwidget.cj | QDockWidget | ✅ P1 新增 |
| graphicsview.cj | QGraphicsView/QGraphicsScene | ✅ P1 新增 |
| graphicseffect.cj | QGraphicsOpacityEffect / QGraphicsDropShadowEffect | ✅ P2 新增 |
| fontcombobox.cj | QFontComboBox | ✅ P2 新增 |
| commandlinkbutton.cj | QCommandLinkButton | ✅ 初始（未在 P0/P1/P2 报告中列出） |
| dialogbuttonbox.cj | QDialogButtonBox | ✅ 初始 |
| rubberband.cj | QRubberBand | ✅ 初始 |
| scrollbar.cj | QScrollBar | ✅ 初始 |
| sizegrip.cj | QSizeGrip | ✅ 初始 |
| splashscreen.cj | QSplashScreen | ✅ 初始 |
| validators.cj | QValidator / QIntValidator / QDoubleValidator | ✅ 初始 |

### views/ — 10 文件
| 文件 | 控件 | 状态 |
|------|------|------|
| listwidget.cj | QListWidget | ✅ 较完整 |
| tablewidget.cj | QTableWidget | ✅ 较完整 |
| treewidget.cj | QTreeWidget + QTreeWidgetItem | ✅ 较完整 |
| listview.cj | QListView | ✅ 较完整（含 QModelIndex 和 EditTrigger） |
| tableview.cj | QTableView（含 SelectionBehavior） | ✅ 较完整 |
| treeview.cj | QTreeView | ✅ 较完整 |
| headerview.cj | QHeaderView（含 Orientation/ResizeMode） | ✅ 较完整 |
| standarditemmodel.cj | QStandardItemModel | ✅ 较完整 |
| filesystemmodel.cj | QFileSystemModel | ✅ 较完整 |
| sortfilterproxymodel.cj | QSortFilterProxyModel | ✅ P3 新增 |

### dialogs/ — 1 文件（9 个对话框）
| 控件 | 状态 | 阶段 |
|------|------|------|
| QMessageBox | ✅ 完整 | 初始 |
| QFileDialog | ✅ 较完整 | 初始 |
| QInputDialog | ✅ 基础 | 初始 |
| QColorDialog | ✅ 基础 | 初始 |
| QFontDialog | ✅ P0 新增 | P0 |
| QProgressDialog | ✅ P0 新增 | P0 |
| QWizard/QWizardPage | ✅ P1 新增 | P1 |
| QErrorMessage | ✅ P1 新增 | P1 |

### menu/ — 1 文件
| 控件 | 状态 |
|------|------|
| QMainWindow | ✅ 基础 |
| QMenuBar | ✅ 基础 |
| QMenu | ✅ 较完整 |
| QAction | ✅ 较完整 |
| QToolBar | ✅ 基础 |
| QStatusBar | ✅ 基础 |

### gui/ — 3 文件
| 控件 | 状态 |
|------|------|
| QVBoxLayout/QHBoxLayout/QGridLayout/QFormLayout | ✅ 较完整（含 stretch 参数） |
| 对齐/方向/边距类型 | ✅ 完整 |
| QStyleHelper（QStyle 查询） | ✅ P3 新增 |

### paint/ — 3 文件
| 控件 | 状态 |
|------|------|
| QColor/QPen/QBrush/QPainter/QImage/QPixmap/QFont | ✅ 基础-较完整 |
| QTransform | ✅ 基础 |
| QFontDatabase | ✅ P2 新增 |

### multimedia/ — 4 文件
| 控件 | 状态 |
|------|------|
| QMediaPlayer | ✅ 较完整 |
| QAudioOutput | ✅ 基础 |
| QSoundEffect | ✅ P2 新增 |
| QCameraDevice / QCamera / QMediaCaptureSession / QMediaDevices | ✅ P3 新增 |
| QVideoWidget | ✅ P3 新增 |

### network/ — 3 文件
| 控件 | 状态 |
|------|------|
| QTcpSocket | ✅ 较完整 |
| QUdpSocket | ✅ 基础 |
| QHostAddress | ✅ 基础 |

### 其他
| 模块 | 状态 |
|------|------|
| SQL (QSqlDatabase) | ✅ 基础 |
| Print (QPrinter / QPrintDialog / QPrintPreviewDialog) | ✅ 基础 |
| QML | ✅ 基础 |
| Resource Management | ✅ 较完整 |

## 四、已实施与剩余未封装控件

### ✅ Phase 0：P0 高频缺失（已完成）

| 控件 | 模块 | 复杂度 | 说明 |
|------|------|-------|------|
| QButtonGroup | widgets | ⭐ | 单选按钮互斥 |
| QStackedWidget | widgets | ⭐ | 多页面切换 |
| QPlainTextEdit | widgets | ⭐⭐ | 代码编辑器/日志 |
| QCompleter | widgets | ⭐⭐ | 输入自动补全 |
| QFormLayout | gui | ⭐ | 表单布局 — 已跳过（QFormLayout 可直接用 QGridLayout 替代） |
| QFontDialog | dialogs | ⭐ | 字体选择 |
| QProgressDialog | dialogs | ⭐ | 进度反馈 |

### ✅ Phase 1：P1 重要但可替代（已完成）

| 控件 | 模块 | 复杂度 |
|------|------|-------|
| QSystemTrayIcon | widgets | ⭐⭐ |
| QDockWidget | widgets | ⭐⭐⭐ |
| QToolBox | widgets | ⭐⭐ |
| QMdiArea/QMdiSubWindow | widgets | ⭐⭐⭐ |
| QTextBrowser | widgets | ⭐ |
| QWizard/QWizardPage | dialogs | ⭐⭐ |
| QKeySequenceEdit | widgets | ⭐ |
| QGraphicsView/QGraphicsScene | widgets | ⭐⭐⭐⭐ |
| QPrintDialog/QPrintPreviewDialog | print | ⭐⭐ — 已在 P0 前完成 |
| QErrorMessage | dialogs | ⭐ |

### ✅ Phase 2：P2 增强功能类（已完成）

| 分类 | 控件/类 | 模块 | 复杂度 |
|------|--------|------|-------|
| 动画 | QPropertyAnimation | core | ⭐⭐ |
| | QGraphicsOpacityEffect | widgets | ⭐ |
| | QGraphicsDropShadowEffect | widgets | ⭐ |
| 系统工具 | QSettings | core | ⭐⭐ |
| | QStandardPaths | core | ⭐ |
| | QFileSystemWatcher | core | ⭐⭐ |
| | QClipboard | core | ⭐ |
| | QDesktopServices | core | ⭐ |
| | QShortcut | core | ⭐ |
| | QScreen | core | ⭐ |
| 多媒体增强 | QSoundEffect | multimedia | ⭐ |
| 字体 | QFontComboBox | widgets | ⭐ |
| | QFontDatabase | paint | ⭐⭐ |

### ✅ Phase 3：P3 全部完成

| 控件/类 | 模块 | 完成状态 |
|---------|------|---------|
| QAbstractAnimation / QParallelAnimationGroup | core | ✅ 已完成 |
| QUndoCommand / QUndoStack | core | ✅ 已完成 |
| QStyleHelper（QStyle 查询） | gui | ✅ 已完成 |
| QCamera / QCameraDevice / QMediaCaptureSession / QMediaDevices | multimedia | ✅ 已完成 |
| QVideoWidget | multimedia | ✅ 已完成（需 Qt6::MultimediaWidgets） |
| QSortFilterProxyModel | views | ✅ 已完成 |

**至此，CJQT6 所有已知常用控件封装已全部完成**，覆盖率达 ~98%。QVideoSink 已于 2026-08-29 封装（videoSize/subtitleText）。后续按需补充进阶方法。

## 五、实施路线图（已完成）

```
Phase 0 (已完成)         Phase 1 (已完成)          Phase 2 (已完成)
┌──────────────────┐   ┌──────────────────┐    ┌──────────────────┐
│ QButtonGroup     │   │ QSystemTrayIcon  │    │ QPropertyAnimation│
│ QStackedWidget   │   │ QGraphicsView    │    │ QSettings        │
│ QPlainTextEdit   │   │ QDockWidget      │    │ QClipboard       │
│ QCompleter       │   │ QWizard          │    │ QShortcut        │
│ QFontDialog      │   │ QKeySequenceEdit │    │ QStandardPaths   │
│ QProgressDialog  │   │ QToolBox         │    │ QFileSystemWatcher│
│                  │   │ QTextBrowser     │    │ QSoundEffect     │
│                  │   │ QPrintDialog     │    │ QFontComboBox    │
│                  │   │ QErrorMessage    │    │ QFontDatabase    │
│                  │   │ QMdiArea         │    │ QScreen          │
│                  │   │                  │    │ QDesktopServices │
│                  │   │                  │    │ QGraphicsEffect  │
└──────────────────┘   └──────────────────┘    └──────────────────┘
  6 个控件               10 个控件               12 个控件/类
```

当前焦点：**Phase 3**（按需实施）— 见第四节 🔵 清单。

## 六、实施模板（标准 3 层模式）

### C++ 桥接头文件声明
```cpp
// native/includes/widgets.h 追加 extern "C" 函数声明
```

### C++ 桥接实现
```cpp
// native/src/widgets/bridge_*.cpp 追加 extern "C" 函数实现
extern "C" {
    int64_t qControlCreate() { ... }
    void qControlSetSomething(int64_t ptr, ...) { ... }
    void qControlDelete(int64_t ptr) { ... }
}
```

### 仓颉封装类
```cangjie
// src/*/control.cj
package cjqt6.xxx

foreign func qControlCreate(): Int64
foreign func qControlDelete(ptr: Int64): Unit

public class QControl {
    private var ptr: Int64 = 0
    
    public init() { unsafe { ptr = qControlCreate() } }
    public func getPtr(): Int64 { ptr }
    public func delete() { if (ptr != 0) { unsafe { qControlDelete(ptr) }; ptr = 0 } }
}
```

### 构建命令
```powershell
# 重新编译桥接库
cd native\build_windows_x64 && cmake --build . --config Release && cd ..\..

# 仓颉编译
cjpm build
```
