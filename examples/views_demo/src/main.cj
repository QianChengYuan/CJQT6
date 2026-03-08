package views_demo

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.views.*
import CJQT6.gui.*
import CJQT6.dialogs.*

// 全局变量
var g_listWidget: Option<QListWidget> = None
var g_treeWidget: Option<QTreeWidget> = None

// 列表操作函数
func onAddItem(_: Int64): Unit {
    let text = QInputDialog.getText(0, "添加项", "请输入项名称:", "")
    if (text.size > 0) {
        if (let Some(list) <- g_listWidget) {
            list.addItem(text)
        }
    }
}

func onRemoveItem(_: Int64): Unit {
    if (let Some(list) <- g_listWidget) {
        let row = list.currentRow()
        if (row >= 0) {
            list.removeItem(row)
        }
    }
}

func onCountItems(_: Int64): Unit {
    if (let Some(list) <- g_listWidget) {
        let count = list.count()
        QMessageBox.information(0, "统计", "列表共有 ${count} 项")
    }
}

// 树形操作函数
func onExpandAll(_: Int64): Unit {
    if (let Some(tree) <- g_treeWidget) {
        tree.expandAll()
    }
}

func onCollapseAll(_: Int64): Unit {
    if (let Some(tree) <- g_treeWidget) {
        tree.collapseAll()
    }
}

func onShowItemInfo(_: Int64): Unit {
    if (let Some(tree) <- g_treeWidget) {
        if (let Some(item) <- tree.currentItem()) {
            let name = item.text(0)
            let kind = item.text(1)
            QMessageBox.information(0, "选中项信息", "名称: ${name}\n类型: ${kind}")
        } else {
            QMessageBox.warning(0, "提示", "请先选中一项")
        }
    }
}

main(): Int32 {
    // 创建应用
    let app = QApplication()
    
    // 创建主窗口
    let window = QWidget()
    window.resize(900, 600)
    
    // 创建主布局
    let mainLayout = QHBoxLayout()
    
    // ========== 左侧：QListWidget 示例 ==========
    let leftGroup = QGroupBox()
    leftGroup.setTitle("QListWidget 示例")
    let leftLayout = QVBoxLayout()
    
    // 创建列表
    let listWidget = QListWidget()
    g_listWidget = Some(listWidget)
    listWidget.setAlternatingRowColors(true)
    
    // 添加一些项
    listWidget.addItem("苹果")
    listWidget.addItem("香蕉")
    listWidget.addItem("橙子")
    listWidget.addItem("葡萄")
    listWidget.addItem("西瓜")
    
    // 设置一些项可勾选
    listWidget.setItemCheckable(0, true)
    listWidget.setItemCheckable(1, true)
    listWidget.setItemCheckable(2, true)
    listWidget.setChecked(0, true) // 苹果默认勾选
    
    // 设置图标
    listWidget.setItemIcon(0, 2) // 文件图标
    
    leftLayout.addWidget(listWidget.getPtr())
    
    // 列表操作按钮
    let listBtnLayout = QHBoxLayout()
    
    let addBtn = QPushButton()
    addBtn.setText("添加项")
    addBtn.setOnClick({ _: Int64 => onAddItem(0) })
    listBtnLayout.addWidget(addBtn.getPtr())
    
    let removeBtn = QPushButton()
    removeBtn.setText("删除选中")
    removeBtn.setOnClick({ _: Int64 => onRemoveItem(0) })
    listBtnLayout.addWidget(removeBtn.getPtr())
    
    let countBtn = QPushButton()
    countBtn.setText("统计")
    countBtn.setOnClick({ _: Int64 => onCountItems(0) })
    listBtnLayout.addWidget(countBtn.getPtr())
    
    leftLayout.addLayout(listBtnLayout.getPtr())
    leftGroup.setLayout(leftLayout.getPtr())
    
    // ========== 右侧：QTreeWidget 示例 ==========
    let rightGroup = QGroupBox()
    rightGroup.setTitle("QTreeWidget 示例")
    let rightLayout = QVBoxLayout()
    
    // 创建树形控件
    let treeWidget = QTreeWidget()
    g_treeWidget = Some(treeWidget)
    treeWidget.setColumnCount(3)
    treeWidget.setHeaderLabel(0, "名称")
    treeWidget.setHeaderLabel(1, "类型")
    treeWidget.setHeaderLabel(2, "大小")
    listWidget.setAlternatingRowColors(true)
    
    // 添加顶级项
    let root1 = treeWidget.addTopLevelItem("项目文件夹")
    root1.setText(1, "文件夹")
    root1.setText(2, "-")
    
    // 添加子项
    let child1 = root1.addChild("src")
    child1.setText(1, "文件夹")
    child1.setText(2, "-")
    
    let file1 = child1.addChild("main.cj")
    file1.setText(1, "仓颉源码")
    file1.setText(2, "2KB")
    
    let file2 = child1.addChild("utils.cj")
    file2.setText(1, "仓颉源码")
    file2.setText(2, "1KB")
    
    let child2 = root1.addChild("docs")
    child2.setText(1, "文件夹")
    child2.setText(2, "-")
    
    let file3 = child2.addChild("README.md")
    file3.setText(1, "文档")
    file3.setText(2, "3KB")
    
    // 第二个顶级项
    let root2 = treeWidget.addTopLevelItem("配置文件")
    root2.setText(1, "文件夹")
    root2.setText(2, "-")
    
    let config1 = root2.addChild("cjpm.toml")
    config1.setText(1, "配置")
    config1.setText(2, "512B")
    
    let config2 = root2.addChild("CMakeLists.txt")
    config2.setText(1, "配置")
    config2.setText(2, "1KB")
    
    // 展开所有
    treeWidget.expandAll()
    
    rightLayout.addWidget(treeWidget.getPtr())
    
    // 树形操作按钮
    let treeBtnLayout = QHBoxLayout()
    
    let expandBtn = QPushButton()
    expandBtn.setText("展开全部")
    expandBtn.setOnClick({ _: Int64 => onExpandAll(0) })
    treeBtnLayout.addWidget(expandBtn.getPtr())
    
    let collapseBtn = QPushButton()
    collapseBtn.setText("折叠全部")
    collapseBtn.setOnClick({ _: Int64 => onCollapseAll(0) })
    treeBtnLayout.addWidget(collapseBtn.getPtr())
    
    let infoBtn = QPushButton()
    infoBtn.setText("查看选中")
    infoBtn.setOnClick({ _: Int64 => onShowItemInfo(0) })
    treeBtnLayout.addWidget(infoBtn.getPtr())
    
    rightLayout.addLayout(treeBtnLayout.getPtr())
    rightGroup.setLayout(rightLayout.getPtr())
    
    // 添加到主布局
    mainLayout.addWidget(leftGroup.getPtr())
    mainLayout.addWidget(rightGroup.getPtr())
    
    window.setLayout(mainLayout.getPtr())
    window.show()
    
    let result = app.exec()
    
    // 清理
    listWidget.delete()
    treeWidget.delete()
    window.delete()
    
    return result
}