package all_controls_demo

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.dialogs.*
import cjqt6.views.*

// ============================================================
// CJQT6 全控件演示 - 侧边栏导航 + 页面切换
// ============================================================

// ============================================================
// 对齐常量 (Int32 values for QLabel.setAlignment etc.)
// ============================================================
let AlignLeft: Int32 = 0x0001
let AlignCenter: Int32 = 0x0084

// ============================================================
// 全局控件引用（用于CFunc回调 - CFunc不能捕获外部变量）
// ============================================================
var gStackedWidget: ?QStackedWidget = None
var gStatusLabel: ?QLabel = None
var gProgressBar: ?QProgressBar = None
var gSliderValueLabel: ?QLabel = None
var gSpinValueLabel: ?QLabel = None
var gDialValueLabel: ?QLabel = None
var gLcdNumber: ?QLCDNumber = None
var gMainWindow: ?QWidget = None
var gCheckStateLabel: ?QLabel = None
var gRadioLabel: ?QLabel = None
var gComboLabel: ?QLabel = None
var gKeyEdit: ?QKeySequenceEdit = None

// ============================================================
// 页面名称列表（与createPages顺序一致）
// ============================================================
let pageNames: Array<String> = [
    "[1] 基础控件",
    "[2] 文本输入",
    "[3] 数值控件",
    "[4] 选择控件",
    "[5] 容器布局",
    "[6] 高级控件",
    "[7] 对话框"
]

// ============================================================
// 回调函数
// ============================================================

// 侧边栏切换回调
let onSidebarChanged: CFunc<(Int32) -> Unit> = { row: Int32 =>
    if (row >= 0) {
        if (let Some(stack) <- gStackedWidget) {
            stack.setCurrentIndex(row)
        }
        if (let Some(status) <- gStatusLabel) {
            if (row < Int32(pageNames.size)) {
                status.setText("当前页面: ${pageNames[Int64(row)]}")
            }
        }
    }
}

// 基础控件 - 按钮点击
let onBtnClick: VoidCallback = { =>
    if (let Some(status) <- gStatusLabel) {
        status.setText("按钮被点击了！(点击时间: ${now()})")
    }
}

let onBtnClear: VoidCallback = { =>
    if (let Some(status) <- gStatusLabel) {
        status.setText("信息已清空 ✓")
    }
}

let onSliderChanged: Int32Callback = { value: Int32 =>
    if (let Some(label) <- gSliderValueLabel) {
        label.setText("当前值: ${value}")
    }
    if (let Some(bar) <- gProgressBar) {
        bar.setValue(value)
    }
}

let onSpinChanged: Int32Callback = { value: Int32 =>
    if (let Some(label) <- gSpinValueLabel) {
        label.setText("值: ${value}")
    }
}

let onDialChanged: Int32Callback = { value: Int32 =>
    if (let Some(label) <- gDialValueLabel) {
        label.setText("角度: ${value}°")
    }
    if (let Some(lcd) <- gLcdNumber) {
        lcd.displayInt(value)
    }
}

let onCheckChanged: Int32Callback = { state: Int32 =>
    if (let Some(label) <- gCheckStateLabel) {
        if (state == 2) {
            label.setText("复选框: 已选中 ✓")
        } else {
            label.setText("复选框: 未选中 ✗")
        }
    }
}

let onRadioChanged: Int32Callback = { checked: Int32 =>
    if (checked == 1) {
        if (let Some(label) <- gRadioLabel) {
            label.setText("单选: 选项已切换")
        }
    }
}

let onComboChanged: Int32Callback = { index: Int32 =>
    if (let Some(label) <- gComboLabel) {
        label.setText("已选择: 第 ${index + 1} 项")
    }
}

// 对话框回调
let onMsgInfo: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        QMessageBox.information(w.getPtr(), "信息", "这是一个信息对话框")
    }
}

let onMsgWarning: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        QMessageBox.warning(w.getPtr(), "警告", "这是一个警告对话框！")
    }
}

