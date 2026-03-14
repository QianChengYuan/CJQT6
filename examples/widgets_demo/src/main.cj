package widgets_demo

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*

// ============================================================
// CJQT6 常用控件示例
// ============================================================

// 全局控件引用（用于回调中访问）
var infoLabel: ?QLabel = None
var progressBar: ?QProgressBar = None
var sliderValueLabel: ?QLabel = None
var spinBoxValueLabel: ?QLabel = None
var passwordEdit: ?QLineEdit = None
var passwordVisible: Bool = false

// ============================================================
// 回调函数定义
// ============================================================

// 按钮回调
let onButtonClick: VoidCallback = { =>
    if (let Some(label) <- infoLabel) {
        label.setText("按钮被点击了！")
    }
}

let onClearClick: VoidCallback = { =>
    if (let Some(label) <- infoLabel) {
        label.setText("信息已清空")
    }
}

// 文本变化回调
let onTextChanged: CStringCallback = { text: CString =>
    if (let Some(label) <- infoLabel) {
        label.setText("输入内容: ${text.toString()}")
    }
}

// 数值变化回调
let onSpinBoxChanged: Int32Callback = { value: Int32 =>
    if (let Some(label) <- spinBoxValueLabel) {
        label.setText("值: ${value}")
    }
}

let onSliderChanged: Int32Callback = { value: Int32 =>
    if (let Some(label) <- sliderValueLabel) {
        label.setText("值: ${value}")
    }
    if (let Some(bar) <- progressBar) {
        bar.setValue(value)
    }
}

// 复选框回调
let onCheckBoxAChanged: Int32Callback = { state: Int32 =>
    if (let Some(label) <- infoLabel) {
        if (state == 2) {
            label.setText("选项 A 已选中")
        } else {
            label.setText("选项 A 未选中")
        }
    }
}

let onCheckBoxBChanged: Int32Callback = { state: Int32 =>
    if (let Some(label) <- infoLabel) {
        if (state == 2) {
            label.setText("选项 B 已选中")
        } else {
            label.setText("选项 B 未选中")
        }
    }
}

let onCheckBoxCChanged: Int32Callback = { state: Int32 =>
    if (let Some(label) <- infoLabel) {
        if (state == 2) {
            label.setText("选项 C 已选中")
        } else {
            label.setText("选项 C 未选中")
        }
    }
}

// 单选按钮回调
let onRadioAChanged: Int32Callback = { checked: Int32 =>
    if (let Some(label) <- infoLabel) {
        if (checked == 1) { label.setText("选择了: 选项 A") }
    }
}

let onRadioBChanged: Int32Callback = { checked: Int32 =>
    if (let Some(label) <- infoLabel) {
        if (checked == 1) { label.setText("选择了: 选项 B") }
    }
}

let onRadioCChanged: Int32Callback = { checked: Int32 =>
    if (let Some(label) <- infoLabel) {
        if (checked == 1) { label.setText("选择了: 选项 C") }
    }
}

// 下拉框回调
let onComboBoxChanged: Int32Callback = { index: Int32 =>
    if (let Some(label) <- infoLabel) {
        label.setText("选择了第 ${index + 1} 项")
    }
}

// 密码可见性切换
let onTogglePassword: VoidCallback = { =>
    passwordVisible = !passwordVisible
    if (let Some(edit) <- passwordEdit) {
        if (passwordVisible) {
            edit.setEchoMode(0)
            edit.setPasswordToggleIcon(true)
        } else {
            edit.setEchoMode(2)
            edit.setPasswordToggleIcon(false)
        }
    }
}

// ============================================================
// 辅助函数
// ============================================================

func separator(text: String): QLabel {
    let label = QLabel()
    label.setText("── ${text} ──")
    label.setAlignment(AlignCenter)
    return label
}

func label(text: String): QLabel {
    let l = QLabel()
    l.setText(text)
    return l
}

