package delegate_demo

import cjqt6.core.*
import cjqt6.views.*
import cjqt6.paint.*

// ============================================================
// QStyledItemDelegate 绘制实测
// ------------------------------------------------------------
// 目标：验证自绘委托的 paint/sizeHint 回调在视图渲染时被真实调用，
//       且绘制上下文（painter 指针 / rect / state / row / col）透传正确。
// 运行：QT_QPA_PLATFORM=offscreen cjpm run
// 判据：gPaintCount > 0 且 gSizeHintCount > 0 表示自绘生效。
// ============================================================

// CFunc 回调不能捕获局部变量，用全局变量共享状态（库内信号回调的既定模式）
var gDelegate: ?QStyledItemDelegate = None
var gPaintCount: Int64 = 0
var gSizeHintCount: Int64 = 0

// 自绘回调：统计调用次数，并在每个单元格左下角绘制 "R{行}C{列}" 标识
let gPaintCb: CFunc<(Int64) -> Unit> = { _ =>
    if (let Some(d) <- gDelegate) {
        gPaintCount += 1
        // 借用 painter 指针（fromPtr 不拥有所有权，勿 close/delete）
        let painter = QPainter.fromPtr(d.getPainterPtr())
        let x = d.getRectX()
        let y = d.getRectY()
        let h = d.getRectH()
        let row = d.getRow()
        let col = d.getCol()
        // 在单元格底部偏上位置绘制行列标识
        painter.drawText(x + 4, y + h - 6, "R${row}C${col}")
    }
}

// 尺寸回调：统一每格 90x26，统计调用次数
let gSizeCb: CFunc<(Int64) -> Int64> = { _ =>
    gSizeHintCount += 1
    makeSizeHintValue(90, 26)
}

main() {
    println("=== QStyledItemDelegate 绘制实测 ===")
    let app = QApplication()

    // 1) 建模型：4 行 3 列，填充测试数据
    let model = QStandardItemModel(4, 3)
    for (r in 0..4) {
        for (c in 0..3) {
            model.setItem(Int32(r), Int32(c), "数据-${r}-${c}")
        }
    }
    model.setHorizontalHeaderLabel(0, "列A")
    model.setHorizontalHeaderLabel(1, "列B")
    model.setHorizontalHeaderLabel(2, "列C")

    // 2) 建委托并注册 paint/sizeHint 回调
    let delegate = QStyledItemDelegate()
    delegate.setOnPaint(gPaintCb)
    delegate.setOnSizeHint(gSizeCb)
    gDelegate = delegate

    // 3) 建视图、挂载委托、显示
    let view = QTableView()
    view.setModel(model)
    view.setItemDelegate(delegate)
    view.resize(420, 320)
    // 强制向 delegate 询问每格尺寸，触发 sizeHint 回调
    view.resizeColumnsToContents()
    view.resizeRowsToContents()
    view.show()

    // 4) 定时退出：让事件循环跑 300ms，触发 paintEvent（offscreen 平台离屏渲染）
    let timer = QTimer()
    timer.setInterval(300)
    timer.setOnTimeout({ => QApp.quit() })
    timer.start()

    app.exec()

    // 5) 汇报结果
    println("paint    回调触发次数: ${gPaintCount}")
    println("sizeHint 回调触发次数: ${gSizeHintCount}")
    if (gPaintCount > 0 && gSizeHintCount > 0) {
        println("[OK] 自绘委托生效：paint 与 sizeHint 回调均被视图调用")
    } else if (gPaintCount > 0) {
        println("[WARN] paint 回调生效，但 sizeHint 回调未触发")
    } else {
        println("[FAIL] 自绘委托未生效：paint 回调从未被调用")
    }

    // 6) 清理：delegate 已挂载，close 只标记不删除；view/model 靠 app.delete 级联
    timer.stop()
    timer.close()
    delegate.close()
    app.delete()
}