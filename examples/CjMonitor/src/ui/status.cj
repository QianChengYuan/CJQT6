package CjMonitor.ui

import cjqt6.widgets.*

// ============================================================
// 状态栏
//
// 独立成文件的原因：仓颉对**同包内文件间**的顶层绑定做循环依赖检查。
// 若状态栏写在 main_window.cj 里，则 main_window（用 realtime_tab 的
// onPauseToggle）与 realtime_tab（用状态栏写入）会构成文件级环。
// 把状态栏抽成被双方依赖的叶子文件即可解环。
// ============================================================

var gStatusLabel: ?QLabel = None

/// 状态栏写入次数与最近文本（供界面自测统计刷新节拍，见 src/ui_selftest.cj）
var gStatusUpdates: Int64 = 0
var gLastStatusText: String = ""

/// 写状态栏左侧文案（未就绪时静默）
public func setStatusText(text: String): Unit {
    gStatusUpdates += 1
    gLastStatusText = text
    if (let Some(label) <- gStatusLabel) {
        label.setText(text)
    }
}

/// 状态栏写入次数（≈ 采样摘要在 1s 节拍下的推送次数）
public func statusUpdateCount(): Int64 {
    gStatusUpdates
}

/// 最近一次写入状态栏的文本
public func lastStatusText(): String {
    gLastStatusText
}

/// 状态栏控件几何文本（布局塌陷检查用）
public func statusLabelSizeText(): String {
    if (let Some(label) <- gStatusLabel) {
        return "${label.width()}×${label.height()}"
    }
    "未挂载"
}

/// 状态栏是否塌陷（尺寸为 0）
public func statusLabelCollapsed(): Bool {
    if (let Some(label) <- gStatusLabel) {
        return label.width() <= 0 || label.height() <= 0
    }
    true
}
