package all_controls_demo

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.dialogs.*
import cjqt6.views.*
import cjqt6.richwidgets.*

// -------- 页面2: 数值控件 --------

func createPageNumeric(): QScrollArea {
    let (scrollArea, _, layout) = createPageContainer()

    let title = QLabel()
    title.setText("数值控件演示")
    setLabelStyle(title, "font-size: 18px; font-weight: bold; color: #2c3e50; padding: 8px 0;")
    title.setAlignment(AlignCenter)
    layout.addWidget(title.getPtr())

    // QSpinBox
    layout.addWidget(sectionTitle("QSpinBox").getPtr())
    let spinRow = QHBoxLayout()
    spinRow.setSpacing(8)
    spinRow.addWidget(infoLabel("整数:").getPtr())
    let spinBox = QSpinBox()
    spinBox.setRange(0, 1000)
    spinBox.setValue(256)
    spinBox.setSingleStep(10)
    spinBox.setOnValueChanged(onSpinChanged)
    spinRow.addWidget(spinBox.getPtr())
    let spinVal = QLabel()
    spinVal.setText("值: 256")
    gSpinValueLabel = spinVal
    spinRow.addWidget(spinVal.getPtr())
    layout.addLayout(spinRow.getPtr())

    // QDoubleSpinBox
    let doubleRow = QHBoxLayout()
    doubleRow.setSpacing(8)
    doubleRow.addWidget(infoLabel("浮点:").getPtr())
    let doubleBox = QDoubleSpinBox()
    doubleBox.setRange(0.0, 100.0)
    doubleBox.setValue(3.14)
    doubleBox.setSingleStep(0.1)
    doubleBox.setDecimals(2)
    doubleRow.addWidget(doubleBox.getPtr())
    let doubleVal = QLabel()
    doubleVal.setText("值: 3.14")
    doubleRow.addWidget(doubleVal.getPtr())
    layout.addLayout(doubleRow.getPtr())

    // QSlider
    layout.addWidget(sectionTitle("QSlider").getPtr())
    let sliderRow = QHBoxLayout()
    sliderRow.setSpacing(8)
    sliderRow.addWidget(infoLabel("滑动:").getPtr())
    let slider = QSlider()
    slider.setOrientation(1)
    slider.setRange(0, 100)
    slider.setValue(50)
    slider.setOnValueChanged(onSliderChanged)
    sliderRow.addWidget(slider.getPtr())
    let sliderVal = QLabel()
    sliderVal.setText("当前值: 50")
    gSliderValueLabel = sliderVal
    sliderRow.addWidget(sliderVal.getPtr())
    layout.addLayout(sliderRow.getPtr())

    // QDial
    layout.addWidget(sectionTitle("QDial").getPtr())
    let dialRow = QHBoxLayout()
    dialRow.setSpacing(8)
    let dial = QDial()
    dial.setRange(0, 360)
    dial.setValue(180)
    dial.setWrapping(true)
    dial.setNotchesVisible(true)
    dial.setOnValueChanged(onDialChanged)
    dialRow.addWidget(dial.getPtr())
    let dialVal = QLabel()
    dialVal.setText("角度: 180°")
    gDialValueLabel = dialVal
    dialRow.addWidget(dialVal.getPtr())
    layout.addLayout(dialRow.getPtr())

    // QLCDNumber
    layout.addWidget(sectionTitle("QLCDNumber").getPtr())
    let lcd = QLCDNumber(4)
    lcd.displayInt(180)
    gLcdNumber = lcd
    layout.addWidget(lcd.getPtr())

    layout.addStretch()
    scrollArea
}