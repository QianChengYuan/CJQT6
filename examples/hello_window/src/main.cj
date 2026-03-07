package hello_window

import CJQT6.core.*

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    
    window.setTitle("Hello CJQT6")
    window.resize(400, 300)
    window.show()
    
    let result = app.exec()
    
    window.delete()
    app.delete()
    
    return result
}
