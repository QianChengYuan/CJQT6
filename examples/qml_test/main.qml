import QtQuick

Window {
    id: root
    width: 640
    height: 480
    visible: true
    color: "#2b579a"
    title: "CJQT6 QML Demo"

    Text {
        anchors.centerIn: parent
        text: "Hello QML!"
        font.pixelSize: 48
        font.bold: true
        color: "white"
    }

    Rectangle {
        id: button
        width: 150
        height: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        color: mouseArea.pressed ? "#1e3a5f" : mouseArea.containsMouse ? "#3c78d8" : "#2b579a"
        border.color: "white"
        border.width: 2
        radius: 8

        Text {
            anchors.centerIn: parent
            text: "Click Me"
            color: "white"
            font.pixelSize: 18
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                label.text = "Clicked " + counter.value + " times!"
                counter.value++
            }
        }
    }

    Text {
        id: label
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: button.top
        anchors.bottomMargin: 20
        text: "Click the button below"
        color: "white"
        font.pixelSize: 20
    }

    QtObject {
        id: counter
        property int value: 1
    }
}
