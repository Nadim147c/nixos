pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: state
    property string qrcode: ""
    IpcHandler {
        target: "state"
        function set(key: string, value: string) {
            state[key] = value;
        }
    }
}
