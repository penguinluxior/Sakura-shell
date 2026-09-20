import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

ShellRoot {
    property string currentTime: ""
    property int battery: 0
    property string batteryStatus: ""
    property bool wifiConnected: false

    property real volume: 0
    property bool volumeMuted: false
    property real lastVolume: -1
    property bool firstVolumeRead: true

    property real brightness: 0
    property real lastBrightness: -1
    property bool firstBrightnessRead: true

    property bool micMuted: false
    property bool firstMicRead: true
    property bool lastMicMuted: false

    Process {
        id: timeReader
        command: ["date", "+%H:%M"]
        stdout: StdioCollector {
            onStreamFinished: currentTime = this.text.trim()
        }
    }

    Process {
        id: batteryReader
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        stdout: StdioCollector {
            onStreamFinished: battery = Number(this.text.trim())
        }
    }

    Process {
        id: statusReader
        command: ["cat", "/sys/class/power_supply/BAT0/status"]
        stdout: StdioCollector {
            onStreamFinished: batteryStatus = this.text.trim()
        }
    }

    Process {
        id: wifiReader
        command: ["nmcli", "-t", "-f", "GENERAL.STATE", "device", "show", "wlan0"]
        stdout: StdioCollector {
            onStreamFinished: {
                wifiConnected = this.text.trim().includes("100")
            }
        }
    }

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
                    if (!firstVolumeRead && (newVolume !== lastVolume || newMuted !== volumeMuted)) {
                        volume = newVolume
                        volumeMuted = newMuted
                        volumeHud.opacity = 1
                        volumeHide.restart()
                    } else {
                        volume = newVolume
                        volumeMuted = newMuted
                    }
                    lastVolume = newVolume
                    firstVolumeRead = false
                }
            }
        }
    }

    Process {
        id: brightnessReader
        command: ["sh", "-c", "brightnessctl get; brightnessctl max"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split(/\s+/)
                if (lines.length >= 2) {
                    const newBrightness = Math.round((Number(lines[0]) / Number(lines[1])) * 100)
                    if (!firstBrightnessRead && newBrightness !== lastBrightness) {
                        brightness = newBrightness
                        brightnessHud.opacity = 1
                        brightnessHide.restart()
                    } else {
                        brightness = newBrightness
                    }
                    lastBrightness = newBrightness
                    firstBrightnessRead = false
                }
            }
        }
    }

    Process {
        id: micReader
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const newMuted = this.text.trim().includes("[MUTED]")
                if (!firstMicRead && newMuted !== lastMicMuted) {
                    micMuted = newMuted
                    micHud.opacity = 1
                    micHide.restart()
                } else {
                    micMuted = newMuted
                }
                lastMicMuted = newMuted
                firstMicRead = false
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (!timeReader.running) timeReader.running = true
            if (!batteryReader.running) batteryReader.running = true
            if (!statusReader.running) statusReader.running = true
            if (!wifiReader.running) wifiReader.running = true
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            if (!volumeReader.running) volumeReader.running = true
        }
    }

    Timer {
        interval: 80
        running: true
        repeat: true
        onTriggered: {
            if (!brightnessReader.running) brightnessReader.running = true
            if (!micReader.running) micReader.running = true
        }
    }

    Timer { id: volumeHide; interval: 1200; onTriggered: volumeHud.opacity = 0 }
    Timer { id: brightnessHide; interval: 1200; onTriggered: brightnessHud.opacity = 0 }
    Timer { id: micHide; interval: 1200; onTriggered: micHud.opacity = 0 }

    PanelWindow {
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 40
        color: "transparent"
        aboveWindows: true
        exclusiveZone: 40

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            text: currentTime
            color: "#FFFFFF"
            font.pixelSize: 17
            font.bold: true
        }

        Row {
            anchors.centerIn: parent
            spacing: 5

            Repeater {
                model: 9

                Rectangle {
                    required property int index
                    width: 30
                    height: 28
                    radius: 8
                    color: (index + 1) === (Hyprland.focusedWorkspace?.id ?? 1) ? "#E69BD0" : "#55FFFFFF"
                    border.width: 1
                    border.color: "#E69BD0"

                    Text {
                        anchors.centerIn: parent
                        text: String(index + 1)
                        color: (index + 1) === (Hyprland.focusedWorkspace?.id ?? 1) ? "#000000" : "#FFFFFF"
                        font.pixelSize: 15
                        font.bold: true
                    }
                }
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 9

            Text {
                text: wifiConnected ? "󰤨" : "󰤭"
                color: "#E69BD0"
                font.pixelSize: 20
            }

            Text {
                text: batteryStatus === "Charging" ? "󰂄" : "󰁹"
                color: "#E69BD0"
                font.pixelSize: 19
            }

            Text {
                text: battery + "%"
                color: "#FFFFFF"
                font.pixelSize: 16
                font.bold: true
            }
        }
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
            id: volumeHud
            width: 230
            height: 58
            anchors.top: parent.top
            anchors.left: parent.left
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
                    text: volumeMuted ? "󰖁" : "󰕾"
                    color: "#E69BD0"
                    font.pixelSize: 24
                }

                Rectangle {
                    width: 120
                    height: 7
                    radius: 4
                    color: "#55FFFFFF"

                    Rectangle {
                        width: parent.width * Math.min(volume / 100, 1)
                        height: parent.height
                        radius: 4
                        color: "#E69BD0"
                    }
                }

                Text {
                    text: volumeMuted ? "0%" : volume + "%"
                    color: "#FFFFFF"
                    font.pixelSize: 17
                    font.bold: true
                }
            }
        }
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
            id: brightnessHud
            width: 230
            height: 58
            anchors.top: parent.top
            anchors.left: parent.left
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
                    text: "󰃠"
                    color: "#E69BD0"
                    font.pixelSize: 24
                }

                Rectangle {
                    width: 120
                    height: 7
                    radius: 4
                    color: "#55FFFFFF"

                    Rectangle {
                        width: parent.width * Math.min(brightness / 100, 1)
                        height: parent.height
                        radius: 4
                        color: "#E69BD0"
                    }
                }

                Text {
                    text: brightness + "%"
                    color: "#FFFFFF"
                    font.pixelSize: 17
                    font.bold: true
                }
            }
        }
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
            id: micHud
            width: 230
            height: 58
            anchors.top: parent.top
            anchors.left: parent.left
            radius: 22
            color: "#66FFFFFF"
            border.width: 2
            border.color: "#E69BD0"
            opacity: 0

            Behavior on opacity {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }

            Text {
                anchors.centerIn: parent
                text: micMuted ? "󰍭" : "󰍬"
                color: "#E69BD0"
                font.pixelSize: 34
            }
        }
    }
}
