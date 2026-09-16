pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common.models

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property RongColors material: RongColors {}

    readonly property FontConfig font: FontConfig {}
    readonly property Space space: Space {}
    readonly property Round round: Round {}
    readonly property AnimationTime time: AnimationTime {}
    readonly property AnimationCurves animationCurves: AnimationCurves {}
    readonly property ExpressiveAnimations animation: ExpressiveAnimations {}

    function reloadTheme() {
        themeFileView.reload();
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
