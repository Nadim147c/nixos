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

                        fragmentShader: "./pixel_image_border.frag.qsb"
                    }
                }
                spacing: Appearance.space.large

                ColumnLayout {
                    id: control
                    implicitWidth: content.width - coverArt.width - Appearance.space.large
                    Item {
                        implicitWidth: control.width
                        implicitHeight: trackTitle.height
                        StyledText {
                            id: trackTitle
                            width: control.width
                            color: Appearance.player.myOnBackground
                            text: WaybarLyric.title || "Untitled"
                            elide: Text.ElideRight
                            animateChange: true
                            animationDistanceX: 6
                            animationDistanceY: 0
                            font.family: Appearance.font.family.pixel
                            font.pixelSize: Appearance.font.pixelSize.larger
                        }
                    }
                    Item {
                        implicitWidth: control.width
                        implicitHeight: trackArtist.height
                        StyledText {
                            id: trackArtist
                            width: control.width
                            color: Appearance.player.myOnSurfaceVariant
                            text: WaybarLyric.artist || "Untitled"
                            elide: Text.ElideRight
                            animateChange: true
                            animationDistanceX: 6
                            animationDistanceY: 0
                            font.family: Appearance.font.family.pixel
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                    Item {
                        implicitWidth: control.width
                        implicitHeight: trackArtist.height
                        StyledText {
                            width: control.width
                            color: Appearance.player.myOnSurfaceVariant
                            text: WaybarLyric.album || "Single"
                            elide: Text.ElideRight
                            animateChange: true
                            animationDistanceX: 6
                            animationDistanceY: 0
                            font.family: Appearance.font.family.pixel
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                    Item {
                        implicitHeight: buttons.height
                        implicitWidth: control.width
                        PlayerButtons {
                            id: buttons
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                    Slider {
                        id: slider
                        Layout.fillWidth: true
                        implicitHeight: 10
                        value: WaybarLyric.position / (WaybarLyric.player?.length || WaybarLyric.position)
                        onMoved: {
                            WaybarLyric.player.position = value * (WaybarLyric.player?.length || WaybarLyric.position);
                        }
                        live: true

                        Behavior on value {
                            SmoothedAnimation {
                                velocity: Appearance.animation.elementMoveFast.velocity
                            }
                        }

                        background: Item {
                            anchors.verticalCenter: parent.verticalCenter
                            implicitWidth: control.width
                            height: 5

                            Rectangle {
                                anchors.fill: parent
                                color: Appearance.player.mySurfaceVariant
                            }

                            Rectangle {
                                width: slider.visualPosition * parent.width
                                height: parent.height
                                color: Appearance.player.myPrimary
                            }
                        }

                        handle: Rectangle {
                            id: handle
                            property real size: 15
                            implicitHeight: size
                            implicitWidth: size

                            x: slider.visualPosition * (slider.width - width)
                            y: (parent.height - height) / 2
                            Behavior on y {
                                animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
                            }

                            color: Appearance.player.mySurfaceVariant
                            border {
                                width: 2
                                color: Appearance.player.myOutline
                            }
                        }
                    }
                    Item {
                        Layout.fillHeight: true
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
