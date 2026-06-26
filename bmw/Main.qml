// BMW Museum — top placard, M-stripe accent column on the left side
// (keeps the cars on the right visible). Login behaves like a key-fob panel.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 1920; height: 1080
    color: "#000000"

    property color mBlue:   "#1c69d4"
    property color mPurple: "#1f2e6e"
    property color mRed:    "#e22718"
    property color ink:     "#f4f4f4"
    property color sub:     "#9a9a9a"

    Image {
        anchors.fill: parent
        source: "assets/wallpaper.jpg"
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    // Left dim wash so the panel reads
    Rectangle {
        anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
        width: parent.width * 0.36
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#000000" }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // M-stripe column
    Row {
        anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
        anchors.leftMargin: 0
        Rectangle { width: 8; height: parent.height; color: root.mBlue }
        Rectangle { width: 8; height: parent.height; color: root.mPurple }
        Rectangle { width: 8; height: parent.height; color: root.mRed }
    }

    // Top museum placard
    Row {
        anchors.top: parent.top; anchors.left: parent.left
        anchors.topMargin: 48; anchors.leftMargin: 80
        spacing: 16
        Rectangle { width: 14; height: 14; radius: 7; color: "#fff"
            anchors.verticalCenter: parent.verticalCenter }
        Text { text: "BMW · M-MOTORSPORT"; color: root.ink
            font.family: "Helvetica"; font.pixelSize: 14; font.letterSpacing: 5
            anchors.verticalCenter: parent.verticalCenter }
        Text { text: "—  1986  —  E28 M535i"; color: root.sub
            font.family: "Helvetica"; font.pixelSize: 12; font.letterSpacing: 3
            anchors.verticalCenter: parent.verticalCenter }
    }

    // Key-fob login panel — left third
    ColumnLayout {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 80
        width: 380; spacing: 10

        Text { text: "IGNITION"; color: root.mBlue
            font.family: "Helvetica"; font.pixelSize: 11; font.letterSpacing: 5 }
        Text { text: userModel ? userModel.lastUser : "driver"
            color: root.ink; font.family: "Helvetica"; font.pixelSize: 36; font.bold: true }
        Text { text: "Authorized operator"; color: root.sub
            font.pixelSize: 12; font.letterSpacing: 2 }

        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 1
            color: root.mBlue; Layout.topMargin: 14
        }

        TextField {
            id: passField
            Layout.fillWidth: true
            placeholderText: "ENTER KEY CODE"
            placeholderTextColor: root.sub
            echoMode: TextInput.Password
            color: root.ink
            font.family: "Helvetica"; font.pixelSize: 18; font.letterSpacing: 6
            background: Rectangle { color: "transparent"
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 2; color: root.mRed } }
            onAccepted: sddm.login((userModel ? userModel.lastUser : "driver"), passField.text, sessionModel.lastIndex)
        }

        Row {
            spacing: 10; Layout.topMargin: 18
            Rectangle { width: 110; height: 36; color: root.mBlue
                Text { anchors.centerIn: parent; text: "▸ START"
                    color: "#fff"; font.family: "Helvetica"; font.pixelSize: 12; font.letterSpacing: 4 }
                MouseArea { anchors.fill: parent
                    onClicked: sddm.login((userModel ? userModel.lastUser : "driver"), passField.text, sessionModel.lastIndex) } }
            Rectangle { width: 90; height: 36; color: "transparent"; border.color: root.sub; border.width: 1
                Text { anchors.centerIn: parent; text: "PLASMA"
                    color: root.sub; font.family: "Helvetica"; font.pixelSize: 11; font.letterSpacing: 3 } }
        }
    }

    // Telemetry bottom-left
    Row {
        anchors.left: parent.left; anchors.bottom: parent.bottom
        anchors.leftMargin: 80; anchors.bottomMargin: 36
        spacing: 28
        Repeater {
            model: [{l:"⏻ OFF", fn:function(){sddm.powerOff()}},
                    {l:"↻ RST", fn:function(){sddm.reboot()}},
                    {l:"☾ SLP", fn:function(){sddm.suspend()}}]
            delegate: Text { text: modelData.l; color: root.sub
                font.family: "Helvetica"; font.pixelSize: 11; font.letterSpacing: 3
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: modelData.fn() } }
        }
    }

    Connections { target: sddm
        function onLoginFailed() { passField.text = "" }
    }
    Component.onCompleted: passField.forceActiveFocus()
}
