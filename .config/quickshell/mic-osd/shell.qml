import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    property bool muted: false
    property bool firstRead: true
    property bool lastMuted: false

    Process {
        id: micReader
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim()
                const newMuted = output.includes("[MUTED]")

                if (!firstRead && newMuted !== lastMuted) {
                    muted = newMuted
                    hud.opacity = 1
                    hideTimer.restart()
                } else {
                    muted = newMuted
                }

                lastMuted = newMuted
                firstRead = false
            }
        }
    }

    Timer {
        interval: 80
        running: true
        repeat: true
        onTriggered: {
            if (!micReader.running)
                micReader.running = true
        }
    }

    Timer {
        id: hideTimer
        interval: 1200
        onTriggered: hud.opacity = 0
    }

    PanelWindow {
        anchors.bottom: true
        implicitWidth: 80
        implicitHeight: 80
        margins.bottom: 30
        color: "transparent"
        aboveWindows: true
        exclusiveZone: 0

        Rectangle {
            id: hud
            anchors.fill: parent
            radius: 22
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

            Text {
                anchors.centerIn: parent
                text: muted ? "󰍭" : "󰍬"
                color: "#E69BD0"
                font.pixelSize: 34
            }
        }
    }
}
