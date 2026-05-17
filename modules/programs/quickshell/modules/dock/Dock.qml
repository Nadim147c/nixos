import qs.modules.common
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: root
    anchors.bottom: true

    implicitWidth: body.width + (borderRadius * 2)
    implicitHeight: 200
    margins.bottom: 10

    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore

    color: "transparent"

    HyprlandFocusGrab {
        windows: [root]
        active: Toggle.dock
        onCleared: Toggle.dock = false
    }

    MouseArea {
        anchors.top: parent.top
        implicitWidth: parent.width
        implicitHeight: parent.height - body.height
        onClicked: Toggle.dock = false
    }

    property real borderRadius: Appearance.round.larger * 2
    property color bg: Appearance.material.mySurface

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
                icon: "apps"
                tooltip: "Application Launcher"
                leftRadius: Appearance.round.large * 2
                radius: Appearance.round.small
                size: parent.iconSize
                onClicked: Toggle.launcher = true
            }

            MaterialButton {
                icon: "screen_record"
                tooltip: "Screen Record"
                radius: Appearance.round.small
                size: parent.iconSize
                onClicked: Quickshell.execDetached(["qs-screenrecord"])
            }

            MaterialButton {
                icon: "screenshot_monitor"
                tooltip: "Screenshot"
                radius: Appearance.round.small
                size: parent.iconSize
                onClicked: Quickshell.execDetached(["hyprscreenshot", "screen"])
            }

            MaterialButton {
                icon: "screenshot_frame"
                tooltip: "Screenshot Selection"
                radius: Appearance.round.small
                size: parent.iconSize
                onClicked: Quickshell.execDetached(["hyprscreenshot", "region"])
            }

            MaterialButton {
                icon: "content_paste_search"
                tooltip: "Clipboard History"
                radius: Appearance.round.small
                size: parent.iconSize
                onClicked: Toggle.clipboard = true
            }

            MaterialButton {
                icon: "wallpaper"
                tooltip: "Wallpaper Changer"
                radius: Appearance.round.small
                size: parent.iconSize
                onClicked: Toggle.wallpaper = true
            }

            MaterialButton {
                icon: "power_settings_new"
                tooltip: "Logout options"
                radius: Appearance.round.small
                size: parent.iconSize
                rightRadius: Appearance.round.large * 2
                onClicked: Toggle.logout = true
            }
        }
    }
}
