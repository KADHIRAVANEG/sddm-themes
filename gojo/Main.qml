// Gojo — monochrome manga split.
// Structure: left half = artwork bleed, right half = pure black with a thin
// white-stroke login. Manga vertical title "INFINITY" runs down the divider.
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920; height: 1080
    color: "#000"

    Image {
        width: parent.width * 0.6; height: parent.height
        source: "assets/wallpaper.png"
        fillMode: Image.PreserveAspectCrop
    }
    // hard divider
    Rectangle { x: parent.width * 0.6; width: 2; height: parent.height; color: "#fff" }

    // vertical kanji-feel label
    Column {
        x: parent.width * 0.6 + 18; y: 60; spacing: 14
        Repeater {
            model: ["I","N","F","I","N","I","T","Y"]
            delegate: Text { text: modelData; color: "#fff"
                font.family: "Times New Roman"; font.pixelSize: 22; font.letterSpacing: 4 }
        }
    }

    // right-side login
    Column {
        anchors.right: parent.right; anchors.rightMargin: 120
        anchors.verticalCenter: parent.verticalCenter
        spacing: 28; width: 360

        Text { id: cl; color: "#fff"
            font.family: "Times New Roman"; font.pixelSize: 88; font.weight: Font.Light
            text: Qt.formatDateTime(new Date(), "HH:mm") }
        Text { color: "#bdbdbd"
            font.family: "Times New Roman"; font.italic: true; font.pixelSize: 16
            text: "the honored one — " + Qt.formatDateTime(new Date(), "dddd").toLowerCase() }
        Timer { interval: 1000; running: true; repeat: true
            onTriggered: cl.text = Qt.formatDateTime(new Date(), "HH:mm") }

        Rectangle { width: parent.width; height: 1; color: "#fff"; opacity: 0.6 }

        TextField {
            id: u; width: parent.width
            text: userModel ? userModel.lastUser : ""
            placeholderText: "name"
            color: "#fff"
            font.family: "Times New Roman"; font.pixelSize: 20
            background: Rectangle { color: "transparent"
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#fff" } }
        }
        TextField {
            id: p; width: parent.width
            placeholderText: "password"; echoMode: TextInput.Password
            color: "#fff"
            font.family: "Times New Roman"; font.pixelSize: 20
            background: Rectangle { color: "transparent"
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#fff" } }
            onAccepted: sddm.login(u.text, p.text, sessionModel.lastIndex)
        }

        Text { text: "↵  unseal"; color: "#fff"
            font.family: "Times New Roman"; font.italic: true; font.pixelSize: 16
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: sddm.login(u.text, p.text, sessionModel.lastIndex) }
        }

        Row { spacing: 18
            Repeater {
                model: [{l:"shutdown", fn:function(){sddm.powerOff()}},
                        {l:"reboot",   fn:function(){sddm.reboot()}},
                        {l:"sleep",    fn:function(){sddm.suspend()}}]
                delegate: Text { text: modelData.l; color: "#7a7a7a"
                    font.family: "Times New Roman"; font.italic: true; font.pixelSize: 13
                    MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onEntered: parent.color = "#fff"; onExited: parent.color = "#7a7a7a"
                        onClicked: modelData.fn() } }
            }
        }
    }

    Connections { target: sddm; function onLoginFailed() { p.text = "" } }
    Component.onCompleted: p.forceActiveFocus()
}
