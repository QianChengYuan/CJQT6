package all_controls_demo

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.dialogs.*
import cjqt6.views.*
import cjqt6.richwidgets.*

// ============================================================
// CJQT6 全控件演示 - 侧边栏导航 + 页面切换
// ============================================================

// ============================================================
// 对齐常量 (Int32 values for QLabel.setAlignment etc.)
// ============================================================
let AlignLeft: Int32 = 0x0001
let AlignCenter: Int32 = 0x0084

// ============================================================
// 全局控件引用（用于CFunc回调 - CFunc不能捕获外部变量）
// ============================================================
var gStackedWidget: ?QStackedWidget = None
var gStatusLabel: ?QLabel = None
var gProgressBar: ?QProgressBar = None
var gSliderValueLabel: ?QLabel = None
var gSpinValueLabel: ?QLabel = None
var gDialValueLabel: ?QLabel = None
var gLcdNumber: ?QLCDNumber = None
var gMainWindow: ?QWidget = None
var gCheckStateLabel: ?QLabel = None
var gRadioLabel: ?QLabel = None
var gComboLabel: ?QLabel = None
var gKeyEdit: ?QKeySequenceEdit = None

// 新控件页 (v1.2.0) 全局引用
var gNewScrollVal: ?QLabel = None
var gNewDlgInfo: ?QLabel = None
var gNewContainer: ?QWidget = None
var gNewRubberBand: ?QRubberBand = None
var gNewSplash: ?QSplashScreen = None
var gNewTimer: ?QTimer = None
var gNewFsModel: ?QFileSystemModel = None

// 懒加载：页面创建状态与占位 widget 指针
var gPageCreated: Array<Bool> = [false, false, false, false, false, false, false, false, false]
var gPlaceholderPtrs: Array<Int64> = [0, 0, 0, 0, 0, 0, 0, 0, 0]

// ============================================================
// 页面名称列表（与createPages顺序一致）
// ============================================================
let pageNames: Array<String> = [
    "[1] 基础控件",
    "[2] 文本输入",
    "[3] 数值控件",
    "[4] 选择控件",
    "[5] 容器布局",
    "[6] 高级控件",
    "[7] 对话框",
    "[8] 新控件 v1.2.0",
    "[9] 组合控件"
]

// ============================================================
// 回调函数
// ============================================================

// 侧边栏切换回调（懒加载：首次切换时才创建页面内容）
let onSidebarChanged: CFunc<(Int32) -> Unit> = { row: Int32 =>
    if (row >= 0) {
        let r = Int64(row)
        if (let Some(stack) <- gStackedWidget) {
            // 懒加载：首次切换时才创建页面，避免初始化时一次性创建所有页面导致 UI 卡死
            if (r < gPageCreated.size && !gPageCreated[r]) {
                let page = match (row) {
                    case 0 => createPageBasic()
                    case 1 => createPageText()
                    case 2 => createPageNumeric()
                    case 3 => createPageSelection()
                    case 4 => createPageContainers()
                    case 5 => createPageAdvanced()
                    case 6 => createPageDialogs()
                    case 7 => createPageNewWidgets()
                    case 8 => createPageRichWidgets()
                    case _ => createPageBasic()
                }
                // 移除占位 widget，插入真实页面
                let placeholderPtr = gPlaceholderPtrs[r]
                if (placeholderPtr != 0) {
                    stack.removeWidget(placeholderPtr)
                }
                stack.insertWidget(row, page.getPtr())
                gPageCreated[r] = true
            }
            stack.setCurrentIndex(row)
        }
        if (let Some(status) <- gStatusLabel) {
            if (r < Int64(pageNames.size)) {
                status.setText("当前页面: ${pageNames[r]}")
            }
        }
    }
}

// 基础控件 - 按钮点击
let onBtnClick: VoidCallback = { =>
    if (let Some(status) <- gStatusLabel) {
        status.setText("按钮被点击了！(点击时间: ${now()})")
    }
}

let onBtnClear: VoidCallback = { =>
    if (let Some(status) <- gStatusLabel) {
        status.setText("信息已清空 ✓")
    }
}

let onSliderChanged: Int32Callback = { value: Int32 =>
    if (let Some(label) <- gSliderValueLabel) {
        label.setText("当前值: ${value}")
    }
    if (let Some(bar) <- gProgressBar) {
        bar.setValue(value)
    }
}

