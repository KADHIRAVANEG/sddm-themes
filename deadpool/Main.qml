// Deadpool — fourth-wall-breaking chat layout.
// Structure: hero portrait pinned right, snarky chat bubbles on the left
// leading down into the password "reply" box. Power row as fake emoji bar.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 1920; height: 1080
    color: "#0a0203"

    property color brand: config.brand || "#d62828"
    property color ink:   "#f5e9e9"
    property color sub:   "#8a6a6a"

    // Diagonal red slash background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#1a0608" }
            GradientStop { position: 0.6; color: "#0a0203" }
            GradientStop { position: 1.0; color: "#000000" }
        }
    }

    // Hero portrait — bottom-right, lets the face stay visible
    Image {
        id: hero
        source: "assets/wallpaper.jpg"
        fillMode: Image.PreserveAspectFit
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: parent.width * 0.55
        smooth: true
    }

    // Chat column on the LEFT — keeps the face uncovered
    ColumnLayout {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 80
        width: 520
        spacing: 14

        Text { text: "★ DEADPOOL OS"; color: root.brand
            font.family: "Impact"; font.pixelSize: 14; font.letterSpacing: 4 }
        Text { text: "Oh hey, you're back."; color: root.ink
            font.pixelSize: 42; font.bold: true; wrapMode: Text.WordWrap; Layout.fillWidth: true }
        Text { text: "I was just monologuing to a coat rack.\nPassword. You know the drill, chimichanga."
            color: root.sub; font.pixelSize: 16; wrapMode: Text.WordWrap; Layout.fillWidth: true }

        // Chat bubble — username
        Rectangle {
            Layout.preferredWidth: 320; Layout.preferredHeight: 44
            radius: 22; color: "#1a1a1a"; border.color: root.sub; border.width: 1
            TextField {
                id: userField
                anchors.fill: parent; anchors.leftMargin: 18
                text: userModel ? userModel.lastUser : "wade"
                color: root.ink; font.pixelSize: 15
                background: Rectangle { color: "transparent" }
            }
        }
        // Chat bubble — password (brand red)
        Rectangle {
            Layout.preferredWidth: 460; Layout.preferredHeight: 52
            radius: 26; color: root.brand
            TextField {
                id: passField
                anchors.fill: parent; anchors.leftMargin: 22; anchors.rightMargin: 70
                placeholderText: "type something snarky…"
                placeholderTextColor: "#ffd6d6"
                echoMode: TextInput.Password
                color: "#ffffff"; font.pixelSize: 16
                background: Rectangle { color: "transparent" }
                onAccepted: sddm.login(userField.text, passField.text, sessionModel.lastIndex)
            }
            Text { anchors.right: parent.right; anchors.rightMargin: 22
                anchors.verticalCenter: parent.verticalCenter
                text: "↵"; color: "#fff"; font.pixelSize: 22 }
        }

        Text { text: "🌮  ⚔️  🔫  ❤️‍🩹"; font.pixelSize: 18; opacity: 0.7 }
    }

    // Power row bottom-left
    Row {
        anchors.left: parent.left; anchors.bottom: parent.bottom
        anchors.margins: 40; spacing: 22
        Repeater {
            model: [{l:"☠ SHUTDOWN", fn:function(){sddm.powerOff()}},
                    {l:"↻ REBOOT",   fn:function(){sddm.reboot()}},
                    {l:"💤 SUSPEND", fn:function(){sddm.suspend()}}]
            delegate: Text {
                text: modelData.l; color: root.sub
                font.family: "Impact"; font.pixelSize: 13; font.letterSpacing: 3
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: parent.color = root.brand
                    onExited:  parent.color = root.sub
                    onClicked: modelData.fn() }
            }
        }
    }

    Connections { target: sddm
        function onLoginFailed() { passField.text = "" }
    }
    Component.onCompleted: passField.forceActiveFocus()
}
