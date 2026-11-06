// Joker — gritty, off-center, theatrical.
// Structure: full-bleed portrait with heavy vignette, login as a narrow
// vertical strip pinned to the right third. Smile-red + sickly green accents.
import QtQuick 2.15
import QtQuick.Controls 2.15
import "components" as Common

Rectangle {
    id: viewport

    property color themeAccent: root.themeAccent
    readonly property bool compactMode: width < 1200 || height < 680
    readonly property real layoutScale: Math.min(width / 1920, height / 1080)

    width: 1920
    height: 1080
    color: "#000000"

    Rectangle {
        id: root

        property color themeAccent: config.brand || config.accent || "#a8132b"
        property color smile: root.themeAccent
        property color sick: "#6d8a3a"
        property color text: "#eaeaea"
        property color dim: "#8a8a8a"

        width: viewport.width / viewport.layoutScale
        height: viewport.height / viewport.layoutScale
        scale: viewport.layoutScale
        transformOrigin: Item.TopLeft
        visible: !viewport.compactMode
        color: "#000"
        Component.onCompleted: p.forceActiveFocus()

        Common.Wallpaper {
            anchors.fill: parent
            source: Qt.resolvedUrl(config.background || "assets/wallpaper.jpg")
            fallbackSource: Qt.resolvedUrl("assets/wallpaper.jpg")
            fillMode: Image.PreserveAspectCrop
        }

        Rectangle {
            anchors.fill: parent

            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop {
                    position: 0
                    color: "#00000000"
                }

                GradientStop {
                    position: 0.55
                    color: "#aa000000"
                }

                GradientStop {
                    position: 1
                    color: "#ff000000"
                }
            }
        }

        Column {
            anchors.right: parent.right
            anchors.rightMargin: 110
            anchors.verticalCenter: parent.verticalCenter
            spacing: 18
            width: 340

            Text {
                text: "put on a happy face."
                color: root.sick
                font.family: "Georgia"
                font.italic: true
                font.pixelSize: 14
                font.letterSpacing: 2
            }

            Text {
                id: jc

                color: root.text
                font.family: "Georgia"
                font.pixelSize: 78
                text: Qt.formatDateTime(new Date(), "HH:mm")
            }

            Text {
                color: root.dim
                font.family: "Georgia"
                font.italic: true
                font.pixelSize: 13
                text: Qt.formatDateTime(new Date(), "dddd · MMMM d").toLowerCase()
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: jc.text = Qt.formatDateTime(new Date(), "HH:mm")
            }

            Rectangle {
                width: 60
                height: 2
                color: root.smile
            }

            Common.UsernamePicker {
                id: u

                objectName: "usernameField"
                controller: auth
                Accessible.name: qsTr("Username")
                width: parent.width
                height: 44

                foreground: root.text
                font.family: "sans-serif"
                font.italic: true
                font.pixelSize: 18

                background: Rectangle {
                    color: "transparent"

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: root.dim
                    }
                }
            }

            TextField {
                id: p

                placeholderTextColor: color
                objectName: "passwordField"
                onTextEdited: auth.dismissError()
                Accessible.description: auth.rejected ? auth.errorMessage : ""
                enabled: !auth.busy
                Accessible.name: qsTr("Password")
                width: parent.width
                height: 44
                placeholderText: qsTr("Password")
                focus: true
                echoMode: TextInput.Password
                color: root.text
                font.family: "sans-serif"
                font.italic: true
                font.pixelSize: 18
                onAccepted: auth.login(auth.username, p.text, auth.sessionIndex)

                Common.FieldFocus {
                    controller: auth
                }

                background: Rectangle {
                    color: "transparent"

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: root.smile
                    }
                }
            }

            Text {
                text: "› laugh"
                color: root.smile
                font.family: "Georgia"
                font.italic: true
                font.pixelSize: 16

                Common.ActionArea {
                    Accessible.name: qsTr("Sign in")
                    objectName: "loginButton"
                    enabled: !auth.busy
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: auth.login(auth.username, p.text, auth.sessionIndex)
                }
            }

            Item {
                width: 1
                height: 12
            }
        }

        Common.AuthController {
            id: auth

            passwordField: viewport.compactMode ? compact.passwordField : p
        }
    }

    Common.CompactGreeter {
        id: compact

        anchors.fill: parent
        visible: viewport.compactMode
        controller: auth
        accent: root.themeAccent
        title: "JOKER"
        wallpaperSource: Qt.resolvedUrl(config.background || "assets/wallpaper.jpg")
        fallbackSource: Qt.resolvedUrl("assets/wallpaper.jpg")
    }

    Common.SystemBar {
        id: systemBar
        anchors.left: viewport.compactMode ? undefined : parent.left
        anchors.leftMargin: viewport.compactMode ? 0 : 40
        anchors.horizontalCenter: viewport.compactMode ? parent.horizontalCenter : undefined
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        controller: auth
        accent: root.themeAccent
        surface: "#ed11100f"
        foreground: "#eaeaea"
        cornerRadius: 0
        controlRadius: 0
        fontFamily: "sans-serif"
        treatment: "line"
    }

    Common.LoginStatus {
        compactMode: viewport.compactMode
        accent: root.themeAccent
        title: "JOKER"
        fontFamily: viewport.compactMode ? "sans-serif" : p.font.family
        surface: viewport.compactMode || !p.background || p.background.color.a < 0.5 ? "#ed171717" : p.background.color
        foreground: viewport.compactMode || !p.background || p.background.color.a < 0.5 ? "#ffffff" : p.color
        cornerRadius: viewport.compactMode ? 10 : 0
        controller: auth
    }
}