// ============================================================
// 主函数
// ============================================================
main(): Int32 {
    let app = QApplication()
    
    let window = QWidget()
    window.setTitle("CJQT6 常用控件示例")
    window.resize(550, 700)
    
    let mainLayout = QVBoxLayout()
    mainLayout.setSpacing(8)
    mainLayout.setMargin(15)
    
    // ========== 标题 ==========
    let titleLabel = QLabel()
    titleLabel.setText("CJQT6 常用控件演示")
    titleLabel.setAlignment(AlignCenter)
    mainLayout.addWidget(titleLabel.getPtr())
    
    let info = QLabel()
    info.setText("操作控件查看效果")
    info.setAlignment(AlignCenter)
    infoLabel = info
    mainLayout.addWidget(info.getPtr())
    
    // ============================================================
    // 按钮区域
    // ============================================================
    mainLayout.addWidget(separator("按钮 Button").getPtr())
    
    // 普通按钮
    let btnRow1 = QHBoxLayout()
    let btn1 = QPushButton()
    btn1.setText("点击我")
    btn1.setOnClick(onButtonClick)
    btnRow1.addWidget(btn1.getPtr())
    
    let btn2 = QPushButton()
    btn2.setText("清空信息")
    btn2.setOnClick(onClearClick)
    btnRow1.addWidget(btn2.getPtr())
    mainLayout.addLayout(btnRow1.getPtr())
    
    // 带图标按钮
    let btnRow2 = QHBoxLayout()
    let iconBtn1 = QPushButton()
    iconBtn1.setStandardIcon(StandardIcon.Open)
    iconBtn1.setText("打开")
    btnRow2.addWidget(iconBtn1.getPtr())
    
    let iconBtn2 = QPushButton()
    iconBtn2.setStandardIcon(StandardIcon.Save)
    iconBtn2.setText("保存")
    btnRow2.addWidget(iconBtn2.getPtr())
    
    let iconBtn3 = QPushButton()
    iconBtn3.setStandardIcon(StandardIcon.Help)
    iconBtn3.setText("帮助")
    btnRow2.addWidget(iconBtn3.getPtr())
    
    let iconBtn4 = QPushButton()
    iconBtn4.setStandardIcon(StandardIcon.Cancel)
    iconBtn4.setText("取消")
    btnRow2.addWidget(iconBtn4.getPtr())
    
    let iconBtn5 = QPushButton()
    iconBtn5.setStandardIcon(StandardIcon.ArrowRight)
    iconBtn5.setText("下一步")
    btnRow2.addWidget(iconBtn5.getPtr())
    mainLayout.addLayout(btnRow2.getPtr())
    
    // ============================================================
    // 输入框区域
    // ============================================================
    mainLayout.addWidget(separator("输入框 LineEdit").getPtr())
    
    // 基本文本输入
    let inputRow1 = QHBoxLayout()
    inputRow1.addWidget(label("文本:").getPtr())
    let textEdit = QLineEdit()
    textEdit.setPlaceholder("请输入内容...")
    textEdit.setOnTextChanged(onTextChanged)
    inputRow1.addWidget(textEdit.getPtr())
    mainLayout.addLayout(inputRow1.getPtr())
    
    // 显示模式
    let inputRow2 = QHBoxLayout()
    inputRow2.addWidget(label("密码:").getPtr())
    let pwdEdit = QLineEdit()
    pwdEdit.setPlaceholder("密码模式")
    pwdEdit.setEchoMode(2)
    pwdEdit.addPasswordToggleAction(onTogglePassword)
    passwordEdit = pwdEdit
    inputRow2.addWidget(pwdEdit.getPtr())
    mainLayout.addLayout(inputRow2.getPtr())
    
    // 输入掩码 - IP
    let inputRow3 = QHBoxLayout()
    inputRow3.addWidget(label("IP:").getPtr())
    let ipEdit = QLineEdit()
    ipEdit.setInputMask(InputMask.IP)
    ipEdit.setPlaceholder("000.000.000.000")
    inputRow3.addWidget(ipEdit.getPtr())
    mainLayout.addLayout(inputRow3.getPtr())
    
    // 输入掩码 - MAC
    let inputRow4 = QHBoxLayout()
    inputRow4.addWidget(label("MAC:").getPtr())
    let macEdit = QLineEdit()
    macEdit.setInputMask(InputMask.MAC)
    macEdit.setPlaceholder("HH:HH:HH:HH:HH:HH")
    inputRow4.addWidget(macEdit.getPtr())
    mainLayout.addLayout(inputRow4.getPtr())
    
    // 输入掩码 - 日期
    let inputRow5 = QHBoxLayout()
    inputRow5.addWidget(label("日期:").getPtr())
    let dateEdit = QLineEdit()
    dateEdit.setInputMask(InputMask.Date)
    dateEdit.setPlaceholder("YYYY-MM-DD")
    inputRow5.addWidget(dateEdit.getPtr())
    mainLayout.addLayout(inputRow5.getPtr())
    
    // 输入掩码 - 密钥
    let inputRow6 = QHBoxLayout()
    inputRow6.addWidget(label("密钥:").getPtr())
    let keyEdit = QLineEdit()
    keyEdit.setInputMask(InputMask.LicenseKey)
    keyEdit.setPlaceholder("XXXXX-XXXXX-...")
    inputRow6.addWidget(keyEdit.getPtr())
    mainLayout.addLayout(inputRow6.getPtr())
    
    // 样式设置
    let inputRow7 = QHBoxLayout()
    inputRow7.addWidget(label("无边框:").getPtr())
    let noFrameEdit = QLineEdit()
    noFrameEdit.setPlaceholder("无边框样式")
    noFrameEdit.setFrame(false)
    noFrameEdit.setStyleSheet("background-color: #f0f0f0; padding: 5px;")
    inputRow7.addWidget(noFrameEdit.getPtr())
    mainLayout.addLayout(inputRow7.getPtr())
    
    let inputRow8 = QHBoxLayout()
    inputRow8.addWidget(label("居中:").getPtr())
    let centerEdit = QLineEdit()
    centerEdit.setPlaceholder("文本居中")
    centerEdit.setAlignment(Alignment.Center)
    inputRow8.addWidget(centerEdit.getPtr())
    mainLayout.addLayout(inputRow8.getPtr())
    
    // ============================================================
    // 数值控件区域
    // ============================================================
    mainLayout.addWidget(separator("数值控件").getPtr())
    
    // 旋转框
    let spinRow = QHBoxLayout()
    spinRow.addWidget(label("数字:").getPtr())
    let spinBox = QSpinBox()
    spinBox.setRange(0, 100)
    spinBox.setValue(50)
    spinBox.setOnValueChanged(onSpinBoxChanged)
    spinRow.addWidget(spinBox.getPtr())
    let spinValLabel = QLabel()
    spinValLabel.setText("值: 50")
    spinBoxValueLabel = spinValLabel
    spinRow.addWidget(spinValLabel.getPtr())
    mainLayout.addLayout(spinRow.getPtr())
    
    // 滑动条
    let sliderRow = QHBoxLayout()
    sliderRow.addWidget(label("滑动:").getPtr())
    let slider = QSlider()
    slider.setOrientation(1)
    slider.setRange(0, 100)
    slider.setValue(0)
    slider.setOnValueChanged(onSliderChanged)
    sliderRow.addWidget(slider.getPtr())
    let sliderValLabel = QLabel()
    sliderValLabel.setText("值: 0")
    sliderValueLabel = sliderValLabel
    sliderRow.addWidget(sliderValLabel.getPtr())
    mainLayout.addLayout(sliderRow.getPtr())
    
    // 进度条
    let progressRow = QHBoxLayout()
    progressRow.addWidget(label("进度:").getPtr())
    let progress = QProgressBar()
    progress.setRange(0, 100)
    progress.setValue(0)
    progress.setTextVisible(true)
    progressBar = progress
    progressRow.addWidget(progress.getPtr())
    mainLayout.addLayout(progressRow.getPtr())
    
    // ============================================================
    // 选择控件区域
    // ============================================================
    mainLayout.addWidget(separator("选择控件").getPtr())
    
    // 复选框
    let checkRow = QHBoxLayout()
    checkRow.addWidget(label("多选:").getPtr())
    let checkBox1 = QCheckBox()
    checkBox1.setText("A")
    checkBox1.setChecked(true)
    checkBox1.setOnStateChanged(onCheckBoxAChanged)
    checkRow.addWidget(checkBox1.getPtr())
    let checkBox2 = QCheckBox()
    checkBox2.setText("B")
    checkBox2.setOnStateChanged(onCheckBoxBChanged)
    checkRow.addWidget(checkBox2.getPtr())
    let checkBox3 = QCheckBox()
    checkBox3.setText("C")
    checkBox3.setOnStateChanged(onCheckBoxCChanged)
    checkRow.addWidget(checkBox3.getPtr())
    mainLayout.addLayout(checkRow.getPtr())
    
    // 单选按钮
    let radioRow = QHBoxLayout()
    radioRow.addWidget(label("单选:").getPtr())
    let radio1 = QRadioButton()
    radio1.setText("A")
    radio1.setChecked(true)
    radio1.setOnToggled(onRadioAChanged)
    radioRow.addWidget(radio1.getPtr())
    let radio2 = QRadioButton()
    radio2.setText("B")
    radio2.setOnToggled(onRadioBChanged)
    radioRow.addWidget(radio2.getPtr())
    let radio3 = QRadioButton()
    radio3.setText("C")
    radio3.setOnToggled(onRadioCChanged)
    radioRow.addWidget(radio3.getPtr())
    mainLayout.addLayout(radioRow.getPtr())
    
    // 下拉框
    let comboRow = QHBoxLayout()
    comboRow.addWidget(label("下拉:").getPtr())
    let comboBox = QComboBox()
    comboBox.addItem("选项一")
    comboBox.addItem("选项二")
    comboBox.addItem("选项三")
    comboBox.addItem("选项四")
    comboBox.addItem("选项五")
    comboBox.setOnCurrentIndexChanged(onComboBoxChanged)
    comboRow.addWidget(comboBox.getPtr())
    mainLayout.addLayout(comboRow.getPtr())
    
    // ============================================================
    // 底部
    // ============================================================
    mainLayout.addStretch()
    
    let noteLabel = QLabel()
    noteLabel.setText("提示: 操作各控件查看信号槽效果")
    noteLabel.setAlignment(AlignCenter)
    mainLayout.addWidget(noteLabel.getPtr())
    
    window.setLayout(mainLayout.getPtr())
    window.show()
    
    let result = app.exec()
    return result
}
