import Quickshell
import QtQuick
import QtQuick.Controls

ShellRoot {
    property int page: 0
    property string discordLink: "PON_AQUI_TU_LINK_DE_DISCORD"

    PanelWindow {
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        color: "transparent"
        aboveWindows: true
        focusable: true

        Rectangle {
            anchors.centerIn: parent
            width: 620
            height: 430
            radius: 30
            color: "#E6101010"
            border.width: 2
            border.color: "#E69BD0"

            Column {
                anchors.fill: parent
                anchors.margins: 35
                spacing: 18

                Text {
                    width: parent.width
                    text: page === 0 ? "🌸 BIENVENIDO A SAKURA SHELL" : page === 1 ? "⌨️ ATAJOS" : "🌸"
                    color: "#FFFFFF"
                    font.family: "Fredoka"
                    font.pixelSize: page === 2 ? 34 : 25
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Item {
                    width: parent.width
                    height: 250

                    Text {
                        anchors.centerIn: parent
                        width: parent.width - 20
                        text: page === 0 ? "Este proyecto fue creado por Penguinluxior.\n\nDisfruta esta shell. Pronto habrá actualizaciones y nuevas funciones.\n\nSi encuentras algún error, avísame por Discord." : page === 1 ? "SUPER + SPACE   →   Launcher\n\nSUPER + N       →   Wi-Fi\n\n󰃭               →   Calendario\n\nLos atajos pueden cambiar y recibir nuevas funciones." : "DISFRÚTALO ;3\n\nSakura Shell\nby Penguinluxior"
                        color: "#FFFFFF"
                        font.family: "Fredoka"
                        font.pixelSize: page === 2 ? 30 : 18
                        lineHeight: 1.4
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Button {
                        visible: page === 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        width: 190
                        height: 40
                        text: "󰞉  DISCORD: penguinluxior"
                        onClicked: Qt.openUrlExternally(discordLink)
                        background: Rectangle {
                            radius: 20
                            color: "#33E69BD0"
                            border.width: 1
                            border.color: "#E69BD0"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#E69BD0"
                            font.family: "Fredoka"
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing: 12

                    Button {
                        visible: page > 0
                        width: 48
                        height: 40
                        text: "‹"
                        onClicked: page--
                        background: Rectangle {
                            radius: 20
                            color: "#22FFFFFF"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#FFFFFF"
                            font.pixelSize: 25
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Item { width: parent.width - 120; height: 40 }

                    Button {
                        width: 48
                        height: 40
                        text: page < 2 ? "›" : "✓"
                        onClicked: {
                            if (page < 2) page++
                            else Qt.quit()
                        }
                        background: Rectangle {
                            radius: 20
                            color: "#33E69BD0"
                            border.width: 1
                            border.color: "#E69BD0"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#FFFFFF"
                            font.pixelSize: 25
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