let onMsgQuestion: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        let result = QMessageBox.question(w.getPtr(), "询问", "确定要执行此操作吗？")
        if (let Some(status) <- gStatusLabel) {
            if (result) {
                status.setText("询问结果: 是 ✓")
            } else {
                status.setText("询问结果: 否 ✗")
            }
        }
    }
}

let onMsgError: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        QMessageBox.critical(w.getPtr(), "错误", "发生了一个严重错误！")
    }
}

let onFileOpen: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        let filePath = QFileDialog.getOpenFileName(w.getPtr(), "选择文件", "所有文件 (*.*)")
        if (!filePath.isEmpty()) {
            if (let Some(status) <- gStatusLabel) {
                status.setText("打开文件: ${filePath}")
            }
        }
    }
}

let onFileSave: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        let filePath = QFileDialog.getSaveFileName(w.getPtr(), "保存文件", "文本文件 (*.txt)")
        if (!filePath.isEmpty()) {
            if (let Some(status) <- gStatusLabel) {
                status.setText("保存文件: ${filePath}")
            }
        }
    }
}

let onInputText: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        let (text, ok) = QInputDialog.getTextWithResult(w.getPtr(), "输入文本", "请输入内容:", "")
        if (ok) {
            if (let Some(status) <- gStatusLabel) {
                status.setText("输入文本: ${text}")
            }
        }
    }
}

let onInputInt: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        let (value, ok) = QInputDialog.getIntWithResult(w.getPtr(), "输入整数", "请输入一个数字:", 0, 0, 1000)
        if (ok) {
            if (let Some(status) <- gStatusLabel) {
                status.setText("输入整数: ${value}")
            }
        }
    }
}

let onColorPicker: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        let color = QColorDialog.getColor(w.getPtr(), "选择颜色")
        if (!color.isEmpty()) {
            if (let Some(status) <- gStatusLabel) {
                status.setText("选择颜色: ${color}")
            }
        }
    }
}

let onFontPicker: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        let fontName = QFontDialog.getFontName(w.getPtr(), "选择字体")
        if (!fontName.isEmpty()) {
            if (let Some(status) <- gStatusLabel) {
                status.setText("选择字体: ${fontName}")
            }
        }
    }
}

// ============================================================
// 辅助函数
// ============================================================

func now(): String {
    "12:00:00"  // 简化实现
}

func setLabelStyle(lbl: QLabel, style: String) {
    lbl.setStyleSheet(style)
}

func sectionTitle(text: String): QLabel {
    let lbl = QLabel()
    lbl.setText("▸ ${text}")
    setLabelStyle(lbl, "font-size: 14px; font-weight: bold; color: #2c3e50; margin-top: 8px;")
    lbl.setAlignment(AlignLeft)
    lbl
}

func infoLabel(text: String): QLabel {
    let lbl = QLabel()
    lbl.setText(text)
    setLabelStyle(lbl, "color: #7f8c8d; font-size: 12px;")
    lbl
}

// ============================================================
// 页面创建函数 - 每个页面放在QScrollArea中
// ============================================================

// 创建一个带滚动条的页面容器
func createPageContainer(): (QScrollArea, QWidget, QVBoxLayout) {
    let container = QWidget()
    let layout = QVBoxLayout()
    layout.setSpacing(6)
    layout.setMargin(12)
    container.setLayout(layout.getPtr())

    let scrollArea = QScrollArea()
    scrollArea.setWidget(container.getPtr())
    scrollArea.setWidgetResizable(true)

    (scrollArea, container, layout)
}

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

