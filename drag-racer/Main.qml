// Drag Racer — racing telemetry overlay.
// Structure: full-bleed photo, top-left HUD with huge clock + lap-time vibe,
// bottom-right pill-shaped login. Race red accent, italic condensed type.
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920; height: 1080
    color: "#000"

    property color red:   "#e63946"
    property color white: "#ffffff"
    property color dim:   "rgba(255,255,255,0.55)"

    Image {
        anchors.fill: parent
        source: "assets/wallpaper.jpg"
        fillMode: Image.PreserveAspectCrop
    }
    Rectangle { anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000099" }
            GradientStop { position: 0.5; color: "#00000033" }
            GradientStop { position: 1.0; color: "#000000cc" }
        }
    }

    // top-left HUD
    Column {
        x: 64; y: 56; spacing: 4
        Row { spacing: 10
            Rectangle { width: 12; height: 12; color: root.red; anchors.verticalCenter: parent.verticalCenter }
            Text { text: "STAGE // READY"; color: root.white
                font.family: "Arial Black"; font.italic: true; font.pixelSize: 14; font.letterSpacing: 4 }
        }
        Text { id: bigC; color: root.white
            font.family: "Arial Black"; font.italic: true; font.pixelSize: 132
            text: Qt.formatDateTime(new Date(), "HH:mm") }
        Text { id: smC; color: root.red
            font.family: "Monospace"; font.pixelSize: 18; font.letterSpacing: 2
            text: Qt.formatDateTime(new Date(), "ss.zzz").substring(0,5) + "  |  " +
                  Qt.formatDateTime(new Date(), "ddd dd MMM").toUpperCase() }
        Timer { interval: 50; running: true; repeat: true
            onTriggered: { bigC.text = Qt.formatDateTime(new Date(), "HH:mm")
                            smC.text  = Qt.formatDateTime(new Date(), "ss.zzz").substring(0,5) +
                                        "  |  " + Qt.formatDateTime(new Date(), "ddd dd MMM").toUpperCase() } }
    }

    // bottom-right pill login
    Rectangle {
        anchors.right: parent.right; anchors.bottom: parent.bottom
        anchors.margins: 56
        width: 520; height: 96
        radius: 48
        color: "#0a0a0aee"
        border.color: root.red; border.width: 2

        Row {
            anchors.fill: parent; anchors.margins: 12; spacing: 8
            TextField {
                id: u; width: 150; height: parent.height
                text: userModel ? userModel.lastUser : ""
                placeholderText: "DRIVER"
                color: root.white; font.family: "Arial Black"; font.italic: true; font.pixelSize: 16
                background: Rectangle { color: "transparent" }
            }
            Rectangle { width: 1; height: parent.height - 16; color: root.dim
                anchors.verticalCenter: parent.verticalCenter }
            TextField {
                id: p; width: 220; height: parent.height
                placeholderText: "PASSCODE"; echoMode: TextInput.Password
                color: root.white; font.family: "Arial Black"; font.italic: true; font.pixelSize: 16
                background: Rectangle { color: "transparent" }
                onAccepted: sddm.login(u.text, p.text, sessionModel.lastIndex)
            }
            Rectangle {
                width: 96; height: parent.height; radius: 48; color: root.red
                Text { anchors.centerIn: parent; text: "GO"; color: root.white
                    font.family: "Arial Black"; font.italic: true; font.pixelSize: 24; font.letterSpacing: 3 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.login(u.text, p.text, sessionModel.lastIndex) }
            }
        }
    }

    // bottom-left power row
    Row {
        anchors.left: parent.left; anchors.bottom: parent.bottom
        anchors.margins: 56; spacing: 28
        Repeater {
            model: [{l:"PIT // SHUTDOWN", fn:function(){sddm.powerOff()}},
                    {l:"RESET // REBOOT", fn:function(){sddm.reboot()}}]
            delegate: Text { text: modelData.l; color: root.dim
                font.family: "Monospace"; font.pixelSize: 12; font.letterSpacing: 3
                MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onEntered: parent.color = root.red; onExited: parent.color = root.dim
                    onClicked: modelData.fn() } }
        }
    }

    Connections { target: sddm; function onLoginFailed() { p.text = "" } }
    Component.onCompleted: p.forceActiveFocus()
}
