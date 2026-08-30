# CJQT6 API 文档索引

CJQT6 是仓颉语言的 Qt6 封装库，提供跨平台 GUI 开发能力。

## 文档目录

| 文档 | 说明 |
|------|------|
| [01_core.md](./01_core.md) | 核心模块 - QApplication、QWidget、QTimer、QAbstractAnimation、QUndoStack、资源管理 |
| [02_widgets_basic.md](./02_widgets_basic.md) | 基础控件 - QLabel、QPushButton、QLineEdit |
| [03_widgets_selection.md](./03_widgets_selection.md) | 选择与数值控件 - QCheckBox、QRadioButton、QComboBox、QSpinBox、QSlider |
| [04_containers_layout.md](./04_containers_layout.md) | 容器与布局 - QGroupBox、QTabWidget、QVBoxLayout、QHBoxLayout、QGridLayout |
| [05_views.md](./05_views.md) | 视图控件 - QTableWidget、QListWidget、QTreeWidget、QSortFilterProxyModel |
| [06_menu_dialogs.md](./06_menu_dialogs.md) | 菜单与对话框 - QMainWindow、QMenu、QAction、QMessageBox、QFileDialog |
| [07_events.md](./07_events.md) | 事件处理 - QEventWidget、鼠标事件、键盘事件 |
| [08_paint.md](./08_paint.md) | 绘图模块 - QColor、QPen、QBrush、QPainter、QPixmap |
| [09_process.md](./09_process.md) | 进程管理 - QProcess、QProcessEnvironment |
| [10_datetime.md](./10_datetime.md) | 日期时间 - QDate、QTime、QDateTime、QCalendarWidget、QDateEdit |
| [11_qml.md](./11_qml.md) | QML模块 - QQmlApplicationEngine、QQuickView |
| [12_signal_slot.md](./12_signal_slot.md) | 信号与槽 - 回调机制、信号连接 |
| [13_multimedia.md](./13_multimedia.md) | 多媒体模块 - QMediaPlayer、QAudioOutput、QCamera、QVideoWidget |
| [14_print.md](./14_print.md) | 打印模块 - QPrinter、QPrintDialog |
| [15_examples_faq.md](./15_examples_faq.md) | 示例与常见问题 |
| [16_misc_widgets.md](./16_misc_widgets.md) | 其他控件 - QLCDNumber、QToolButton、QUiLoader |
| [17_dragdrop.md](./17_dragdrop.md) | 拖放支持 - QMimeData、QDrag |
| [18_sql.md](./18_sql.md) | SQL数据库 - QSqlDatabase、QSqlQuery |
| [19_network.md](./19_network.md) | 网络模块 - QTcpSocket、QUdpSocket、QHostAddress |
| [20_charts.md](./20_charts.md) | 图表模块 - QChart、QChartView、QLineSeries、QValueAxis |

## 快速开始

```cangjie
import cjqt6.core.*
import cjqt6.widgets.*

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
import cjqt6.core.*      // 核心类
import cjqt6.widgets.*   // 控件
import cjqt6.gui.*       // GUI相关
import cjqt6.views.*     // 视图控件
import cjqt6.dialogs.*   // 对话框
import cjqt6.menu.*      // 菜单工具栏
import cjqt6.paint.*     // 绘图
import cjqt6.qml.*       // QML
import cjqt6.multimedia.* // 多媒体
import cjqt6.print.*     // 打印
import cjqt6.network.*   // 网络通信
import cjqt6.sql.*       // 数据库
```

## 重要提示

1. **控件类终结器已禁用** - QWidget、QLabel、QPushButton 等控件的终结器已被禁用，因为仓颉 GC 可能在对象仍被引用时提前调用终结器。请使用 `close()` 或 `delete()` 显式释放。

2. **QTimer 必须手动释放** - 调用 `timer.delete()`

3. **CFunc 回调不能捕获局部变量** - 使用全局变量传递

4. **绘图类终结器已禁用** - QColor、QPen、QBrush、QFont、QPixmap 等绘图类的终结器已被禁用。请在不再使用时显式调用 `delete()` 释放资源

5. **推荐缓存常用对象** - 在渲染循环中复用颜色、画笔、画刷等对象，避免重复创建
