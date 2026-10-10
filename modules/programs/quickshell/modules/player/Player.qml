import qs.modules.common
import qs.modules.end4
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: player

    anchors {
        top: true
    }

    implicitWidth: body.width
    implicitHeight: Math.max(500, body.height)

    WlrLayershell.namespace: "quickshell:player"

    aboveWindows: true
    exclusiveZone: 0

    color: "transparent"

    HyprlandFocusGrab {
        windows: [player]
        active: Toggle.player
        onCleared: Toggle.player = false
    }

    mask: Region {
        item: body
    }

    Card {
        id: body
        implicitWidth: 450
        implicitHeight: content.height + (Appearance.space.large * 2)
        ColumnLayout {
            id: content
            width: parent.width - (Appearance.space.large * 2)
            x: Appearance.space.large
            y: Appearance.space.large
            spacing: 0

            RowLayout {
                Item {
                    property real size: 150
                    Layout.preferredWidth: size
                    Layout.preferredHeight: size
                    Card {
                        anchors.fill: parent
                        radius: 3
                        borderWidth: 1
                        borderPixelSize: 3
                        KuwaharaFilter {
                            anchors.fill: parent
                            kuwaharaStrength: 0.67
                            bitDepth: 4
                            pixelSize: 2.0
                            Image {
                                source: WaybarLyric.cover
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                            }
                        }
                    }
                }
                spacing: Appearance.space.large

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    ColumnLayout {
                        anchors {
                            fill: parent
                            topMargin: Appearance.space.small
                            bottomMargin: Appearance.space.big
                        }

                        StyledText {
                            Layout.fillWidth: true
                            color: Appearance.material.myOnBackground
                            text: WaybarLyric.title || "Untitled"
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            animateChange: true
                            animationDistanceX: 6
                            animationDistanceY: 0
                            font.family: Appearance.font.family.pixel
                            font.pixelSize: Appearance.font.pixelSize.larger
                        }

                        StyledText {
                            Layout.fillWidth: true
                            color: Appearance.material.myOnSurfaceVariant
                            text: `  ${WaybarLyric.artist || "Unknown Artist"}`
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            animateChange: true
                            animationDistanceX: 6
                            animationDistanceY: 0
                            font.family: Appearance.font.family.pixel
                            font.pixelSize: Appearance.font.pixelSize.small
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            Text {
                                Layout.fillWidth: true
                                color: Appearance.material.myOnSurfaceVariant
                                text: `󰀥  ${WaybarLyric.album || "Single"}`
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignRight
                                font.family: Appearance.font.family.pixel
                                font.pixelSize: Appearance.font.pixelSize.small
                            }
                            Item {
                                Layout.preferredWidth: Appearance.space.medium
                            }
                            Text {
                                Layout.fillWidth: true
                                color: Appearance.material.myOnSurfaceVariant
                                text: `   ${WaybarLyric.player.identity || "Unknow Player"}`
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignLeft
                                font.family: Appearance.font.family.pixel
                                font.pixelSize: Appearance.font.pixelSize.small
                            }
                        }

                        Item {
                            implicitHeight: buttons.height
                            Layout.fillWidth: true
                            PlayerButtons {
                                id: buttons
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        Slider {
                            id: slider
                            Layout.fillWidth: true
                            implicitHeight: 10
                            value: WaybarLyric.position / (WaybarLyric.player?.length || WaybarLyric.position)
                            onMoved: {
                                WaybarLyric.player.position = Utils.clamp(0, value, 0.99) * (WaybarLyric.player?.length || WaybarLyric.position);
                            }
                            live: true

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onPressed: mouse => mouse.accepted = false
                            }

                            property real gap: 3
                            property real handleSize: 15
                            property real offset: visualPosition * (width - handleSize)
                            Behavior on offset {
                                animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
                            }

                            background: Item {
                                implicitWidth: slider.width
                                y: (parent.height - height) / 2
                                height: 5 + ((slider.hovered || slider.pressed) * 2)
                                Behavior on height {
                                    animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
                                }

                                Rectangle {
                                    anchors.right: parent.right
                                    height: parent.height
                                    width: slider.width - slider.offset - slider.handleSize - slider.gap
                                    radius: 1
                                    color: Appearance.material.mySurfaceVariant
                                }

                                Rectangle {
                                    width: slider.offset - slider.gap
                                    height: parent.height
                                    radius: 1
                                    color: Appearance.material.myPrimary
                                }
                            }

                            handle: Pixelate {
                                implicitHeight: slider.handleSize
                                implicitWidth: slider.handleSize
                                x: slider.offset
                                y: (parent.height - height) / 2

                                Rectangle {
                                    id: handle
                                    anchors.fill: parent
                                    radius: width / 2

                                    color: Appearance.material.mySurfaceVariant
                                    border {
                                        width: 2
                                        color: Appearance.material.myPrimary
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                visible: WaybarLyric.lines.length !== 0
                Layout.fillWidth: true
                implicitHeight: Appearance.space.little
            }

            Revealer {
                reveal: WaybarLyric.lines.length !== 0
                vertical: true
                Item {
                    implicitHeight: lyrics.height + Appearance.space.big
                    implicitWidth: content.width
                    PlayerLyrics {
                        id: lyrics
                        y: Appearance.space.big
                        implicitWidth: content.width
                    }
                }
            }
        }
    }
}
