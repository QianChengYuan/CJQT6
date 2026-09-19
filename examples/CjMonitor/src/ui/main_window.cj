package CjMonitor.ui

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.menu.*
import cjqt6.dialogs.*
import CjMonitor.app.*

// ============================================================
// 主窗口外壳
// 负责：菜单栏 / 状态栏 / 页签容器 / 头部信息区。
// 各页签的实际内容由 realtime_tab / process_tab / history_tab 提供，
// 装配点统一在 main.cj。
// ============================================================

// 全局持有：跨回调访问 + 退出时统一释放
var gMainWindow: ?QMainWindow = None
var gTabWidget: ?QTabWidget = None
var gProcessTab: ?ProcessTab = None
var gHistoryTab: ?HistoryTab = None

// 状态栏（gStatusLabel / setStatusText）见 ui/status.cj：
// 抽成叶子文件以避免与 realtime_tab.cj 形成文件级循环依赖。

/// 取页签容器（供 app/ui 层挂载页面）
public func tabWidget(): ?QTabWidget {
    gTabWidget
}

let onQuitAction: VoidCallback = {
    => QApp.quit()
}
let onAboutAction: VoidCallback = {
    => QMessageBox.information(
        0,
        "关于 CjMonitor",
        "CjMonitor —— CJQT6 系统监控台\n\n" +
            "定位：性能与实时性压测（高频采样 + 实时渲染 + 长稳运行）\n" + "采样周期：100ms\n" +
            "监控通道：CPU / 内存 / 磁盘 / 网络"
    )
}

/// 巡检报告输出文件名（运行时生成；examples/**/*.pdf 未忽略，属预期产物）
let REPORT_FILE = "cjmonitor_report.pdf"

// 菜单动作：都落在 ui 包内（顶层 CFunc，不捕获局部变量），
// 由 ui 调用 app / report 的能力，避免 ui 反向依赖根包造成循环。
let onExportReportAction: VoidCallback = {
    => exportInspectionReport(REPORT_FILE)
}
let onTogglePauseAction: VoidCallback = {
    =>
    // CFunc 的调用本身也需要 unsafe 上下文
    unsafe { onPauseToggle() }
}
let onThresholdAction: VoidCallback = {
    => openThresholdWindow()
}

func buildMenuBar(): QMenuBar {
    let bar = QMenuBar()

    let fileMenu = bar.addMenu("文件")
    let exportAction = fileMenu.addAction("导出巡检报告…")
    exportAction.setOnTriggered(onExportReportAction)
    fileMenu.addSeparator()
    let quitAction = fileMenu.addAction("退出")
    quitAction.setOnTriggered(onQuitAction)

    let viewMenu = bar.addMenu("视图")
    let togglePauseAction = viewMenu.addAction("暂停采样")
    togglePauseAction.setOnTriggered(onTogglePauseAction)

    let settingMenu = bar.addMenu("阈值")
    let thresholdAction = settingMenu.addAction("阈值设置…")
    thresholdAction.setOnTriggered(onThresholdAction)

    let helpMenu = bar.addMenu("帮助")
    let aboutAction = helpMenu.addAction("关于")
    aboutAction.setOnTriggered(onAboutAction)

    bar
}

/// 头部信息区：标题 + 副标题
func buildHeader(): Int64 {
    let row = QHBoxLayout()
    row.setSpacing(12)

    let title = QLabel()
    title.setText("系统监控台")
    title.setStyleSheet(qssTitle())
    row.addWidget(title.getPtr())

    let subtitle = QLabel()
    subtitle.setText("100ms 高频采样 · 实时自绘 · 长稳压测")
    subtitle.setStyleSheet(qssSubtitle())
    row.addWidget(subtitle.getPtr())

    row.addStretch()
    row.getPtr()
}

