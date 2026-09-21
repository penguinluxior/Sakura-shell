import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    property real volume: 0
    property bool muted: false
    property real lastVolume: -1
    property bool firstRead: true

    Process {
        id: volumeReader
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim()
                const match = output.match(/Volume:\s+([0-9.]+)/)
                if (match) {
                    const newVolume = Math.round(Number(match[1]) * 100)
                    const newMuted = output.includes("[MUTED]")
                    if (!firstRead && (newVolume !== lastVolume || newMuted !== muted)) {
                        volume = newVolume
                        muted = newMuted
                        hud.opacity = 1
                        hideTimer.restart()
                    } else {
                        volume = newVolume
                        muted = newMuted
                    }
                    lastVolume = newVolume
                    firstRead = false
                }
            }
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: if (!volumeReader.running) volumeReader.running = true
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
        mask: Region {}

        Rectangle {
            id: hud
            anchors.fill: parent
            radius: 16
            color: "#66FFFFFF"
            border.width: 2
            border.color: "#E69BD0"
            opacity: 0

            Behavior on opacity {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }

            Row {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: muted ? "󰖁" : "󰕾"
                    color: "#E69BD0"
                    font.pixelSize: 24
                }

                Rectangle {
                    width: 120
                    height: 7
                    radius: 4
                    color: "#55FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: parent.width * Math.min(volume / 100, 1)
                        height: parent.height
                        radius: 4
                        color: "#E69BD0"
                        Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                    }
                }

                Text {
                    text: muted ? "0%" : volume + "%"
                    color: "#FFFFFF"
                    font.pixelSize: 17
                    font.bold: true
                }
            }
        }
    }
}
