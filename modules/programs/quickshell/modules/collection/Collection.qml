pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.widgets

import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    anchors {
        bottom: true
        left: true
    }

    property real size: 20

    // raw urls as dropped
    property var urls: []
    // parsed: [{ raw, local, path, proxy, downloadable }]
    property var items: []

    readonly property var downloadable: items.filter(i => i.downloadable).map(i => i.raw)
    readonly property bool hasDownloadable: downloadable.length > 0

    readonly property var playTargets: items.map(i => i.local ? i.path : i.raw)

    readonly property var dragUris: items.map(i => {
        if (i.local) {
            let target = i.proxy ? i.proxy : i.path;
            return target ? "file://" + encodeURI(target) : "";
        }
        return i.raw;
    }).filter(u => u !== "")
    onDragUrisChanged: console.log(dragUris)

    WlrLayershell.namespace: "quickshell:collection"
    aboveWindows: true
    exclusiveZone: 0
    color: "transparent"
    implicitWidth: Math.max(buttons.implicitWidth, shape.implicitWidth)
    implicitHeight: Math.max(buttons.implicitHeight, shape.implicitHeight, root.size)

    function parse(list) {
        const out = [];
        for (const u of list) {
            const s = String(u).trim();
            if (!s)
                continue;
            try {
                const url = new URL(s);
                if (url.protocol === "file:") {
                    out.push({
                        raw: s,
                        local: true,
                        path: decodeURIComponent(url.pathname),
                        proxy: "",
                        downloadable: false
                    });
                } else {
                    out.push({
                        raw: s,
                        local: false,
                        path: "",
                        proxy: "",
                        downloadable: ["http:", "https:", "ftp:", "ftps:"].includes(url.protocol)
                    });
                }
            } catch (e) {
                // not a valid url, ignore
            }
        }
        return out;
    }

    function setUrls(list) {
        urls = list;
        items = parse(list);

        const paths = items.filter(i => i.local).map(i => i.path);
        proxyProc.running = false;
        if (paths.length > 0) {
            proxyProc.command = ["qs-collection-proxy", ...paths];
            proxyProc.running = true;
        }
    }

    function clear() {
        const proxies = items.filter(i => i.proxy).map(i => i.proxy);
        if (proxies.length > 0)
            Quickshell.execDetached(["rm", "-f", ...proxies]);
        urls = [];
        items = [];
    }

    function runInTerminal(...cmdline) {
        console.log("qs-run-terminal", ...cmdline);
        Quickshell.execDetached(["qs-run-terminal", ...cmdline]);
    }

    function playMpv() {
        Quickshell.execDetached(["mpv", ...playTargets]);
    }

    Process {
        id: proxyProc
        stdout: StdioCollector {
            onStreamFinished: {
                const map = {};
                for (const line of text.split("\n")) {
                    const parts = line.split("\t");
                    if (parts.length === 2)
                        map[parts[0]] = parts[1];
                }
                root.items = root.items.map(i => i.local && map[i.path] ? Object.assign({}, i, {
                        proxy: map[i.path]
                    }) : i);
            }
        }
    }

    ColumnLayout {
        id: buttons
        visible: root.items.length > 0
        spacing: 0

        Btn {
            visible: root.hasDownloadable
            icon: "󰗃"
            text: "Download (yt-dlp)"
            onClicked: root.runInTerminal("yt-dlp", ...root.urls)
        }
        Btn {
            visible: root.hasDownloadable
            icon: ""
            text: "Download (aria2c)"
            onClicked: root.runInTerminal("aria2c", ...root.urls)
        }
        Btn {
            icon: ""
            text: "Play on mpv"
            onClicked: root.playMpv()
        }

        // drag out: hands over proxied files (~/.portal) + remote urls
        RetroButton {
            id: dragBtn
            Layout.leftMargin: Appearance.space.big
            enabled: root.dragUris.length > 0

            Drag.active: dragHandler.active && root.dragUris.length > 0
            Drag.dragType: Drag.Automatic
            Drag.supportedActions: Qt.CopyAction
            Drag.proposedAction: Qt.CopyAction
            Drag.mimeData: ({
                    "text/uri-list": root.dragUris.join("\r\n") + "\r\n"
                })
            DragHandler {
                id: dragHandler
                target: null
            }

            Item {
                implicitHeight: row1.height + (Appearance.space.small * 2)
                implicitWidth: row1.width + (Appearance.space.small * 2)
                RowLayout {
                    id: row1
                    anchors.centerIn: parent
                    Text {
                        color: Appearance.material.myOnBackground
                        text: "󰹇"
                        font.family: Appearance.font.family.iconNerd
                        font.pixelSize: Appearance.font.pixelSize.large
                    }
                    Text {
                        color: Appearance.material.myOnBackground
                        text: "Drag"
                        font.family: Appearance.font.family.pixel
                        font.pixelSize: Appearance.font.pixelSize.large
                    }
                }
            }
        }

        Btn {
            icon: ""
            text: "Clear"
            onClicked: root.clear()
        }
    }

    component Btn: RetroButton {
        id: btn
        Layout.leftMargin: Appearance.space.big
        required property string icon
        required property string text
        property string iconFont: Appearance.font.family.iconNerd
        Item {
            implicitHeight: row.height + (Appearance.space.small * 2)
            implicitWidth: row.width + (Appearance.space.small * 2)
            RowLayout {
                id: row
                anchors.centerIn: parent
                Text {
                    color: Appearance.material.myOnBackground
                    text: btn.icon
                    font.family: Appearance.font.family.iconNerd
                    font.pixelSize: Appearance.font.pixelSize.large
                }
                Text {
                    color: Appearance.material.myOnBackground
                    text: btn.text
                    font.family: Appearance.font.family.pixel
                    font.pixelSize: Appearance.font.pixelSize.large
                }
            }
        }
    }

    Pixelate {
        id: shape
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: strokeWidth / 2
        color: "transparent"

        implicitHeight: dropArea.dragging ? root.size : 0
        implicitWidth: dropArea.dragging ? root.size : 0

        Behavior on implicitHeight {
            animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        Behavior on implicitWidth {
            animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
        }

        property real strokeWidth: 4
        Shape {
            ShapePath {
                startX: 0
                startY: 0

                strokeWidth: shape.strokeWidth
                strokeColor: Appearance.material.myOutline
                fillColor: Appearance.material.mySurfaceContainerHighest

                PathLine {
                    x: 0
                    y: shape.height
                }
                PathLine {
                    x: shape.width
                    y: shape.height
                }
                PathLine {}
            }
        }
    }

    DropArea {
        id: dropArea
        height: root.size
        width: root.size
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        property bool dragging: false

        onPositionChanged: drag => {
            const x = drag.x;
            const y = height - drag.y;
            dragging = x + y < height;
        }
        onExited: dragging = false
        onDropped: drop => {
            if (!dragging) {
                return;
            }
            dragging = false;

            let list = [];
            if (drop.hasUrls) {
                list = Array.from(drop.urls, u => u.toString());
            } else if (drop.hasText) {
                list = drop.text.split(/\r?\n/);
            }
            if (list.length === 0) {
                return;
            }
            drop.accepted = true;
            root.setUrls(list);
        }
    }
}
