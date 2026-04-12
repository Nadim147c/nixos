pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
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
            property string preview: ""
            property string filename: ""
        }
    }

    property string filename: ""
    onFilenameChanged: generate(filename)
    property var palette: []

    function generate(filename) {
        console.log("[Wallpaper]", "Generating colors for", filename);
        rongColors.exec(["rong", "score", "-m2", filename]);
    }

    Process {
        id: rongColors
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const colors = JSON.parse(text);
                    root.palette = colors;
                } catch (e) {
                    console.log(text);
                    console.error(e);
                }
            }
        }
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
                        preview: wallpaper.preview,
                        filename: wallpaper.filename
                    });
                    qtWallpapers.push(obj);
                }
                root.wallpapers = qtWallpapers;
                root.filename = qtWallpapers[0].filename;
            }
        }
    }

    anchors.bottom: true
    margins.bottom: 10

    implicitWidth: body.width
    implicitHeight: body.height + popupBody.expandedHeight + Appearance.space.big

    WlrLayershell.namespace: "quickshell:wallpaper"
    aboveWindows: true
    exclusiveZone: 0
    color: "transparent"

    HyprlandFocusGrab {
        windows: [root]
        active: Toggle.wallpaper
        onCleared: Toggle.wallpaper = false
    }

    Rectangle {
        id: popupBody
        anchors.horizontalCenter: parent.horizontalCenter
        property real expandedHeight: 30 + (Appearance.space.medium * 2)
        implicitHeight: root.palette.length > 0 ? expandedHeight : 0
        implicitWidth: popupRow.width + (Appearance.space.medium * 2)
        Behavior on implicitWidth {
            animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        radius: Appearance.round.big
        color: Appearance.material.myBackground
        RowLayout {
            id: popupRow
            anchors.centerIn: parent
            Repeater {
                model: root.palette
                MaterialLoading {
                    id: palette
                    required property string modelData
                    property int value: parseInt(modelData.substring(1), 16)
                    shape: shapes[value % shapes.length]
                    color: modelData
                    animate: false
                    implicitHeight: 30
                    implicitWidth: implicitHeight
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            console.log("wallpaper", `--color=${palette.modelData}`, root.filename);
                            Quickshell.execDetached(["wallpaper", `--color=${palette.modelData}`, root.filename]);
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: body
        anchors.bottom: parent.bottom
        implicitHeight: content.height + (Appearance.space.big * 2)
        implicitWidth: content.width + (Appearance.space.big * 2)
        radius: Appearance.round.huge
        color: Appearance.material.myBackground
        ClippingRectangle {
            id: content
            x: Appearance.space.big
            y: Appearance.space.big
            implicitHeight: row.height
            implicitWidth: row.width
            radius: Appearance.round.larger
            color: "transparent"

            ListView {
                id: row
                height: 150
                width: 750
                model: root.wallpapers
                orientation: ListView.Horizontal
                spacing: Appearance.space.big
                delegate: Item {
                    id: listItem
                    required property string preview
                    required property string filename
                    required property int index
                    width: 150
                    height: 150
                    readonly property real visibleAmount: {
                        let start = row.contentX;
                        if (start < 0 && index === 0) {
                            return -start + width;
                        }
                        let end = row.contentX + row.width;
                        if (end > row.contentWidth && index === row.model.length - 1) {
                            return row.contentWidth - end - width;
                        }
                        let imageStart = x;
                        let imageEnd = x + width;
                        if (imageStart > start && imageEnd > end) {
                            return imageStart - end; // returns negative
                        }
                        if (imageStart < start && imageStart < end) {
                            return imageEnd - start;
                        }
                        return width; // we use to default to avoid weirdness
                    }
                    Item {
                        height: parent.height
                        width: Math.abs(listItem.visibleAmount)
                        x: listItem.visibleAmount > 0 ? listItem.width - listItem.visibleAmount : 0
                        ClippingRectangle {
                            anchors.fill: parent
                            radius: Appearance.round.big
                            Image {
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                source: listItem.preview
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.filename = listItem.filename
                            onClicked: {
                                console.log("wallpaper", listItem.filename);
                                Quickshell.execDetached(["wallpaper", listItem.filename]);
                            }
                        }
                    }
                }
            }
        }
    }
}
