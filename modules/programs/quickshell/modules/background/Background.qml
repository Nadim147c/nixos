pragma ComponentBehavior: Bound

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
    property real angle: Math.PI / 4 // 45 deg

    property int counter: 0

    function setWallpaper(path: string) {
        root.inverse = !root.inverse;
        effect.t = 0;
        if (!path && anim.running)
            return;

        wallpaperFileView.setText(path);

        if (!root.inverse) {
            if (bottom.wallpaper !== path) {
                bottom.wallpaper = path;
            }
        } else {
            if (top.wallpaper !== path) {
                top.wallpaper = path;
            }
        }

        // different type of transition
        const effects = ["./slide.frag.qsb", "./pixel_rand.frag.qsb", "./diamon_sweep.frag.qsb", "./circle_expand.frag.qsb", "./circle_shrink.frag.qsb", "./hexagon_expand.frag.qsb", "./hexagon_shrink.frag.qsb", "./fade.frag.qsb"];
        effect.fragmentShader = effects[root.counter % effects.length];
        root.counter++;

        console.log(effect.fragmentShader);

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
        function setAngle(deg: real): void {
            root.angle = deg * Math.PI / 180;
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

    SequentialAnimation {
        id: anim
        PauseAnimation {
            duration: 100
        }
        NumberAnimation {
            duration: 2000
            easing.type: Easing.OutQuart
            from: 0
            to: 1
            target: effect
            property: "t"
        }
        PropertyAction {
            target: effect
            property: "t"
            value: 1
        }

        onFinished: {
            if (!root.inverse) {
                top.wallpaper = "";
            } else {
                bottom.wallpaper = "";
            }
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

        property variant fromSource: root.inverse ? bottomTexture : topTexture
        property variant toSource: root.inverse ? topTexture : bottomTexture
        property real t: 0.0
        property point cursor: root.cursorNormalized
        property real angle: root.angle
        property point size: Qt.point(root.width, root.height)
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
