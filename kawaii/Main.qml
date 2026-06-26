// Kawaii — soft pastel card with hearts.
// Structure: subject anchored right, big rounded pink-tinted card on the
// left with rounded inputs. Floating hearts animate. Cursive friendly type.
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920; height: 1080
    color: "#0d0710"

    property color pink:   "#ffb3d1"
    property color purple: "#c8a2ff"
    property color soft:   "#fff0f6"
    property color cardBg: "#1a0f1fcc"

    Image {
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        source: "assets/wallpaper.png"; fillMode: Image.PreserveAspectFit
        height: parent.height
    }

    // floating hearts
    Repeater {
        model: 12
        delegate: Text {
            text: "♡"; color: root.pink; opacity: 0.4
            font.pixelSize: 18 + (index % 4) * 8
            x: 80 + (index * 53) % 600
            y: 100 + (index * 91) % 900
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: 100 + (index * 91) % 900 - 30; duration: 2000 + index * 200; easing.type: Easing.InOutSine }
                NumberAnimation { to: 100 + (index * 91) % 900;      duration: 2000 + index * 200; easing.type: Easing.InOutSine }
            }
        }
    }

    // rounded card
    Rectangle {
        x: 140; anchors.verticalCenter: parent.verticalCenter
        width: 460; height: 540; radius: 36
        color: root.cardBg
        border.color: root.pink; border.width: 1

        Column {
            anchors.fill: parent; anchors.margins: 36; spacing: 18

            Text { text: "welcome back  ♡"; color: root.pink
                font.family: "Comic Sans MS"; font.pixelSize: 28 }
            Text { id: kc; color: root.soft
                font.family: "Comic Sans MS"; font.pixelSize: 56
                text: Qt.formatDateTime(new Date(), "HH:mm") }
            Text { color: root.purple; font.family: "Comic Sans MS"; font.pixelSize: 14
                text: Qt.formatDateTime(new Date(), "dddd, MMMM d") }
            Timer { interval: 1000; running: true; repeat: true
                onTriggered: kc.text = Qt.formatDateTime(new Date(), "HH:mm") }

            Item { width: 1; height: 8 }

            Rectangle { width: parent.width - 0; height: 50; radius: 25
                color: "#2a1530"; border.color: root.purple; border.width: 1
                TextField {
                    id: u; anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 20
                    text: userModel ? userModel.lastUser : ""
                    placeholderText: "username ✿"
                    color: root.soft; font.family: "Comic Sans MS"; font.pixelSize: 16
                    background: Rectangle { color: "transparent" }
                } }
            Rectangle { width: parent.width; height: 50; radius: 25
                color: "#2a1530"; border.color: root.pink; border.width: 1
                TextField {
                    id: p; anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 20
                    placeholderText: "password ♡"; echoMode: TextInput.Password
                    color: root.soft; font.family: "Comic Sans MS"; font.pixelSize: 16
                    background: Rectangle { color: "transparent" }
                    onAccepted: sddm.login(u.text, p.text, sessionModel.lastIndex)
                } }

            Rectangle { width: parent.width; height: 52; radius: 26; color: root.pink
                Text { anchors.centerIn: parent; text: "let me in ♡"
                    color: "#3a1030"; font.family: "Comic Sans MS"; font.pixelSize: 18; font.bold: true }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.login(u.text, p.text, sessionModel.lastIndex) } }

            Row { spacing: 22; anchors.horizontalCenter: parent.horizontalCenter
                Repeater {
                    model: [{l:"⏻", fn:function(){sddm.powerOff()}},
                            {l:"↻", fn:function(){sddm.reboot()}},
                            {l:"☾", fn:function(){sddm.suspend()}}]
                    delegate: Text { text: modelData.l; color: root.purple; font.pixelSize: 22
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.fn() } }
                }
            }
        }
    }

    Connections { target: sddm; function onLoginFailed() { p.text = "" } }
    Component.onCompleted: p.forceActiveFocus()
}
