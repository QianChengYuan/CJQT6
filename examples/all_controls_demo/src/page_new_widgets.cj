package all_controls_demo

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.dialogs.*
import cjqt6.views.*
import cjqt6.richwidgets.*

// -------- 页面7: 新控件 v1.2.0 --------

func createPageNewWidgets(): QScrollArea {
    let (scrollArea, container, layout) = createPageContainer()
    gNewContainer = container

    let title = QLabel()
    title.setText("新控件演示 (v1.2.0)")
    setLabelStyle(title, "font-size: 18px; font-weight: bold; color: #2c3e50; padding: 8px 0;")
    title.setAlignment(AlignCenter)
    layout.addWidget(title.getPtr())

    // QCommandLinkButton
    layout.addWidget(sectionTitle("QCommandLinkButton").getPtr())
    let cmdRow = QHBoxLayout()
    cmdRow.setSpacing(8)
    let cmd1 = QCommandLinkButton()
    cmd1.setText("新建项目")
    cmd1.setDescription("创建一个全新的 Cangjie Qt6 应用程序")
    cmdRow.addWidget(cmd1.getPtr())
    let cmd2 = QCommandLinkButton()
    cmd2.setText("打开现有项目")
    cmd2.setDescription("从磁盘打开一个已有项目")
    cmdRow.addWidget(cmd2.getPtr())
    layout.addLayout(cmdRow.getPtr())

    // QDialogButtonBox
    layout.addWidget(sectionTitle("QDialogButtonBox").getPtr())
    let dlgInfo = QLabel()
    dlgInfo.setText("点击标准按钮组合中的按钮触发信号:")
    gNewDlgInfo = dlgInfo
    layout.addWidget(dlgInfo.getPtr())

    let dlgRow1 = QHBoxLayout()
    dlgRow1.setSpacing(8)
    let box1 = QDialogButtonBox()
    box1.setStandardButtons(makeStandardButtons([StandardButtons.Ok, StandardButtons.Cancel]))
    box1.setOnAccepted({ => if (let Some(l) <- gNewDlgInfo) { l.setText("结果: 接受 (OK)") } })
    box1.setOnRejected({ => if (let Some(l) <- gNewDlgInfo) { l.setText("结果: 拒绝 (Cancel)") } })
    dlgRow1.addWidget(box1.getPtr())
    let box2 = QDialogButtonBox()
    box2.setStandardButtons(makeStandardButtons([StandardButtons.Yes, StandardButtons.No]))
    box2.setOnAccepted({ => if (let Some(l) <- gNewDlgInfo) { l.setText("结果: 是 (Yes)") } })
    box2.setOnRejected({ => if (let Some(l) <- gNewDlgInfo) { l.setText("结果: 否 (No)") } })
    dlgRow1.addWidget(box2.getPtr())
    layout.addLayout(dlgRow1.getPtr())

    let dlgRow2 = QHBoxLayout()
    dlgRow2.setSpacing(8)
    let box3 = QDialogButtonBox()
    box3.setStandardButtons(makeStandardButtons([StandardButtons.Save, StandardButtons.Cancel, StandardButtons.Help]))
    dlgRow2.addWidget(box3.getPtr())
    layout.addLayout(dlgRow2.getPtr())

    // QScrollBar
    layout.addWidget(sectionTitle("QScrollBar").getPtr())
    let scrollVal = QLabel()
    scrollVal.setText("当前值: 0")
    gNewScrollVal = scrollVal
    layout.addWidget(scrollVal.getPtr())
    let hScroll = QScrollBar(ScrollBarOrientation.Horizontal)
    hScroll.setRange(0, 100)
    hScroll.setValue(0)
    hScroll.setSingleStep(5)
    hScroll.setPageStep(20)
    hScroll.setOnValueChanged({ v: Int32 =>
        if (let Some(l) <- gNewScrollVal) { l.setText("当前值: ${v}") }
    })
    layout.addWidget(hScroll.getPtr())
    let vScroll = QScrollBar(ScrollBarOrientation.Vertical)
    vScroll.setRange(0, 100)
    vScroll.setValue(50)
    vScroll.resize(0, 100)
    layout.addWidget(vScroll.getPtr())

    // 输入验证器
    layout.addWidget(sectionTitle("输入验证器 (QIntValidator / QDoubleValidator)").getPtr())
    let intRow = QHBoxLayout()
    intRow.setSpacing(8)
    intRow.addWidget(infoLabel("整数 0-100:").getPtr())
    let intEdit = QLineEdit()
    intEdit.setPlaceholder("只能输入 0~100 的整数")
    let intValidator = QIntValidator(0, 100)
    setLineEditValidator(intEdit, intValidator)
    intRow.addWidget(intEdit.getPtr())
    layout.addLayout(intRow.getPtr())

    let dblRow = QHBoxLayout()
    dblRow.setSpacing(8)
    dblRow.addWidget(infoLabel("小数 0-1:").getPtr())
    let dblEdit = QLineEdit()
    dblEdit.setPlaceholder("只能输入 0.00~1.00")
    let dblValidator = QDoubleValidator(0.0, 1.0, 2)
    setLineEditValidator(dblEdit, dblValidator)
    dblRow.addWidget(dblEdit.getPtr())
    layout.addLayout(dblRow.getPtr())

    // QSplashScreen
    layout.addWidget(sectionTitle("QSplashScreen").getPtr())
    let splashBtn = QPushButton()
    splashBtn.setText("显示启动画面 (2秒)")
    splashBtn.setOnClick(onShowSplash)
    layout.addWidget(splashBtn.getPtr())

    // QSizeGrip
    layout.addWidget(sectionTitle("QSizeGrip").getPtr())
    let gripBox = QWidget()
    gripBox.setStyleSheet("QWidget { border: 1px solid #bdc3c7; border-radius: 4px; padding: 6px; }")
    let gripLayout = QVBoxLayout()
    let gripLabel = QLabel()
    gripLabel.setText("该区域右下角有一个可拖拽的大小手柄 ↓")
    gripLabel.setAlignment(AlignCenter)
    gripLayout.addWidget(gripLabel.getPtr())
    let grip = QSizeGrip(gripBox)
    grip.setVisible(true)
    gripLayout.addWidget(grip.getPtr())
    gripBox.setLayout(gripLayout.getPtr())
    layout.addWidget(gripBox.getPtr())

    // QRubberBand
    layout.addWidget(sectionTitle("QRubberBand").getPtr())
    let rbBtnRow = QHBoxLayout()
    rbBtnRow.setSpacing(8)
    let rbShow = QPushButton()
    rbShow.setText("显示选择框")
    rbShow.setOnClick(onRubberShow)
    rbBtnRow.addWidget(rbShow.getPtr())
    let rbHide = QPushButton()
    rbHide.setText("隐藏选择框")
    rbHide.setOnClick(onRubberHide)
    rbBtnRow.addWidget(rbHide.getPtr())
    layout.addLayout(rbBtnRow.getPtr())

    // Model/View: QListView
    layout.addWidget(sectionTitle("Model/View: QListView + QStandardItemModel").getPtr())
    let listModel = QStandardItemModel()
    listModel.setColumnCount(1)
    let listItems = ["苹果", "香蕉", "樱桃", "葡萄", "西瓜", "芒果"]
    for (i in 0..listItems.size) {
        listModel.setItem(Int32(i), 0, listItems[i])
    }
    let listView = QListView()
    listView.setModel(listModel)
    listView.setSelectionMode(SelectionMode.Single)
    listView.resize(0, 100)
    layout.addWidget(listView.getPtr())

    // Model/View: QTableView
    layout.addWidget(sectionTitle("Model/View: QTableView + QStandardItemModel").getPtr())
    let tableModel = QStandardItemModel()
    tableModel.setColumnCount(4)
    tableModel.setHorizontalHeaderLabel(0, "姓名")
    tableModel.setHorizontalHeaderLabel(1, "年龄")
    tableModel.setHorizontalHeaderLabel(2, "城市")
    tableModel.setHorizontalHeaderLabel(3, "职业")
    let tdata = [
        ["张三", "28", "北京", "工程师"],
        ["李四", "32", "上海", "设计师"],
        ["王五", "25", "广州", "产品经理"]
    ]
    for (r in 0..tdata.size) {
        for (c in 0..4) {
            tableModel.setItem(Int32(r), Int32(c), tdata[r][c])
        }
    }
    let tableView = QTableView()
    tableView.setModel(tableModel)
    tableView.setShowGrid(true)
    tableView.setSelectionBehavior(SelectionBehavior.SelectRows)
    tableView.setSelectionMode(SelectionMode.Single)
    tableView.resizeColumnsToContents()
    tableView.resize(0, 110)
    layout.addWidget(tableView.getPtr())

    // Model/View: QTreeView
    layout.addWidget(sectionTitle("Model/View: QTreeView + QStandardItemModel").getPtr())
    let treeModel = QStandardItemModel()
    treeModel.setColumnCount(2)
    treeModel.setHorizontalHeaderLabel(0, "项目")
    treeModel.setHorizontalHeaderLabel(1, "说明")
    treeModel.setItem(0, 0, "水果")
    treeModel.setItem(0, 1, "生鲜")
    treeModel.setItem(1, 0, "蔬菜")
    treeModel.setItem(1, 1, "生鲜")
    treeModel.setItem(2, 0, "工具")
    treeModel.setItem(2, 1, "杂项")
    let treeView = QTreeView()
    treeView.setModel(treeModel)
    treeView.resize(0, 110)
    layout.addWidget(treeView.getPtr())

    // QFileSystemModel
    layout.addWidget(sectionTitle("Model/View: QFileSystemModel").getPtr())
    let fsModel = QFileSystemModel()
    // 注意：setRootPath 会启动后台线程扫描文件系统。
    // 设置为 "."（当前目录）而非 "C:/"，避免扫描整个 C 盘导致 UI 卡死。
    fsModel.setRootPath(".")
    gNewFsModel = fsModel
    let fsInfo = QLabel()
    fsInfo.setText("文件系统模型根路径: ${fsModel.rootPath()}")
    setLabelStyle(fsInfo, "color: #7f8c8d; font-size: 12px;")
    layout.addWidget(fsInfo.getPtr())
    let fsBtn = QPushButton()
    fsBtn.setText("获取当前目录路径索引 (验证 API)")
    fsBtn.setOnClick({ =>
        if (let Some(m) <- gNewFsModel) {
            let idx = m.index(".")
            if (let Some(status) <- gStatusLabel) {
                status.setText("QFileSystemModel index 获取成功 (ptr=${idx})")
            }
        }
    })
    layout.addWidget(fsBtn.getPtr())

    // QHeaderView
    layout.addWidget(sectionTitle("QHeaderView").getPtr())
    let header = QHeaderView(1 /* Orientation.Horizontal */)
    header.setSectionResizeMode(ResizeMode.Stretch)
    header.setStretchLastSection(true)
    let headerInfo = QLabel()
    headerInfo.setText("已创建 QHeaderView(Horizontal) 并配置 ResizeMode.Stretch")
    setLabelStyle(headerInfo, "color: #7f8c8d; font-size: 12px;")
    layout.addWidget(headerInfo.getPtr())

    layout.addStretch()
    scrollArea
}