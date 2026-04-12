pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.end4

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
    id: root
    spacing: 2
    height: parent.height

    signal firstActive(bool b)

    Repeater {
        model: Hyprland.workspaces

        MouseArea {
            id: workspace
            cursorShape: Qt.PointingHandCursor

            required property var modelData
            required property real index
            property bool active: workspace.modelData.active

            implicitHeight: root.height
            implicitWidth: active ? root.height + Appearance.space.big : root.height

            Behavior on implicitWidth {
                animation: Appearance?.animation.elementMove.numberAnimation.createObject(this)
            }

            onClicked: modelData.activate()

            hoverEnabled: true
            enabled: true

            property color bg: {
                if (workspace.containsMouse) {
                    return Appearance.material.mySecondary;
                } else if (workspace.modelData.urgent) {
                    return Appearance.material.myTertiary;
                } else if (workspace.modelData.active) {
                    return Appearance.material.myPrimary;
                } else {
                    return "transparent";
                }
            }
            property color fg: {
                if (workspace.containsMouse) {
                    return Appearance.material.myOnSecondary;
                } else if (workspace.modelData.urgent) {
                    return Appearance.material.myOnTertiary;
                } else if (workspace.modelData.active) {
                    return Appearance.material.myOnPrimary;
                } else {
                    return Appearance.material.myPrimary;
                }
            }
            Behavior on bg {
                animation: Appearance?.animation.elementMove.colorAnimation.createObject(this)
            }

            Behavior on fg {
                animation: Appearance?.animation.elementMove.colorAnimation.createObject(this)
            }
            Rectangle {
                id: rect
                anchors.fill: parent
                color: workspace.bg

                property bool active: workspace.modelData.active
                property real roundness: Appearance.round.little
                property real targetRadius: workspace.modelData.active ? Appearance.round.large : Appearance.round.little
                onActiveChanged: {
                    radiusAnim.restart();
                    if (workspace.index == 0) {
                        root.firstActive(active);
                    }
                }

                property bool first: workspace.index == 0 && !active
                property bool last: (workspace.index + 1) == Hyprland.workspaces.values.length && !active

                bottomLeftRadius: first ? Appearance.round.large : roundness
                topLeftRadius: first ? Appearance.round.large : roundness
                bottomRightRadius: roundness
                topRightRadius: roundness

                SequentialAnimation {
                    id: radiusAnim
                    running: false
                    NumberAnimation {
                        target: rect
                        property: "roundness"
                        to: 5
                        from: rect.targetRadius
                        duration: Appearance.animation.elementMove.duration / 2
                        easing.type: Appearance.animation.elementMove.type
                        easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
                    }
                    NumberAnimation {
                        target: rect
                        property: "roundness"
                        to: rect.targetRadius
                        duration: Appearance.animation.elementMove.duration / 2
                        easing.type: Appearance.animation.elementMove.type
                        easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
                    }
                }
            }

            Item {
                anchors.fill: parent
                StyledText {
                    x: (parent.width - width) / 2
                    y: (parent.height - height) / 2
                    text: workspace.modelData.name
                    color: workspace.fg
                    font.bold: true
                }
            }
        }
    }
}
