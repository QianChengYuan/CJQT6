package qml_demo

import CJQT6.core.*
import CJQT6.qml.*

// LibC system 函数
foreign func system(cmd: CString): Int32

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
    let qmlContent = "import QtQuick; Rectangle { width: 400; height: 300; color: \"#f5f5f5\"; Text { anchors.centerIn: parent; text: \"Hello from CJQT6!\"; font.pixelSize: 24; color: \"#333\"; } Rectangle { anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottomMargin: 20; width: 120; height: 40; color: mouseArea.pressed ? \"#388E3C\" : \"#4CAF50\"; radius: 5; Text { anchors.centerIn: parent; text: \"Quit\"; color: \"white\"; font.pixelSize: 14; } MouseArea { id: mouseArea; anchors.fill: parent; onClicked: Qt.quit(); } } }"
    
    // 写入临时 QML 文件
    unsafe {
        let cmd = "echo '" + qmlContent + "' > " + qmlPath
        let cmdCStr = LibC.mallocCString(cmd)
        system(cmdCStr)
        LibC.free(cmdCStr)
    }
    
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