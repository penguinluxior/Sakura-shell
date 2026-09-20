import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls

ShellRoot {
    property bool passwordMode: false
    property bool showPassword: false
    property string selectedSsid: ""
    property string connectedSsid: ""
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
        id: connectionChecker
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID", "device", "wifi"]

        stdout: StdioCollector {
            onStreamFinished: {
                connectedSsid = ""
                const lines = this.text.trim().split("\n")
                for (const line of lines) {
                    const parts = line.split(":")
                    if (parts[0] === "yes" && parts[1]) {
                        connectedSsid = parts.slice(1).join(":")
                        break
                    }
                }
            }
        }
    }

    Process {
        id: connector
        command: ["true"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.includes("successfully activated")) {
                    statusText = "Conectado. Comprobando Internet..."
                    password = ""
                    passwordMode = false
                    showPassword = false
                    passwordField.text = ""
                    connectionChecker.running = true
                    internetChecker.running = true
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

    Process {
        id: internetChecker
        command: ["nmcli", "-t", "-f", "CONNECTIVITY", "general"]

        stdout: StdioCollector {
            onStreamFinished: {
                const result = this.text.trim()
                if (result === "full")
                    statusText = "Conectado ✓ Internet ✓"
                else if (result === "limited")
                    statusText = "Wi-Fi conectado, Internet limitada"
                else
                    statusText = "Wi-Fi conectado, sin Internet"
                connectionChecker.running = true
            }
        }
    }

    function scan() {
        statusText = "Buscando redes..."
        if (!scanner.running)
            scanner.running = true
        if (!connectionChecker.running)
            connectionChecker.running = true
    }

    function connectNetwork() {
        if (!selectedSsid || !password) {
            statusText = "Escribe una contraseña"
            return
        }

        statusText = "Conectando a " + selectedSsid + "..."
        connector.command = ["nmcli", "device", "wifi", "connect", selectedSsid, "password", password]
        connector.running = true
    }

    PanelWindow {
        anchors.top: true
        anchors.right: true
        margins.top: 60
        margins.right: 24
        implicitWidth: 360
        implicitHeight: passwordMode ? 340 : 430
        color: "transparent"
        aboveWindows: true
        focusable: true
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

                Text {
                    visible: !passwordMode
                    text: connectedSsid ? "Conectado a: " + connectedSsid : "No conectado"
                    color: connectedSsid ? "#9BE69B" : "#AAAAAA"
                    font.pixelSize: 14
                    elide: Text.ElideRight
                    width: parent.width
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
                                        showPassword = false
                                        statusText = ""
                                        Qt.callLater(function() { passwordField.forceActiveFocus() })
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
                    spacing: 10

                    Text {
                        text: "Contraseña"
                        color: "#CCCCCC"
                        font.pixelSize: 14
                    }

                    TextField {
                        id: passwordField
                        width: parent.width
                        height: 48
                        focus: passwordMode
                        activeFocusOnPress: true
                        echoMode: showPassword ? TextInput.Normal : TextInput.Password
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

                    CheckBox {
                        id: showPasswordBox
                        text: "Mostrar contraseña"
                        checked: showPassword
                        onCheckedChanged: showPassword = checked
                        contentItem: Text {
                            text: showPasswordBox.text
                            color: "#CCCCCC"
                            font.pixelSize: 14
                            leftPadding: showPasswordBox.indicator.width + 8
                            verticalAlignment: Text.AlignVCenter
                        }
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
                            showPassword = false
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
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }

    Component.onCompleted: scan()
}
