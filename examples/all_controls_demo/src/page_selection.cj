package all_controls_demo

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.dialogs.*
import cjqt6.views.*
import cjqt6.richwidgets.*

// -------- 页面3: 选择控件 --------

func createPageSelection(): QScrollArea {
    let (scrollArea, _, layout) = createPageContainer()

    let title = QLabel()
    title.setText("选择控件演示")
    setLabelStyle(title, "font-size: 18px; font-weight: bold; color: #2c3e50; padding: 8px 0;")
    title.setAlignment(AlignCenter)
    layout.addWidget(title.getPtr())

    // QCheckBox
    layout.addWidget(sectionTitle("QCheckBox").getPtr())
    let checkRow = QHBoxLayout()
    checkRow.setSpacing(12)
    let cb1 = QCheckBox()
    cb1.setText("选项 A")
    cb1.setChecked(true)
    cb1.setOnStateChanged(onCheckChanged)
    checkRow.addWidget(cb1.getPtr())
    let cb2 = QCheckBox()
    cb2.setText("选项 B")
    cb2.setOnStateChanged(onCheckChanged)
    checkRow.addWidget(cb2.getPtr())
    let cb3 = QCheckBox()
    cb3.setText("选项 C")
    cb3.setOnStateChanged(onCheckChanged)
    checkRow.addWidget(cb3.getPtr())
    layout.addLayout(checkRow.getPtr())

    let checkState = QLabel()
    checkState.setText("复选框: 未操作")
    gCheckStateLabel = checkState
    layout.addWidget(checkState.getPtr())

    // QRadioButton
    layout.addWidget(sectionTitle("QRadioButton").getPtr())
    let radioRow = QHBoxLayout()
    radioRow.setSpacing(12)
    let rb1 = QRadioButton()
    rb1.setText("选项 1")
    rb1.setChecked(true)
    rb1.setOnToggled(onRadioChanged)
    radioRow.addWidget(rb1.getPtr())
    let rb2 = QRadioButton()
    rb2.setText("选项 2")
    rb2.setOnToggled(onRadioChanged)
    radioRow.addWidget(rb2.getPtr())
    let rb3 = QRadioButton()
    rb3.setText("选项 3")
    rb3.setOnToggled(onRadioChanged)
    radioRow.addWidget(rb3.getPtr())
    layout.addLayout(radioRow.getPtr())

    let radioState = QLabel()
    radioState.setText("单选: 选项 1 已选")
    gRadioLabel = radioState
    layout.addWidget(radioState.getPtr())

    // QComboBox
    layout.addWidget(sectionTitle("QComboBox").getPtr())
    let comboRow = QHBoxLayout()
    comboRow.setSpacing(8)
    comboRow.addWidget(infoLabel("下拉:").getPtr())
    let combo = QComboBox()
    combo.addItem("红苹果")
    combo.addItem("香蕉")
    combo.addItem("樱桃")
    combo.addItem("葡萄")
    combo.addItem("芒果")
    combo.addItem("橙子")
    combo.addItem("西瓜")
    combo.setCurrentIndex(0)
    combo.setOnCurrentIndexChanged(onComboChanged)
    comboRow.addWidget(combo.getPtr())
    layout.addLayout(comboRow.getPtr())

    let comboState = QLabel()
    comboState.setText("已选择: 第 1 项")
    gComboLabel = comboState
    layout.addWidget(comboState.getPtr())

    // QFontComboBox
    layout.addWidget(sectionTitle("QFontComboBox").getPtr())
    let fontRow = QHBoxLayout()
    fontRow.setSpacing(8)
    fontRow.addWidget(infoLabel("字体:").getPtr())
    let fontCombo = QFontComboBox()
    fontCombo.setCurrentFont("Arial")
    fontRow.addWidget(fontCombo.getPtr())
    layout.addLayout(fontRow.getPtr())

    layout.addStretch()
    scrollArea
}