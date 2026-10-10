pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string currentFile
    property bool recording: false
    property real timestamp: 0

    function start() {
        socket.write("record\n");
        socket.flush();
    }

    function stop() {
        socket.write("stop\n");
        socket.flush();
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: socket.connected = true
    }

    Socket {
        id: socket
        path: `${Quickshell.env("XDG_RUNTIME_DIR")}/qs-screen-recorder`
        parser: SplitParser {
            onRead: data => {
                console.log(data);
                let idx = data.indexOf(":");
                if (idx === -1)
                    return;
                let evt = data.substring(0, idx);
                let val = data.substring(idx + 1);

                switch (evt) {
                case "start":
                    root.currentFile = val;
                    root.recording = true;
                    break;
                case "stop":
                case "idle":
                    root.recording = false;
                    root.timestamp = 0;
                    if (val !== "null") {
                        root.currentFile = val;
                    }
                    break;
                case "recording":
                    root.recording = true;
                    root.timestamp = parseFloat(val) / 1000;
                    break;
                }
            }
        }
    }
}
