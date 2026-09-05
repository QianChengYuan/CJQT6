package hello_cjqt6

// ============================================================
// CJQT6 最小演示实例 - Hello CJQT6
// 创建一个窗口，显示居中对齐的 "Hello CJQT6!" 标签
// ============================================================

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

main(): Int32 {
    let app = QApplication()

    let window = QWidget()
    window.setTitle("Hello CJQT6")
    window.resize(400, 300)

    let label = QLabel()
    label.setText("Hello CJQT6!")
    label.setAlignment(Alignment.Center.value)

    let layout = QVBoxLayout()
    layout.addWidget(label.getPtr())
    window.setLayout(layout.getPtr())

    window.show()
    return app.exec()
}
