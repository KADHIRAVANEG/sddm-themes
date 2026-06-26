// Classic JDM — full-bleed photo, dashboard HUD bar across the bottom.
// Structure: no blur, the wallpaper carries the mood. Bottom strip = digital
// odometer clock | login | session/power, like a car instrument cluster.
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920; height: 1080
    color: "#000"

    property color amber: "#f5a623"
    property color panel: "#0c0c0ccc"
    property color text:  "#ececec"
    property color dim:   "#7a7a7a"

    Image {
        anchors.fill: parent
        source: "assets/wallpaper.jpg"
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    // ---- Dashboard HUD bar ----
    Rectangle {
        id: hud
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        height: 140
        color: root.panel
        border.color: root.amber; border.width: 1

        // odometer clock
        Column {
            anchors.left: parent.left; anchors.leftMargin: 48
            anchors.verticalCenter: parent.verticalCenter
            Text { id: clk; color: root.amber; font.family: "Monospace"; font.pixelSize: 56; font.bold: true
                text: Qt.formatDateTime(new Date(), "HH:mm:ss") }
            Text { id: dt; color: root.dim; font.family: "Monospace"; font.pixelSize: 14; font.letterSpacing: 3
                text: Qt.formatDateTime(new Date(), "ddd dd MMM yyyy").toUpperCase() }
        }
        Timer { interval: 1000; running: true; repeat: true
            onTriggered: { clk.text = Qt.formatDateTime(new Date(), "HH:mm:ss");
                            dt.text  = Qt.formatDateTime(new Date(), "ddd dd MMM yyyy").toUpperCase() } }

        // center login
        Row {
            anchors.centerIn: parent; spacing: 16
            TextField {
                id: u; width: 220
                text: userModel ? userModel.lastUser : ""
                placeholderText: "USER"
                color: root.text; font.family: "Monospace"; font.pixelSize: 18
                background: Rectangle { color: "#000"; border.color: root.amber; border.width: 1 }
            }
            TextField {
                id: p; width: 320
                placeholderText: "PASSWORD"; echoMode: TextInput.Password
                color: root.text; font.family: "Monospace"; font.pixelSize: 18
                background: Rectangle { color: "#000"; border.color: root.amber; border.width: 1 }
                onAccepted: sddm.login(u.text, p.text, s.currentIndex)
            }
            Rectangle {
                width: 90; height: 42; color: root.amber
                Text { anchors.centerIn: parent; text: "START"; color: "#000"
                    font.family: "Monospace"; font.bold: true; font.letterSpacing: 4 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.login(u.text, p.text, s.currentIndex) }
            }
        }

        // right cluster
        Row {
            anchors.right: parent.right; anchors.rightMargin: 48
            anchors.verticalCenter: parent.verticalCenter; spacing: 24
            ComboBox {
                id: s; width: 160; model: sessionModel; textRole: "name"; currentIndex: sessionModel.lastIndex
            }
            Text { text: "⏻"; color: root.amber; font.pixelSize: 28
                MouseArea { anchors.fill: parent; onClicked: sddm.powerOff(); cursorShape: Qt.PointingHandCursor } }
            Text { text: "↻"; color: root.amber; font.pixelSize: 28
                MouseArea { anchors.fill: parent; onClicked: sddm.reboot(); cursorShape: Qt.PointingHandCursor } }
        }
    }

    Connections { target: sddm; function onLoginFailed() { p.text = "" } }
    Component.onCompleted: p.forceActiveFocus()
}
