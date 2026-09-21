import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

ShellRoot {
    property string currentTime: ""
    property int battery: 0
    property string batteryStatus: ""
    property bool wifiConnected: false

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
                const output = this.text.trim()
                wifiConnected = output.includes("100")
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

            MouseArea {
                width: 24
                height: 28
                anchors.verticalCenter: parent.verticalCenter
                cursorShape: Qt.PointingHandCursor

                Text {
                    anchors.centerIn: parent
                    text: "󰃭"
                    color: "#E69BD0"
                    font.pixelSize: 20
                }

                onClicked: {
                    Quickshell.execDetached(["sh", "-c", "~/.local/bin/toggle-calendar"])
                }
            }

            Text {
                text: wifiConnected ? "󰤨" : "󰤭"
                color: "#E69BD0"
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: batteryStatus === "Charging" ? "󰂄" : "󰁹"
                color: "#E69BD0"
                font.pixelSize: 19
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: battery + "%"
                color: "#FFFFFF"
                font.pixelSize: 16
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
