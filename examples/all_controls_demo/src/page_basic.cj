package all_controls_demo

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.dialogs.*
import cjqt6.views.*
import cjqt6.richwidgets.*

// -------- 页面0: 基础控件 --------

func createPageBasic(): QScrollArea {
    let (scrollArea, _, layout) = createPageContainer()

    // 标题
    let title = QLabel()
    title.setText("基础控件演示")
    setLabelStyle(title, "font-size: 18px; font-weight: bold; color: #2c3e50; padding: 8px 0;")
    title.setAlignment(AlignCenter)
    layout.addWidget(title.getPtr())

    // QLabel
    layout.addWidget(sectionTitle("QLabel").getPtr())
    let labelDemo = QLabel()
    labelDemo.setText("这是一个QLabel标签，用于显示文本。")
    setLabelStyle(labelDemo, "background-color: #ecf0f1; padding: 8px; border-radius: 4px;")
    layout.addWidget(labelDemo.getPtr())

    // QPushButton
    layout.addWidget(sectionTitle("QPushButton").getPtr())
    let btnRow1 = QHBoxLayout()
    btnRow1.setSpacing(8)

    let btn1 = QPushButton()
    btn1.setText("点击我")
    btn1.setOnClick(onBtnClick)
    btnRow1.addWidget(btn1.getPtr())

    let btn2 = QPushButton()
    btn2.setText("清空")
    btn2.setOnClick(onBtnClear)
    btnRow1.addWidget(btn2.getPtr())

    let btn3 = QPushButton()
    btn3.setText("标准按钮")
    btnRow1.addWidget(btn3.getPtr())

    let btn4 = QPushButton()
    btn4.setText("禁用按钮")
    btn4.setEnabled(false)
    btnRow1.addWidget(btn4.getPtr())
    layout.addLayout(btnRow1.getPtr())

    // 图标按钮行
    let btnRow2 = QHBoxLayout()
    btnRow2.setSpacing(8)
    let iconBtns = ["打开", "保存", "帮助", "取消", "刷新"]
    let iconTypes = [StandardIcon.Open, StandardIcon.Save, StandardIcon.Help, StandardIcon.Cancel, StandardIcon.Reload]
    for (i in 0..iconBtns.size) {
        let btn = QPushButton()
        btn.setStandardIcon(iconTypes[i])
        btn.setText(iconBtns[i])
        btnRow2.addWidget(btn.getPtr())
    }
    layout.addLayout(btnRow2.getPtr())

    // QToolButton
    layout.addWidget(sectionTitle("QToolButton").getPtr())
    let toolRow = QHBoxLayout()
    toolRow.setSpacing(8)

    for (text in ["新建", "打开", "保存", "删除"]) {
        let tb = QToolButton()
        tb.setText(text)
        tb.setToolButtonStyle(ToolButtonTextOnly)
        toolRow.addWidget(tb.getPtr())
    }
    layout.addLayout(toolRow.getPtr())

    // QProgressBar
    layout.addWidget(sectionTitle("QProgressBar").getPtr())
    let bar = QProgressBar()
    bar.setRange(0, 100)
    bar.setValue(65)
    bar.setTextVisible(true)
    gProgressBar = bar
    layout.addWidget(bar.getPtr())

    // 进度控制行
    let progressCtrl = QHBoxLayout()
    progressCtrl.setSpacing(8)
    let btnSet30 = QPushButton()
    btnSet30.setText("30%")
    btnSet30.setOnClick({ => if (let Some(b) <- gProgressBar) { b.setValue(30) } })
    progressCtrl.addWidget(btnSet30.getPtr())
    let btnSet60 = QPushButton()
    btnSet60.setText("60%")
    btnSet60.setOnClick({ => if (let Some(b) <- gProgressBar) { b.setValue(60) } })
    progressCtrl.addWidget(btnSet60.getPtr())
    let btnSet90 = QPushButton()
    btnSet90.setText("90%")
    btnSet90.setOnClick({ => if (let Some(b) <- gProgressBar) { b.setValue(90) } })
    progressCtrl.addWidget(btnSet90.getPtr())
    let btnSet100 = QPushButton()
    btnSet100.setText("100%")
    btnSet100.setOnClick({ => if (let Some(b) <- gProgressBar) { b.setValue(100) } })
    progressCtrl.addWidget(btnSet100.getPtr())
    layout.addLayout(progressCtrl.getPtr())

    layout.addStretch()
    scrollArea
}