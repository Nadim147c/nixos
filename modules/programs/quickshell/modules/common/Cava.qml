pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Individual double properties avoid JS Array wrapping allocations entirely
    property double b0: 0
    property double b1: 0
    property double b2: 0
    property double b3: 0
    property double b4: 0
    property double b5: 0
    property double b6: 0
    property double b7: 0
    property double b8: 0
    property double b9: 0
    property double b10: 0
    property double b11: 0
    property double b12: 0
    property double b13: 0
    property double b14: 0

    // Helper method to fetch value by index dynamically
    function getBar(i) {
        switch (i) {
        case 0:
            return b0;
        case 1:
            return b1;
        case 2:
            return b2;
        case 3:
            return b3;
        case 4:
            return b4;
        case 5:
            return b5;
        case 6:
            return b6;
        case 7:
            return b7;
        case 8:
            return b8;
        case 9:
            return b9;
        case 10:
            return b10;
        case 11:
            return b11;
        case 12:
            return b12;
        case 13:
            return b13;
        case 14:
            return b14;
        default:
            return 0;
        }
    }

    property double total: 0
    property bool mute: true

    onTotalChanged: {
        if (total === 0) {
            muteTimer.start();
        } else {
            mute = false;
        }
    }

    Timer {
        id: muteTimer
        interval: 2000
        onTriggered: root.mute = !root.total
    }

    Process {
        id: process
        running: true
        command: ["qs-cava"]
        stdout: SplitParser {
            onRead: msg => {
                const parts = msg.split(";");
                if (parts.length < 15)
                    return;

                // Direct double assignments (primitive values, zero heap allocations)
                root.b0 = (parseInt(parts[0]) || 0) / 1000;
                root.b1 = (parseInt(parts[1]) || 0) / 1000;
                root.b2 = (parseInt(parts[2]) || 0) / 1000;
                root.b3 = (parseInt(parts[3]) || 0) / 1000;
                root.b4 = (parseInt(parts[4]) || 0) / 1000;
                root.b5 = (parseInt(parts[5]) || 0) / 1000;
                root.b6 = (parseInt(parts[6]) || 0) / 1000;
                root.b7 = (parseInt(parts[7]) || 0) / 1000;
                root.b8 = (parseInt(parts[8]) || 0) / 1000;
                root.b9 = (parseInt(parts[9]) || 0) / 1000;
                root.b10 = (parseInt(parts[10]) || 0) / 1000;
                root.b11 = (parseInt(parts[11]) || 0) / 1000;
                root.b12 = (parseInt(parts[12]) || 0) / 1000;
                root.b13 = (parseInt(parts[13]) || 0) / 1000;
                root.b14 = (parseInt(parts[14]) || 0) / 1000;

                root.total = root.b0 + root.b1 + root.b2 + root.b3 + root.b4 + root.b5 + root.b6 + root.b7 + root.b8 + root.b9 + root.b10 + root.b11 + root.b12 + root.b13 + root.b14;
            }
        }
    }
}
