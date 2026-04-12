pragma ComponentBehavior: Bound
pragma Singleton

import qs.modules.common.models

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property RongColors material: RongColors {}
    property RongColors player: RongColors {}

    readonly property FontConfig font: FontConfig {}
    readonly property Space space: Space {}
    readonly property Round round: Round {}
    readonly property AnimationTime time: AnimationTime {}
    readonly property AnimationCurves animationCurves: AnimationCurves {}
    readonly property ExpressiveAnimations animation: ExpressiveAnimations {}

    function reloadTheme() {
        themeFileView.reload();
    }

    function applyPlayerColors(fileContent: string) {
        const json = JSON.parse(fileContent);
        for (let i = 0; i < json.colors.length; i++) {
            const color = json.colors[i];
            const key = "my" + color.name.pascal;
            if (root.player.hasOwnProperty(key)) {
                root.player[key] = color.value.hex_rgb;
            }
        }
    }

    function applyColors(fileContent) {
        const json = JSON.parse(fileContent);
        for (const key in json) {
            if (root.material.hasOwnProperty(key)) {
                root.material[key] = json[key];
            }
        }
    }

    FileView {
        id: themeFileView
        path: Quickshell.statePath("colors.json")
        watchChanges: true

        onFileChanged: {
            console.log("File changed, reloading...");
            themeFileView.reload();
        }
        onLoaded: {
            if (!themeFileView.loaded) {
                return;
            }
            const fileContent = themeFileView.text();
            try {
                root.applyColors(fileContent);
            } catch (e) {
                console.error("failed parse JSON: ", e, fileContent);
            }
        }
    }
}
