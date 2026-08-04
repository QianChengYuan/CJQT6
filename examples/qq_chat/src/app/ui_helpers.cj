// ============================================================
// QQ聊天 - UI 辅助工厂函数
// 通用控件创建封装，供各界面模块复用。
// 所有创建函数均返回控件对象本身（非指针），调用方需用 .getPtr() 传给布局。
// ============================================================
package qq_chat.app

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.menu.*
import cjqt6.paint.*

/// 创建文本标签，设置指定文本内容。
public func createLabel(text: String): QLabel {
    let l = QLabel()
    l.setText(text)
    l
}

/// 创建带自定义对齐方式的文本标签。
/// align: 0=居中, 1=左对齐, 2=右对齐
public func createLabelAligned(text: String, align: Int32): QLabel {
    let l = QLabel()
    l.setText(text)
    let alignValue = if (align == 0) {
        Alignment.Center.value
    } else if (align == 2) {
        (Alignment.Right | Alignment.VCenter).value
    } else {
        (Alignment.Left | Alignment.VCenter).value
    }
    l.setAlignment(alignValue)
    l
}

/// 创建按钮（绑定顶层 VoidCallback 回调）。
public func createButton(text: String, onClick: VoidCallback): QPushButton {
    let btn = QPushButton()
    btn.setText(text)
    btn.setOnClick(onClick)
    btn
}

/// 创建带自定义对齐方式的按钮。
/// align: 0=居中, 1=左对齐, 2=右对齐
/// 注：QPushButton 无 setAlignment 方法，通过样式表 text-align 实现
public func createButtonAligned(text: String, onClick: VoidCallback, align: Int32): QPushButton {
    let btn = QPushButton()
    btn.setText(text)
    btn.setOnClick(onClick)
    let alignCss = if (align == 0) {
        "center"
    } else if (align == 2) {
        "right"
    } else {
        "left"
    }
    btn.setStyleSheet("text-align: ${alignCss};")
    btn
}

/// 创建单行输入框，设置占位提示文本，默认左对齐。
public func createLineEdit(placeholder: String): QLineEdit {
    let e = QLineEdit()
    e.setPlaceholder(placeholder)
    // 输入框默认左对齐，光标跟在文本后
    e.setAlignment((Alignment.Left | Alignment.VCenter).value)
    e
}

/// 创建带左侧标签的水平行，返回布局指针。
/// 用于表单式布局（如"密码:" + 输入框）。
public func createLabeledRow(labelText: String, widgetPtr: Int64): Int64 {
    let row = QHBoxLayout()
    let lb = createLabel(labelText)
    row.addWidget(lb.getPtr())
    row.addWidget(widgetPtr)
    row.getPtr()
}

/// 创建蓝色下划线可点击文字链接（用QPushButton模拟，QLabel无点击事件）。
public func createLink(text: String, onClick: VoidCallback): QPushButton {
    let btn = QPushButton()
    btn.setText(text)
    btn.setStyleSheet("color: blue; text-decoration: underline; border: none; background: transparent; padding: 0; margin: 0;")
    btn.setOnClick(onClick)
    btn
}

/// 创建下拉框并添加选项。
public func createComboBox(items: Array<String>): QComboBox {
    let cb = QComboBox()
    for (item in items) {
        cb.addItem(item)
    }
    cb
}

/// 创建复选框并绑定状态变化回调。
public func createCheckBox(text: String, onStateChanged: Int32Callback): QCheckBox {
    let cb = QCheckBox()
    cb.setText(text)
    cb.setOnStateChanged(onStateChanged)
    cb
}

/// 创建图标标签（用于小企鹅/小键盘图标）。
public func createIconLabel(pixmap: QPixmap): QLabel {
    let l = QLabel()
    l.setPixmap(pixmap.getPtr())
    l
}