let onSpinChanged: Int32Callback = { value: Int32 =>
    if (let Some(label) <- gSpinValueLabel) {
        label.setText("值: ${value}")
    }
}

let onDialChanged: Int32Callback = { value: Int32 =>
    if (let Some(label) <- gDialValueLabel) {
        label.setText("角度: ${value}°")
    }
    if (let Some(lcd) <- gLcdNumber) {
        lcd.displayInt(value)
    }
}

let onCheckChanged: Int32Callback = { state: Int32 =>
    if (let Some(label) <- gCheckStateLabel) {
        if (state == 2) {
            label.setText("复选框: 已选中 ✓")
        } else {
            label.setText("复选框: 未选中 ✗")
        }
    }
}

let onRadioChanged: Int32Callback = { checked: Int32 =>
    if (checked == 1) {
        if (let Some(label) <- gRadioLabel) {
            label.setText("单选: 选项已切换")
        }
    }
}

let onComboChanged: Int32Callback = { index: Int32 =>
    if (let Some(label) <- gComboLabel) {
        label.setText("已选择: 第 ${index + 1} 项")
    }
}

// 对话框回调
let onMsgInfo: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        QMessageBox.information(w.getPtr(), "信息", "这是一个信息对话框")
    }
}

let onMsgWarning: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        QMessageBox.warning(w.getPtr(), "警告", "这是一个警告对话框！")
    }
}

let onMsgQuestion: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        let result = QMessageBox.question(w.getPtr(), "询问", "确定要执行此操作吗？")
        if (let Some(status) <- gStatusLabel) {
            if (result) {
                status.setText("询问结果: 是 ✓")
            } else {
                status.setText("询问结果: 否 ✗")
            }
        }
    }
}

let onMsgError: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        QMessageBox.critical(w.getPtr(), "错误", "发生了一个严重错误！")
    }
}

let onFileOpen: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        let filePath = QFileDialog.getOpenFileName(w.getPtr(), "选择文件", "所有文件 (*.*)")
        if (!filePath.isEmpty()) {
            if (let Some(status) <- gStatusLabel) {
                status.setText("打开文件: ${filePath}")
            }
        }
    }
}

let onFileSave: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        let filePath = QFileDialog.getSaveFileName(w.getPtr(), "保存文件", "文本文件 (*.txt)")
        if (!filePath.isEmpty()) {
            if (let Some(status) <- gStatusLabel) {
                status.setText("保存文件: ${filePath}")
            }
        }
    }
}

let onInputText: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        let (text, ok) = QInputDialog.getTextWithResult(w.getPtr(), "输入文本", "请输入内容:", "")
        if (ok) {
            if (let Some(status) <- gStatusLabel) {
                status.setText("输入文本: ${text}")
            }
        }
    }
}

let onInputInt: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        let (value, ok) = QInputDialog.getIntWithResult(w.getPtr(), "输入整数", "请输入一个数字:", 0, 0, 1000)
        if (ok) {
            if (let Some(status) <- gStatusLabel) {
                status.setText("输入整数: ${value}")
            }
        }
    }
}

let onColorPicker: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        let color = QColorDialog.getColor(w.getPtr(), "选择颜色")
        if (!color.isEmpty()) {
            if (let Some(status) <- gStatusLabel) {
                status.setText("选择颜色: ${color}")
            }
        }
    }
}

let onFontPicker: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        let fontName = QFontDialog.getFontName(w.getPtr(), "选择字体")
        if (!fontName.isEmpty()) {
            if (let Some(status) <- gStatusLabel) {
                status.setText("选择字体: ${fontName}")
            }
        }
    }
}

// 新控件页 (v1.2.0) 回调

// QSplashScreen 超时回调（独立 CFunc，不捕获局部变量）
let onSplashTimeout: VoidCallback = { =>
    if (let Some(win) <- gMainWindow) {
        if (let Some(sp) <- gNewSplash) {
            sp.finish(win)
            sp.delete()
            gNewSplash = None
        }
    }
    if (let Some(t) <- gNewTimer) {
        t.stop()
        t.delete()
        gNewTimer = None
    }
}

