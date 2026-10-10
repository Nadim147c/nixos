pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool hasDevice: false
    property string targetDeviceID: ""
    property list<string> devices: []

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.refreshDevices()
    }

    Process {
        id: listProcess
        running: true
        command: ["kdeconnect-cli", "--list-available", "--id-only"]
        stdout: SplitParser {
            onRead: msg => {
                root.parseDeviceList(msg);
            }
        }
    }

    function refreshDevices() {
        listProcess.running = false;
        listProcess.running = true;
    }

    function parseDeviceList(output: string) {
        let lines = output.trim().split("\n");
        let validIds = [];

        for (let i = 0; i < lines.length; ++i) {
            let id = lines[i].trim();
            if (id.length > 0) {
                validIds.push(id);
            }
        }

        devices = validIds;
        hasDevice = devices.length > 0;
        targetDeviceID = hasDevice ? devices[0] : "";
    }

    function ping() {
        console.log("[Kdeconnect]", "pinging", targetDeviceID);
        Quickshell.execDetached(["kdeconnect-cli", "--device", targetDeviceID, "--ping"]);
    }

    function ring() {
        console.log("[Kdeconnect]", "ringing", targetDeviceID);
        Quickshell.execDetached(["kdeconnect-cli", "--device", targetDeviceID, "--ring"]);
    }

    function shareFile(filePath: string) {
        console.log("[Kdeconnect]", `sending ${filePath} to ${targetDeviceID}`);
        Quickshell.execDetached(["kdeconnect-cli", "--device", targetDeviceID, "--share", filePath]);
    }
}
