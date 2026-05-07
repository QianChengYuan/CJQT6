package calculator

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import std.convert.*

// ============================================================
// 计算器状态
// ============================================================

// 全局显示屏引用
var display: ?QLineEdit = None

// 计算器状态变量
var currentValue: String = "0"      // 当前显示值
var storedValue: String = ""        // 存储的值（用于计算）
var currentOp: String = ""          // 当前运算符
var waitingForOperand: Bool = true  // 是否等待新的操作数

// ============================================================
// 数字按钮回调 - 每个数字一个独立回调
// ============================================================

let onDigit0: VoidCallback = { =>
    if (waitingForOperand) {
        currentValue = "0"
        waitingForOperand = false
    } else {
        if (currentValue != "0") {
            currentValue = currentValue + "0"
        }
    }
    updateDisplay()
}

let onDigit1: VoidCallback = { =>
    if (waitingForOperand) {
        currentValue = "1"
        waitingForOperand = false
    } else {
        if (currentValue == "0") {
            currentValue = "1"
        } else {
            currentValue = currentValue + "1"
        }
    }
    updateDisplay()
}

let onDigit2: VoidCallback = { =>
    if (waitingForOperand) {
        currentValue = "2"
        waitingForOperand = false
    } else {
        if (currentValue == "0") {
            currentValue = "2"
        } else {
            currentValue = currentValue + "2"
        }
    }
    updateDisplay()
}

let onDigit3: VoidCallback = { =>
    if (waitingForOperand) {
        currentValue = "3"
        waitingForOperand = false
    } else {
        if (currentValue == "0") {
            currentValue = "3"
        } else {
            currentValue = currentValue + "3"
        }
    }
    updateDisplay()
}

let onDigit4: VoidCallback = { =>
    if (waitingForOperand) {
        currentValue = "4"
        waitingForOperand = false
    } else {
        if (currentValue == "0") {
            currentValue = "4"
        } else {
            currentValue = currentValue + "4"
        }
    }
    updateDisplay()
}

let onDigit5: VoidCallback = { =>
    if (waitingForOperand) {
        currentValue = "5"
        waitingForOperand = false
    } else {
        if (currentValue == "0") {
            currentValue = "5"
        } else {
            currentValue = currentValue + "5"
        }
    }
    updateDisplay()
}

let onDigit6: VoidCallback = { =>
    if (waitingForOperand) {
        currentValue = "6"
        waitingForOperand = false
    } else {
        if (currentValue == "0") {
            currentValue = "6"
        } else {
            currentValue = currentValue + "6"
        }
    }
    updateDisplay()
}

let onDigit7: VoidCallback = { =>
    if (waitingForOperand) {
        currentValue = "7"
        waitingForOperand = false
    } else {
        if (currentValue == "0") {
            currentValue = "7"
        } else {
            currentValue = currentValue + "7"
        }
    }
    updateDisplay()
}

let onDigit8: VoidCallback = { =>
    if (waitingForOperand) {
        currentValue = "8"
        waitingForOperand = false
    } else {
        if (currentValue == "0") {
            currentValue = "8"
        } else {
            currentValue = currentValue + "8"
        }
    }
    updateDisplay()
}

let onDigit9: VoidCallback = { =>
    if (waitingForOperand) {
        currentValue = "9"
        waitingForOperand = false
    } else {
        if (currentValue == "0") {
            currentValue = "9"
        } else {
            currentValue = currentValue + "9"
        }
    }
    updateDisplay()
}

// 小数点回调
let onDecimalClick: VoidCallback = { =>
    if (waitingForOperand) {
        currentValue = "0."
        waitingForOperand = false
    } else {
        if (!currentValue.contains(".")) {
            currentValue = currentValue + "."
        }
    }
    updateDisplay()
}

// ============================================================
// 运算符回调 - 每个运算符一个独立回调
// ============================================================

let onAddClick: VoidCallback = { =>
    if (!storedValue.isEmpty() && !currentOp.isEmpty() && !waitingForOperand) {
        calculate()
    }
    storedValue = currentValue
    currentOp = "+"
    waitingForOperand = true
}

let onSubClick: VoidCallback = { =>
    if (!storedValue.isEmpty() && !currentOp.isEmpty() && !waitingForOperand) {
        calculate()
    }
    storedValue = currentValue
    currentOp = "-"
    waitingForOperand = true
}

let onMulClick: VoidCallback = { =>
    if (!storedValue.isEmpty() && !currentOp.isEmpty() && !waitingForOperand) {
        calculate()
    }
    storedValue = currentValue
    currentOp = "*"
    waitingForOperand = true
}

let onDivClick: VoidCallback = { =>
    if (!storedValue.isEmpty() && !currentOp.isEmpty() && !waitingForOperand) {
        calculate()
    }
    storedValue = currentValue
    currentOp = "/"
    waitingForOperand = true
}

// 等号回调
let onEqualClick: VoidCallback = { =>
    if (!storedValue.isEmpty() && !currentOp.isEmpty()) {
        calculate()
        storedValue = ""
        currentOp = ""
        waitingForOperand = true
    }
}

// 清除回调
let onClearClick: VoidCallback = { =>
    currentValue = "0"
    storedValue = ""
    currentOp = ""
    waitingForOperand = true
    updateDisplay()
}

// 退格回调
let onBackspaceClick: VoidCallback = { =>
    if (!waitingForOperand) {
        if (currentValue.size > 1) {
            currentValue = currentValue[0..currentValue.size - 1]
        } else {
            currentValue = "0"
            waitingForOperand = true
        }
        updateDisplay()
    }
}

