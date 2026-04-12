import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    anchors.bottom: true

    implicitWidth: 400
    implicitHeight: 5

    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell:dock-spawner"

    color: "transparent"

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onHoveredChanged: timer.start()
    }

    Timer {
        id: timer
        interval: 200
        repeat: false
        onTriggered: {
            if (mouse.containsMouse)
                Toggle.dock = true;
        }
    }
}
