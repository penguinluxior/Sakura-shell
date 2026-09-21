import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls

ShellRoot {
    property bool passwordMode: false
    property string selectedSsid: ""
    property string password: ""
    property string statusText: ""
    property var networks: []

    Process {
        id: scanner
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY", "device", "wifi", "list"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n")
                const result = []

                for (const line of lines) {
                    if (!line.trim()) continue

                    const parts = line.split(":")
                    if (parts.length < 3) continue

                    const ssid = parts[0]
                    const signal = Number(parts[1]) || 0
                    const security = parts.slice(2).join(":")

                    if (ssid && !result.some(n => n.ssid === ssid)) {
                        result.push({ ssid, signal, security })
                    }
                }

                result.sort((a, b) => b.signal - a.signal)
                networks = result
                statusText = ""
            }
        }
    }

    Process {
        id: connector
        command: ["true"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.includes("successfully activated")) {
                    statusText = "Conectado ✓"
                    password = ""
                    passwordMode = false
                    passwordField.text = ""
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim())
                    statusText = "No se pudo conectar"
            }
        }
    }

    function scan() {
        statusText = "Buscando redes..."
        if (!scanner.running)
            scanner.running = true
    }

    function connectNetwork() {
        if (!selectedSsid || !password) {
            statusText = "Escribe una contraseña"
            return
        }

        statusText = "Conectando..."
        connector.command = ["nmcli", "device", "wifi", "connect", selectedSsid, "password", password]
        connector.running = true
    }

    PanelWindow {
        anchors.top: true
        anchors.right: true
        margins.top: 60
        margins.right: 24
        implicitWidth: 360
        implicitHeight: passwordMode ? 300 : 430
        color: "transparent"
        aboveWindows: true
        exclusiveZone: 0

        Rectangle {
            anchors.fill: parent
            radius: 24
            color: "#DD101010"
            border.width: 2
            border.color: "#E69BD0"

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                Row {
                    spacing: 10

                    Text {
                        text: "󰖩"
                        color: "#E69BD0"
                        font.pixelSize: 28
                    }

                    Text {
                        text: passwordMode ? selectedSsid : "Wi-Fi"
                        color: "#FFFFFF"
                        font.pixelSize: 21
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#44FFFFFF"
                }

                Column {
                    visible: !passwordMode
                    width: parent.width
                    spacing: 8

                    Text {
                        visible: networks.length === 0
                        text: statusText || "Buscando redes..."
                        color: "#AAAAAA"
                        font.pixelSize: 15
                    }

                    Repeater {
                        model: networks

                        Rectangle {
                            width: parent.width
                            height: 52
                            radius: 14
                            color: mouse.containsMouse ? "#35E69BD0" : "#22FFFFFF"

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                spacing: 10

                                Text {
                                    text: modelData.security ? "󰌾" : "󰤨"
                                    color: "#E69BD0"
                                    font.pixelSize: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData.ssid
                                    color: "#FFFFFF"
                                    font.pixelSize: 15
                                    elide: Text.ElideRight
                                    width: parent.width - 105
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData.signal + "%"
                                    color: "#BBBBBB"
                                    font.pixelSize: 13
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    selectedSsid = modelData.ssid
                                    password = ""

                                    if (modelData.security) {
                                        passwordMode = true
                                        statusText = ""
                                    } else {
                                        password = " "
                                        connectNetwork()
                                    }
                                }
                            }
                        }
                    }
                }

                Column {
                    visible: passwordMode
                    width: parent.width
                    spacing: 12

                    Text {
                        text: "Contraseña"
                        color: "#CCCCCC"
                        font.pixelSize: 14
                    }

                    TextField {
                        id: passwordField
                        width: parent.width
                        height: 48
                        echoMode: TextInput.Password
                        placeholderText: "Escribe la contraseña..."
                        color: "#FFFFFF"
                        placeholderTextColor: "#888888"
                        font.pixelSize: 15
                        background: Rectangle {
                            radius: 18
                            color: "#22FFFFFF"
                            border.width: 1
                            border.color: "#66E69BD0"
                        }
                        onTextChanged: password = text
                    }

                    Button {
                        width: parent.width
                        height: 48
                        text: "CONECTAR"
                        onClicked: connectNetwork()
                        background: Rectangle {
                            radius: 24
                            color: parent.down ? "#C982B5" : "#E69BD0"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#151015"
                            font.pixelSize: 15
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        width: parent.width
                        height: 42
                        text: "←  Volver"
                        onClicked: {
                            passwordMode = false
                            password = ""
                            statusText = ""
                            passwordField.text = ""
                        }
                        background: Rectangle {
                            radius: 21
                            color: parent.down ? "#33E69BD0" : "#22FFFFFF"
                            border.width: 1
                            border.color: "#88E69BD0"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#FFFFFF"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Text {
                        text: statusText
                        color: statusText.includes("✓") ? "#9BE69B" : "#AAAAAA"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                    }
                }
            }
        }
    }

    Component.onCompleted: scan()
}
