import Quickshell
import QtQuick

ShellRoot {
    PanelWindow {
        anchors.right: true
        anchors.bottom: true
        implicitWidth: 1
        implicitHeight: 1
        margins.right: 0
        margins.bottom: 0
        color: "transparent"
        exclusiveZone: 0

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: function() {
                console.log("CORNER TRIGGER")
            }
        }
    }
}
