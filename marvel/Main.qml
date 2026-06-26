// Marvel Studios — bold cinematic title-card layout.
// Structure: tiny logo wallpaper top, massive red "ENTER" block center,
// password as a slim white underline. Power row anchored bottom-right.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 1920; height: 1080
    color: "#000000"

    property color brand: config.brand || "#ed1d24"
    property color text:  "#ffffff"
    property color sub:   "#9a9a9a"

    // ---- Logo strip (the wallpaper IS the logo, kept small & centered) ----
    Image {
        id: logo
        source: "assets/wallpaper.jpg"
        fillMode: Image.PreserveAspectFit
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.18
        width: parent.width * 0.45
        smooth: true
    }

    // ---- Massive red title block ----
    Rectangle {
        id: titleBlock
        anchors.top: logo.bottom
        anchors.topMargin: 64
        anchors.horizontalCenter: parent.horizontalCenter
        width: 520; height: 110
        color: root.brand
        Text {
            anchors.centerIn: parent
            text: "ENTER"
            color: root.text
            font.family: "Impact"
            font.pixelSize: 78
            font.letterSpacing: 8
        }
    }

    // ---- Username + password in a credits-style stack ----
    ColumnLayout {
        anchors.top: titleBlock.bottom
        anchors.topMargin: 48
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 18
        width: 460

        TextField {
            id: userField
            Layout.fillWidth: true
            text: userModel ? userModel.lastUser : ""
            placeholderText: "USER"
            color: root.text
            font.family: "Impact"; font.pixelSize: 22; font.letterSpacing: 4
            background: Rectangle { color: "transparent"; border.color: root.sub; border.width: 0
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 2; color: root.sub } }
        }
        TextField {
            id: passField
            Layout.fillWidth: true
            placeholderText: "PASSWORD"
            echoMode: TextInput.Password
            color: root.text
            font.family: "Impact"; font.pixelSize: 22; font.letterSpacing: 4
            background: Rectangle { color: "transparent"
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 2; color: root.brand } }
            onAccepted: sddm.login(userField.text, passField.text, sessionModel.lastIndex)
        }
    }

    // ---- Power controls bottom-right ----
    Row {
        anchors.right: parent.right; anchors.bottom: parent.bottom
        anchors.margins: 32; spacing: 24
        Repeater {
            model: [{l:"SHUTDOWN", fn:function(){sddm.powerOff()}},
                    {l:"REBOOT",   fn:function(){sddm.reboot()}},
                    {l:"SUSPEND",  fn:function(){sddm.suspend()}}]
            delegate: Text {
                text: modelData.l
                color: root.sub
                font.family: "Impact"; font.pixelSize: 14; font.letterSpacing: 3
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onEntered: parent.color = root.brand
                    onExited:  parent.color = root.sub
                    hoverEnabled: true
                    onClicked: modelData.fn() }
            }
        }
    }

    Connections { target: sddm
        function onLoginFailed() { passField.text = ""; titleBlock.color = "#ffffff"; resetTimer.start() }
    }
    Timer { id: resetTimer; interval: 400; onTriggered: titleBlock.color = root.brand }
    Component.onCompleted: passField.forceActiveFocus()
}
