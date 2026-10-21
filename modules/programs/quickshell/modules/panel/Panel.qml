import qs.modules.common
import qs.modules.widgets
import qs.modules.end4

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

PanelWindow {
    id: root
    anchors {
        top: true
        right: true
        bottom: true
    }
    margins {
        top: 5
        right: 5
        bottom: 5
    }

    implicitWidth: 420

    WlrLayershell.namespace: "quickshell:panel"
    exclusiveZone: 0
    aboveWindows: true
    color: "transparent"

    HyprlandFocusGrab {
        windows: [root]
        active: Toggle.panel
        onCleared: Toggle.panel = false
    }

    Card {
        id: body
        anchors.fill: parent
        color: Appearance.material.myBackground

        ColumnLayout {
            id: content
            anchors.fill: parent
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: Appearance.space.big
                Card {
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 150
                    Layout.margins: Appearance.space.small
                    radius: 3
                    borderWidth: 1
                    borderPixelSize: 3

                    KuwaharaFilter {
                        anchors.fill: parent
                        kuwaharaStrength: 0.67
                        bitDepth: 4
                        pixelSize: 2.0
                        StyledImage {
                            anchors.fill: parent
                            source: `${Quickshell.env("HOME")}/.face`
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                }
                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: Appearance.space.big

                    StyledText {
                        text: `Hi, ${Quickshell.env("USER")}`
                        font.pixelSize: Appearance.font.pixelSize.larger
                        font.family: Appearance.font.family.pixel2
                    }

                    RowLayout {
                        StyledText {
                            text: "robot"
                            font.family: Appearance.font.family.iconPixel
                        }
                        StyledText {
                            text: SystemUsage.uptimeString
                            font.family: Appearance.font.family.pixel
                        }
                    }

                    GridLayout {
                        Layout.topMargin: Appearance.space.big

                        uniformCellHeights: true
                        uniformCellWidths: true

                        PanelIcon {
                            icon: "lock"
                            size: 20
                            onClicked: Quickshell.execDetached(["loginctl", "lock-session"])
                        }
                        PanelIcon {
                            icon: "logout"
                            size: 20
                            onClicked: Quickshell.execDetached(["app-launcher", "hyprshutdown"])
                        }
                        PanelIcon {
                            icon: "bedtime"
                            size: 20
                            onClicked: Quickshell.execDetached(["systemctl", "suspend"])
                        }
                        PanelIcon {
                            icon: "power_settings_new"
                            size: 20
                            onClicked: Quickshell.execDetached(["app-launcher", "hyprshutdown", "-p", "systemctl poweroff"])
                        }
                        PanelIcon {
                            icon: "replay"
                            size: 20
                            onClicked: Quickshell.execDetached(["app-launcher", "hyprshutdown", "-p", "systemctl reboot"])
                        }
                    }

                    RowLayout {
                        visible: Weather.hasData
                        StyledImage {
                            visible: Weather.weather.condition.icon
                            Layout.preferredWidth: 25
                            Layout.preferredHeight: 25
                            source: `https:${Weather.weather.condition.icon}`
                            fillMode: Image.PreserveAspectCrop
                        }
                        StyledText {
                            text: `${Weather.weather.condition.text}`
                            font.family: Appearance.font.family.pixel
                        }
                        Rectangle {
                            Layout.preferredWidth: 2
                            Layout.preferredHeight: 20
                            Layout.rightMargin: Appearance.space.big
                            Layout.leftMargin: Appearance.space.big
                            color: Appearance.material.myOnBackground
                        }
                        StyledText {
                            text: `${Weather.weather.tempC}°C`
                            font.family: Appearance.font.family.pixel
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
            }
            GridLayout {
                Layout.margins: Appearance.space.large
                Layout.topMargin: 0
                Layout.fillWidth: true
                columns: 7
                uniformCellHeights: true
                uniformCellWidths: true
                PanelIcon {
                    tooltip: "Application Launcher"
                    icon: "apps"
                    onClicked: Toggle.launcher = true
                }
                PanelIcon {
                    tooltip: "Screenshot Region"
                    icon: "screenshot_region"
                    onClicked: Quickshell.execDetached(["hyprscreenshot", "region"])
                }
                PanelIcon {
                    tooltip: "Screenshot Screen"
                    icon: "screenshot_monitor"
                    onClicked: Quickshell.execDetached(["hyprscreenshot", "screen"])
                }
                PanelIcon {
                    tooltip: "Recrod Screen"
                    icon: "screen_record"
                    onClicked: GpuScreenRecord.start()
                }
                PanelIcon {
                    tooltip: "Recrod Timelapse"
                    icon: "timelapse"
                    onClicked: GpuScreenRecord.timelapse()
                }
                PanelIcon {
                    tooltip: "Clipboard"
                    icon: "content_paste_search"
                    onClicked: Toggle.clipboard = true
                }
                PanelIcon {
                    tooltip: "Game mode"
                    icon: "stadia_controller"
                    active: Toggle.gamemode
                    onClicked: Toggle.gamemode = !Toggle.gamemode
                }
                PanelIcon {
                    tooltip: "Wallpaper"
                    icon: "wallpaper"
                    onClicked: Toggle.wallpaper = true
                }
                Repeater {
                    model: SystemTray.items.values
                    PanelIcon {
                        id: trayItem
                        required property SystemTrayItem modelData
                        tooltip: trayItem.modelData.tooltipTitle
                        icon: ""
                        implicitWidth: icon.width

                        TrayIcon {
                            id: icon
                            anchors.centerIn: parent
                            size: trayItem.height
                            item: trayItem.modelData
                        }

                        PanelTrayMenu {
                            id: menu
                            modelData: trayItem.modelData.menu
                        }

                        onClicked: trayItem.modelData.activate()
                        onMiddleClicked: trayItem.modelData.secondaryActivate()
                        onRightClicked: menu.popup()
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
