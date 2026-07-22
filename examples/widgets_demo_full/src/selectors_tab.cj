package widgets_demo_full

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

var g_selInfo: ?QLabel = None

func createSelectorsTab(): QWidget {
    let tab = QWidget()
    let layout = QVBoxLayout()
    layout.setSpacing(6)
    layout.setMargin(12)

    let info = QLabel()
    info.setText("Toggle selectors to see effects")
    g_selInfo = info
    layout.addWidget(info.getPtr())

    // CheckBoxes
    let secCB = QLabel()
    secCB.setText("-- CheckBoxes --")
    secCB.setStyleSheet("font-weight: bold; color: #ea4335;")
    layout.addWidget(secCB.getPtr())
    let cbRow = QHBoxLayout()
    let cb1 = QCheckBox()
    cb1.setText("Option A")
    cb1.setChecked(true)
    cbRow.addWidget(cb1.getPtr())
    let cb2 = QCheckBox()
    cb2.setText("Option B")
    cbRow.addWidget(cb2.getPtr())
    let cb3 = QCheckBox()
    cb3.setText("Option C")
    cb3.setEnabled(false)
    cbRow.addWidget(cb3.getPtr())
    layout.addLayout(cbRow.getPtr())

    // RadioButtons
    let secRB = QLabel()
    secRB.setText("-- Radio Buttons --")
    secRB.setStyleSheet("font-weight: bold; color: #ea4335;")
    layout.addWidget(secRB.getPtr())
    let rbRow = QHBoxLayout()
    let rb1 = QRadioButton()
    rb1.setText("Red")
    rb1.setChecked(true)
    rbRow.addWidget(rb1.getPtr())
    let rb2 = QRadioButton()
    rb2.setText("Green")
    rbRow.addWidget(rb2.getPtr())
    let rb3 = QRadioButton()
    rb3.setText("Blue")
    rbRow.addWidget(rb3.getPtr())
    layout.addLayout(rbRow.getPtr())

    // ComboBox
    let secCombo = QLabel()
    secCombo.setText("-- Combo Box --")
    secCombo.setStyleSheet("font-weight: bold; color: #ea4335;")
    layout.addWidget(secCombo.getPtr())
    let combo = QComboBox()
    combo.addItem("Item 1")
    combo.addItem("Item 2")
    combo.addItem("Item 3")
    combo.addItem("Item 4")
    combo.setOnCurrentIndexChanged({ idx: Int32 =>
        if (let Some(l) <- g_selInfo) { l.setText("Combo selected: index " + idx.toString()) }
    })
    layout.addWidget(combo.getPtr())

    // Slider
    let secSlider = QLabel()
    secSlider.setText("-- Slider --")
    secSlider.setStyleSheet("font-weight: bold; color: #ea4335;")
    layout.addWidget(secSlider.getPtr())
    let slider = QSlider()
    slider.setOrientation(1)
    slider.setRange(0, 100)
    slider.setValue(50)
    layout.addWidget(slider.getPtr())

    // Dial
    let secDial = QLabel()
    secDial.setText("-- Dial --")
    secDial.setStyleSheet("font-weight: bold; color: #ea4335;")
    layout.addWidget(secDial.getPtr())
    let dial = QDial()
    dial.setRange(0, 100)
    dial.setValue(30)
    layout.addWidget(dial.getPtr())

    // SpinBox & DoubleSpinBox
    let secSpin = QLabel()
    secSpin.setText("-- Spin Boxes --")
    secSpin.setStyleSheet("font-weight: bold; color: #ea4335;")
    layout.addWidget(secSpin.getPtr())
    let spinRow = QHBoxLayout()
    let spin = QSpinBox()
    spin.setRange(0, 9999)
    spin.setValue(42)
    spinRow.addWidget(spin.getPtr())
    let dspin = QDoubleSpinBox()
    dspin.setRange(0.0, 100.0)
    dspin.setValue(3.14)
    dspin.setDecimals(2)
    spinRow.addWidget(dspin.getPtr())
    layout.addLayout(spinRow.getPtr())

    layout.addStretch()
    tab.setLayout(layout.getPtr())
    return tab
}