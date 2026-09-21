import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    id: root

    signal cornerEntered()
    
    // Propiedades globales para sincronizar las coordenadas en tiempo real con el panel
    property int cursorX: 0
    property int cursorY: 0
    property bool wasInCorner: false

    // Usamos el hook integrado del socket de Hyprland para rastrear el puntero reactivamente
    Connections {
        target: Hyprland
        
        // Cuando cambia la posición enfocada por el monitor o el cursor se mueve
        function onFocusedMonitorChanged() {
            updateCoords();
        }
    }

    // Timer súper pasivo de fallback o puedes usar el refresco de ventana nativo de QML
    Timer {
        interval: 50 // 50ms para un deslizamiento ultra suave y rápido
        running: true
        repeat: true
        onTriggered: updateCoords()
    }

    function updateCoords() {
        // Quickshell expone la API nativa de Hyprland sin necesidad de invocar scripts
        var pos = Hyprland.get_cursor_pos ? Hyprland.get_cursor_pos() : null;
        if (!pos) return;

        root.cursorX = pos.x;
        root.cursorY = pos.y;

        var isInCornerNow = (pos.x >= 1351 && pos.y >= 749);

        if (isInCornerNow && !root.wasInCorner) {
            root.cornerEntered();
        }

        root.wasInCorner = isInCornerNow;
    }
}