// -------- 页面1: 文本输入 --------
func createPageText(): QScrollArea {
    let (scrollArea, _, layout) = createPageContainer()

    let title = QLabel()
    title.setText("文本输入控件演示")
    setLabelStyle(title, "font-size: 18px; font-weight: bold; color: #2c3e50; padding: 8px 0;")
    title.setAlignment(AlignCenter)
    layout.addWidget(title.getPtr())

    // QLineEdit
    layout.addWidget(sectionTitle("QLineEdit").getPtr())

    let lineNormal = QHBoxLayout()
    lineNormal.addWidget(infoLabel("普通:").getPtr())
    let editNormal = QLineEdit()
    editNormal.setPlaceholder("请输入文本...")
    lineNormal.addWidget(editNormal.getPtr())
    layout.addLayout(lineNormal.getPtr())

    let linePassword = QHBoxLayout()
    linePassword.addWidget(infoLabel("密码:").getPtr())
    let editPwd = QLineEdit()
    editPwd.setPlaceholder("密码模式")
    editPwd.setEchoMode(2)
    linePassword.addWidget(editPwd.getPtr())
    layout.addLayout(linePassword.getPtr())

    let lineReadOnly = QHBoxLayout()
    lineReadOnly.addWidget(infoLabel("只读:").getPtr())
    let editRO = QLineEdit()
    editRO.setText("只读文本内容")
    editRO.setReadOnly(true)
    lineReadOnly.addWidget(editRO.getPtr())
    layout.addLayout(lineReadOnly.getPtr())

    let lineMask = QHBoxLayout()
    lineMask.addWidget(infoLabel("掩码IP:").getPtr())
    let editIP = QLineEdit()
    editIP.setInputMask(InputMask.IP)
    editIP.setPlaceholder("000.000.000.000")
    lineMask.addWidget(editIP.getPtr())
    layout.addLayout(lineMask.getPtr())

    // QTextEdit
    layout.addWidget(sectionTitle("QTextEdit").getPtr())
    let textEdit = QTextEdit()
    textEdit.setText("这是一个QTextEdit多行文本编辑器。\n支持多行文本编辑。\n可以设置字体、大小等属性。")
    textEdit.setMinimumSize(0, 100)
    layout.addWidget(textEdit.getPtr())

    // QPlainTextEdit
    layout.addWidget(sectionTitle("QPlainTextEdit").getPtr())
    let plainEdit = QPlainTextEdit()
    plainEdit.setPlainText("这是一个QPlainTextEdit纯文本编辑器。\n比QTextEdit更轻量。\n适合日志查看、代码编辑等场景。")
    plainEdit.setMinimumSize(0, 80)
    layout.addWidget(plainEdit.getPtr())

    // QTextBrowser
    layout.addWidget(sectionTitle("QTextBrowser").getPtr())
    let browser = QTextBrowser()
    let htmlContent: String = "<h2 style='color:#3498db;'>HTML 富文本</h2>" +
        "<p>QTextBrowser 支持 <b>HTML</b> 内容显示。</p>" +
        "<ul>" +
        "<li><span style='color:#e74c3c;'>红色</span></li>" +
        "<li><span style='color:#27ae60;'>绿色</span></li>" +
        "<li><span style='color:#f39c12;'>橙色</span></li>" +
        "</ul>" +
        "<p><a href='#'>超链接示例</a></p>"
    browser.setHtml(htmlContent)
    browser.setMinimumSize(0, 100)
    layout.addWidget(browser.getPtr())

    layout.addStretch()
    scrollArea
}

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

