import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property bool insideCorner: false
    signal cornerEntered()

    Process {
        id: cursorProcess
        command: ["hyprctl", "cursorpos"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(",")

                if (parts.length !== 2)
                    return

                const x = Number(parts[0].trim())
                const y = Number(parts[1].trim())
                const inside = x >= 1350 && y >= 745

                console.log("CURSOR:", x, y, "CORNER:", inside)

                if (inside && !root.insideCorner) {
                    root.insideCorner = true
                    root.cornerEntered()
                } else if (!inside) {
                    root.insideCorner = false
                }
            }
        }

        onRunningChanged: {
            if (!running)
                running = true
        }
    }
}
