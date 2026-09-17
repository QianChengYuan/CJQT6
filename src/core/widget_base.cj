package cjqt6.core

// ============================================================
// 控件通用能力接口
//
// 背景（见 docs/internal/cjmonitor-findings.md P0-1）：
// CJQT6 的控件类此前统一只实现 QtResource（仅 isClosed/close/getPtr/isValid/checkValid），
// 通用能力（样式 / 尺寸 / 可见性）由每个类各自复制一份，导致覆盖不齐——
// 例如 setVisible 全库仅 9 处，setMinimumWidth / setFixedWidth / setFixedHeight 全库 0 处。
//
// 两层结构（对应两类控件的历史形态）：
//   QtWidgetCore —— 只要实现者提供 getPtr()，即获得 11 个通用能力的**默认实现**
//                   （供未实现 QtResource 的老控件直接采纳）
//   QtWidget     —— QtWidgetCore + QtResource，即「资源管理 + 通用能力」的完整控件接口
//
// 默认实现全部基于 getPtr() 调用 native 既有的 qWidget* 导出，因此实现类无需重复编码；
// 类内若已有同名同签名方法，则以类实现为准（自动覆盖默认实现），既有行为不变。
//
// 安全前提：实现者的 getPtr() 必须指向 **QWidget 派生对象**。
// 非 QWidget 的指针持有者（如 QProcess / QTimer / QUiLoader / QSystemTrayIcon /
// QSqlDatabase / QAbstractItemModel / QGraphicsScene / QAction 等）**不得**实现本接口，
// 否则默认实现会产生未定义行为。
// ============================================================

/// 控件通用能力（默认实现）：实现者只需提供 `getPtr()`
public interface QtWidgetCore {
    /// 原生指针（由实现者提供，必须指向 QWidget 派生对象）
    func getPtr(): Int64

    /// 设置样式表
    func setStyleSheet(styleSheet: String): Unit {
        withCString(styleSheet) {c => unsafe { qWidgetSetStyleSheet(getPtr(), c) }}
    }

    /// 获取样式表
    func styleSheet(): String {
        unsafe {
            let cstr = qWidgetStyleSheet(getPtr())
            let result = cstr.toString()
            freeBridgeString(cstr)
            return result
        }
    }

    /// 设置 objectName（QSS 的 `#id` 选择器依赖它）
    func setObjectName(name: String): Unit {
        withCString(name) {c => unsafe { qWidgetSetObjectName(getPtr(), c) }}
    }

    /// 设置最小尺寸
    func setMinimumSize(width: Int32, height: Int32): Unit {
        unsafe {
            qWidgetSetMinimumSize(getPtr(), width, height)
        }
    }

    /// 设置最大尺寸
    func setMaximumSize(width: Int32, height: Int32): Unit {
        unsafe {
            qWidgetSetMaximumSize(getPtr(), width, height)
        }
    }

    /// 设置可见性
    func setVisible(visible: Bool): Unit {
        unsafe {
            qWidgetSetVisible(getPtr(), if (visible) {
                1
            } else {
                0
            })
        }
    }

    /// 是否可见
    func isVisible(): Bool {
        unsafe {
            return qWidgetIsVisible(getPtr()) == 1
        }
    }

    /// 设置启用状态
    func setEnabled(enabled: Bool): Unit {
        unsafe {
            qWidgetSetEnabled(getPtr(), if (enabled) {
                1
            } else {
                0
            })
        }
    }

    /// 是否启用
    func isEnabled(): Bool {
        unsafe {
            return qWidgetIsEnabled(getPtr()) == 1
        }
    }

    /// 当前宽度（像素）
    func width(): Int32 {
        unsafe {
            qWidgetWidth(getPtr())
        }
    }

    /// 当前高度（像素）
    func height(): Int32 {
        unsafe {
            qWidgetHeight(getPtr())
        }
    }
}

/// 完整控件接口：资源管理（QtResource）+ 通用能力（QtWidgetCore）
public interface QtWidget <: QtResource & QtWidgetCore {
}
