import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../theme"

PanelWindow {
    id: panelWindow

    aboveWindows: true

    anchors {
        top: true
        bottom: true
        right: true
    }

    implicitWidth: 320
    
    margins {
        right: panelWindow.isOpen ? 16 : -panelWindow.implicitWidth - 32
        top: 40
        bottom: 40
    }

    color: "transparent"

    property bool isOpen: false

    readonly property int panelLeftEdge: 1366 - implicitWidth - 16

    Behavior on margins.right {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Connections {
        target: cornerDetector
        function onCursorXChanged() {
            if (panelWindow.isOpen) {
                if (cornerDetector.cursorX < panelWindow.panelLeftEdge) {
                    panelWindow.isOpen = false;
                }
            }
        }
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
                    text: "Volumen (" + Math.round(volSlider.value) + "%)"
                    color: Theme.text
                    font.pixelSize: 14
                    font.bold: true
                }

                Slider {
                    id: volSlider
                    width: parent.width
                    from: 0
                    to: 100

                    onMoved: {
                        volumeSetter.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (volSlider.value / 100).toFixed(2)]
                        volumeSetter.running = true
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 16

                Text {
                    text: "Estado del Sistema"
                    color: Theme.text
                    font.pixelSize: 14
                    font.bold: true
                }

                Text {
                    text: "Uso de CPU: " + Math.round(sysMonitor.cpuUsage) + "%"
                    color: Theme.cpuColor
                    font.pixelSize: 12
                }

                Text {
                    text: "Memoria RAM: " + Math.round(sysMonitor.ramUsage) + "%"
                    color: Theme.ramColor
                    font.pixelSize: 12
                }
            }
        }
    }

    Process {
        id: volumeSetter
        running: false
    }

    Item {
        id: sysMonitor
        property double cpuUsage: 0
        property double ramUsage: 0
        property var prevIdle: 0
        property var prevTotal: 0

        Timer {
            interval: 1000
            running: panelWindow.isOpen
            repeat: true
            triggeredOnStart: true

            onTriggered: {
                volGetter.running = true
                cpuReader.running = true
                memReader.running = true
            }
        }

        Process {
            id: volGetter
            command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]

            stdout: StdioCollector {
                id: vCollector
                onStreamFinished: {
                    var out = vCollector.text.trim();
                    var match = out.match(/Volume:\s+([0-9.]+)/);
                    if (match && !volSlider.pressed)
                        volSlider.value = parseFloat(match[1]) * 100;
                }
            }
        }

        Process {
            id: cpuReader
            command: ["cat", "/proc/stat"]

            stdout: StdioCollector {
                id: cCollector
                onStreamFinished: {
                    var lines = cCollector.text.split("\n");
                    if (lines.length === 0 || !lines\[0\].startsWith("cpu ")) return;

                    var parts = lines\[0\].split(/\s+/).filter(Boolean);
                    var user = parseInt(parts\[1\], 10);
                    var nice = parseInt(parts\[2\], 10);
                    var system = parseInt(parts\[3\], 10);
                    var idle = parseInt(parts\[4\], 10);
                    var iowait = parseInt(parts\[5\], 10);
                    var irq = parseInt(parts\[6\], 10);
                    var softirq = parseInt(parts\[7\], 10);

                    var totalIdle = idle + iowait;
                    var totalNonIdle = user + nice + system + irq + softirq;
                    var total = totalIdle + totalNonIdle;
                    var totalDiff = total - sysMonitor.prevTotal;
                    var idleDiff = totalIdle - sysMonitor.prevIdle;

                    if (totalDiff > 0)
                        sysMonitor.cpuUsage = ((totalDiff - idleDiff) / totalDiff) * 100;

                    sysMonitor.prevIdle = totalIdle;
                    sysMonitor.prevTotal = total;
                }
            }
        }

        Process {
            id: memReader
            command: ["cat", "/proc/meminfo"]

            stdout: StdioCollector {
                id: mCollector
                onStreamFinished: {
                    var out = mCollector.text;
                    var totalMatch = out.match(/MemTotal:\s+(\d+)/);
                    var availMatch = out.match(/MemAvailable:\s+(\d+)/);

                    if (totalMatch && availMatch) {
                        var total = parseInt(totalMatch\[1\], 10);
                        var avail = parseInt(availMatch\[1\], 10);
                        sysMonitor.ramUsage = ((total - avail) / total) * 100;
                    }
                }
            }
        }
    }
}
