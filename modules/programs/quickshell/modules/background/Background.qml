pragma ComponentBehavior: Bound

import qs.modules.common

import QtMultimedia
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        right: true
        left: true
    }

    WlrLayershell.namespace: "quickshell:background"
    WlrLayershell.layer: WlrLayer.Background
    exclusionMode: ExclusionMode.Ignore

    color: "transparent"

    property bool filled: Hyprland.focusedWorkspace.hasFullscreen || Hyprland.focusedWorkspace.toplevels.values.some(x => !x.lastIpcObject.floating)
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "changefloatingmode")
                Hyprland.refreshToplevels();
        }
    }
    property bool inverse: false
    property point cursorNormalized: Qt.point(0.5, 0.5)

    property int counter: 0

    function setWallpaper(path: string) {
        if (!path && anim.running)
            return;

        wallpaperFileView.setText(path);

        if (root.inverse) {
            if (bottom.wallpaper === path)
                return;
            bottom.wallpaper = path;
        } else {
            if (top.wallpaper === path)
                return;
            top.wallpaper = path;
        }

        root.counter++;
        // different type of transition
        const effects = ["./pixel_rand.frag.qsb", "./diamon_sweep.frag.qsb", "./circle_expand.frag.qsb", "./circle_shrink.frag.qsb", "./hexagon_expand.frag.qsb", "./hexagon_shrink.frag.qsb", "./dissolve.frag.qsb"];
        effect.fragmentShader = effects[root.counter % effects.length];

        effect.progress = root.inverse * 1.0;
        anim.restart();
    }

    function setCursorPosition(x: real, y: real) {
        root.cursorNormalized = Qt.point(x / width, y / height);
    }

    IpcHandler {
        target: "wallpaper"
        function set(path: string): void {
            root.setWallpaper(path);
        }
        function setCursor(x: real, y: real): void {
            root.setCursorPosition(x, y);
        }
    }

    FileView {
        id: wallpaperFileView
        path: Quickshell.statePath("wallpaper.txt")
        blockWrites: true
        onLoaded: {
            if (!wallpaperFileView.loaded)
                return;
            root.setWallpaper(wallpaperFileView.text().trim());
        }
    }

    Component.onCompleted: wallpaperFileView.reload()

    NumberAnimation {
        id: anim
        duration: Appearance.time.slow
        easing.type: Easing.OutQuart
        from: root.inverse * 1.0
        to: (!root.inverse) * 1.0
        target: effect
        property: "progress"
        onFinished: {
            if (root.inverse) {
                top.wallpaper = "";
            } else {
                bottom.wallpaper = "";
            }
            root.inverse = !root.inverse;
        }
    }

    Wallpaper {
        id: bottom
        name: "bottom"
        paused: root.filled
        visible: false
    }

    Wallpaper {
        id: top
        name: "top"
        visible: false
        paused: root.filled
    }

    ShaderEffectSource {
        id: bottomTexture
        sourceItem: bottom
        hideSource: true
        live: true
    }

    ShaderEffectSource {
        id: topTexture
        sourceItem: top
        hideSource: true
        live: true
    }

    ShaderEffect {
        id: effect
        anchors.fill: parent

        property variant bottomTex: bottomTexture
        property variant topTex: topTexture
        property real progress: 0.0
        property bool inversed: root.inverse
        property point cursor: root.cursorNormalized
        property point resolution: Qt.point(root.width, root.height)
        property real aspect: root.width / root.height

        fragmentShader: "./template.frag.qsb"
    }

    component Wallpaper: Loader {
        id: loader
        property string wallpaper: ""
        property string name: ""
        required property bool paused

        anchors.fill: parent
        active: wallpaper !== ""
        onActiveChanged: !active && console.log(`Wallpaper ${name} has been unloaded`)

        sourceComponent: Video {
            anchors.fill: parent
            source: loader.wallpaper ? `file://${loader.wallpaper}` : ""
            property bool isPaused: loader.paused
            onIsPausedChanged: isPaused ? pause() : play()
            autoPlay: true
            muted: true
            loops: -1
            fillMode: VideoOutput.PreserveAspectCrop
        }
    }
}
