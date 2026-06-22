import qs.modules.common
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: root

    property real borderRadius: Appearance.round.larger * 2
    property color bg: Appearance.material.mySurface

    anchors.bottom: true
    margins.bottom: 10

    implicitWidth: body.width + (borderRadius * 2)
    implicitHeight: body.height

    WlrLayershell.namespace: "quickshell:logout"
    aboveWindows: true
    exclusiveZone: 0
    color: "transparent"

    mask: Region {
        item: body
    }

    HyprlandFocusGrab {
        windows: [root]
        active: Toggle.logout
        onCleared: Toggle.logout = false
    }

    Rectangle {
        id: body
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        implicitHeight: content.height + (Appearance.space.medium * 2)
        implicitWidth: content.width + (Appearance.space.medium * 2)
        radius: root.borderRadius
        color: root.bg

        RowLayout {
            id: content
            anchors.centerIn: parent

            property real iconSize: 35
            spacing: Appearance.space.tiny

            MaterialButton {
                icon: "bedtime"
                tooltip: "Sleep"
                leftRadius: Appearance.round.large * 2
                radius: Appearance.round.small
                size: parent.iconSize
                onClicked: Quickshell.execDetached(["systemctl", "suspend"])
            }

            MaterialButton {
                icon: "lock"
                tooltip: "Lock"
                radius: Appearance.round.tiny
                size: parent.iconSize
                onClicked: Quickshell.execDetached(["loginctl", "lock-session"])
            }

            MaterialButton {
                icon: "logout"
                tooltip: "Logout"
                radius: Appearance.round.tiny
                size: parent.iconSize
                onClicked: Quickshell.execDetached(["app-launcher", "hyprshutdown"])
            }

            MaterialButton {
                icon: "replay"
                tooltip: "Reboot"
                radius: Appearance.round.tiny
                size: parent.iconSize
                onClicked: Quickshell.execDetached(["app-launcher", "hyprshutdown", "-p", "systemctl reboot"])
            }

            MaterialButton {
                icon: "power_settings_new"
                tooltip: "Shutdown"
                radius: Appearance.round.tiny
                rightRadius: Appearance.round.large * 2
                size: parent.iconSize
                onClicked: Quickshell.execDetached(["app-launcher", "hyprshutdown", "-p", "systemctl poweroff"])
            }
        }
    }
}