// 正负号切换
let onSignClick: VoidCallback = { =>
    if (currentValue != "0") {
        if (currentValue.startsWith("-")) {
            currentValue = currentValue[1..]
        } else {
            currentValue = "-" + currentValue
        }
        updateDisplay()
    }
}

// 百分比
let onPercentClick: VoidCallback = { =>
    if (let Some(v) <- Float64.tryParse(currentValue)) {
        let result = v / 100.0
        currentValue = formatResult(result)
        updateDisplay()
    }
}

// ============================================================
// 辅助函数
// ============================================================

func updateDisplay(): Unit {
    if (let Some(d) <- display) {
        d.setText(currentValue)
    }
}

func calculate(): Unit {
    if (let Some(a) <- Float64.tryParse(storedValue)) {
        if (let Some(b) <- Float64.tryParse(currentValue)) {
            var result: Float64 = 0.0
            if (currentOp == "+") {
                result = a + b
            } else if (currentOp == "-") {
                result = a - b
            } else if (currentOp == "*") {
                result = a * b
            } else if (currentOp == "/") {
                if (b != 0.0) {
                    result = a / b
                } else {
                    currentValue = "Error"
                    updateDisplay()
                    return
                }
            }
            currentValue = formatResult(result)
            updateDisplay()
        }
    }
}

func formatResult(v: Float64): String {
    // 如果是整数，不显示小数点
    if (v == Float64(Int64(v))) {
        return "${Int64(v)}"
    }
    // 否则显示最多8位小数
    var s = "${v}"
    if (s.size > 12) {
        s = s[0..12]
    }
    s
}

// 创建按钮的辅助函数
func createButton(text: String, onClick: VoidCallback, style: String): QPushButton {
    let btn = QPushButton()
    btn.setText(text)
    btn.setOnClick(onClick)
    btn.setStyleSheet(style + " min-width: 50px; min-height: 50px;")
    return btn
}

func digitButton(text: String, callback: VoidCallback): QPushButton {
    createButton(text, callback, "font-size: 20px;")
}

func opButton(text: String, callback: VoidCallback): QPushButton {
    createButton(text, callback, "font-size: 20px; background-color: #f0a000; color: white;")
}

func funcButton(text: String, callback: VoidCallback): QPushButton {
    createButton(text, callback, "font-size: 18px; background-color: #a0a0a0; color: white;")
}

// ============================================================
// 主函数
// ============================================================
main(): Int32 {
    let app = QApplication()
    
    let window = QWidget()
    window.setTitle("计算器")
    window.resize(300, 420)
    
    let mainLayout = QVBoxLayout()
    mainLayout.setSpacing(8)
    mainLayout.setMargin(10)
    
    // ========== 显示屏 ==========
    let displayEdit = QLineEdit()
    displayEdit.setText("0")
    displayEdit.setAlignment(Alignment.Right)
    displayEdit.setReadOnly(true)
    displayEdit.setStyleSheet("font-size: 28px; padding: 10px; background-color: #f5f5f5; min-height: 40px;")
    display = displayEdit
    mainLayout.addWidget(displayEdit.getPtr())
    
    // ========== 按钮网格 ==========
    let gridLayout = QGridLayout()
    gridLayout.setSpacing(8)
    
    // 第一行: C, ←, %, ÷
    gridLayout.addWidget(funcButton("C", onClearClick).getPtr(), 0, 0)
    gridLayout.addWidget(funcButton("←", onBackspaceClick).getPtr(), 0, 1)
    gridLayout.addWidget(funcButton("%", onPercentClick).getPtr(), 0, 2)
    gridLayout.addWidget(opButton("÷", onDivClick).getPtr(), 0, 3)
    
    // 第二行: 7, 8, 9, ×
    gridLayout.addWidget(digitButton("7", onDigit7).getPtr(), 1, 0)
    gridLayout.addWidget(digitButton("8", onDigit8).getPtr(), 1, 1)
    gridLayout.addWidget(digitButton("9", onDigit9).getPtr(), 1, 2)
    gridLayout.addWidget(opButton("×", onMulClick).getPtr(), 1, 3)
    
    // 第三行: 4, 5, 6, -
    gridLayout.addWidget(digitButton("4", onDigit4).getPtr(), 2, 0)
    gridLayout.addWidget(digitButton("5", onDigit5).getPtr(), 2, 1)
    gridLayout.addWidget(digitButton("6", onDigit6).getPtr(), 2, 2)
    gridLayout.addWidget(opButton("-", onSubClick).getPtr(), 2, 3)
    
    // 第四行: 1, 2, 3, +
    gridLayout.addWidget(digitButton("1", onDigit1).getPtr(), 3, 0)
    gridLayout.addWidget(digitButton("2", onDigit2).getPtr(), 3, 1)
    gridLayout.addWidget(digitButton("3", onDigit3).getPtr(), 3, 2)
    gridLayout.addWidget(opButton("+", onAddClick).getPtr(), 3, 3)
    
    // 第五行: ±, 0, ., =
    gridLayout.addWidget(digitButton("±", onSignClick).getPtr(), 4, 0)
    gridLayout.addWidget(digitButton("0", onDigit0).getPtr(), 4, 1)
    gridLayout.addWidget(digitButton(".", onDecimalClick).getPtr(), 4, 2)
    gridLayout.addWidget(opButton("=", onEqualClick).getPtr(), 4, 3)
    
    mainLayout.addLayout(gridLayout.getPtr())
    
    // 设置布局并显示
    window.setLayout(mainLayout.getPtr())
    window.show()
    
    let result = app.exec()
    return result
}