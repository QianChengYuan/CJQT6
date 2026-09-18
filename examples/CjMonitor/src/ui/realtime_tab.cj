package CjMonitor.ui

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import CjMonitor.app.*
import CjMonitor.widget.*

// ============================================================
// 实时页：仪表行 + 实时曲线 + 控制条 + 告警条
//
// 本页只负责“建控件 + 装配”，数据由 AppState 经 attachViews 注入；
// 采样驱动的重绘也由 AppState 发起（ui 不接收每帧回调）。
// ============================================================

var gRealtimeCurve: ?CurveWidget = None
var gRealtimeGauge: ?GaugePanel = None
var gRealtimeAlertLabel: ?QLabel = None
var gPauseButton: ?QPushButton = None

/// 暂停 / 继续
let onPauseToggle: VoidCallback = { =>
    if (let Some(s) <- gAppState) {
        let next = !s.isPaused()
        s.setPaused(next)
        if (let Some(b) <- gPauseButton) {
            if (next) {
                b.setText("继续")
            } else {
                b.setText("暂停")
            }
        }
        publishStatus(if (next) { "已暂停采样" } else { "已恢复采样" })
    }
}

/// 清空窗口数据
let onClearData: VoidCallback = { =>
    if (let Some(s) <- gAppState) {
        s.clearData()
        if (let Some(c) <- gRealtimeCurve) {
            c.requestRepaint()
        }
        if (let Some(g) <- gRealtimeGauge) {
            g.requestRepaint()
        }
        publishStatus("已清空窗口数据")
    }
}

/// 窗口时长切换（下拉框索引 → 可见点数）
let onWindowChanged: Int32Callback = { idx: Int32 =>
    if (let Some(c) <- gRealtimeCurve) {
        match (idx) {
            case 1 => c.setVisiblePoints(600)
            case 2 => c.setVisiblePoints(1200)
            case _ => c.setVisiblePoints(300)
        }
        c.requestRepaint()
        publishStatus("窗口时长已切换")
    }
}

/// 最近一次告警文案写入口（M5 的告警链路调用）
public func setAlertText(text: String, level: Int32): Unit {
    if (let Some(l) <- gRealtimeAlertLabel) {
        l.setText(text)
        match (level) {
            case 2 => l.setStyleSheet(qssPillDanger())
            case 1 => l.setStyleSheet(qssPillWarn())
            case _ => l.setStyleSheet(qssPillOk())
        }
    }
}

/// 告警条当前文本（M5 自测用：验证告警链路已到达界面）
public func alertBarText(): String {
    if (let Some(l) <- gRealtimeAlertLabel) {
        return l.text()
    }
    "未挂载"
}

func buildControlRow(): Int64 {
    let row = QHBoxLayout()
    row.setSpacing(8)

    let pauseBtn = QPushButton()
    pauseBtn.setText("暂停")
    pauseBtn.setOnClick(onPauseToggle)
    row.addWidget(pauseBtn.getPtr())

    let clearBtn = QPushButton()
    clearBtn.setText("清空")
    clearBtn.setOnClick(onClearData)
    row.addWidget(clearBtn.getPtr())

    let winLabel = QLabel()
    winLabel.setText("窗口")
    winLabel.setStyleSheet(qssSubtitle())
    row.addWidget(winLabel.getPtr())

    let combo = QComboBox()
    combo.addItem("30 秒")
    combo.addItem("60 秒")
    combo.addItem("120 秒")
    combo.setCurrentIndex(1)
    combo.setOnCurrentIndexChanged(onWindowChanged)
    row.addWidget(combo.getPtr())

    row.addStretch()

    let hint = QLabel()
    hint.setText("采样周期 100ms · 曲线高频刷新 · 表格降频 1s")
    hint.setStyleSheet(qssMuted())
    row.addWidget(hint.getPtr())

    gPauseButton = Some(pauseBtn)
    row.getPtr()
}

/// 取实时曲线的公开句柄（供装配点注入 AppState）
public func realtimeCurve(): ?CurveWidget {
    gRealtimeCurve
}

/// 取仪表盘的公开句柄（供装配点注入 AppState）
public func realtimeGauge(): ?GaugePanel {
    gRealtimeGauge
}

/// 构建实时页
public func createRealtimeTab(): QWidget {
    let page = QWidget()

    let v = QVBoxLayout()
    v.setMargin(10)
    v.setSpacing(10)

    // 顶部：四通道仪表
    let gauge = createGaugePanel()
    v.addWidget(gauge.getPtr(), 0)

    // 中部：实时曲线（占主要高度）
    let curve = createCurveWidget()
    curve.setVisiblePoints(600)
    v.addWidget(curve.getPtr(), 1)

    // 控制条
    v.addLayout(buildControlRow())

    // 告警条
    let alert = QLabel()
    alert.setText("最近告警：—")
    alert.setStyleSheet(qssPillOk())
    v.addWidget(alert.getPtr())

    page.setLayout(v.getPtr())

    gRealtimeGauge = Some(gauge)
    gRealtimeCurve = Some(curve)
    gRealtimeAlertLabel = Some(alert)
    page
}
