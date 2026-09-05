package all_controls_demo

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.dialogs.*
import cjqt6.views.*
import cjqt6.richwidgets.*

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