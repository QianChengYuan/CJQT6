package my_qy_app

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

main() {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("Hello CJQT6")
    window.resize(400, 300)

    let label = QLabel()
    label.setText("欢迎使用 CJQT6!")
    label.setAlignment(Alignment.Center.value)

    let layout = QVBoxLayout()
    layout.addWidget(label.getPtr())
    window.setLayout(layout.getPtr())

    window.show()
    app.exec()
}

