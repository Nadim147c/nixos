import qs.modules.common
import qs.modules.end4
import qs.modules.end4.functions

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
        radius: Appearance.round.larger
        color: Appearance.material.myBackground
        ColumnLayout {
            id: content
            x: body.pad
            y: body.pad
            GridLayout {
                columns: 6
                uniformCellHeights: true
                uniformCellWidths: true
                Rectangle {
                    radius: Appearance.round.large
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                    implicitHeight: 50
                    color: Appearance.material.myPrimary
                    RowLayout {
                        height: 35
                        y: (parent.height - height) / 2
                        x: (parent.height - height) / 2
                        Rectangle {
                            implicitHeight: parent.height
                            implicitWidth: height
                            color: "transparent"
                            radius: Appearance.round.medium
                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "globe"
                                color: Appearance.material.myOnPrimary
                                font.pixelSize: Appearance.font.pixelSize.huge
                            }
                        }
                        ColumnLayout {
                            spacing: 0
                            StyledText {
                                text: "Internet"
                                color: Appearance.material.myOnPrimary
                                font.pixelSize: Appearance.font.pixelSize.small
                            }
                            StyledText {
                                text: "unimplemented"
                                color: Appearance.material.myOnPrimary
                                font.pixelSize: Appearance.font.pixelSize.smaller
                            }
                        }
                    }
                }
                Rectangle {
                    radius: Appearance.round.large
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                    implicitHeight: 50
                    color: Appearance.material.myPrimary
                    RowLayout {
                        height: 35
                        y: (parent.height - height) / 2
                        x: (parent.height - height) / 2
                        Rectangle {
                            implicitHeight: parent.height
                            implicitWidth: height
                            color: Appearance.material.myPrimaryContainer
                            radius: Appearance.round.medium
                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "bluetooth"
                                color: Appearance.material.myOnPrimaryContainer
                                font.pixelSize: Appearance.font.pixelSize.larger
                            }
                        }
                        ColumnLayout {
                            spacing: 0
                            StyledText {
                                text: "Bluetooth"
                                color: Appearance.material.myOnPrimary
                                font.pixelSize: Appearance.font.pixelSize.small
                            }
                            StyledText {
                                text: "unimplemented"
                                color: Appearance.material.myOnPrimary
                                font.pixelSize: Appearance.font.pixelSize.smaller
                            }
                        }
                    }
                }
                PanelIcon {
                    text: "Screenshot"
                    icon: "screenshot_region"
                    onActivate: Hyprland.dispatch("exec screenshot")
                    menu: PanelMenu {
                        PanelMenuItem {
                            first: true
                            text: `Fullscreen Screenshot`
                            onActivate: Hyprland.dispatch("exec screenshot screen")
                        }
                        PanelMenuItem {
                            last: true
                            text: `Region Screenshot`
                            onActivate: Hyprland.dispatch("exec screenshot region")
                        }
                    }
                }
                PanelIcon {
                    text: "Recrod Screen"
                    icon: "screen_record"
                    onActivate: Hyprland.dispatch("exec qs-screenrecord")
                }
                PanelIcon {
                    text: "QR Code"
                    icon: "qr_code"
                    onActivate: Toggle.qrcode = true
                }
                PanelIcon {
                    text: "Year Progress"
                    icon: "calendar_view_month"
                    onActivate: Toggle.year = true
                }
                PanelIcon {
                    text: "Clipboard"
                    icon: "content_paste_search"
                    onActivate: Toggle.clipboard = true
                }
                PanelIcon {
                    text: "Wallpaper"
                    icon: "wallpaper"
                    onActivate: Toggle.wallpaper = true
                }
                Repeater {
                    model: SystemTray.items.values
                    Rectangle {
                        id: trayItem
                        required property SystemTrayItem modelData
                        radius: Appearance.round.full
                        height: 50
                        Layout.fillWidth: true

                        color: iconMouseArea.containsMouse ? Appearance.material.mySecondary : Appearance.material.mySurfaceContainerHighest
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                        TrayIcon {
                            anchors.centerIn: parent
                            item: trayItem.modelData
                            size: 50
                            color: iconMouseArea.containsMouse ? Appearance.material.myOnSecondary : Appearance.material.myPrimary
                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                        }

                        PanelTrayMenu {
                            id: menu
                            modelData: trayItem.modelData.menu
                        }

                        StyledToolTip {
                            text: trayItem.modelData.tooltipTitle
                            extraVisibleCondition: iconMouseArea.containsMouse && text !== ""
                        }

                        MouseArea {
                            id: iconMouseArea
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            anchors.fill: parent
                            onClicked: mouse => {
                                switch (mouse.button) {
                                case Qt.LeftButton:
                                    trayItem.modelData.activate();
                                    break;
                                case Qt.MiddleButton:
                                    trayItem.modelData.secondaryActivate();
                                    break;
                                case Qt.RightButton:
                                    menu.popup();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
