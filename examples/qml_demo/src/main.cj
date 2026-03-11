package qml_demo

import CJQT6.core.*
import CJQT6.qml.*

main(): Int32 {
    // QML 应用需要 QGuiApplication，但这里先用 QApplication
    let app = QApplication()
    
    // 使用 QQmlApplicationEngine 加载 QML
    let engine = QQmlApplicationEngine()
    
    // 加载内联 QML
    let qmlCode = """
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "CJQT6 QML Demo"
    
    Column {
        anchors.centerIn: parent
        spacing: 20
        
        Text {
            id: title
            text: "Hello QML!"
            font.pixelSize: 28
            color: "#333333"
        }
        
        Text {
            text: "CJQT6 + Qt Quick"
            font.pixelSize: 16
            color: "#666666"
        }
        
        Button {
            text: "Click Me"
            onClicked: {
                title.text = "Button Clicked!"
            }
        }
    }
}
"""
    
    engine.loadData(qmlCode)
    
    let result = app.exec()
    
    engine.delete()
    app.delete()
    
    return result
}
