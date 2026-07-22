package widgets_demo_full

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

var g_newInfo: ?QLabel = None
var g_dlgBtnBoxInfo: ?QLabel = None
var g_scrollBarVal: ?QLabel = None

func createNewWidgetsTab(): QWidget {
    let tab = QWidget()
    let layout = QVBoxLayout()
    layout.setSpacing(8)
    layout.setMargin(12)

    let info = QLabel()
    info.setText("New convenience widgets added to CJQT6")
    g_newInfo = info
    layout.addWidget(info.getPtr())

    // ---- QDialogButtonBox ----
    let secDlg = QLabel()
    secDlg.setText("-- QDialogButtonBox (Dialog Button Box) --")
    secDlg.setStyleSheet("font-weight: bold; color: #34a853;")
    layout.addWidget(secDlg.getPtr())

    let dlgInfo = QLabel()
    dlgInfo.setText("Click buttons below:")
    g_dlgBtnBoxInfo = dlgInfo
    layout.addWidget(dlgInfo.getPtr())

    let dlgRow1 = QHBoxLayout()
    let btnBox1 = QDialogButtonBox()
    btnBox1.setStandardButtons(makeStandardButtons([StandardButtons.Ok, StandardButtons.Cancel]))
    btnBox1.setOnAccepted({ => if (let Some(l) <- g_dlgBtnBoxInfo) { l.setText("Accepted (OK clicked)") }})
    btnBox1.setOnRejected({ => if (let Some(l) <- g_dlgBtnBoxInfo) { l.setText("Rejected (Cancel clicked)") }})
    dlgRow1.addWidget(btnBox1.getPtr())
    layout.addLayout(dlgRow1.getPtr())

    let dlgRow2 = QHBoxLayout()
    let btnBox2 = QDialogButtonBox()
    btnBox2.setStandardButtons(makeStandardButtons([StandardButtons.Yes, StandardButtons.No]))
    btnBox2.setOnAccepted({ => if (let Some(l) <- g_dlgBtnBoxInfo) { l.setText("Yes clicked") }})
    btnBox2.setOnRejected({ => if (let Some(l) <- g_dlgBtnBoxInfo) { l.setText("No clicked") }})
    dlgRow2.addWidget(btnBox2.getPtr())

    let btnBox3 = QDialogButtonBox()
    btnBox3.setStandardButtons(makeStandardButtons([StandardButtons.Save, StandardButtons.Cancel, StandardButtons.Help]))
    dlgRow2.addWidget(btnBox3.getPtr())
    layout.addLayout(dlgRow2.getPtr())

    // ---- QCommandLinkButton ----
    let secCmd = QLabel()
    secCmd.setText("-- QCommandLinkButton (Command Link) --")
    secCmd.setStyleSheet("font-weight: bold; color: #34a853;")
    layout.addWidget(secCmd.getPtr())

    let cmdRow = QHBoxLayout()
    let cmdBtn1 = QCommandLinkButton()
    cmdBtn1.setText("Create New Project")
    cmdBtn1.setDescription("Start a new Cangjie Qt6 application")
    cmdRow.addWidget(cmdBtn1.getPtr())

    let cmdBtn2 = QCommandLinkButton()
    cmdBtn2.setText("Open Existing")
    cmdBtn2.setDescription("Open an existing project from disk")
    cmdRow.addWidget(cmdBtn2.getPtr())
    layout.addLayout(cmdRow.getPtr())

    // ---- QScrollBar ----
    let secScroll = QLabel()
    secScroll.setText("-- QScrollBar (Standalone ScrollBar) --")
    secScroll.setStyleSheet("font-weight: bold; color: #34a853;")
    layout.addWidget(secScroll.getPtr())

    let scrollVal = QLabel()
    scrollVal.setText("Value: 0")
    g_scrollBarVal = scrollVal
    layout.addWidget(scrollVal.getPtr())

    let hScroll = QScrollBar(ScrollBarOrientation.Horizontal)
    hScroll.setRange(0, 100)
    hScroll.setValue(0)
    hScroll.setSingleStep(5)
    hScroll.setPageStep(20)
    hScroll.setOnValueChanged({ v: Int32 =>
        if (let Some(l) <- g_scrollBarVal) { l.setText("Value: " + v.toString()) }
    })
    layout.addWidget(hScroll.getPtr())

    let vScroll = QScrollBar(ScrollBarOrientation.Vertical)
    vScroll.setRange(0, 100)
    vScroll.setValue(50)
    layout.addWidget(vScroll.getPtr())

    // ---- QProgressBar ----
    let secProg = QLabel()
    secProg.setText("-- QProgressBar --")
    secProg.setStyleSheet("font-weight: bold; color: #34a853;")
    layout.addWidget(secProg.getPtr())
    let progBar = QProgressBar()
    progBar.setRange(0, 100)
    progBar.setValue(65)
    progBar.setTextVisible(true)
    layout.addWidget(progBar.getPtr())

    // ---- QLCDNumber ----
    let secLCD = QLabel()
    secLCD.setText("-- QLCDNumber --")
    secLCD.setStyleSheet("font-weight: bold; color: #34a853;")
    layout.addWidget(secLCD.getPtr())
    let lcd = QLCDNumber()
    lcd.setDigitCount(6)
    lcd.displayInt(12345)
    layout.addWidget(lcd.getPtr())

    // ---- QKeySequenceEdit ----
    let secKey = QLabel()
    secKey.setText("-- QKeySequenceEdit (Keyboard Shortcut) --")
    secKey.setStyleSheet("font-weight: bold; color: #34a853;")
    layout.addWidget(secKey.getPtr())
    let keyEdit = QKeySequenceEdit()
    layout.addWidget(keyEdit.getPtr())

    layout.addStretch()
    tab.setLayout(layout.getPtr())
    return tab
}