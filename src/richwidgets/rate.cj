package cjqt6.richwidgets

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*
import std.collection.ArrayList

// ============================================================
// Rate - 评分
// 纯仓颉组合层：N 个 QPushButton 星星，点击设分
// ============================================================

/// 评分：星级评分控件，点击星星设分，支持回调
public class Rate <: QtResource {
    private let group: QGroupBox
    private let layout: QHBoxLayout
    private let stars: ArrayList<QPushButton>
    private var rating: Int32 = 0
    private let maxStars: Int32
    private var cb: ?(() -> Unit) = None

    /// 创建评分（指定最大星数，默认 5）
    public init(count: Int32) {
        group = QGroupBox()
        group.setFlat(true)
        layout = QHBoxLayout()
        stars = ArrayList<QPushButton>()
        maxStars = if (count < 1) { 1 } else { count }
        for (i in 0..maxStars) {
            let star = QPushButton()
            star.setText("☆")
            // 闭包捕获 this 与循环变量 i（均为 let），调成员方法 setRating
            star.setOnClickCapture({ => setRating(i + 1) })
            layout.addWidget(star.getPtr())
            stars.add(star)
        }
        rating = 0
        updateStars()
        group.setLayout(layout.getPtr())
    }

    /// 创建评分（默认 5 星）
    public init() {
        group = QGroupBox()
        group.setFlat(true)
        layout = QHBoxLayout()
        stars = ArrayList<QPushButton>()
        maxStars = 5
        for (i in 0..maxStars) {
            let star = QPushButton()
            star.setText("☆")
            star.setOnClickCapture({ => setRating(i + 1) })
            layout.addWidget(star.getPtr())
            stars.add(star)
        }
        rating = 0
        updateStars()
        group.setLayout(layout.getPtr())
    }

    /// 设置评分（越界自动钳制）
    public func setRating(r: Int32): Unit {
        rating = if (r < 0) {
            0
        } else if (r > maxStars) {
            maxStars
        } else {
            r
        }
        updateStars()
        if (let Some(f) <- cb) {
            f()
        }
    }

    /// 获取当前评分
    public func getRating(): Int32 {
        rating
    }

    /// 获取最大星数
    public func maxCount(): Int32 {
        maxStars
    }

    /// 评分变化回调（可捕获局部变量）
    public func setOnRatingChanged(callback: () -> Unit): Unit {
        cb = Some(callback)
    }

    // 内部：更新星星显示
    private func updateStars(): Unit {
        for (i in 0..stars.size) {
            let star = stars[i]
            if (i < Int64(rating)) {
                star.setText("★")
                star.setStyleSheet("color:#fadb14; border:none;")
            } else {
                star.setText("☆")
                star.setStyleSheet("color:#d9d9d9; border:none;")
            }
        }
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