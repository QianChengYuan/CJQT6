# CJQT6 API 文档索引

CJQT6 是仓颉语言的 Qt6 封装库，提供跨平台 GUI 开发能力。

## 文档目录

| 文档 | 说明 |
|------|------|
| [01_core.md](./01_core.md) | 核心模块 - QApplication、QWidget、QTimer、资源管理 |
| [02_widgets_basic.md](./02_widgets_basic.md) | 基础控件 - QLabel、QPushButton、QLineEdit |
| [03_widgets_selection.md](./03_widgets_selection.md) | 选择与数值控件 - QCheckBox、QRadioButton、QComboBox、QSpinBox、QSlider |
| [04_containers_layout.md](./04_containers_layout.md) | 容器与布局 - QGroupBox、QTabWidget、QVBoxLayout、QHBoxLayout、QGridLayout |
| [05_views.md](./05_views.md) | 视图控件 - QTableWidget、QListWidget、QTreeWidget |
| [06_menu_dialogs.md](./06_menu_dialogs.md) | 菜单与对话框 - QMainWindow、QMenu、QAction、QMessageBox、QFileDialog |
| [07_events.md](./07_events.md) | 事件处理 - QEventWidget、鼠标事件、键盘事件 |
| [08_paint.md](./08_paint.md) | 绘图模块 - QColor、QPen、QBrush、QPainter、QPixmap |
| [09_process.md](./09_process.md) | 进程管理 - QProcess、QProcessEnvironment |
| [10_datetime.md](./10_datetime.md) | 日期时间 - QDate、QTime、QDateTime、QCalendarWidget、QDateEdit |
| [11_qml.md](./11_qml.md) | QML模块 - QQmlApplicationEngine、QQuickView |
| [12_signal_slot.md](./12_signal_slot.md) | 信号与槽 - 回调机制、信号连接 |
| [13_multimedia.md](./13_multimedia.md) | 多媒体模块 - QMediaPlayer、QAudioOutput |
| [14_print.md](./14_print.md) | 打印模块 - QPrinter、QPrintDialog |
| [15_examples_faq.md](./15_examples_faq.md) | 示例与常见问题 |

## 快速开始

```cangjie
import CJQT6.core.*
import CJQT6.widgets.*

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("Hello CJQT6")
    window.resize(400, 300)
    
    let layout = QVBoxLayout()
    let label = QLabel()
    label.setText("欢迎使用 CJQT6!")
    layout.addWidget(label.getPtr())
    
    window.setLayout(layout.getPtr())
    window.show()
    
    return app.exec()
}
```

## 模块导入

```cangjie
import CJQT6.core.*      // 核心类
import CJQT6.widgets.*   // 控件
import CJQT6.gui.*       // GUI相关
import CJQT6.views.*     // 视图控件
import CJQT6.dialogs.*   // 对话框
import CJQT6.menu.*      // 菜单工具栏
import CJQT6.paint.*     // 绘图
import CJQT6.qml.*       // QML
import CJQT6.multimedia.* // 多媒体
import CJQT6.print.*     // 打印
import CJQT6.sql.*       // 数据库
```

## 重要提示

1. **QTimer 必须手动释放** - 调用 `timer.delete()`
2. **CFunc 回调不能捕获局部变量** - 使用全局变量
3. **绘图类建议手动释放** - QColor、QPen、QBrush 等
