import QtQuick
import "../theme"

Item {
    id: root
    property real value: 0.65
    implicitWidth: 280
    implicitHeight: 18

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.backgroundAlt
        border.width: 1
        border.color: Theme.accent

        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: height / 2
            color: Theme.accent
        }
    }
}
