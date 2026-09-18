package CjMonitor.ui

import CjMonitor.app.*

// ============================================================
// 界面上下文
//
// ui 需要读写 AppState（暂停、清空、阈值），但 app **不依赖 ui**。
// 依赖方向只能是 ui → app，因此由装配点（main.cj）把 AppState 注入这里。
// ============================================================

var gAppState: ?AppState = None

/// 注入全局状态（main.cj 装配时调用）
public func setAppState(s: AppState): Unit {
    gAppState = Some(s)
}

public func appState(): ?AppState {
    gAppState
}

/// 状态栏文案写入口（无状态时静默）
public func publishStatus(text: String): Unit {
    setStatusText(text)
}
