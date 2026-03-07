package widget_demo

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*

// 全局变量
var buttonClickCount: Int32 = 0

// CFunc回调函数
let buttonCallback: CFunc<(Int64) -> Unit> = { _: Int64 => 
    buttonClickCount = buttonClickCount + 1
    println("按钮被点击了！点击次数: ${buttonClickCount}")
}

let spinBoxCallback: CFunc<(Int64) -> Unit> = { _: Int64 =>
    println("SpinBox值改变了！")
}

let sliderCallback: CFunc<(Int64) -> Unit> = { _: Int64 =>
    println("Slider值改变了！")
}

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("CJQT6 信号与槽演示")
    window.resize(500, 400)
    
    // 创建主布局
    let mainLayout = QVBoxLayout()
    
    // ===== 标签 =====
    let label = QLabel()
    label.setText("点击按钮测试信号")
    mainLayout.addWidget(label.getPtr())
    
    // ===== 按钮 - 点击信号 =====
    let btn = QPushButton()
    btn.setText("点击我")
    btn.setOnClick(buttonCallback)
    mainLayout.addWidget(btn.getPtr())
    
    // ===== SpinBox - 值变化信号 =====
    let spinBox = QSpinBox()
    spinBox.setRange(0, 100)
    spinBox.setValue(50)
    spinBox.setOnValueChanged(spinBoxCallback)
    mainLayout.addWidget(spinBox.getPtr())
    
    // ===== Slider - 值变化信号 =====
    let slider = QSlider()
    slider.setRange(0, 100)
    slider.setValue(50)
    slider.setOnValueChanged(sliderCallback)
    mainLayout.addWidget(slider.getPtr())
    
    // ===== 进度条 =====
    let progressBar = QProgressBar()
    progressBar.setRange(0, 100)
    progressBar.setValue(50)
    mainLayout.addWidget(progressBar.getPtr())
    
    // 设置窗口布局
    window.setLayout(mainLayout.getPtr())
    
    // 显示窗口
    window.show()
    
    // 运行应用
    let result = app.exec()
    
    // 清理资源
    label.delete()
    btn.delete()
    spinBox.delete()
    slider.delete()
    progressBar.delete()
    window.delete()
    app.delete()
    
    return result
}
