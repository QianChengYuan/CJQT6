package CjMonitor.ui

import std.collection.*
import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import CjMonitor.common.*
import CjMonitor.app.*

// ============================================================
// 阈值设置窗口
//
// 说明：CJQT6 当前未封装通用 QDialog（只有 QMessageBox / QFileDialog /
// QInputDialog 等具体对话框），因此本窗口基于 QWidget 实现为独立设置窗口
// 而非严格模态对话框。行为等价：读当前阈值 → 编辑 → 确定写回。
//
// 每通道一行：通道名 + 数值输入（禁用则填 0）
// ============================================================

/// 当前设置窗口（关闭后置空，避免长期持有）
var gThresholdWindow: ?ThresholdWindow = None

public class ThresholdWindow {
    private let page: QWidget
    private let spins: ArrayList<QDoubleSpinBox> = ArrayList<QDoubleSpinBox>()
    private let status: QLabel

    public init() {
        page = QWidget()
        page.setTitle("阈值设置")
        page.resize(460, 320)

        let v = QVBoxLayout()
        v.setMargin(14)
        v.setSpacing(10)

        let title = QLabel()
        title.setText("通道告警阈值")
        title.setStyleSheet(qssSectionTitle())
        v.addWidget(title.getPtr())

        let hint = QLabel()
        hint.setText("大于 0 启用该通道告警；连续 3 次超阈值才触发，同类告警 5 秒内只提示一次。")
        hint.setStyleSheet(qssMuted())
        hint.setWordWrap(true)
        v.addWidget(hint.getPtr())

        let form = QFormLayout()
        var i: Int64 = 0
        while (i < Int64(Channel.COUNT)) {
            let spin = QDoubleSpinBox()
            spin.setRange(0.0, 1000.0)
            spin.setSingleStep(1.0)
            spin.setDecimals(1)
            if (let Some(s) <- gAppState) {
                spin.setValue(s.threshold(Int32(i)))
            }
            spins.add(spin)
            form.addRow(Channel.name(Int32(i)) + " " + Channel.unit(Int32(i)), spin.getPtr())
            i += 1
        }
        v.addLayout(form.getPtr())

        status = QLabel()
        status.setText(" ")
        status.setStyleSheet(qssMuted())
        v.addWidget(status.getPtr())

        let row = QHBoxLayout()
        row.addStretch()

        let cancelBtn = QPushButton()
        cancelBtn.setText("取消")
        cancelBtn.setOnClickCapture({=> this.onCancel()})
        row.addWidget(cancelBtn.getPtr())

        let okBtn = QPushButton()
        okBtn.setText("确定")
        okBtn.setOnClickCapture({=> this.onApply()})
        row.addWidget(okBtn.getPtr())

        v.addLayout(row.getPtr())
        page.setLayout(v.getPtr())
        page.setStyleSheet(qssRootBackground())
    }

    public func show(): Unit {
        page.show()
    }

    public func dispose(): Unit {
        page.close()
    }

    /// 窗口尺寸文本（M5 自测用）
    public func sizeText(): String {
        "${page.width()}×${page.height()}"
    }

    /// 各通道回填值文本（M5 自测用）
    public func spinText(): String {
        var s = ""
        var i: Int64 = 0
        while (i < Int64(spins.size)) {
            if (!s.isEmpty()) {
                s += " / "
            }
            s += fmt1(spins[i].value())
            i += 1
        }
        if (s.isEmpty()) {
            s = "（无输入项）"
        }
        s
    }

    func onApply(): Unit {
        if (let Some(s) <- gAppState) {
            var i: Int64 = 0
            while (i < Int64(spins.size)) {
                s.setThreshold(Int32(i), spins[i].value())
                i += 1
            }
            status.setText("已应用阈值设置")
            publishStatus("阈值已更新")
        } else {
            status.setText("状态未就绪")
        }
        page.hide()
    }

    func onCancel(): Unit {
        page.hide()
    }
}

/// 打开阈值设置窗口（每次新建，隐藏即释放引用）
public func openThresholdWindow(): Unit {
    // 已有窗口先释放，避免叠加
    if (let Some(old) <- gThresholdWindow) {
        old.dispose()
    }
    let w = ThresholdWindow()
    gThresholdWindow = Some(w)
    w.show()
}

/// 关闭阈值窗口（M5 自测用：验收后立即释放）
public func closeThresholdWindow(): Unit {
    if (let Some(w) <- gThresholdWindow) {
        w.dispose()
    }
    gThresholdWindow = None
}

/// 阈值窗口尺寸文本（M5 自测用）
public func thresholdWindowSizeText(): String {
    if (let Some(w) <- gThresholdWindow) {
        return w.sizeText()
    }
    "未挂载"
}

/// 阈值窗口各通道回填值文本（M5 自测用：验证「读当前阈值」）
public func thresholdSpinText(): String {
    if (let Some(w) <- gThresholdWindow) {
        return w.spinText()
    }
    "未挂载"
}
