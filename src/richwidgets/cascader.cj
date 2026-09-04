package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*

// ============================================================
// Cascader - 级联选择器
// 纯仓颉组合层：两个 QComboBox 两级选择
// 注：当前为两级独立选择，自动联动需 QComboBox Capture 回调支持（待后续）
// ============================================================

/// 级联选择器：两级下拉选择，支持自动联动（setCascadeData）或独立设置
public class Cascader <: QtResource {
    private let group: QGroupBox
    private let layout: QHBoxLayout
    private let level1: QComboBox
    private let sep: QLabel
    private let level2: QComboBox
    private var level2Data: ?Array<Array<String>> = None
    private var level1Cb: ?(() -> Unit) = None

    /// 创建级联选择器（两级均为空）
    public init() {
        group = QGroupBox()
        group.setFlat(true)
        layout = QHBoxLayout()
        level1 = QComboBox()
        sep = QLabel()
        sep.setText(" / ")
        level2 = QComboBox()
        layout.addWidget(level1.getPtr())
        layout.addWidget(sep.getPtr())
        layout.addWidget(level2.getPtr())
        group.setLayout(layout.getPtr())
    }

    /// 设置级联数据并启用自动联动：一级选项 + 对应的二级选项数组（索引对应）
    public func setCascadeData(level1Items: Array<String>, level2Items: Array<Array<String>>): Unit {
        level2Data = Some(level2Items)
        // 填充一级
        level1.clear()
        for (t in level1Items) {
            level1.addItem(t)
        }
        // 默认填第一项的二级
        if (level1Items.size > 0) {
            updateLevel2(0)
        }
        // 注册联动回调（一级变化时自动更新二级）
        level1.setOnCurrentIndexChangedCapture({ => onLevel1Changed() })
    }

    /// 一级变化回调（联动更新二级后触发，可捕获局部变量）
    public func setOnLevel1Changed(callback: () -> Unit): Unit {
        level1Cb = Some(callback)
    }

    // 内部：一级变化处理
    private func onLevel1Changed(): Unit {
        updateLevel2(level1.currentIndex())
        if (let Some(cb) <- level1Cb) {
            cb()
        }
    }

    // 内部：根据一级索引更新二级内容
    private func updateLevel2(idx: Int32): Unit {
        if (let Some(data) <- level2Data) {
            let i = Int64(idx)
            if (i >= 0 && i < data.size) {
                level2.clear()
                for (t in data[i]) {
                    level2.addItem(t)
                }
            }
        }
    }

    /// 设置一级选项
    public func setLevel1Items(items: Array<String>): Unit {
        level1.clear()
        for (t in items) {
            level1.addItem(t)
        }
    }

    /// 设置二级选项
    public func setLevel2Items(items: Array<String>): Unit {
        level2.clear()
        for (t in items) {
            level2.addItem(t)
        }
    }

    /// 获取一级当前选中文本
    public func getLevel1Current(): String {
        level1.currentText()
    }

    /// 获取二级当前选中文本
    public func getLevel2Current(): String {
        level2.currentText()
    }

    /// 设置一级当前选中索引
    public func setLevel1Current(index: Int32): Unit {
        level1.setCurrentIndex(index)
    }

    /// 设置二级当前选中索引
    public func setLevel2Current(index: Int32): Unit {
        level2.setCurrentIndex(index)
    }

    /// 获取一级选项数
    public func level1Count(): Int32 {
        level1.count()
    }

    /// 获取二级选项数
    public func level2Count(): Int32 {
        level2.count()
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
        group.close()
    }
}