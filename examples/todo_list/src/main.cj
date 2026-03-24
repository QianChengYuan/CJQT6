package todo_list

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*
import CJQT6.views.*
import std.collection.*

// ============================================================
// 全局状态
// ============================================================
var gTreeWidget: ?QTreeWidget = None
var gTaskInput: ?QLineEdit = None
var gTaskCountLabel: ?QLabel = None
var gTasks: ArrayList<String> = ArrayList<String>()

// ============================================================
// 辅助函数
// ============================================================

func updateTaskCount(): Unit {
    if (let Some(label) <- gTaskCountLabel) {
        label.setText("共 ${gTasks.size} 项任务")
    }
}

func refreshList(): Unit {
    if (let Some(tree) <- gTreeWidget) {
        tree.clear()
        for (task in gTasks) {
            let item = tree.addTopLevelItem(task)
            item.setCheckState(0, CheckState.Unchecked)
        }
        updateTaskCount()
    }
}

// ============================================================
// 按钮回调
// ============================================================

// 添加任务
let onAddClick: VoidCallback = { =>
    if (let Some(input) <- gTaskInput) {
        let text = input.text()
        if (!text.isEmpty()) {
            gTasks.add(text)
            refreshList()
            input.clear()
        }
    }
}

// 删除选中任务
let onDeleteClick: VoidCallback = { =>
    if (let Some(tree) <- gTreeWidget) {
        let itemOpt = tree.currentItem()
        if (let Some(item) <- itemOpt) {
            let taskText = item.text(0)
            // 从列表中移除
            let newTasks = ArrayList<String>()
            for (task in gTasks) {
                if (task != taskText) {
                    newTasks.add(task)
                }
            }
            gTasks = newTasks
            refreshList()
        }
    }
}

// 清除已完成
let onClearCompletedClick: VoidCallback = { =>
    if (let Some(tree) <- gTreeWidget) {
        let newTasks = ArrayList<String>()
        let checkedValue = CheckState.Checked
        var i: Int32 = 0
        while (i < Int32(gTasks.size)) {
            let item = tree.topLevelItem(i)
            if (item.checkState(0) != checkedValue) {
                newTasks.add(gTasks[Int64(i)])
            }
            i = i + 1
        }
        gTasks = newTasks
        refreshList()
    }
}

// 清除全部
let onClearAllClick: VoidCallback = { =>
    gTasks.clear()
    refreshList()
}

// 文本变化回调 - 按回车时添加
let onTextChanged: CStringCallback = { text: CString =>
    // 检查是否按了回车（通过检查文本是否以换行结尾）
}

// ============================================================
// 辅助函数
// ============================================================

func label(text: String): QLabel {
    let l = QLabel()
    l.setText(text)
    l
}

func button(text: String, onClick: VoidCallback): QPushButton {
    let btn = QPushButton()
    btn.setText(text)
    btn.setOnClick(onClick)
    btn
}

// ============================================================
// 主函数
// ============================================================
main(): Int32 {
    let app = QApplication()
    
    // 创建窗口
    let window = QWidget()
    window.setTitle("待办事项")
    window.resize(400, 500)
    
    let mainLayout = QVBoxLayout()
    mainLayout.setMargin(15)
    mainLayout.setSpacing(10)
    
    // ========== 标题 ==========
    let titleLabel = QLabel()
    titleLabel.setText("待办事项")
    titleLabel.setAlignment(Alignment.Center)
    mainLayout.addWidget(titleLabel.getPtr())
    
    // ========== 输入区域 ==========
    let inputLayout = QHBoxLayout()
    inputLayout.setSpacing(8)
    
    let taskInput = QLineEdit()
    taskInput.setPlaceholder("输入新任务...")
    gTaskInput = taskInput
    inputLayout.addWidget(taskInput.getPtr())
    
    let addBtn = button("添加", onAddClick)
    addBtn.setStyleSheet("background-color: #3498db; color: white;")
    inputLayout.addWidget(addBtn.getPtr())
    
    mainLayout.addLayout(inputLayout.getPtr())
    
    // ========== 任务列表 ==========
    let tree = QTreeWidget()
    tree.setColumnCount(1)
    tree.setHeaderLabel(0, "任务列表")
    gTreeWidget = tree
    mainLayout.addWidget(tree.getPtr())
    
    // ========== 操作按钮 ==========
    let btnLayout = QHBoxLayout()
    btnLayout.setSpacing(8)
    
    let deleteBtn = button("删除选中", onDeleteClick)
    deleteBtn.setStyleSheet("background-color: #e74c3c; color: white;")
    btnLayout.addWidget(deleteBtn.getPtr())
    
    let clearCompletedBtn = button("清除已完成", onClearCompletedClick)
    clearCompletedBtn.setStyleSheet("background-color: #f39c12; color: white;")
    btnLayout.addWidget(clearCompletedBtn.getPtr())
    
    let clearAllBtn = button("清除全部", onClearAllClick)
    clearAllBtn.setStyleSheet("background-color: #95a5a6; color: white;")
    btnLayout.addWidget(clearAllBtn.getPtr())
    
    mainLayout.addLayout(btnLayout.getPtr())
    
    // ========== 状态栏 ==========
    let statusLayout = QHBoxLayout()
    
    let countLabel = QLabel()
    countLabel.setText("共 0 项任务")
    gTaskCountLabel = countLabel
    statusLayout.addWidget(countLabel.getPtr())
    
    statusLayout.addStretch()
    
    let tipLabel = QLabel()
    tipLabel.setText("提示: 点击勾选完成任务")
    statusLayout.addWidget(tipLabel.getPtr())
    
    mainLayout.addLayout(statusLayout.getPtr())
    
    // 添加一些示例任务
    gTasks.add("学习仓颉语言基础语法")
    gTasks.add("完成 CJQT6 示例项目")
    gTasks.add("编写单元测试")
    refreshList()
    
    // 设置布局并显示
    window.setLayout(mainLayout.getPtr())
    window.show()
    
    let result = app.exec()
    
    // 清理
    if (let Some(t) <- gTreeWidget) {
        t.delete()
    }
    
    return result
}
