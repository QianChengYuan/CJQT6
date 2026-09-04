package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*
import cjqt6.views.*
import std.collection.ArrayList

// ============================================================
// Transfer - 穿梭框
// 纯仓颉组合层：左右两个 QListWidget + 中间按钮，选中项可互相移动
// ============================================================

/// 穿梭框：左侧候选项 + 右侧已选项，按钮移动选中项
public class Transfer <: QtResource {
    private let group: QGroupBox
    private let layout: QHBoxLayout
    private let leftList: QListWidget
    private let rightList: QListWidget
    private let toRightBtn: QPushButton
    private let toLeftBtn: QPushButton

    /// 创建穿梭框（左右均为空）
    public init() {
        group = QGroupBox()
        layout = QHBoxLayout()
        leftList = QListWidget()
        rightList = QListWidget()
        // 中间按钮列
        let btnLayout = QVBoxLayout()
        toRightBtn = QPushButton()
        toRightBtn.setText("→")
        toLeftBtn = QPushButton()
        toLeftBtn.setText("←")
        btnLayout.addWidget(toRightBtn.getPtr())
        btnLayout.addWidget(toLeftBtn.getPtr())
        btnLayout.addStretch()
        layout.addWidget(leftList.getPtr())
        layout.addLayout(btnLayout.getPtr())
        layout.addWidget(rightList.getPtr())
        group.setLayout(layout.getPtr())
        // 所有成员已初始化，注册按钮回调
        toRightBtn.setOnClickCapture({ => moveSelectedToRight() })
        toLeftBtn.setOnClickCapture({ => moveSelectedToLeft() })
    }

    /// 添加候选项到左侧
    public func addCandidate(text: String): Unit {
        leftList.addItem(text)
    }

    /// 添加已选项到右侧
    public func addSelected(text: String): Unit {
        rightList.addItem(text)
    }

    /// 把左侧当前选中项移到右侧
    public func moveSelectedToRight(): Unit {
        let row = leftList.currentRow()
        if (row < 0) {
            return
        }
        let text = leftList.itemText(row)
        rightList.addItem(text)
        leftList.removeItem(row)
    }

    /// 把右侧当前选中项移到左侧
    public func moveSelectedToLeft(): Unit {
        let row = rightList.currentRow()
        if (row < 0) {
            return
        }
        let text = rightList.itemText(row)
        leftList.addItem(text)
        rightList.removeItem(row)
    }

    /// 获取右侧所有已选项
    public func getSelectedItems(): ArrayList<String> {
        let result = ArrayList<String>()
        let n = rightList.count()
        for (i in 0..n) {
            result.add(rightList.itemText(i))
        }
        result
    }

    /// 获取左侧所有候选项
    public func getCandidateItems(): ArrayList<String> {
        let result = ArrayList<String>()
        let n = leftList.count()
        for (i in 0..n) {
            result.add(leftList.itemText(i))
        }
        result
    }

    /// 清空两侧
    public func clear(): Unit {
        leftList.clear()
        rightList.clear()
    }

    // ---- QtResource 接口委托给内部容器 ----
    public func getPtr(): Int64 {
        group.getPtr()
    }
    public func isClosed(): Bool {
        group.isClosed()
    }
    public func isValid(): Bool {
        group.isValid()
    }
    public func checkValid(): Unit {
        group.checkValid()
    }
    public func close(): Unit {
        // QListWidget 不实现 QtResource，需显式 delete；按钮由容器级联清理
        leftList.delete()
        rightList.delete()
        group.close()
    }
}