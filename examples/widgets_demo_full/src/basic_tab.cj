package widgets_demo_full

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

var g_basicInfo: ?QLabel = None
var g_basicLineEdit: ?QLineEdit = None

func createBasicTab(): QWidget {
    let tab = QWidget()
    let layout = QVBoxLayout()
    layout.setSpacing(8)
    layout.setMargin(12)

    // Info display
    let info = QLabel()
    info.setText("Interact with controls to see effects")
    g_basicInfo = info
    layout.addWidget(info.getPtr())

    // ---- Labels ----
    let secLabels = QLabel()
    secLabels.setText("-- Labels --")
    secLabels.setStyleSheet("font-weight: bold; color: #1a73e8;")
    layout.addWidget(secLabels.getPtr())

    let lblNormal = QLabel()
    lblNormal.setText("Normal Label")
    layout.addWidget(lblNormal.getPtr())

    let lblStyled = QLabel()
    lblStyled.setText("Styled Label (blue, bold)")
    lblStyled.setStyleSheet("color: blue; font-weight: bold; font-size: 14px;")
    layout.addWidget(lblStyled.getPtr())

    let lblWrapped = QLabel()
    lblWrapped.setText("This is a word-wrapped label that should span multiple lines if the text is long enough to exceed the available width of the widget.")
    lblWrapped.setWordWrap(true)
    layout.addWidget(lblWrapped.getPtr())

    // ---- Buttons ----
    let secBtns = QLabel()
    secBtns.setText("-- Push Buttons --")
    secBtns.setStyleSheet("font-weight: bold; color: #1a73e8;")
    layout.addWidget(secBtns.getPtr())

    let btnRow1 = QHBoxLayout()
    let btnNormal = QPushButton()
    btnNormal.setText("Click Me")
    btnNormal.setOnClick({ => if (let Some(l) <- g_basicInfo) { l.setText("Normal button clicked!") }})
    btnRow1.addWidget(btnNormal.getPtr())


    let btnDisabled = QPushButton()
    btnDisabled.setText("Disabled")
    btnDisabled.setEnabled(false)
    btnRow1.addWidget(btnDisabled.getPtr())
    layout.addLayout(btnRow1.getPtr())

    let btnRow2 = QHBoxLayout()
    let btnOpen = QPushButton()
    btnOpen.setStandardIcon(StandardIcon.Open)
    btnOpen.setText("Open")
    btnRow2.addWidget(btnOpen.getPtr())
    let btnSave = QPushButton()
    btnSave.setStandardIcon(StandardIcon.Save)
    btnSave.setText("Save")
    btnRow2.addWidget(btnSave.getPtr())
    let btnDelete = QPushButton()
    btnDelete.setStandardIcon(StandardIcon.Cancel)
    btnDelete.setText("Cancel")
    btnRow2.addWidget(btnDelete.getPtr())
    layout.addLayout(btnRow2.getPtr())

    // Tool button
    let toolBtn = QToolButton()
    toolBtn.setText("Tool")
    toolBtn.setPopupMode(ToolButtonMenuButtonPopup)
    layout.addWidget(toolBtn.getPtr())

    // ---- Line Edit ----
    let secInput = QLabel()
    secInput.setText("-- Line Edit --")
    secInput.setStyleSheet("font-weight: bold; color: #1a73e8;")
    layout.addWidget(secInput.getPtr())

    let le1 = QLineEdit()
    le1.setPlaceholder("Type something...")
    le1.setOnTextChanged({ text: CString =>
        if (let Some(l) <- g_basicInfo) { l.setText("Text: " + text.toString()) }
    })
    g_basicLineEdit = le1
    layout.addWidget(le1.getPtr())

    let leRow = QHBoxLayout()
    let lePass = QLineEdit()
    lePass.setPlaceholder("Password mode")
    lePass.setEchoMode(2)
    leRow.addWidget(lePass.getPtr())
    let leRO = QLineEdit()
    leRO.setText("Read only")
    leRO.setReadOnly(true)
    leRow.addWidget(leRO.getPtr())
    layout.addLayout(leRow.getPtr())

    // ---- Text Edit (multi-line) ----
    let secText = QLabel()
    secText.setText("-- Text Edit --")
    secText.setStyleSheet("font-weight: bold; color: #1a73e8;")
    layout.addWidget(secText.getPtr())

    let textEdit = QTextEdit()
    textEdit.setText("Multi-line text editor.\nYou can type multiple lines here.")
    textEdit.resize(-1, 80)
    layout.addWidget(textEdit.getPtr())

    let plainEdit = QPlainTextEdit()
    plainEdit.setPlainText("Plain text editor.\nNo rich text formatting.")
    plainEdit.resize(-1, 60)
    layout.addWidget(plainEdit.getPtr())

    layout.addStretch()
    tab.setLayout(layout.getPtr())
    return tab
}