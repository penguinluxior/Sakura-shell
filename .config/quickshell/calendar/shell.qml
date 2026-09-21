import Quickshell
import QtQuick
import QtQuick.Controls

ShellRoot {
    property int displayedMonth: new Date().getMonth()
    property int displayedYear: new Date().getFullYear()

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    function firstDay(year, month) {
        return new Date(year, month, 1).getDay()
    }

    function monthName(month) {
        const names = ["ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"]
        return names[month]
    }

    function isToday(day) {
        const now = new Date()
        return day === now.getDate() && displayedMonth === now.getMonth() && displayedYear === now.getFullYear()
    }

    function previousMonth() {
        if (displayedMonth === 0) {
            displayedMonth = 11
            displayedYear--
        } else {
            displayedMonth--
        }
    }

    function nextMonth() {
        if (displayedMonth === 11) {
            displayedMonth = 0
            displayedYear++
        } else {
            displayedMonth++
        }
    }

    PanelWindow {
        anchors.top: true
        anchors.right: true
        margins.top: 25
        margins.right: 24
        implicitWidth: 360
        implicitHeight: 390
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

            MouseArea {
                width: 32
                height: 32
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 4
                anchors.rightMargin: 4
                cursorShape: Qt.PointingHandCursor

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    color: "#FFFFFF"
                    font.pixelSize: 18
                }

                onClicked: Qt.quit()
            }

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                Row {
                    width: parent.width
                    spacing: 8

                    Button {
                        width: 42
                        height: 42
                        text: "‹"
                        onClicked: previousMonth()
                        background: Rectangle {
                            radius: 21
                            color: parent.down ? "#55E69BD0" : "#22FFFFFF"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#FFFFFF"
                            font.pixelSize: 25
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Column {
                        width: parent.width - 100
                        spacing: 2

                        Text {
                            width: parent.width
                            text: monthName(displayedMonth)
                            color: "#FFFFFF"
                            font.pixelSize: 19
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            width: parent.width
                            text: displayedYear
                            color: "#AAAAAA"
                            font.pixelSize: 13
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Button {
                        width: 42
                        height: 42
                        text: "›"
                        onClicked: nextMonth()
                        background: Rectangle {
                            radius: 21
                            color: parent.down ? "#55E69BD0" : "#22FFFFFF"
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

                Button {
                    width: parent.width
                    height: 32
                    text: "Hoy"
                    onClicked: {
                        const now = new Date()
                        displayedMonth = now.getMonth()
                        displayedYear = now.getFullYear()
                    }
                    background: Rectangle {
                        radius: 16
                        color: parent.down ? "#55E69BD0" : "#22E69BD0"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#E69BD0"
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Row {
                    width: parent.width
                    spacing: 0

                    Repeater {
                        model: ["D", "L", "M", "M", "J", "V", "S"]
                        Text {
                            width: parent.width / 7
                            text: modelData
                            color: "#E69BD0"
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                Grid {
                    width: parent.width
                    columns: 7
                    rows: 6
                    rowSpacing: 5
                    columnSpacing: 0

                    Repeater {
                        model: 42

                        Rectangle {
                            width: parent.width / 7
                            height: 38
                            radius: 19
                            color: {
                                const day = index - firstDay(displayedYear, displayedMonth) + 1
                                return day > 0 && day <= daysInMonth(displayedYear, displayedMonth) && isToday(day) ? "#E69BD0" : "transparent"
                            }

                            Text {
                                anchors.centerIn: parent
                                property int day: index - firstDay(displayedYear, displayedMonth) + 1
                                text: day > 0 && day <= daysInMonth(displayedYear, displayedMonth) ? day : ""
                                color: isToday(day) ? "#151015" : "#FFFFFF"
                                font.pixelSize: 14
                                font.bold: isToday(day)
                            }
                        }
                    }
                }
            }
        }
    }
}
