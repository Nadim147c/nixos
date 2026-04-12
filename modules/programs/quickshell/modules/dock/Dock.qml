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

    property real borderRadius: Appearance.round.large
    property color bg: Appearance.material.mySurface

    Rectangle {
        id: body
        anchors.bottom: parent.bottom
        x: root.borderRadius
        implicitHeight: content.height + (Appearance.space.small * 2)
        implicitWidth: content.width + (Appearance.space.small * 2)
        radius: root.borderRadius
        color: root.bg

        RowLayout {
            id: content
            x: Appearance.space.small
            y: Appearance.space.small
            spacing: Appearance.space.small

            MaterialButton {
                icon: "qr_code"
                onClicked: Hyprland.dispatch("exec hyprqr-decode.sh")
            }

            MaterialButton {
                icon: "screenshot_region"
                onClicked: Hyprland.dispatch("exec screenshot")
            }

            MaterialButton {
                icon: "screenshot_frame"
                onClicked: Hyprland.dispatch("exec screenshot active-output")
            }

            MaterialButton {
                icon: "screen_record"
                onClicked: Hyprland.dispatch("exec qs-screenrecord")
            }

            MaterialButton {
                icon: "document_scanner"
                onClicked: Hyprland.dispatch("exec hyprocr.sh")
            }

            MaterialButton {
                icon: "content_paste_search"
                onClicked: Toggle.clipboard = true
            }

            MaterialButton {
                icon: "calendar_view_month"
                onClicked: Toggle.year = true
            }

            MaterialButton {
                icon: "wallpaper"
                onClicked: Toggle.wallpaper = true
            }

            // Temporally
            MaterialButton {
                icon: "power_settings_new"
                onClicked: Toggle.logout = true
            }
        }
    }
}
