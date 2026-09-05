package all_controls_demo

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.dialogs.*
import cjqt6.views.*
import cjqt6.richwidgets.*

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