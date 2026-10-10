pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.end4.functions
import qs.modules.widgets

import OkLab
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
    implicitHeight: 330

    WlrLayershell.namespace: "quickshell:wallpaper"
    aboveWindows: true
    exclusiveZone: 0
    color: "transparent"

    Card {
        anchors.fill: parent

        borderColor: Appearance.material.myOutline
        color: Appearance.material.myBackground
        radius: 6
        borderWidth: 2
        borderPixelSize: 3

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

                        Card {
                            id: preview
                            anchors.fill: parent

                            borderColor: delegateItem.modelData.color
                            property color highlightColor: {
                                const ok = OkLab.fromColor(delegateItem.modelData.color);
                                ok.l += 0.2;
                                return OkLab.toColor(ok);
                            }
                            FlickerAnimation {
                                id: flicker
                                target: preview
                                property: "borderColor"
                                baseColor: preview.borderColor
                                highlightColor: preview.highlightColor
                                totalDuration: 1000
                                stepDuration: totalDuration / 3
                            }
                            radius: 3
                            borderWidth: 1
                            borderPixelSize: 4
                            Pixelate {
                                anchors.fill: parent
                                pixelSize: 2
                                colorsPerChannel: 16
                                Image {
                                    id: previewImage
                                    asynchronous: true
                                    cache: true
                                    anchors.fill: parent
                                    source: delegateItem.modelData.preview
                                    fillMode: Image.PreserveAspectCrop
                                }
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
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                flicker.restart();
                                console.log("app-launcher", "wallpaper", delegateItem.modelData.filename);
                                Quickshell.execDetached(["app-launcher", "wallpaper", delegateItem.modelData.filename]);
                            }
                        }
                    }
                }
            }
        }
    }
}
