package all_controls_demo

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.dialogs.*
import cjqt6.views.*
import cjqt6.richwidgets.*

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
    frame1.setFrameShape(FrameShape.StyledPanel)
    frame1.setFrameShadow(FrameShadow.Raised)
    frame1.setLineWidth(2)
    let frame1Layout = QVBoxLayout()
    let frame1Label = QLabel()
    frame1Label.setText("凸起面板")
    frame1Label.setAlignment(AlignCenter)
    frame1Layout.addWidget(frame1Label.getPtr())
    frame1.setLayout(frame1Layout.getPtr())
    frameRow.addWidget(frame1.getPtr())

    let frame2 = QFrame()
    frame2.setFrameShape(FrameShape.StyledPanel)
    frame2.setFrameShadow(FrameShadow.Sunken)
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
    frame3.setFrameShadow(FrameShadow.Plain)
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