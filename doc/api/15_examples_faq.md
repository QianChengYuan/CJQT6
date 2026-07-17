# CJQT6 示例与常见问题

## 完整示例

```cangjie
package demo

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.views.*
import cjqt6.dialogs.*

// 全局变量（用于回调中访问，CFunc 闭包不能捕获局部变量）
var label: ?QLabel = None

// 回调函数（必须在顶层定义）
let clickCallback: VoidCallback = { =>
    if (let Some(l) <- label) {
        l.setText("按钮被点击了！")
    }
}

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("CJQT6 完整示例")
    window.resize(600, 400)
    
    // 主布局
    let mainLayout = QVBoxLayout()
    
    // 标签
    let lbl = QLabel()
    lbl.setText("欢迎使用CJQT6")
    label = lbl  // 保存到全局变量
    mainLayout.addWidget(lbl.getPtr())
    
    // 按钮
    let btn = QPushButton()
    btn.setText("点击我")
    btn.setOnClick(clickCallback)
    mainLayout.addWidget(btn.getPtr())
    
    // 表格
    let table = QTableWidget(3, 2)
    table.setHorizontalHeaderLabel(0, "项目")
    table.setHorizontalHeaderLabel(1, "值")
    table.setItem(0, 0, "名称")
    table.setItem(0, 1, "CJQT6")
    table.setItem(1, 0, "版本")
    table.setItem(1, 1, "1.0.0")
    table.setAutoFillWidth()
    mainLayout.addWidget(table.getPtr())
    
    window.setLayout(mainLayout.getPtr())
    window.show()
    
    // 不需要手动清理，终结器自动处理
    let result = app.exec()
    return result
}
```

---

## 常见问题

### Q: 如何让控件自动填充布局？

A: 使用布局管理器，并添加弹性空间：
```cangjie
let layout = QVBoxLayout()
layout.addWidget(topWidget.getPtr())
layout.addStretch()  // 添加弹性空间
layout.addWidget(bottomWidget.getPtr())
```

### Q: 如何实现控件之间的联动？

A: 使用信号槽机制：
```cangjie
let sliderCallback: Int32Callback = { value: Int32 =>
    progressBar.setValue(value)
}
slider.setOnValueChanged(sliderCallback)
```

### Q: 为什么CFunc回调不能访问外部变量？

A: 这是仓颉语言的安全限制。解决方案：
1. 使用全局变量存储需要访问的对象
2. 在回调中重新读取控件状态

### Q: 如何在布局中嵌套布局？

A: 使用`addLayout`方法：
```cangjie
let mainLayout = QVBoxLayout()
let topLayout = QHBoxLayout()
topLayout.addWidget(btn1.getPtr())
topLayout.addWidget(btn2.getPtr())
mainLayout.addLayout(topLayout.getPtr())
```

### Q: QTimer 为什么需要手动释放？

A: 由于仓颉运行时可能在对象仍被引用时提前调用终结器，导致 Qt 对象被错误释放。因此 QTimer 的终结器已被禁用，必须手动调用 `delete()`。

### Q: 如何在回调中更新 UI？

A: 由于 CFunc 不能捕获局部变量，需要使用全局变量：
```cangjie
var gLabel: ?QLabel = None

let callback: VoidCallback = { =>
    if (let Some(l) <- gLabel) {
        l.setText("已更新")
    }
}

main(): Int32 {
    let label = QLabel()
    gLabel = label  // 保存到全局变量
    // ...
}
```

### Q: 如何添加日期选择控件？

A: 使用 QDateEdit：
```cangjie
let dateEdit = QDateEdit()
dateEdit.setDisplayFormat("yyyy-MM-dd")
dateEdit.setCalendarPopup(true)  // 启用日历弹出
dateEdit.setDate(QDate.currentDate())
```

---

## 游戏示例：贪吃蛇

```cangjie
package snake_game

import cjqt6.core.*
import cjqt6.paint.*
import cjqt6.widgets.*
import std.random.*
import std.collection.*

// 游戏常量
let CELL_SIZE: Int32 = 20
let GRID_WIDTH: Int32 = 30
let GRID_HEIGHT: Int32 = 25
let GAME_SPEED: Int32 = 100

// 全局状态
var gSnake: ArrayList<(Int32, Int32)> = ArrayList<(Int32, Int32)>()
var gDirection: Int32 = 3  // DIR_RIGHT
var gFood: (Int32, Int32) = (10, 10)
var gScore: Int32 = 0
var gGameOver: Bool = false
var gGameStarted: Bool = false

// 渲染器（缓存资源避免内存泄漏）
public class SnakeRenderer {
    private let pen: QPen
    private let brush: QBrush
    private let colorSnakeHead: QColor
    private let colorSnakeBody: QColor
    private let colorFood: QColor
    
    public init() {
        pen = QPen()
        brush = QBrush()
        colorSnakeHead = QColor(50, 205, 50)
        colorSnakeBody = QColor(34, 139, 34)
        colorFood = QColor(255, 69, 0)
    }
    
    public func cleanup(): Unit {
        pen.delete(); brush.delete()
        colorSnakeHead.delete(); colorSnakeBody.delete(); colorFood.delete()
    }
    
    public func render(painterPtr: Int64): Unit {
        let painter = QPainter.fromPtr(painterPtr)
        // 渲染蛇和食物...
    }
}

main(): Int32 {
    let app = QApplication()
    let widget = QEventWidget()
    let timer = QTimer()
    let renderer = SnakeRenderer()
    
    widget.setOnKeyPress({ key, mods, unicode => onKeyPress(key, mods, unicode) })
    widget.setOnPaint({ ptr => renderer.render(ptr) })
    timer.setOnTimeout({ => updateGame() })
    
    widget.show()
    timer.start(GAME_SPEED)
    
    let result = app.exec()
    
    // 清理资源
    timer.stop(); timer.delete()
    renderer.cleanup()
    widget.delete()
    
    return result
}
```

**关键点**：
- 使用 `ArrayList` 存储蛇身坐标
- 渲染器缓存颜色/画笔避免每帧创建
- 程序退出时调用 `cleanup()` 释放资源
- 方向键/WASD 控制，空格暂停
