import qs.modules.common

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    anchors {
        left: true
        top: true
        right: true
    }
    aboveWindows: false

    property real margin: 5

    color: "transparent"
    property color bg: Appearance.material.myBackground

    WlrLayershell.namespace: "quickshell:bar"

    property real borderRadius: Appearance.space.large

    implicitHeight: 32 + root.margin
    exclusiveZone: implicitHeight

    Item {
        id: body
        implicitHeight: 32
        implicitWidth: parent.width - (root.margin * 2)
        y: root.margin
        x: root.margin

        RowLayout {
            id: rootRow
            height: parent.height
            width: parent.width
            spacing: Appearance.space.medium

            BarWorkspaces {}
            BarCava {}
            BarPlayerButtons {}
            BarLyrics {}
            BarNetwork {}
            BarVolume {}
            BarRecord {}
            BarMemory {}
            BarCPU {}
            BarDiscord {}
            BarClock {}
            BarPanel {}
        }
    }
}
