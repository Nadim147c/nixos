import qs.modules.common
import qs.modules.end4
import qs.modules.end4.functions

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:discord-overlay"

    anchors {
        top: true
        left: false
        bottom: true
        right: true
    }

    margins {
        top: Appearance.space.big
        right: Appearance.space.big
        bottom: Appearance.space.big
    }

    exclusiveZone: 0
    color: "transparent"
    implicitWidth: 500

    property bool hidden: false

    ColumnLayout {
        id: vcList
        y: root.height - height
        x: root.hidden ? root.width : root.width - width
        Behavior on x {
            animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
        }

        Repeater {
            model: DiscordVoiceRPC.members

            delegate: RowLayout {
                id: user
                required property DiscordVoiceMember modelData
                Layout.alignment: Qt.AlignRight

                Rectangle {
                    id: nameBound
                    color: ColorUtils.transparentize(Appearance.material.myBackground, 0.50)
                    radius: Appearance.round.little
                    implicitHeight: nickname.height + Appearance.space.large
                    implicitWidth: nickname.width + Appearance.space.larger
                    StyledText {
                        id: nickname
                        anchors.centerIn: parent
                        text: user.modelData.serverName || user.modelData.nickname || user.modelData.username
                        color: {
                            if (user.modelData.isSuppressed() || user.modelData.isDeaf()) {
                                return Appearance.material.myError;
                            }
                            if (user.modelData.isMute()) {
                                return Appearance.material.myOnSurfaceVariant;
                            }
                            return Appearance.material.myOnBackground;
                        }
                        font {
                            pixelSize: Appearance.font.pixelSize.smaller
                            family: Appearance.font.family.pixel
                        }
                    }
                }

                ClippingRectangle {
                    id: avatarCircle
                    property real size: 30
                    implicitHeight: size
                    implicitWidth: size
                    radius: Appearance.round.little
                    StyledImage {
                        anchors.centerIn: parent
                        height: parent.height
                        width: height
                        cache: true
                        source: user.modelData.avatarURL
                    }
                    Rectangle {
                        anchors.fill: parent
                        visible: user.modelData.isTalking
                        color: "transparent"
                        radius: Appearance.round.little
                        border {
                            color: Appearance.material.myBackground
                            width: 3
                        }
                    }
                    Rectangle {
                        anchors.fill: parent
                        visible: user.modelData.isTalking
                        color: "transparent"
                        radius: Appearance.round.little
                        border {
                            color: Appearance.material.myGreen
                            width: 2
                        }
                    }
                    Rectangle {
                        anchors.fill: parent
                        visible: user.modelData.status !== 0
                        color: ColorUtils.transparentize(Appearance.material.mySurfaceContainer, 0.2)
                        Text {
                            visible: !deafIcon.visible && user.modelData.isMute()
                            anchors.fill: parent
                            text: "mic-off"
                            font.preferShaping: true
                            fontSizeMode: Text.Fit
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Appearance.font.pixelSize.huge
                            font.family: Appearance.font.family.iconPixel
                            color: Appearance.material.myError
                        }
                        Text {
                            id: deafIcon
                            visible: user.modelData.isDeaf() || user.modelData.isSuppressed()
                            anchors.fill: parent
                            text: "volume-x"
                            font.preferShaping: true
                            fontSizeMode: Text.Fit
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Appearance.font.pixelSize.huge
                            font.family: Appearance.font.family.iconPixel
                            color: Appearance.material.myError
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: vcList
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.hidden = true;
            timer.running = true;
        }
    }

    Timer {
        id: timer
        running: false
        repeat: false
        interval: 5000
        onTriggered: root.hidden = false
    }

    mask: Region {
        item: vcList
    }
}
