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

    Rectangle {
        id: body
        implicitHeight: 32
        implicitWidth: parent.width - (root.margin * 2)
        y: root.margin
        x: root.margin
        color: root.bg
        radius: Appearance.round.large
        property real roundness: radius
        topLeftRadius: roundness
        bottomLeftRadius: roundness

        SequentialAnimation {
            id: radiusAnim
            running: false
            NumberAnimation {
                target: body
                property: "roundness"
                to: 8
                duration: Appearance.animation.elementMove.duration / 2
                easing.type: Appearance.animation.elementMove.type
                easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
            }
            NumberAnimation {
                target: body
                property: "roundness"
                to: Appearance.round.large
                duration: Appearance.animation.elementMove.duration / 2
                easing.type: Appearance.animation.elementMove.type
                easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
            }
        }

        RowLayout {
            id: rootRow
            anchors {
                fill: parent
                margins: Appearance.space.little
            }

            Rectangle {
                color: "transparent"
                implicitHeight: rootRow.height
                implicitWidth: leftModule.implicitWidth
                RowLayout {
                    id: leftModule
                    anchors.fill: parent
                    spacing: Appearance.space.tiny
                    BarWorkspaces {
                        onFirstActive: active => {
                            if (active) {
                                radiusAnim.restart();
                            }
                        }
                    }
                    BarCava {}
                    BarLyrics {}
                }
            }

            // Spacer to push the next item to the right
            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                color: "transparent"
                implicitHeight: rootRow.height
                implicitWidth: rightModule.implicitWidth
                RowLayout {
                    id: rightModule
                    spacing: Appearance.space.tiny
                    anchors.fill: parent
                    BarNetwork {}
                    BarWeather {}
                    BarVolume {}
                    BarRecord {}
                    BarMemory {}
                    BarCPU {}
                    BarTmux {}
                    BarDiscord {}
                    BarClock {}
                    BarPanel {}
                    // BarTray {}
                }
            }
        }
    }
}