// -------- 页面4: 容器布局 --------
func createPageContainers(): QScrollArea {
    let (scrollArea, _, layout) = createPageContainer()

    let title = QLabel()
    title.setText("容器布局演示")
    setLabelStyle(title, "font-size: 18px; font-weight: bold; color: #2c3e50; padding: 8px 0;")
    title.setAlignment(AlignCenter)
    layout.addWidget(title.getPtr())

    // QGroupBox
    layout.addWidget(sectionTitle("QGroupBox").getPtr())
    let groupBox = QGroupBox()
    groupBox.setTitle("用户信息")
    let groupLayout = QVBoxLayout()
    let nameRow = QHBoxLayout()
    nameRow.addWidget(infoLabel("姓名:").getPtr())
    let nameEdit = QLineEdit()
    nameEdit.setPlaceholder("请输入姓名")
    nameRow.addWidget(nameEdit.getPtr())
    groupLayout.addLayout(nameRow.getPtr())
    let emailRow = QHBoxLayout()
    emailRow.addWidget(infoLabel("邮箱:").getPtr())
    let emailEdit = QLineEdit()
    emailEdit.setPlaceholder("请输入邮箱")
    emailRow.addWidget(emailEdit.getPtr())
    groupLayout.addLayout(emailRow.getPtr())
    groupBox.setLayout(groupLayout.getPtr())
    layout.addWidget(groupBox.getPtr())

    // QTabWidget
    layout.addWidget(sectionTitle("QTabWidget").getPtr())
    let tabWidget = QTabWidget()

    let tab1Content = QWidget()
    let tab1Layout = QVBoxLayout()
    let tab1Label = QLabel()
    tab1Label.setText("这是标签页 1 的内容")
    tab1Label.setAlignment(AlignCenter)
    tab1Layout.addWidget(tab1Label.getPtr())
    tab1Layout.addStretch()
    tab1Content.setLayout(tab1Layout.getPtr())
    tabWidget.addTab(tab1Content.getPtr(), "页面 1")

    let tab2Content = QWidget()
    let tab2Layout = QVBoxLayout()
    let tab2Label = QLabel()
    tab2Label.setText("这是标签页 2 的内容")
    tab2Label.setAlignment(AlignCenter)
    tab2Layout.addWidget(tab2Label.getPtr())
    tab2Layout.addStretch()
    tab2Content.setLayout(tab2Layout.getPtr())
    tabWidget.addTab(tab2Content.getPtr(), "页面 2")

    let tab3Content = QWidget()
    let tab3Layout = QVBoxLayout()
    let tab3Label = QLabel()
    tab3Label.setText("这是标签页 3 的内容")
    tab3Label.setAlignment(AlignCenter)
    tab3Layout.addWidget(tab3Label.getPtr())
    tab3Layout.addStretch()
    tab3Content.setLayout(tab3Layout.getPtr())
    tabWidget.addTab(tab3Content.getPtr(), "页面 3")

    tabWidget.setMinimumSize(0, 120)
    layout.addWidget(tabWidget.getPtr())

    // QFrame
    layout.addWidget(sectionTitle("QFrame").getPtr())
    let frameRow = QHBoxLayout()
    frameRow.setSpacing(8)
    let frame1 = QFrame()
    frame1.setFrameShape(StyledPanel)
    frame1.setFrameShadow(Raised)
    frame1.setLineWidth(2)
    let frame1Layout = QVBoxLayout()
    let frame1Label = QLabel()
    frame1Label.setText("凸起面板")
    frame1Label.setAlignment(AlignCenter)
    frame1Layout.addWidget(frame1Label.getPtr())
    frame1.setLayout(frame1Layout.getPtr())
    frameRow.addWidget(frame1.getPtr())

    let frame2 = QFrame()
    frame2.setFrameShape(StyledPanel)
    frame2.setFrameShadow(Sunken)
    frame2.setLineWidth(2)
    let frame2Layout = QVBoxLayout()
    let frame2Label = QLabel()
    frame2Label.setText("凹陷面板")
    frame2Label.setAlignment(AlignCenter)
    frame2Layout.addWidget(frame2Label.getPtr())
    frame2.setLayout(frame2Layout.getPtr())
    frameRow.addWidget(frame2.getPtr())

    let frame3 = QFrame()
    frame3.setFrameShape(1)  // Box
    frame3.setFrameShadow(Plain)
    frame3.setLineWidth(1)
    let frame3Layout = QVBoxLayout()
    let frame3Label = QLabel()
    frame3Label.setText("方框面板")
    frame3Label.setAlignment(AlignCenter)
    frame3Layout.addWidget(frame3Label.getPtr())
    frame3.setLayout(frame3Layout.getPtr())
    frameRow.addWidget(frame3.getPtr())
    layout.addLayout(frameRow.getPtr())

    // QToolBox
    layout.addWidget(sectionTitle("QToolBox").getPtr())
    let toolbox = QToolBox()
    toolbox.setMinimumSize(0, 140)

    let tbPage1 = QWidget()
    let tbLayout1 = QVBoxLayout()
    let tbLabel1 = QLabel()
    tbLabel1.setText("工具箱页面一的内容区域")
    tbLabel1.setAlignment(AlignCenter)
    tbLayout1.addWidget(tbLabel1.getPtr())
    tbPage1.setLayout(tbLayout1.getPtr())

    let tbPage2 = QWidget()
    let tbLayout2 = QVBoxLayout()
    let tbLabel2 = QLabel()
    tbLabel2.setText("工具箱页面二的内容区域")
    tbLabel2.setAlignment(AlignCenter)
    tbLayout2.addWidget(tbLabel2.getPtr())
    tbPage2.setLayout(tbLayout2.getPtr())

    toolbox.addItem(tbPage1.getPtr(), "工具组 1")
    toolbox.addItem(tbPage2.getPtr(), "工具组 2")
    layout.addWidget(toolbox.getPtr())

    layout.addStretch()
    scrollArea
}

