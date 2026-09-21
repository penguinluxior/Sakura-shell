import Quickshell
import Quickshell.Hyprland
import QtQuick

ShellRoot {
    property int currentWorkspace: Hyprland.focusedWorkspace?.id ?? 1

    Connections {
        target: Hyprland

        function onFocusedWorkspaceChanged() {
            hideTimer.stop()
            hud.opacity = 1
            hideTimer.start()
        }
    }

    Timer {
        id: hideTimer
        interval: 800
        onTriggered: {
            hud.y = -70
            hud.opacity = 0
        }
    }

    PanelWindow {
        anchors.top: true
        implicitWidth: 430
        implicitHeight: 54
        margins.top: -12
        color: "transparent"
        aboveWindows: true
        exclusiveZone: 0

        Rectangle {
            id: hud
            width: 430
            height: 54
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 16
            color: "#66FFFFFF"
            border.width: 2
            border.color: "#E69BD0"

            Behavior on y {
                NumberAnimation {
                    duration: 280
                    easing.type: Easing.InOutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InCubic
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: 16

                Repeater {
                    model: 9

                    Text {
                        required property int index
                        text: String(index + 1)
                        color: (index + 1) === currentWorkspace ? "#E69BD0" : "#FFFFFF"
                        opacity: (index + 1) === currentWorkspace ? 1.0 : 0.65
                        font.pixelSize: 20
                        font.bold: (index + 1) === currentWorkspace
                    }
                }
            }
        }
    }
}