/// 构建主窗口外壳
public func createMainWindow(): QMainWindow {
    let window = QMainWindow()
    window.setTitle("CjMonitor · 系统监控台")
    window.resize(1280, 800)

    // 菜单栏（QMainWindow 无 menuBar() getter，需传入指针）
    let menuBar = buildMenuBar()
    window.setMenuBar(menuBar.getPtr())

    // 中央容器
    let root = QWidget()
    root.setMinimumSize(960, 640)
    root.setStyleSheet(qssRootBackground())

    let rootLayout = QVBoxLayout()
    rootLayout.setMargin(16)
    rootLayout.setSpacing(12)
    rootLayout.addLayout(buildHeader())

    // 页签容器
    let tabs = QTabWidget()
    tabs.addTab(createRealtimeTab().getPtr(), "实时监控")

    let procTab = createProcessTab()
    tabs.addTab(procTab.widget().getPtr(), "进程")
    procTab.start()
    gProcessTab = Some(procTab)

    let historyTab = createHistoryTab()
    tabs.addTab(historyTab.widget().getPtr(), "历史")
    gHistoryTab = Some(historyTab)
    rootLayout.addWidget(tabs.getPtr(), 1)
    root.setLayout(rootLayout.getPtr())
    window.setCentralWidget(root.getPtr())

    // 状态栏
    let statusBar = QStatusBar()
    let statusLabel = QLabel()
    statusLabel.setText("就绪 · 等待采集启动")
    statusLabel.setStyleSheet(qssSubtitle())
    statusBar.addWidget(statusLabel.getPtr())
    window.setStatusBar(statusBar.getPtr())

    gMainWindow = Some(window)
    gTabWidget = Some(tabs)
    gStatusLabel = Some(statusLabel)
    window
}

/// 调整主窗口尺寸（界面自测用：验证不同尺寸下布局不塌）
public func resizeMainWindow(w: Int32, h: Int32): Unit {
    if (let Some(window) <- gMainWindow) {
        window.resize(w, h)
    }
}

/// 切到「进程」页签（界面自测用：隐藏页不参与布局，必须可见后再量尺寸）
public func showProcessTab(): Unit {
    if (let Some(tabs) <- gTabWidget) {
        tabs.setCurrentIndex(1)
    }
}

/// 触发历史页查询（M4 自测走 ui 的真实路径：runQuery → rebuild 图表）
public func runHistoryQuery(): Unit {
    if (let Some(ht) <- gHistoryTab) {
        ht.runQuery()
    }
}

/// 历史页查询结果文本（状态 + 摘要）
public func historyQueryText(): String {
    if (let Some(ht) <- gHistoryTab) {
        return ht.statusText() + " ｜ " + ht.summaryText()
    }
    "历史页未挂载"
}

/// 主窗口当前尺寸文本
public func windowSizeText(): String {
    if (let Some(window) <- gMainWindow) {
        return "${window.width()}×${window.height()}"
    }
    "未挂载"
}

/// 进程页容器尺寸文本（进程表所在页）
public func processPageSizeText(): String {
    if (let Some(pt) <- gProcessTab) {
        let w = pt.widget()
        return "${w.width()}×${w.height()}"
    }
    "未挂载"
}

/// 进程页是否塌陷（尺寸为 0）
public func processPageCollapsed(): Bool {
    if (let Some(pt) <- gProcessTab) {
        let w = pt.widget()
        return w.width() <= 0 || w.height() <= 0
    }
    true
}

/// 释放主窗口外壳持有的界面对象。
/// 子控件随父对象级联释放，此处只需注销顶层对象。
public func disposeMainWindow(): Unit {
    // 先释放带定时器/子进程的页，再关闭窗口（子控件随父对象级联释放）
    if (let Some(pt) <- gProcessTab) {
        pt.dispose()
    }
    gProcessTab = None
    if (let Some(ht) <- gHistoryTab) {
        ht.dispose()
    }
    gHistoryTab = None
    if (let Some(tw) <- gThresholdWindow) {
        tw.dispose()
    }
    gThresholdWindow = None
    if (let Some(window) <- gMainWindow) {
        window.close()
    }
    gStatusLabel = None
    gTabWidget = None
    gMainWindow = None
}