// -------- 页面5: 高级控件 --------
func createPageAdvanced(): QScrollArea {
    let (scrollArea, _, layout) = createPageContainer()

    let title = QLabel()
    title.setText("高级控件演示")
    setLabelStyle(title, "font-size: 18px; font-weight: bold; color: #2c3e50; padding: 8px 0;")
    title.setAlignment(AlignCenter)
    layout.addWidget(title.getPtr())

    // QDateTimeEdit - 使用 QDate/QTime
    layout.addWidget(sectionTitle("QDate / QTime").getPtr())
    let dateInfo = QHBoxLayout()
    dateInfo.setSpacing(8)

    let currentDate = QDate.currentDate()
    let dateStr = currentDate.toString()
    let dateLabel = QLabel()
    dateLabel.setText("当前日期: ${dateStr}  |  年: ${currentDate.year()} 月: ${currentDate.month()} 日: ${currentDate.day()}")
    setLabelStyle(dateLabel, "padding: 6px; background-color: #f8f9fa; border-radius: 4px;")
    dateInfo.addWidget(dateLabel.getPtr())
    layout.addLayout(dateInfo.getPtr())

    // QKeySequenceEdit
    layout.addWidget(sectionTitle("QKeySequenceEdit").getPtr())
    let keyRow = QHBoxLayout()
    keyRow.setSpacing(8)
    keyRow.addWidget(infoLabel("快捷键:").getPtr())
    let keyEdit = QKeySequenceEdit()
    keyEdit.setKeySequence("Ctrl+Shift+S")
    gKeyEdit = keyEdit
    keyRow.addWidget(keyEdit.getPtr())
    let keyBtn = QPushButton()
    keyBtn.setText("获取快捷键")
    keyBtn.setOnClick({ =>
        if (let Some(ke) <- gKeyEdit) {
            let seq = ke.keySequence()
            if (let Some(status) <- gStatusLabel) {
                status.setText("快捷键: ${seq}")
            }
        }
    })
    keyRow.addWidget(keyBtn.getPtr())
    layout.addLayout(keyRow.getPtr())

    // QTreeWidget
    layout.addWidget(sectionTitle("QTreeWidget").getPtr())
    let tree = QTreeWidget()
    tree.setColumnCount(2)
    tree.setHeaderLabel(0, "项目")
    tree.setHeaderLabel(1, "值")

    let root1 = tree.addTopLevelItem("水果")
    root1.addChild("苹果")
    root1.addChild("香蕉")
    root1.addChild("橙子")

    let root2 = tree.addTopLevelItem("蔬菜")
    root2.addChild("西红柿")
    root2.addChild("黄瓜")
    root2.addChild("白菜")

    tree.expandAll()
    tree.setMinimumSize(0, 140)
    layout.addWidget(tree.getPtr())

    // QTableWidget
    layout.addWidget(sectionTitle("QTableWidget").getPtr())
    let table = QTableWidget()
    table.setRowCount(5)
    table.setColumnCount(4)
    table.setHorizontalHeaderLabel(0, "姓名")
    table.setHorizontalHeaderLabel(1, "年龄")
    table.setHorizontalHeaderLabel(2, "城市")
    table.setHorizontalHeaderLabel(3, "职业")

    table.setItem(0, 0, "张三")
    table.setItem(0, 1, "28")
    table.setItem(0, 2, "北京")
    table.setItem(0, 3, "工程师")

    table.setItem(1, 0, "李四")
    table.setItem(1, 1, "32")
    table.setItem(1, 2, "上海")
    table.setItem(1, 3, "设计师")

    table.setItem(2, 0, "王五")
    table.setItem(2, 1, "25")
    table.setItem(2, 2, "广州")
    table.setItem(2, 3, "产品经理")

    table.setItem(3, 0, "赵六")
    table.setItem(3, 1, "35")
    table.setItem(3, 2, "深圳")
    table.setItem(3, 3, "架构师")

    table.setItem(4, 0, "钱七")
    table.setItem(4, 1, "29")
    table.setItem(4, 2, "杭州")
    table.setItem(4, 3, "测试工程师")

    table.setAlternatingRowColors(true)
    table.setSelectionBehavior(SelectRows)
    table.setSelectionMode(SingleSelection)
    table.resizeColumnsToContents()
    table.setMinimumSize(0, 160)
    layout.addWidget(table.getPtr())

    // QListWidget
    layout.addWidget(sectionTitle("QListWidget").getPtr())
    let listWidget = QListWidget()
    listWidget.addItem("列表项 1")
    listWidget.addItem("列表项 2")
    listWidget.addItem("列表项 3")
    listWidget.addItem("列表项 4")
    listWidget.addItem("列表项 5")
    listWidget.setAlternatingRowColors(true)
    listWidget.setMinimumSize(0, 100)
    layout.addWidget(listWidget.getPtr())

    layout.addStretch()
    scrollArea
}

