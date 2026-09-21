import QtQuick
import "../theme"

Text {
    property bool muted: false
    text: muted ? "󰖁" : "󰕾"
    color: Theme.accent
    font.pixelSize: 30
    verticalAlignment: Text.AlignVCenter
}
