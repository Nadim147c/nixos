pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property list<double> bars: []
    property double total: 0

    Process {
        id: process
        running: true
        command: ["qs-cava"]
        stdout: SplitParser {
            onRead: msg => {
                const parts = msg.split(";");

                let total = 0;
                const bars = [];
                for (let i = 0; i < 0xF; i++) {
                    const bar = parseInt(parts[i]) / 1000;
                    total += bar;
                    bars.push(bar);
                }
                root.bars = bars;
                root.total = total;
            }
        }
    }
}
