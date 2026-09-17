package CjMonitor.app

import CjMonitor.common.*
import cjqt6.core.*

// ============================================================
// 深色数据仪表盘主题
// 颜色统一取自 common/palette.cj，避免 QSS 与自绘两处色值漂移。
//
// 注意：CJQT6 的 QWidget 未封装 setObjectName（仅 QQuickItem 有），
// 因此 QSS 的 "#id 选择器" 不可用；局部样式以函数形式提供给 ui 层内联挂载。
// ============================================================

/// 全局样式表。需在 QApplication 创建之后调用 QApp.setStyleSheet 生效。
public func darkThemeQss(): String {
    let bgBase = C_BG_BASE.hex()
    let bgPanel = C_BG_PANEL.hex()
    let bgElevated = C_BG_ELEVATED.hex()
    let border = C_BORDER.hex()
    let textPrimary = C_TEXT_PRIMARY.hex()
    let textSecondary = C_TEXT_SECONDARY.hex()
    let textMuted = C_TEXT_MUTED.hex()
    let accent = C_ACCENT.hex()
    let onAccent = C_BG_BASE.hex()

    """
    /* ---------- 基础 ---------- */
    QWidget {
        background-color: ${bgBase};
        color: ${textPrimary};
        font-family: "Microsoft YaHei UI", "PingFang SC", "Noto Sans CJK SC", sans-serif;
        font-size: 12px;
    }
    QMainWindow, QDialog {
        background-color: ${bgBase};
    }

    /* ---------- 菜单栏 ---------- */
    QMenuBar {
        background-color: ${bgPanel};
        color: ${textSecondary};
        border-bottom: 1px solid ${border};
        padding: 2px 6px;
    }
    QMenuBar::item {
        background: transparent;
        padding: 6px 12px;
        border-radius: 4px;
    }
    QMenuBar::item:selected {
        background-color: ${bgElevated};
        color: ${accent};
    }
    QMenu {
        background-color: ${bgPanel};
        border: 1px solid ${border};
        padding: 4px;
    }
    QMenu::item {
        padding: 6px 22px;
        border-radius: 4px;
    }
    QMenu::item:selected {
        background-color: ${bgElevated};
        color: ${accent};
    }
    QMenu::separator {
        height: 1px;
        background: ${border};
        margin: 4px 8px;
    }

    /* ---------- 状态栏 ---------- */
    QStatusBar {
        background-color: ${bgPanel};
        color: ${textSecondary};
        border-top: 1px solid ${border};
    }
    QStatusBar::item {
        border: none;
    }

    /* ---------- 页签 ---------- */
    QTabWidget::pane {
        background-color: ${bgPanel};
        border: 1px solid ${border};
        border-radius: 8px;
        top: -1px;
    }
    QTabBar::tab {
        background-color: transparent;
        color: ${textMuted};
        padding: 8px 20px;
        margin-right: 4px;
        border: 1px solid transparent;
        border-top-left-radius: 8px;
        border-top-right-radius: 8px;
    }
    QTabBar::tab:hover {
        color: ${textPrimary};
        background-color: ${bgElevated};
    }
    QTabBar::tab:selected {
        color: ${accent};
        background-color: ${bgPanel};
        border: 1px solid ${border};
        border-bottom-color: ${bgPanel};
    }

    /* ---------- 分组框 ---------- */
    QGroupBox {
        background-color: ${bgPanel};
        border: 1px solid ${border};
        border-radius: 8px;
        margin-top: 14px;
        padding: 10px;
    }
    QGroupBox::title {
        subcontrol-origin: margin;
        left: 12px;
        padding: 0 6px;
        color: ${textSecondary};
    }

    /* ---------- 按钮 ---------- */
    QPushButton {
        background-color: ${bgElevated};
        color: ${textPrimary};
        border: 1px solid ${border};
        border-radius: 6px;
        padding: 6px 16px;
    }
    QPushButton:hover {
        border-color: ${accent};
        color: ${accent};
    }
    QPushButton:pressed {
        background-color: ${bgBase};
    }
    QPushButton:checked {
        background-color: ${accent};
        color: ${onAccent};
        border-color: ${accent};
    }
    QPushButton:disabled {
        color: ${textMuted};
        border-color: ${border};
    }

    /* ---------- 文本 ---------- */
    QLabel {
        background: transparent;
        color: ${textPrimary};
    }
    QToolTip {
        background-color: ${bgElevated};
        color: ${textPrimary};
        border: 1px solid ${accent};
        padding: 4px 8px;
    }

    /* ---------- 输入控件 ---------- */
    QComboBox, QSpinBox, QDoubleSpinBox, QLineEdit {
        background-color: ${bgElevated};
        color: ${textPrimary};
        border: 1px solid ${border};
        border-radius: 6px;
        padding: 5px 8px;
        selection-background-color: ${accent};
        selection-color: ${onAccent};
    }
    QComboBox:hover, QSpinBox:hover, QDoubleSpinBox:hover, QLineEdit:hover {
        border-color: ${textMuted};
    }
    QComboBox:focus, QSpinBox:focus, QDoubleSpinBox:focus, QLineEdit:focus {
        border-color: ${accent};
    }
    QComboBox::drop-down {
        border: none;
        width: 18px;
    }
    QComboBox QAbstractItemView {
        background-color: ${bgPanel};
        border: 1px solid ${border};
        selection-background-color: ${bgElevated};
        selection-color: ${accent};
        outline: none;
    }
    QCheckBox, QRadioButton {
        background: transparent;
        spacing: 6px;
    }

    /* ---------- 表格 ---------- */
    QTableWidget, QTableView {
        background-color: ${bgPanel};
        alternate-background-color: ${bgElevated};
        color: ${textPrimary};
        border: 1px solid ${border};
        border-radius: 8px;
        gridline-color: ${border};
        outline: none;
        selection-background-color: ${bgElevated};
        selection-color: ${accent};
    }
    QTableWidget::item, QTableView::item {
        padding: 4px 8px;
        border: none;
    }
    QHeaderView::section {
        background-color: ${bgBase};
        color: ${textSecondary};
        border: none;
        border-right: 1px solid ${border};
        border-bottom: 1px solid ${border};
        padding: 6px 8px;
    }
    QHeaderView::section:hover {
        color: ${accent};
    }
    QTableCornerButton::section {
        background-color: ${bgBase};
        border: none;
    }

    /* ---------- 滚动条 ---------- */
    QScrollBar:vertical {
        background: transparent;
        width: 10px;
        margin: 2px;
    }
    QScrollBar::handle:vertical {
        background: ${border};
        border-radius: 5px;
        min-height: 28px;
    }
    QScrollBar::handle:vertical:hover {
        background: ${textMuted};
    }
    QScrollBar:horizontal {
        background: transparent;
        height: 10px;
        margin: 2px;
    }
    QScrollBar::handle:horizontal {
        background: ${border};
        border-radius: 5px;
        min-width: 28px;
    }
    QScrollBar::handle:horizontal:hover {
        background: ${textMuted};
    }
    QScrollBar::add-line, QScrollBar::sub-line {
        height: 0;
        width: 0;
    }
    QScrollBar::add-page, QScrollBar::sub-page {
        background: transparent;
    }

    /* ---------- 分隔条 ---------- */
    QSplitter::handle {
        background-color: ${border};
    }
    QSplitter::handle:hover {
        background-color: ${accent};
    }

    /* ---------- 进度条 ---------- */
    QProgressBar {
        background-color: ${bgElevated};
        border: 1px solid ${border};
        border-radius: 6px;
        text-align: center;
        color: ${textSecondary};
    }
    QProgressBar::chunk {
        background-color: ${accent};
        border-radius: 5px;
    }

    /* ---------- 对话框按钮区 ---------- */
    QDialogButtonBox QPushButton {
        min-width: 72px;
    }

    /* ---------- 语义色工具（供 QChart 等无法内联的场合） ---------- */
    QChartView {
        background-color: ${bgPanel};
    }
    """
}

