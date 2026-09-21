import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    property real brightness: 0
    property real lastBrightness: -1
    property bool firstRead: true

    Process {
        id: brightnessReader
        command: ["sh", "-c", "brightnessctl get; brightnessctl max"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split(/\s+/)

                if (lines.length >= 2) {
                    const current = Number(lines[0])
                    const maximum = Number(lines[1])
                    const newBrightness = Math.round((current / maximum) * 100)

                    if (!firstRead && newBrightness !== lastBrightness) {
                        brightness = newBrightness
                        hud.opacity = 1
                        hideTimer.restart()
                    } else {
                        brightness = newBrightness
                    }

                    lastBrightness = newBrightness
                    firstRead = false
                }
            }
        }
    }

    Timer {
        interval: 80
        running: true
        repeat: true
        onTriggered: {
            if (!brightnessReader.running)
                brightnessReader.running = true
        }
    }

    Timer {
        id: hideTimer
        interval: 1200
        onTriggered: hud.opacity = 0
    }

    PanelWindow {
        anchors.top: true
        anchors.right: true
        margins.top: 70
        margins.right: 24
        implicitWidth: 230
        implicitHeight: 58
        color: "transparent"
        aboveWindows: true
        exclusiveZone: 0

        Rectangle {
            id: hud
            anchors.fill: parent
            radius: 16
            color: "#66FFFFFF"
            border.width: 2
            border.color: "#E69BD0"
            opacity: 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: "󰃠"
                    color: "#E69BD0"
                    font.pixelSize: 24
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 120
                    height: 7
                    radius: 4
                    color: "#55FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: parent.width * Math.min(brightness / 100, 1)
                        height: parent.height
                        radius: 4
                        color: "#E69BD0"

                        Behavior on width {
                            NumberAnimation {
                                duration: 120
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                Text {
                    text: brightness + "%"
                    color: "#FFFFFF"
                    font.pixelSize: 17
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
