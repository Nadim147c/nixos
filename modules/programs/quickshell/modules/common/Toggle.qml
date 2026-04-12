pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: toggle
    property bool player: false
    property bool dock: false
    property bool wallpaper: false
    property bool clipboard: false
    property bool logout: false
    property bool panel: false
    property bool discord: true
    property bool launcher: false

    IpcHandler {
        target: "toggle"
        function set(key: string, value: string): void {
            switch (value) {
            case "toggle":
                toggle[key] = !toggle[key];
                break;
            case "true":
                toggle[key] = true;
                break;
            case "false":
                toggle[key] = false;
                break;
            }
        }
    }
}
