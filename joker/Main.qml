// Joker — gritty, off-center, theatrical.
// Structure: full-bleed portrait with heavy vignette, login as a narrow
// vertical strip pinned to the right third. Smile-red + sickly green accents.
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920; height: 1080
    color: "#000"

    property color smile: "#a8132b"
    property color sick:  "#6d8a3a"
    property color text:  "#eaeaea"
    property color dim:   "#8a8a8a"

    Image { anchors.fill: parent; source: "assets/wallpaper.jpg"; fillMode: Image.PreserveAspectCrop }
    Rectangle { anchors.fill: parent
        gradient: Gradient { orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 0.55; color: "#000000aa" }
            GradientStop { position: 1.0; color: "#000000ff" } } }

    Column {
        anchors.right: parent.right; anchors.rightMargin: 110
        anchors.verticalCenter: parent.verticalCenter
        spacing: 18; width: 340

        Text { text: "put on a happy face."; color: root.sick
            font.family: "Georgia"; font.italic: true; font.pixelSize: 14; font.letterSpacing: 2 }

        Text { id: jc; color: root.text
            font.family: "Georgia"; font.pixelSize: 78
            text: Qt.formatDateTime(new Date(), "HH:mm") }
        Text { color: root.dim; font.family: "Georgia"; font.italic: true; font.pixelSize: 13
            text: Qt.formatDateTime(new Date(), "dddd · MMMM d").toLowerCase() }
        Timer { interval: 1000; running: true; repeat: true
            onTriggered: jc.text = Qt.formatDateTime(new Date(), "HH:mm") }

        Rectangle { width: 60; height: 2; color: root.smile }

        TextField {
            id: u; width: parent.width
            text: userModel ? userModel.lastUser : ""
            placeholderText: "who are you?"
            color: root.text; font.family: "Georgia"; font.italic: true; font.pixelSize: 18
            background: Rectangle { color: "transparent"
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.dim } }
        }
        TextField {
            id: p; width: parent.width
            placeholderText: "the punchline"; echoMode: TextInput.Password
            color: root.text; font.family: "Georgia"; font.italic: true; font.pixelSize: 18
            background: Rectangle { color: "transparent"
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.smile } }
            onAccepted: sddm.login(u.text, p.text, sessionModel.lastIndex)
        }

        Text { text: "› laugh"; color: root.smile
            font.family: "Georgia"; font.italic: true; font.pixelSize: 16
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: sddm.login(u.text, p.text, sessionModel.lastIndex) } }

        Item { width: 1; height: 12 }
        Row { spacing: 18
            Repeater {
                model: [{l:"die",   fn:function(){sddm.powerOff()}},
                        {l:"again", fn:function(){sddm.reboot()}},
                        {l:"dream", fn:function(){sddm.suspend()}}]
                delegate: Text { text: modelData.l; color: root.dim
                    font.family: "Georgia"; font.italic: true; font.pixelSize: 12; font.letterSpacing: 2
                    MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onEntered: parent.color = root.smile; onExited: parent.color = root.dim
                        onClicked: modelData.fn() } }
            }
        }
    }

    Connections { target: sddm; function onLoginFailed() { p.text = "" } }
    Component.onCompleted: p.forceActiveFocus()
}
