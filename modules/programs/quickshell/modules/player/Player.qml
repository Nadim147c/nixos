import qs.modules.common
import qs.modules.end4

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

    Item {
        id: sourceItem
        implicitHeight: body.height
        implicitWidth: body.width
    }

    ShaderEffectSource {
        id: contentTexture
        sourceItem: sourceItem
        hideSource: true
        live: true
    }

    ShaderEffect {
        anchors.fill: sourceItem

        property variant source: contentTexture
        property color borderCol: Appearance.player.myOutline
        property color shadowCol: Appearance.player.myShadow
        property color fillBG: Appearance.player.myBackground
        property real pixelSize: 3
        property real radius: 8
        property real borderWidth: 1.0
        property vector2d shadowOffset: Qt.vector2d(1.4, 2.0)
        property vector2d size: Qt.vector2d(width, height)
        fragmentShader: "./pixel_mask.frag.qsb"
    }

    Item {
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
                    implicitHeight: size
                    implicitWidth: size
                    Image {
                        id: coverArt
                        anchors.fill: parent
                        source: WaybarLyric.cover
                        fillMode: Image.PreserveAspectCrop
                        visible: false
                    }
                    ShaderEffectSource {
                        id: imageSource
                        sourceItem: coverArt
                        hideSource: true
                        live: true
                    }

                    ShaderEffect {
                        anchors.fill: parent

                        property variant imageTexture: imageSource

                        property color borderCol: Appearance.player.myOutline
                        property color shadowCol: Appearance.player.myShadow

                        property real pixelSize: 2.0
                        property real radius: 8
                        property real borderWidth: 1.0
                        property vector2d shadowOffset: Qt.vector2d(2, 2)
                        property vector2d size: Qt.vector2d(width, height)

                        // there are two version
                        // - pixel_image_border.frag will create pixel borders
                        // - pixel_image_border2.frag will create pixel borders and also pixelate the image
                        fragmentShader: "./pixel_image_border2.frag.qsb"
                    }
                }
                spacing: Appearance.space.large

                Item {
                    implicitWidth: content.width - coverArt.width - Appearance.space.large
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors {
                            fill: parent
                            topMargin: Appearance.space.small
                            bottomMargin: Appearance.space.big
                        }

                        StyledText {
                            Layout.fillWidth: true
                            color: Appearance.player.myOnBackground
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
                            color: Appearance.player.myOnSurfaceVariant
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
                                color: Appearance.player.myOnSurfaceVariant
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
                                color: Appearance.player.myOnSurfaceVariant
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
                                    color: Appearance.player.mySurfaceVariant
                                }

                                Rectangle {
                                    width: slider.offset - slider.gap
                                    height: parent.height
                                    radius: 1
                                    color: Appearance.player.myPrimary
                                }
                            }

                            handle: Rectangle {
                                id: handle
                                implicitHeight: slider.handleSize
                                implicitWidth: slider.handleSize

                                x: slider.offset
                                y: (parent.height - height) / 2

                                color: Appearance.player.mySurfaceVariant
                                border {
                                    width: 2
                                    color: Appearance.player.myPrimary
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
