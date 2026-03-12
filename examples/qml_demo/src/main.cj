package qml_demo

import CJQT6.core.*
import CJQT6.qml.*
import std.fs.*

main(): Int32 {
    // 创建应用
    let app = QApplication()
    
    // 创建 QQuickView（QML 视图窗口）
    let view = QQuickView()
    
    // 设置窗口标题
    view.setTitle("CJQT6 QML Demo")
    
    // 创建 QML 文件内容
    // 注意：QQuickView 需要以 Item 或 Rectangle 作为根元素
    let qmlPath = "/tmp/cjqt6_demo.qml"
    let qmlContent = "import QtQuick; Rectangle { width: 400; height: 300; color: \"#f5f5f5\"; Text { anchors.centerIn: parent; text: \"Hello from CJQT6!\"; font.pixelSize: 24; color: \"#333\"; } }"
    
    // 使用仓颉标准库写入 QML 文件
    File.writeTo(qmlPath, qmlContent.toArray())
    
    // 设置 QML 源文件
    view.setSource(qmlPath)
    
    // 设置大小调整模式：根元素跟随视图大小
    view.setResizeMode(ResizeMode.SizeRootObjectToView)
    
    // 显示窗口
    view.show()
    view.resize(400, 300)
    
    let result = app.exec()
    
    view.delete()
    app.delete()
    
    return result
}
