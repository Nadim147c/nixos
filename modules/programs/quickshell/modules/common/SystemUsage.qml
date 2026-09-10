pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real cpuFrequency
    property string cpuFrequencyString
    property real cpuTemperature
    property string cpuTemperatureString
    property real cpuUtilization
    property real memAvailable
    property string memAvailableString
    property real memSwapFree
    property string memSwapFreeString
    property real memSwapTotal
    property string memSwapTotalString
    property real memTotal
    property string memTotalString
    property real memUsed
    property string memUsedString
    property real netDown
    property string netDownString
    property real netName
    property real netTotal
    property string netTotalString
    property real netTotalDown
    property string netTotalDownString
    property real netTotalUp
    property string netTotalUpString
    property real netUp
    property string netUpString

    Process {
        id: net
        running: true
        command: ["qs-system-usage"]
        stdout: SplitParser {
            onRead: data => {
                const stats = JSON.parse(data);
                for (const key in stats) {
                    root[key] = stats[key];
                }
            }
        }
    }
}
