import QtQuick

pragma Singleton

QtObject {
    // Colores base estilo Caelestia
    readonly property color bg: "#1E1E2E"
    readonly property color surface: "#313244"
    readonly property color text: "#CDD6F4"
    readonly property color textMuted: "#A6ADC8"

    // Acentuaciones
    readonly property color accent: "#E69BD0"
    readonly property color cpuColor: "#89B4FA"
    readonly property color ramColor: "#A6E3A1"

    // Estilos globales
    readonly property int radius: 12
    readonly property int padding: 16
}
