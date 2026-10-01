import qs.modules.common
import qs.modules.end4
import qs.modules.end4.functions

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

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

    mask: Region {
        item: vcList
    }

    ColumnLayout {
        id: vcList

        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Repeater {
            model: DiscordVoiceRPC.members

            delegate: Item {
                id: user
                Layout.preferredHeight: row.height
                Layout.preferredWidth: row.width
                required property DiscordVoiceMember modelData
                Layout.alignment: Qt.AlignRight

                Rectangle {
                    id: nameBound
                    anchors.fill: parent
                    color: Appearance.material.myBackground
                }

                RowLayout {
                    id: row
                    spacing: 0
                    Item {
                        Layout.preferredHeight: nickname.height
                        Layout.preferredWidth: nickname.width + Appearance.space.large
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
                                pixelSize: Appearance.font.pixelSize.small
                                family: Appearance.font.family.pixel
                            }
                        }
                    }

                    ClippingRectangle {
                        id: avatarCircle
                        property real size: 30
                        implicitHeight: size
                        implicitWidth: size
                        StyledImage {
                            id: image
                            anchors.centerIn: parent
                            height: parent.height
                            width: height
                            cache: true
                            source: user.modelData.avatarURL
                        }
                        MultiEffect {
                            anchors.fill: image
                            source: image
                            visible: user.modelData.isTalking
                            brightness: 0.2
                        }
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border {
                                color: user.modelData.isTalking ? Appearance.material.myBackground : "#00000000"
                                Behavior on color {
                                    animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
                                }
                                width: 4
                            }
                        }
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border {
                                color: user.modelData.isTalking ? Appearance.material.myPrimary : "#00000000"
                                Behavior on color {
                                    animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
                                }
                                width: 3
                            }
                        }
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border {
                                color: user.modelData.isTalking ? Appearance.material.myBackground : "#00000000"
                                Behavior on color {
                                    animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
                                }
                                width: 1
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

                property real volume: user.modelData.volume
                onVolumeChanged: {
                    console.log("volume changed");
                    volumeRect.implicitHeight = volumeRect.preferredHeight;
                    volumeHideTimer.restart();
                }

                Timer {
                    id: volumeHideTimer
                    interval: 1000
                    onTriggered: volumeRect.implicitHeight = 0
                }

                ClippingRectangle {
                    id: volumeRect
                    property real preferredHeight: parent.height
                    implicitHeight: 0
                    Behavior on implicitHeight {
                        animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
                    }
                    implicitWidth: parent.width - image.width
                    color: Appearance.material.myBackground
                    StyledText {
                        anchors.centerIn: parent
                        text: `${Math.round(user.modelData.volume)}%`
                        color: Appearance.material.myOnBackground
                        font {
                            pixelSize: Appearance.font.pixelSize.small
                            family: Appearance.font.family.pixel
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: DiscordVoiceRPC.mute(user.modelData.userID, !user.modelData.isMute())
                    onWheel: wheel => {
                        try {
                            if (wheel.angleDelta.y > 0) {
                                DiscordVoiceRPC.volume(user.modelData.userID, user.modelData.volume + 1);
                            } else if (wheel.angleDelta.y < 0) {
                                DiscordVoiceRPC.volume(user.modelData.userID, user.modelData.volume - 1);
                            }
                            wheel.accepted = true;
                        } catch (e) {
                            console.error(e);
                        }
                    }
                }
            }
        }
    }
}