// QSplashScreen - 显示 2 秒后自动关闭
let onShowSplash: VoidCallback = { =>
    if (let Some(w) <- gMainWindow) {
        gNewSplash = QSplashScreen()
        if (let Some(sp) <- gNewSplash) {
            sp.showMessage("正在加载 CJQT6 v1.2.0 新控件…")
            sp.show()
        }
        try {
            let timer = QTimer()
            gNewTimer = timer
            timer.setInterval(2000)
            timer.setOnTimeout(onSplashTimeout)
            timer.start()
        } catch (e: Exception) {
            if (let Some(status) <- gStatusLabel) {
                status.setText("定时器创建失败，无法自动关闭启动画面")
            }
        }
        if (let Some(status) <- gStatusLabel) {
            status.setText("启动画面已显示，2 秒后自动关闭")
        }
    }
}

// QRubberBand - 显示选择框
let onRubberShow: VoidCallback = { =>
    if (let Some(c) <- gNewContainer) {
        if (let Some(rb) <- gNewRubberBand) {
            // 已存在，直接显示
            rb.setGeometry(20, 20, 220, 130)
            rb.show()
        } else {
            // 尚不存在，就地创建并持有引用
            let newRb = QRubberBand(RubberBandShape.Rectangle, c)
            newRb.setGeometry(20, 20, 220, 130)
            newRb.show()
            gNewRubberBand = newRb
        }
        if (let Some(rb) <- gNewRubberBand) {
            if (let Some(status) <- gStatusLabel) {
                status.setText("选择框已显示 (x=${rb.x()} y=${rb.y()} w=${rb.width()} h=${rb.height()})")
            }
        }
    }
}

// QRubberBand - 隐藏选择框
let onRubberHide: VoidCallback = { =>
    if (let Some(rb) <- gNewRubberBand) {
        rb.hide()
        if (let Some(status) <- gStatusLabel) {
            status.setText("选择框已隐藏")
        }
    }
}

// ============================================================
// 辅助函数
// ============================================================

func now(): String {
    "12:00:00"  // 简化实现
}

func setLabelStyle(lbl: QLabel, style: String) {
    lbl.setStyleSheet(style)
}

func sectionTitle(text: String): QLabel {
    let lbl = QLabel()
    lbl.setText("▸ ${text}")
    setLabelStyle(lbl, "font-size: 14px; font-weight: bold; color: #2c3e50; margin-top: 8px;")
    lbl.setAlignment(AlignLeft)
    lbl
}

func infoLabel(text: String): QLabel {
    let lbl = QLabel()
    lbl.setText(text)
    setLabelStyle(lbl, "color: #7f8c8d; font-size: 12px;")
    lbl
}

// ============================================================
// 页面创建函数 - 每个页面放在QScrollArea中
// ============================================================

// 创建一个带滚动条的页面容器
func createPageContainer(): (QScrollArea, QWidget, QVBoxLayout) {
    let container = QWidget()
    let layout = QVBoxLayout()
    layout.setSpacing(6)
    layout.setMargin(12)
    container.setLayout(layout.getPtr())

    let scrollArea = QScrollArea()
    scrollArea.setWidget(container.getPtr())
    scrollArea.setWidgetResizable(true)

    (scrollArea, container, layout)
}