// -------- 页面6: 对话框 --------
func createPageDialogs(): QScrollArea {
    let (scrollArea, _, layout) = createPageContainer()

    let title = QLabel()
    title.setText("对话框演示")
    setLabelStyle(title, "font-size: 18px; font-weight: bold; color: #2c3e50; padding: 8px 0;")
    title.setAlignment(AlignCenter)
    layout.addWidget(title.getPtr())

    let desc = QLabel()
    desc.setText("点击下方按钮打开各种对话框")
    setLabelStyle(desc, "color: #7f8c8d; font-size: 13px; margin-bottom: 8px;")
    desc.setAlignment(AlignCenter)
    layout.addWidget(desc.getPtr())

    // QMessageBox
    layout.addWidget(sectionTitle("QMessageBox").getPtr())
    let msgRow1 = QHBoxLayout()
    msgRow1.setSpacing(8)
    let btnInfo = QPushButton()
    btnInfo.setText("📌 信息")
    btnInfo.setOnClick(onMsgInfo)
    msgRow1.addWidget(btnInfo.getPtr())
    let btnWarn = QPushButton()
    btnWarn.setText("! 警告")
    btnWarn.setOnClick(onMsgWarning)
    msgRow1.addWidget(btnWarn.getPtr())
    let btnQuest = QPushButton()
    btnQuest.setText("❓ 询问")
    btnQuest.setOnClick(onMsgQuestion)
    btnQuest.setStyleSheet("QPushButton { color: white; background-color: #f39c12; }")
    msgRow1.addWidget(btnQuest.getPtr())
    let btnErr = QPushButton()
    btnErr.setText("❌ 错误")
    btnErr.setOnClick(onMsgError)
    btnErr.setStyleSheet("QPushButton { color: white; background-color: #e74c3c; }")
    msgRow1.addWidget(btnErr.getPtr())
    layout.addLayout(msgRow1.getPtr())

    // QFileDialog
    layout.addWidget(sectionTitle("QFileDialog").getPtr())
    let fileRow = QHBoxLayout()
    fileRow.setSpacing(8)
    let btnOpen = QPushButton()
    btnOpen.setText("📂 打开文件")
    btnOpen.setOnClick(onFileOpen)
    fileRow.addWidget(btnOpen.getPtr())
    let btnSave = QPushButton()
    btnSave.setText("💾 保存文件")
    btnSave.setOnClick(onFileSave)
    fileRow.addWidget(btnSave.getPtr())
    layout.addLayout(fileRow.getPtr())

    // QInputDialog
    layout.addWidget(sectionTitle("QInputDialog").getPtr())
    let inputRow = QHBoxLayout()
    inputRow.setSpacing(8)
    let btnInputText = QPushButton()
    btnInputText.setText("📝 输入文本")
    btnInputText.setOnClick(onInputText)
    inputRow.addWidget(btnInputText.getPtr())
    let btnInputInt = QPushButton()
    btnInputInt.setText("🔢 输入整数")
    btnInputInt.setOnClick(onInputInt)
    inputRow.addWidget(btnInputInt.getPtr())
    layout.addLayout(inputRow.getPtr())

    // QColorDialog + QFontDialog
    layout.addWidget(sectionTitle("QColorDialog / QFontDialog").getPtr())
    let miscRow = QHBoxLayout()
    miscRow.setSpacing(8)
    let btnColor = QPushButton()
    btnColor.setText("🎨 选择颜色")
    btnColor.setOnClick(onColorPicker)
    miscRow.addWidget(btnColor.getPtr())
    let btnFont = QPushButton()
    btnFont.setText("🔤 选择字体")
    btnFont.setOnClick(onFontPicker)
    miscRow.addWidget(btnFont.getPtr())
    layout.addLayout(miscRow.getPtr())

    // QProgressDialog
    layout.addWidget(sectionTitle("QProgressDialog").getPtr())
    let progRow = QHBoxLayout()
    progRow.setSpacing(8)
    let btnProgressDlg = QPushButton()
    btnProgressDlg.setText("⏳ 进度对话框")
    btnProgressDlg.setOnClick({ =>
        if (let Some(w) <- gMainWindow) {
            let progressDlg = QProgressDialog(w.getPtr(), "正在处理...", "取消", 0, 100)
            progressDlg.setWindowTitle("进度")
            for (i in 0..101) {
                progressDlg.setValue(Int32(i))
                if (progressDlg.wasCanceled()) {
                    break
                }
                // 模拟耗时
                var x: Int32 = 0
                for (j in 0..1000000) {
                    x += Int32(j)
                }
            }
            progressDlg.delete()
            if (let Some(status) <- gStatusLabel) {
                status.setText("进度对话框已完成")
            }
        }
    })
    progRow.addWidget(btnProgressDlg.getPtr())
    layout.addLayout(progRow.getPtr())

    layout.addStretch()
    scrollArea
}

