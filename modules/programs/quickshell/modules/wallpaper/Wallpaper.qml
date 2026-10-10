pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.end4
import qs.modules.end4.functions
import qs.modules.widgets

import OkLab
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

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

    property string status

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
    implicitHeight: 400

    WlrLayershell.namespace: "quickshell:wallpaper"
    aboveWindows: true
    exclusiveZone: 0
    color: "transparent"

    Card {
        anchors.fill: parent

        borderColor: Appearance.material.myOutline
        color: Appearance.material.myBackground
        radius: 4
        borderWidth: 1
        borderPixelSize: 3

        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            Item {
                id: titleBarItem
                Layout.fillWidth: true
                Layout.preferredHeight: 40
            }
            ClippingRectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Appearance.material.mySurface
                GridView {
                    id: grid
                    anchors.fill: parent
                    anchors.margins: spacing * 2
                    model: root.wallpapers
                    property real spacing: Appearance.space.medium
                    cellWidth: width / 4
                    cellHeight: cellWidth / (16 / 9)

                    delegate: Item {
                        id: delegateItem
                        required property var modelData
                        required property int index
                        width: grid.cellWidth
                        height: grid.cellHeight
                        Item {
                            anchors.fill: parent
                            anchors.margins: grid.spacing / 2

                            Card {
                                id: preview
                                anchors.fill: parent

                                borderColor: {
                                    const lab = OkLab.fromColor(delegateItem.modelData.color);
                                    lab.l = 0.5;
                                    return OkLab.toColor(lab);
                                }
                                SequentialAnimation {
                                    id: flicker
                                    property real totalDuration: 1000
                                    property real stepDuration: totalDuration / (loops * 2)
                                    loops: 2
                                    PropertyAnimation {
                                        target: brightness
                                        property: "brightness"
                                        duration: flicker.stepDuration
                                        from: 0
                                        to: 0.2
                                        easing.type: Easing.InOutExpo
                                    }
                                    PropertyAnimation {
                                        target: brightness
                                        property: "brightness"
                                        duration: flicker.stepDuration
                                        from: 0.2
                                        to: 0
                                        easing.type: Easing.InOutExpo
                                    }
                                }
                                radius: 3
                                borderWidth: 1
                                borderPixelSize: 4
                                Pixelate {
                                    anchors.fill: parent
                                    pixelSize: 2
                                    levels: 16
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

                            StyledText {
                                visible: mouseArea.containsMouse
                                anchors.fill: parent
                                text: `SLOT ${delegateItem.index.toString().padStart(2, "0")}`
                                verticalAlignment: Qt.AlignVCenter
                                horizontalAlignment: Qt.AlignHCenter
                                color: ColorUtils.transparentize(Appearance.material.myOnBackground, 0.1)
                                font {
                                    family: Appearance.font.family.pixel2
                                    pixelSize: Appearance.font.pixelSize.normal * 2
                                }
                            }

                            MultiEffect {
                                id: brightness
                                source: parent
                                anchors.fill: parent
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                enabled: true
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mouse => {
                                    flicker.restart();
                                    console.log("app-launcher", "wallpaper", delegateItem.modelData.filename);
                                    root.status = `Slot ${delegateItem.index.toString().padStart(2, "0")} selected...`;
                                    Quickshell.execDetached(["app-launcher", "wallpaper", delegateItem.modelData.filename]);
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: titleBar
            x: titleBarItem.x
            y: titleBarItem.y
            height: titleBarItem.height
            width: titleBarItem.width
            color: Appearance.material.mySurfaceVariant

            // Capture mouse events on the title bar overlay to prevent grid
            // items from receiving hover and click inputs when partially scrolled underneath
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                StyledText {
                    Layout.fillHeight: true
                    text: "[ WALLPAPER.EXE ]"
                    font.pixelSize: Appearance.font.pixelSize.hugeass
                    font.family: Appearance.font.family.pixel2
                }

                StyledText {
                    Layout.fillHeight: true
                    visible: !!root.status
                    text: `(${root.status})`
                    color: Appearance.material.myOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.large
                    font.family: Appearance.font.family.pixel2
                }

                Item {
                    Layout.fillWidth: true
                }

                RetroButton {
                    Layout.topMargin: 3
                    onClicked: {
                        const filename = root.wallpapers[Math.floor(Math.random() * root.wallpapers.length)].filename;
                        console.log("app-launcher", "wallpaper", filename);
                        root.status = "Random slot selected...";
                        Quickshell.execDetached(["app-launcher", "wallpaper", filename]);
                    }
                    Layout.preferredHeight: 30
                    StyledText {
                        anchors.fill: parent
                        anchors.margins: 3
                        color: Appearance.material.myOnBackground
                        text: "star"
                        fontSizeMode: Text.Fit
                        font {
                            family: Appearance.font.family.iconPixel
                            pixelSize: Appearance.font.pixelSize.hugeass
                            bold: true
                        }
                    }
                }

                RetroButton {
                    Layout.topMargin: 3
                    onClicked: Toggle.wallpaper = false
                    Layout.preferredHeight: 30
                    StyledText {
                        anchors.fill: parent
                        anchors.margins: 1
                        color: Appearance.material.myOnBackground
                        text: "close"
                        fontSizeMode: Text.Fit
                        font {
                            family: Appearance.font.family.iconPixel
                            pixelSize: Appearance.font.pixelSize.hugeass
                            bold: true
                        }
                    }
                }
            }
        }
    }
}
