package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*

// ============================================================
// Pagination - 分页栏
// 纯仓颉组合层：上一页按钮 + 页码标签 + 下一页按钮
// ============================================================

/// 分页栏：上一页/页码/下一页，支持翻页回调
public class Pagination <: QtResource {
    private let group: QGroupBox
    private let layout: QHBoxLayout
    private let prevBtn: QPushButton
    private let infoLabel: QLabel
    private let nextBtn: QPushButton
    private var currentPage: Int32 = 1
    private var totalPages: Int32 = 1
    private var pageChangedCb: ?(() -> Unit) = None
    private var registered: Bool = false

    /// 创建分页栏（默认 1/1）
    public init() {
        group = QGroupBox()
        group.setFlat(true)
        prevBtn = QPushButton()
        prevBtn.setText("上一页")
        infoLabel = QLabel()
        infoLabel.setText("1/1")
        nextBtn = QPushButton()
        nextBtn.setText("下一页")
        layout = QHBoxLayout()
        layout.addWidget(prevBtn.getPtr())
        layout.addWidget(infoLabel.getPtr())
        layout.addWidget(nextBtn.getPtr())
        group.setLayout(layout.getPtr())
    }

    /// 设置总页数
    public func setTotalPages(total: Int32): Unit {
        totalPages = if (total < 1) {
            1
        } else {
            total
        }
        if (currentPage > totalPages) {
            currentPage = totalPages
        }
        updateDisplay()
    }

    /// 跳转到指定页（越界则忽略）
    public func setCurrentPage(page: Int32): Unit {
        goToPage(page)
    }

    /// 获取当前页码
    public func getCurrentPage(): Int32 {
        currentPage
    }

    /// 获取总页数
    public func getTotalPages(): Int32 {
        totalPages
    }

    /// 翻页回调（页码变化时触发，回调内用 getCurrentPage() 读取新页码，可捕获局部变量）
    public func setOnPageChanged(callback: () -> Unit): Unit {
        pageChangedCb = Some(callback)
        if (!registered) {
            prevBtn.setOnClickCapture({=> goToPage(currentPage - 1)})
            nextBtn.setOnClickCapture({=> goToPage(currentPage + 1)})
            registered = true
        }
    }

    // 内部：跳转到指定页
    private func goToPage(page: Int32): Unit {
        if (page < 1 || page > totalPages) {
            return
        }
        currentPage = page
        updateDisplay()
        if (let Some(cb) <- pageChangedCb) {
            cb()
        }
    }

    // 内部：更新页码显示
    private func updateDisplay(): Unit {
        infoLabel.setText("${currentPage}/${totalPages}")
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