// ============================================================
// 主函数
// ============================================================
main(): Int32 {
    let app = QApplication()
    app.loadQtTranslation("zh_CN")

    // ========== 主窗口 ==========
    let window = QWidget()
    window.setTitle("CJQT6 全控件演示")
    window.resize(900, 620)
    window.setMinimumSize(700, 480)
    gMainWindow = window

    // ========== 整体布局: 水平分割器 ==========
    let splitter = QSplitter.createHorizontal(0)
    splitter.setHandleWidth(1)
    splitter.setChildrenCollapsible(false)

    // ========== 左侧: 导航栏 ==========
    let sidebar = QListWidget()
    sidebar.setAlternatingRowColors(true)
    sidebar.setSelectionMode(ListSelectionMode.SingleSelection)
    for (name in pageNames) {
        sidebar.addItem(name)
    }
    sidebar.setCurrentRow(0)
    sidebar.setMinimumSize(160, 0)
    sidebar.setMaximumSize(220, 0xFFFFFF)

    // ========== 右侧: 堆叠页面 ==========
    let stackedWidget = QStackedWidget()
    gStackedWidget = stackedWidget

    // 创建所有页面并添加到堆叠控件
    let pages = [
        createPageBasic(),
        createPageText(),
        createPageNumeric(),
        createPageSelection(),
        createPageContainers(),
        createPageAdvanced(),
        createPageDialogs()
    ]
    for (page in pages) {
        stackedWidget.addWidget(page.getPtr())
    }

    // 侧边栏切换事件
    sidebar.setOnCurrentRowChanged(onSidebarChanged)

    // ========== 分割器组装 ==========
    splitter.addWidget(sidebar.getPtr())
    splitter.addWidget(stackedWidget.getPtr())
    splitter.setStretchFactor(0, 0)  // 侧边栏不拉伸
    splitter.setStretchFactor(1, 1)  // 内容区域拉伸

    // ========== 主布局（垂直：分割器 + 状态栏） ==========
    let mainLayout = QVBoxLayout()
    mainLayout.setSpacing(0)
    mainLayout.setMargin(0)

    // 将分割器添加到布局（stretch=1，使其占据所有剩余空间）
    mainLayout.addWidget(splitter.getPtr(), 1)

    // 状态栏（紧凑）
    let statusBar = QFrame()
    statusBar.setFrameShape(0)    // NoFrame - 减少边框高度
    let statusBarLayout = QHBoxLayout()
    statusBarLayout.setMargin(0)
    statusBarLayout.setSpacing(4)
    let statusLabel = QLabel()
    statusLabel.setText("就绪 - 点击侧边栏切换页面")
    setLabelStyle(statusLabel, "color: #7f8c8d; font-size: 10px; padding: 0px; margin: 0px;")
    gStatusLabel = statusLabel
    statusBarLayout.addWidget(statusLabel.getPtr())
    statusBarLayout.addStretch()

    let versionLabel = QLabel()
    versionLabel.setText("CJQT6 v1.1.0")
    setLabelStyle(versionLabel, "color: #bdc3c7; font-size: 9px; padding: 0px; margin: 0px;")
    statusBarLayout.addWidget(versionLabel.getPtr())

    statusBar.setLayout(statusBarLayout.getPtr())
    mainLayout.addWidget(statusBar.getPtr())

    // 将主布局设置到窗口
    window.setLayout(mainLayout.getPtr())

    // ========== 样式美化 ==========
    sidebar.setStyleSheet("""
        QListWidget {
            border: none;
            border-right: 1px solid #dcdde1;
            background-color: #f5f6fa;
            font-size: 13px;
        }
        QListWidget::item {
            padding: 10px 12px;
            border-bottom: 1px solid #e8e9ed;
        }
        QListWidget::item:selected {
            background-color: #3498db;
            color: white;
            border: none;
        }
        QListWidget::item:hover:!selected {
            background-color: #e8e9ed;
        }
    """)

    window.setStyleSheet("""
        QWidget {
            font-family: "Microsoft YaHei", "Segoe UI", sans-serif;
        }
        QPushButton {
            padding: 5px 12px;
            border: 1px solid #bdc3c7;
            border-radius: 3px;
            background-color: #f8f9fa;
        }
        QPushButton:hover {
            background-color: #e8e9ed;
            border-color: #95a5a6;
        }
        QPushButton:pressed {
            background-color: #dcdde1;
        }
        QGroupBox {
            font-weight: bold;
            border: 1px solid #bdc3c7;
            border-radius: 4px;
            margin-top: 8px;
            padding-top: 12px;
        }
        QGroupBox::title {
            subcontrol-origin: margin;
            left: 10px;
            padding: 0 4px;
        }
        QTextEdit, QPlainTextEdit, QLineEdit {
            border: 1px solid #dcdde1;
            border-radius: 3px;
            padding: 3px;
        }
        QTabWidget::pane {
            border: 1px solid #bdc3c7;
            border-top: none;
        }
        QStatusBar {
            background-color: #f5f6fa;
        }
    """)

    // ========== 显示窗口 ==========
    window.show()

    let result = app.exec()

    // 清理资源
    window.delete()

    return result
}