/// 应用全局主题（须在 QApplication 构造之后调用）
public func applyDarkTheme(): Unit {
    QApp.setStyleSheet(darkThemeQss())
}

// ============================================================
// 局部样式片段
// QWidget 无 setObjectName，故以函数形式提供给 ui 层 setStyleSheet 内联挂载。
// ============================================================

/// 根容器底色
public func qssRootBackground(): String {
    "background-color: ${C_BG_BASE.hex()};"
}

/// 面板卡片：与主题底色形成层次
public func qssCard(): String {
    "background-color: ${C_BG_PANEL.hex()}; border: 1px solid ${C_BORDER.hex()}; border-radius: 8px;"
}

/// 抬升面卡片
public func qssCardElevated(): String {
    "background-color: ${C_BG_ELEVATED.hex()}; border: 1px solid ${C_BORDER.hex()}; border-radius: 8px;"
}

/// 主标题
public func qssTitle(): String {
    "font-size: 20px; font-weight: 600; color: ${C_TEXT_PRIMARY.hex()};"
}

/// 副标题
public func qssSubtitle(): String {
    "font-size: 12px; color: ${C_TEXT_SECONDARY.hex()};"
}

/// 弱化文本
public func qssMuted(): String {
    "color: ${C_TEXT_MUTED.hex()};"
}

/// 数值（等宽数字，主色）
public func qssMetricValue(): String {
    "font-family: \"Consolas\", \"Cascadia Mono\", monospace; font-size: 22px; font-weight: 600; color: ${C_ACCENT.hex()};"
}

/// 数值（告警色）
public func qssMetricWarn(): String {
    "font-family: \"Consolas\", \"Cascadia Mono\", monospace; font-size: 22px; font-weight: 600; color: ${C_WARN.hex()};"
}

/// 数值（危险色）
public func qssMetricDanger(): String {
    "font-family: \"Consolas\", \"Cascadia Mono\", monospace; font-size: 22px; font-weight: 600; color: ${C_DANGER.hex()};"
}

/// 小圆点/状态标签：正常
public func qssPillOk(): String {
    "color: ${C_OK.hex()}; font-size: 11px;"
}

/// 小圆点/状态标签：主色
public func qssPillAccent(): String {
    "color: ${C_CYAN.hex()}; font-size: 11px;"
}

/// 小圆点/状态标签：警告
public func qssPillWarn(): String {
    "color: ${C_WARN.hex()}; font-size: 11px;"
}

/// 小圆点/状态标签：危险
public func qssPillDanger(): String {
    "color: ${C_DANGER.hex()}; font-size: 11px;"
}

/// 区段标题（面板内小标题）
public func qssSectionTitle(): String {
    "font-size: 13px; font-weight: 600; color: ${C_TEXT_SECONDARY.hex()};"
}
