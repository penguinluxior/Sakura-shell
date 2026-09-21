import Quickshell
import QtQuick

ShellRoot {
    property int shownMonth: new Date().getMonth()
    property int shownYear: new Date().getFullYear()

    function monthName(month) {
        const names = ["ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"]
        return names[month]
    }

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    function firstDay(year, month) {
        return new Date(year, month, 1).getDay()
    }

    function previousMonth() {
        if (shownMonth === 0) {
            shownMonth = 11
            shownYear--
        } else {
            shownMonth--
        }
    }

    function nextMonth() {
        if (shownMonth === 11) {
            shownMonth = 0
            shownYear++
        } else {
            shownMonth++
        }
    }

    PanelWindow {
        anchors.top: true
        anchors.right: true
        margins.top: 48
        margins.right: 20
        implicitWidth: 330
        implicitHeight: 380
        color: "transparent"
        aboveWindows: true
        exclusiveZone: 0

        Rectangle {
            anchors.fill: parent
            radius: 22
            color: "#CC101010"
            border.width: 2
            border.color: "#E69BD0"

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                Row {
                    width: parent.width
                    spacing: 10

                    Text {
                        text: "‹"
                        color: "#E69BD0"
                        font.pixelSize: 32
                        width: 35
                        horizontalAlignment: Text.AlignHCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: previousMonth()
                        }
                    }

                    Text {
                        text: monthName(shownMonth) + " " + shownYear
                        color: "#FFFFFF"
                        font.pixelSize: 21
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        width: parent.width - 90
                    }

                    Text {
                        text: "›"
                        color: "#E69BD0"
                        font.pixelSize: 32
                        width: 35
                        horizontalAlignment: Text.AlignHCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: nextMonth()
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: ["D", "L", "M", "M", "J", "V", "S"]
                        Text {
                            required property string modelData
                            width: (parent.width - 24) / 7
                            text: modelData
                            color: "#E69BD0"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                Grid {
                    width: parent.width
                    columns: 7
                    rowSpacing: 5
                    columnSpacing: 4

                    Repeater {
                        model: 42

                        Rectangle {
                            required property int index
                            property int dayNumber: index - firstDay(shownYear, shownMonth) + 1
                            property bool validDay: dayNumber >= 1 && dayNumber <= daysInMonth(shownYear, shownMonth)
                            property bool today: validDay && dayNumber === new Date().getDate() && shownMonth === new Date().getMonth() && shownYear === new Date().getFullYear()

                            width: (parent.width - 24) / 7
                            height: 38
                            radius: 10
                            color: today ? "#E69BD0" : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: validDay ? dayNumber : ""
                                color: today ? "#000000" : "#FFFFFF"
                                font.pixelSize: 15
                                font.bold: today
                            }
                        }
                    }
                }
            }
        }
    }
}
