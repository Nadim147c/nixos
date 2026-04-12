import qs.modules.common
import qs.modules.end4

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: root
    anchors {
        top: true
        right: true
        bottom: true
    }
    margins {
        top: 10
        right: 10
        bottom: 10
    }

    implicitWidth: body.width

    WlrLayershell.namespace: "quickshell:player"
    aboveWindows: true
    color: "transparent"

    // HyprlandFocusGrab {
    //     windows: [root]
    //     active: Toggle.netspeed
    //     onCleared: Toggle.netspeed = false
    // }

    Rectangle {
        id: body
        property real pad: Appearance.space.big
        implicitHeight: content.height + (pad * 2)
        implicitWidth: content.width + (pad * 2)
        radius: Appearance.round.larger
        color: Appearance.material.mySurface
        ColumnLayout {
            id: content
            x: body.pad
            y: body.pad
            GridLayout {
                columns: 5
                uniformCellHeights: true
                uniformCellWidths: true
                Rectangle {
                    color: "red"
                    Layout.columnSpan: 5
                    Layout.fillWidth: true
                    height: 50
                }
                Rectangle {
                    color: "green"
                    height: 50
                    width: height
                }
                Rectangle {
                    color: "blue"
                    height: 50
                    width: height
                }
                Rectangle {
                    color: "cyan"
                    height: 50
                    width: height
                }
                Rectangle {
                    color: "magenta"
                    height: 50
                    width: height
                }
                Rectangle {
                    color: "magenta"
                    height: 50
                    width: height
                }
            }
        }
    }
}
