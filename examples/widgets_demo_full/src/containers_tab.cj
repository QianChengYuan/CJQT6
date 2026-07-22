package widgets_demo_full

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

func createContainersTab(): QWidget {
    let tab = QWidget()
    let layout = QVBoxLayout()
    layout.setSpacing(8)
    layout.setMargin(12)

    // GroupBox
    let gb = QGroupBox()
    gb.setTitle("GroupBox - Checkable")
    gb.setCheckable(true)
    gb.setChecked(true)
    let gbLayout = QVBoxLayout()
    let gbLabel = QLabel()
    gbLabel.setText("Content inside GroupBox")
    gbLayout.addWidget(gbLabel.getPtr())
    gb.setLayout(gbLayout.getPtr())
    layout.addWidget(gb.getPtr())

    // Frame
    let frame = QFrame()
    frame.setFrameShape(1)
    frame.setFrameShadow(Sunken)
    frame.setStyleSheet("QFrame { background: #f5f5f5; }")
    let frameLayout = QVBoxLayout()
    let frameLabel = QLabel()
    frameLabel.setText("QFrame with Box + Sunken style")
    frameLayout.addWidget(frameLabel.getPtr())
    frame.setLayout(frameLayout.getPtr())
    layout.addWidget(frame.getPtr())

    // Splitter
    let splitSec = QLabel()
    splitSec.setText("-- QSplitter --")
    layout.addWidget(splitSec.getPtr())
    let splitter = QSplitter(0)
    splitter.setOrientation(SplitterOrientation.Horizontal)
    let splitL = QLabel()
    splitL.setText("Left Panel")
    splitL.setStyleSheet("background: #e3f2fd; padding: 10px;")
    let splitR = QLabel()
    splitR.setText("Right Panel")
    splitR.setStyleSheet("background: #fff3e0; padding: 10px;")
    splitter.addWidget(splitL.getPtr())
    splitter.addWidget(splitR.getPtr())
    layout.addWidget(splitter.getPtr())

    // StackedWidget
    let stackSec = QLabel()
    stackSec.setText("-- QStackedWidget --")
    layout.addWidget(stackSec.getPtr())
    let stack = QStackedWidget()
    let sp1 = QLabel()
    sp1.setText("Page 1 - First")
    sp1.setStyleSheet("background: #e8f5e9; padding: 20px;")
    let sp2 = QLabel()
    sp2.setText("Page 2 - Second")
    sp2.setStyleSheet("background: #fce4ec; padding: 20px;")
    let sp3 = QLabel()
    sp3.setText("Page 3 - Third")
    sp3.setStyleSheet("background: #e1f5fe; padding: 20px;")
    stack.addWidget(sp1.getPtr())
    stack.addWidget(sp2.getPtr())
    stack.addWidget(sp3.getPtr())
    layout.addWidget(stack.getPtr())

    let stackBtns = QHBoxLayout()
    let btnPrev = QPushButton()
    btnPrev.setText("< Prev")
    let btnNext = QPushButton()
    btnNext.setText("Next >")
    // Stack paging requires capturing stack variable - not supported in CFunc lambda
    // Stack paging requires capturing stack variable - not supported in CFunc lambda
    stackBtns.addWidget(btnPrev.getPtr())
    stackBtns.addWidget(btnNext.getPtr())
    layout.addLayout(stackBtns.getPtr())

    // ToolBox
    let tbSec = QLabel()
    tbSec.setText("-- QToolBox --")
    layout.addWidget(tbSec.getPtr())
    let toolbox = QToolBox()
    let tb1 = QLabel()
    tb1.setText("Tools Page 1")
    toolbox.addItem(tb1.getPtr(), "Tools 1")
    let tb2 = QLabel()
    tb2.setText("Tools Page 2")
    toolbox.addItem(tb2.getPtr(), "Tools 2")
    layout.addWidget(toolbox.getPtr())

    layout.addStretch()
    tab.setLayout(layout.getPtr())
    return tab
}