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

    implicitWidth: body.width

    WlrLayershell.namespace: "quickshell:panel"
    exclusiveZone: 0
    aboveWindows: true
    color: "transparent"

    HyprlandFocusGrab {
        windows: [root]
        active: Toggle.panel
        onCleared: Toggle.panel = false
    }

    Rectangle {
        id: body
        opacity: 0.85
        property real pad: Appearance.space.big
        implicitHeight: parent.height
        implicitWidth: content.width + (pad * 2)
        radius: Appearance.round.large
        color: Appearance.material.myBackground

        border.width: 2
        border.color: Appearance.material.myOutline

        ColumnLayout {
            id: content
            x: body.pad
            y: body.pad
            Item {
                implicitHeight: headerRow.height + (Appearance.space.tiny * 2)
                Layout.fillWidth: true
                RowLayout {
                    id: headerRow
                    implicitWidth: parent.width
                    StyledText {
                        id: title
                        text: "Control Panel"
                        font.pixelSize: Appearance.font.pixelSize.hugeass
                        font.family: Appearance.font.family.title
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    PanelIcon {
                        variant: MaterialButton.Variant.Text
                        size: 20
                        tooltip: "Power Menu"
                        icon: "power_settings_new"
                        onClicked: menu.popup()
                        menu: PanelMenu {
                            PanelMenuItem {
                                first: true
                                text: "Lock"
                                icon: "lock"
                                onActivate: Quickshell.execDetached(["loginctl", "lock-session"])
                            }
                            PanelMenuItem {
                                text: "Logout"
                                icon: "logout"
                                onActivate: Quickshell.execDetached(["app-launcher", "hyprshutdown"])
                            }
                            PanelMenuItem {
                                text: "Sleep"
                                icon: "bedtime"
                                onActivate: Quickshell.execDetached(["systemctl", "suspend"])
                            }
                            PanelMenuItem {
                                text: "Shutdown"
                                icon: "power_settings_new"
                                onActivate: Quickshell.execDetached(["app-launcher", "hyprshutdown", "-p", "systemctl poweroff"])
                            }
                            PanelMenuItem {
                                last: true
                                icon: "replay"
                                text: "Reboot"
                                onActivate: Quickshell.execDetached(["app-launcher", "hyprshutdown", "-p", "systemctl reboot"])
                            }
                        }
                    }
                }
            }
            GridLayout {
                columns: 7
                uniformCellHeights: true
                uniformCellWidths: true
                PanelIcon {
                    tooltip: "Application Launcher"
                    icon: "apps"
                    onClicked: Toggle.launcher = true
                }
                PanelIcon {
                    tooltip: "Screenshot"
                    icon: "screenshot_region"
                    onClicked: Quickshell.execDetached(["hyprscreenshot", "region"])
                    menu: PanelMenu {
                        PanelMenuItem {
                            first: true
                            text: `Fullscreen Screenshot`
                            onActivate: Quickshell.execDetached(["hyprscreenshot", "screen"])
                        }
                        PanelMenuItem {
                            last: true
                            text: `Region Screenshot`
                            onActivate: Quickshell.execDetached(["hyprscreenshot", "region"])
                        }
                    }
                }
                PanelIcon {
                    tooltip: "Recrod Screen"
                    icon: "screen_record"
                    onClicked: Quickshell.execDetached(["app-launcher", "qs-screenrecord"])
                }
                PanelIcon {
                    tooltip: "Clipboard"
                    icon: "content_paste_search"
                    onClicked: Toggle.clipboard = true
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

                        TrayIcon {
                            anchors.fill: parent
                            size: trayItem.containerSize
                            fg: trayItem.fg
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
        }
    }
}