// ============================================================
// 主函数
// ============================================================
main(): Int32 {
    let app = QApplication()
    app.loadQtTranslation("zh_CN")

    // ========== 主窗口 ==========
    let window = QWidget()
    window.setTitle("CJQT6 全控件演示")
    window.resize(900, 620)
    window.setMinimumSize(700, 480)
    gMainWindow = window

    // ========== 整体布局: 水平分割器 ==========
    let splitter = QSplitter.createHorizontal(0)
    splitter.setHandleWidth(1)
    splitter.setChildrenCollapsible(false)

    // ========== 左侧: 导航栏 ==========
    let sidebar = QListWidget()
    sidebar.setAlternatingRowColors(true)
    sidebar.setSelectionMode(ListSelectionMode.SingleSelection)
    for (name in pageNames) {
        sidebar.addItem(name)
    }
    sidebar.setCurrentRow(0)
    sidebar.setMinimumSize(160, 0)
    sidebar.setMaximumSize(220, 0xFFFFFF)

    // ========== 右侧: 堆叠页面 ==========
    let stackedWidget = QStackedWidget()
    gStackedWidget = stackedWidget

    // 懒加载：先创建占位 widget 保持索引，首次切换时才创建真实页面
    for (i in 0..9) {
        let placeholder = QWidget()
        gPlaceholderPtrs[i] = placeholder.getPtr()
        stackedWidget.addWidget(placeholder.getPtr())
    }
    // 预创建第 1 页（初始显示）
    let firstPage = createPageBasic()
    stackedWidget.removeWidget(gPlaceholderPtrs[0])
    stackedWidget.insertWidget(0, firstPage.getPtr())
    gPageCreated[0] = true

    // 侧边栏切换事件
    sidebar.setOnCurrentRowChanged(onSidebarChanged)

    // ========== 分割器组装 ==========
    splitter.addWidget(sidebar.getPtr())
    splitter.addWidget(stackedWidget.getPtr())
    splitter.setStretchFactor(0, 0)  // 侧边栏不拉伸
    splitter.setStretchFactor(1, 1)  // 内容区域拉伸

    // ========== 主布局（垂直：分割器 + 状态栏） ==========
    let mainLayout = QVBoxLayout()
    mainLayout.setSpacing(0)
    mainLayout.setMargin(0)

    // 将分割器添加到布局（stretch=1，使其占据所有剩余空间）
    mainLayout.addWidget(splitter.getPtr(), 1)

    // 状态栏（紧凑）
    let statusBar = QFrame()
    statusBar.setFrameShape(0)    // NoFrame - 减少边框高度
    let statusBarLayout = QHBoxLayout()
    statusBarLayout.setMargin(0)
    statusBarLayout.setSpacing(4)
    let statusLabel = QLabel()
    statusLabel.setText("就绪 - 点击侧边栏切换页面")
    setLabelStyle(statusLabel, "color: #7f8c8d; font-size: 10px; padding: 0px; margin: 0px;")
    gStatusLabel = statusLabel
    statusBarLayout.addWidget(statusLabel.getPtr())
    statusBarLayout.addStretch()

    let versionLabel = QLabel()
    versionLabel.setText("CJQT6 v1.2.0")
    setLabelStyle(versionLabel, "color: #bdc3c7; font-size: 9px; padding: 0px; margin: 0px;")
    statusBarLayout.addWidget(versionLabel.getPtr())

    statusBar.setLayout(statusBarLayout.getPtr())
    mainLayout.addWidget(statusBar.getPtr())

    // 将主布局设置到窗口
    window.setLayout(mainLayout.getPtr())

    // ========== 样式美化 ==========
    sidebar.setStyleSheet("""
        QListWidget {
            border: none;
            border-right: 1px solid #dcdde1;
            background-color: #f5f6fa;
            font-size: 13px;
        }
        QListWidget::item {
            padding: 10px 12px;
            border-bottom: 1px solid #e8e9ed;
        }
        QListWidget::item:selected {
            background-color: #3498db;
            color: white;
            border: none;
        }
        QListWidget::item:hover:!selected {
            background-color: #e8e9ed;
        }
    """)

    window.setStyleSheet("""
        QWidget {
            font-family: "Microsoft YaHei", "Segoe UI", sans-serif;
        }
        QPushButton {
            padding: 5px 12px;
            border: 1px solid #bdc3c7;
            border-radius: 3px;
            background-color: #f8f9fa;
        }
        QPushButton:hover {
            background-color: #e8e9ed;
            border-color: #95a5a6;
        }
        QPushButton:pressed {
            background-color: #dcdde1;
        }
        QGroupBox {
            font-weight: bold;
            border: 1px solid #bdc3c7;
            border-radius: 4px;
            margin-top: 8px;
            padding-top: 12px;
        }
        QGroupBox::title {
            subcontrol-origin: margin;
            left: 10px;
            padding: 0 4px;
        }
        QTextEdit, QPlainTextEdit, QLineEdit {
            border: 1px solid #dcdde1;
            border-radius: 3px;
            padding: 3px;
        }
        QTabWidget::pane {
            border: 1px solid #bdc3c7;
            border-top: none;
        }
        QStatusBar {
            background-color: #f5f6fa;
        }
    """)

    // ========== 显示窗口 ==========
    window.show()

    let result = app.exec()

    // 清理资源
    window.delete()

    return result
}
