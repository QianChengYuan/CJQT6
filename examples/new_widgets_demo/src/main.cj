package new_widgets_demo

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*

// 全局变量用于回调
var g_dialLabel: ?QLabel = None
var g_doubleLabel: ?QLabel = None

// 回调函数
let dialCallback: Int32Callback = { value: Int32 =>
    if (let Some(label) <- g_dialLabel) {
        label.setText("Dial值: ${value}")
    }
}

let doubleCallback: Float64Callback = { value: Float64 =>
    if (let Some(label) <- g_doubleLabel) {
        label.setText("DoubleSpinBox值: ${value}")
    }
}

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("新组件演示")
    window.resize(500, 400)
    
    let mainLayout = QVBoxLayout()
    
    // ========== QDial 演示 ==========
    let dialGroup = QGroupBox()
    dialGroup.setTitle("QDial - 旋钮控件")
    let dialLayout = QVBoxLayout()
    
    let dial = QDial()
    dial.setRange(0, 100)
    dial.setValue(50)
    dial.setNotchesVisible(true)
    dial.setOnValueChanged(dialCallback)
    
    let dialLabel = QLabel()
    dialLabel.setText("Dial值: 50")
    g_dialLabel = dialLabel
    
    dialLayout.addWidget(dial.getPtr())
    dialLayout.addWidget(dialLabel.getPtr())
    dialGroup.setLayout(dialLayout.getPtr())
    mainLayout.addWidget(dialGroup.getPtr())
    
    // ========== QDoubleSpinBox 演示 ==========
    let doubleGroup = QGroupBox()
    doubleGroup.setTitle("QDoubleSpinBox - 双精度旋转框")
    let doubleLayout = QVBoxLayout()
    
    let doubleSpinBox = QDoubleSpinBox()
    doubleSpinBox.setRange(0.0, 100.0)
    doubleSpinBox.setValue(25.5)
    doubleSpinBox.setDecimals(2)
    doubleSpinBox.setSingleStep(0.5)
    doubleSpinBox.setOnValueChanged(doubleCallback)
    
    let doubleLabel = QLabel()
    doubleLabel.setText("DoubleSpinBox值: 25.5")
    g_doubleLabel = doubleLabel
    
    doubleLayout.addWidget(doubleSpinBox.getPtr())
    doubleLayout.addWidget(doubleLabel.getPtr())
    doubleGroup.setLayout(doubleLayout.getPtr())
    mainLayout.addWidget(doubleGroup.getPtr())
    
    // ========== QToolButton 演示 ==========
    let toolGroup = QGroupBox()
    toolGroup.setTitle("QToolButton - 工具按钮")
    let toolLayout = QHBoxLayout()
    
    let toolBtn1 = QToolButton()
    toolBtn1.setText("工具1")
    toolBtn1.setAutoRaise(true)
    
    let toolBtn2 = QToolButton()
    toolBtn2.setText("工具2")
    toolBtn2.setArrowType(ArrowRight)
    
    let toolBtn3 = QToolButton()
    toolBtn3.setText("工具3")
    toolBtn3.setToolButtonStyle(ToolButtonTextUnderIcon)
    
    toolLayout.addWidget(toolBtn1.getPtr())
    toolLayout.addWidget(toolBtn2.getPtr())
    toolLayout.addWidget(toolBtn3.getPtr())
    toolGroup.setLayout(toolLayout.getPtr())
    mainLayout.addWidget(toolGroup.getPtr())
    
    // ========== 拖放演示 ==========
    let dragGroup = QGroupBox()
    dragGroup.setTitle("拖放支持演示")
    let dragLayout = QVBoxLayout()
    
    let dragInfo = QLabel()
    dragInfo.setText("QMimeData/QDrag 已封装\n支持文本、HTML、URL拖放")
    
    dragLayout.addWidget(dragInfo.getPtr())
    dragGroup.setLayout(dragLayout.getPtr())
    mainLayout.addWidget(dragGroup.getPtr())
    
    // 设置主布局
    window.setLayout(mainLayout.getPtr())
    window.show()
    
    let result = app.exec()
    
    // 清理 - 先断开信号连接，再删除对象
    dial.disconnectValueChanged()
    doubleSpinBox.disconnectValueChanged()
    
    // 清空全局变量引用
    g_dialLabel = None
    g_doubleLabel = None
    
    // 删除对象
    dial.delete()
    dialLabel.delete()
    doubleSpinBox.delete()
    doubleLabel.delete()
    toolBtn1.delete()
    toolBtn2.delete()
    toolBtn3.delete()
    dialGroup.delete()
    doubleGroup.delete()
    toolGroup.delete()
    dragGroup.delete()
    dragInfo.delete()
    window.delete()
    app.delete()
    
    return result
}