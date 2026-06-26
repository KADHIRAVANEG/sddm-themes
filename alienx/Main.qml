// Alien X — Omnitrix sci-fi terminal.
// Structure: subject keeps its black bg on the right; left half is a
// vertical green-on-black command console. Hex-bordered inputs, scanlines.
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920; height: 1080
    color: "#000"

    property color glow: "#8aff5a"
    property color text: "#d6ffd0"
    property color dim:  "#3d6b35"

    // subject on the right
    Image {
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        source: "assets/wallpaper.png"
        fillMode: Image.PreserveAspectFit
        height: parent.height * 0.9
    }

    // scanline overlay
    Repeater {
        model: 360
        delegate: Rectangle {
            y: index * 3; width: root.width; height: 1
            color: root.glow; opacity: 0.04
        }
    }

    // left console
    Column {
        x: 120; anchors.verticalCenter: parent.verticalCenter
        spacing: 24; width: 480

        Text { text: "OMNITRIX :: AUTH"; color: root.glow
            font.family: "Monospace"; font.pixelSize: 14; font.letterSpacing: 8 }
        Text { text: "[ DNA SAMPLE REQUIRED ]"; color: root.dim
            font.family: "Monospace"; font.pixelSize: 12; font.letterSpacing: 4 }

        Rectangle { width: parent.width; height: 1; color: root.glow; opacity: 0.4 }

        Text { id: bigClock; color: root.glow
            font.family: "Monospace"; font.pixelSize: 92; font.bold: true
            text: Qt.formatDateTime(new Date(), "HH:mm") }
        Timer { interval: 1000; running: true; repeat: true
            onTriggered: bigClock.text = Qt.formatDateTime(new Date(), "HH:mm") }

        // hex-style inputs
        Repeater {
            model: [{ph:"USER ID", id:"u"}, {ph:"PASSPHRASE", id:"p"}]
            delegate: Rectangle {
                width: parent.width; height: 52
                color: "transparent"; border.color: root.glow; border.width: 1
                TextField {
                    id: tf
                    anchors.fill: parent; anchors.margins: 2
                    placeholderText: "> " + modelData.ph
                    text: modelData.id === "u" && userModel ? userModel.lastUser : ""
                    echoMode: modelData.id === "p" ? TextInput.Password : TextInput.Normal
                    color: root.text; font.family: "Monospace"; font.pixelSize: 16
                    background: Rectangle { color: "#001100" }
                    onAccepted: if (modelData.id === "p") sddm.login(userIn.userField(), tf.text, sessionModel.lastIndex)
                    Component.onCompleted: {
                        if (modelData.id === "u") userIn.user = tf
                        else userIn.pass = tf
                    }
                }
            }
        }

        QtObject {
            id: userIn
            property var user
            property var pass
            function userField() { return user ? user.text : "" }
        }

        Rectangle {
            width: parent.width; height: 48; color: root.glow
            Text { anchors.centerIn: parent; text: "▶ TRANSFORM"
                color: "#000"; font.family: "Monospace"; font.bold: true; font.letterSpacing: 6 }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: sddm.login(userIn.userField(), userIn.pass.text, sessionModel.lastIndex) }
        }

        Row {
            spacing: 20
            Repeater {
                model: [{l:"PWR OFF", fn:function(){sddm.powerOff()}},
                        {l:"REBOOT", fn:function(){sddm.reboot()}},
                        {l:"STANDBY", fn:function(){sddm.suspend()}}]
                delegate: Text {
                    text: "[ " + modelData.l + " ]"
                    color: root.dim; font.family: "Monospace"; font.pixelSize: 11; font.letterSpacing: 3
                    MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onEntered: parent.color = root.glow; onExited: parent.color = root.dim
                        onClicked: modelData.fn() }
                }
            }
        }
    }

    Connections { target: sddm; function onLoginFailed() { if (userIn.pass) userIn.pass.text = "" } }
    Component.onCompleted: if (userIn.pass) userIn.pass.forceActiveFocus()
}
