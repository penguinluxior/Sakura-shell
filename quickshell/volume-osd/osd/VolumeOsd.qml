import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: panelWindow

    WlLayershell.layer: WlLayershell.Layer.Top
    WlLayershell.namespace: "quickshell-widgets"

    anchors {
        top: true
        bottom: true
        right: true
    }

    width: 320

    margins {
        right: 16
        top: 40
        bottom: 40
    }

    color: "transparent"

    property bool isOpen: false
    x: isOpen ? (screen.width - width - 16) : screen.width

    Behavior on x {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        radius: Theme.radius
        border.color: Theme.accent
        border.width: 2
        clip: true

        Column {
            anchors.fill: parent
            anchors.margins: Theme.padding
            spacing: 24

            Column {
                width: parent.width
                spacing: 4

                Text {
                    id: timeText
                    text: Qt.formatDateTime(new Date(), "hh:mm A")
                    color: Theme.text
                    font.pixelSize: 32
                    font.bold: true

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: timeText.text = Qt.formatDateTime(new Date(), "hh:mm A")
                    }
                }

                Text {
                    text: Qt.formatDateTime(new Date(), "dddd, d MMMM")
                    color: Theme.textMuted
                    font.pixelSize: 14
                }
            }

            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: "Volumen del Sistema"
                    color: Theme.text
                    font.pixelSize: 14
                    font.bold: true
                }

                Slider {
                    id: volSlider
                    width: parent.width
                    from: 0
                    to: 100
                    value: 50

                    background: Rectangle {
                        x: volSlider.leftPadding
                        y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 6
                        width: volSlider.availableWidth
                        height: implicitHeight
                        radius: 3
                        color: Theme.surface

                        Rectangle {
                            width: volSlider.visualPosition * parent.width
                            height: parent.height
                            color: Theme.accent
                            radius: 3
                        }
                    }

                    handle: Rectangle {
                        x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                        y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 8
                        color: Theme.text
                        border.color: Theme.accent
                        border.width: 2
                    }

                    onMoved: {
                        volumeSetter.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (volSlider.value / 100).toFixed(2)]
                        volumeSetter.running = true
                    }
                }
            }
        }
    }

    Process {
        id: volumeSetter
        running: false
    }

    function toggle() {
        isOpen = !isOpen
    }
}
