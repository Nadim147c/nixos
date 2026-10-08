pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.end4
import qs.modules.end4.functions

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: root

    property list<QtObject> wallpapers: []

    Component {
        id: wallpaperData
        QtObject {
            property color color: "white"
            property string preview: ""
            property string filename: ""
        }
    }

    HyprlandFocusGrab {
        windows: [root]
        active: Toggle.wallpaper
        onCleared: Toggle.wallpaper = false
    }

    Process {
        id: wallpaperFinder
        running: true
        command: ["qs-wallpaper-list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const wallpapers = JSON.parse(text);
                const qtWallpapers = [];
                for (const wallpaper of wallpapers) {
                    const obj = wallpaperData.createObject(root, {
                        preview: wallpaper.preview || "",
                        filename: wallpaper.filename || "",
                        color: wallpaper.color || "white"
                    });
                    qtWallpapers.push(obj);
                }
                root.wallpapers = qtWallpapers;
            }
        }
    }

    anchors.bottom: true
    margins.bottom: 20

    implicitWidth: 1000
    implicitHeight: 500

    WlrLayershell.namespace: "quickshell:wallpaper"
    aboveWindows: true
    exclusiveZone: 0
    color: "transparent"

    Rectangle {
        id: body

        anchors.fill: parent
        color: Appearance.material.mySurfaceContainer
        RowLayout {
            anchors.fill: parent
            GridView {
                id: grid
                Layout.margins: spacing * 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: root.wallpapers
                property real spacing: Appearance.space.medium
                cellWidth: width / 4
                cellHeight: cellWidth / (16 / 9)

                delegate: Item {
                    id: delegateItem
                    required property var modelData
                    width: grid.cellWidth
                    height: grid.cellHeight
                    Item {
                        anchors.fill: parent
                        anchors.margins: grid.spacing / 2

                        Item {
                            id: preview
                            anchors.fill: parent
                            Image {
                                id: previewImage
                                asynchronous: true
                                cache: true
                                anchors.fill: parent
                                source: delegateItem.modelData.preview
                                fillMode: Image.PreserveAspectCrop
                            }
                            Rectangle {
                                anchors.fill: parent
                                opacity: mouseArea.containsMouse * 1
                                Behavior on opacity {
                                    animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
                                }
                                color: ColorUtils.transparentize(Appearance.material.myOnBackground, 0.9)
                            }
                        }

                        ShaderEffectSource {
                            id: imageSource
                            sourceItem: preview
                            hideSource: true
                            live: true
                        }

                        ShaderEffect {
                            anchors.fill: parent
                            visible: previewImage.status === Image.Ready

                            property variant imageTexture: imageSource
                            property color borderColor: delegateItem.modelData.color ?? "white"
                            property real imagePixelSize: 2.0
                            property real borderPixelSize: 4.0
                            property real radius: 3
                            property real borderWidth: 1.0
                            property vector2d shadowOffset: Qt.vector2d(3, 3)
                            property vector2d size: Qt.vector2d(width, height)

                            fragmentShader: "./pixel_image_border.frag.qsb"
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                console.log("app-launcher", "wallpaper", delegateItem.modelData.filename);
                                Quickshell.execDetached(["app-launcher", "wallpaper", delegateItem.modelData.filename]);
                            }
                        }
                    }
                }
            }
        }
    }

    ShaderEffectSource {
        id: bodySource
        sourceItem: body
        hideSource: true
        live: true
    }

    ShaderEffect {
        anchors.fill: parent

        property variant imageTexture: bodySource

        property color borderColor: Appearance.material.myOutline

        property real imagePixelSize: 1.0
        property real borderPixelSize: 5.0
        property real radius: 4
        property real borderWidth: 1.0
        property vector2d shadowOffset: Qt.vector2d(3, 3)
        property vector2d size: Qt.vector2d(width, height)

        fragmentShader: "./pixel_image_border.frag.qsb"
    }
}
