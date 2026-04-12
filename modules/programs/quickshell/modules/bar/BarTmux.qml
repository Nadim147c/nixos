pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.end4

import M3Shapes
import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root

    visible: Tmux.sessions.length !== 0
    implicitWidth: icon.width + (Appearance.space.tiny * 2)
    implicitHeight: parent.height

    color: "transparent"

    property color bg: {
        if (mouseArea.containsMouse) {
            return Appearance.material.mySecondary;
        } else {
            return "transparent";
        }
    }
    property color fg: {
        if (mouseArea.containsMouse) {
            return Appearance.material.myOnSecondary;
        } else {
            return Appearance.material.myPrimary;
        }
    }
    Behavior on color {
        animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
    }
    Behavior on fg {
        animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
    }

    Loader {
        active: root.bg !== "transparent"
        anchors.fill: parent
        sourceComponent: MaterialShape {
            id: shape
            anchors.fill: parent
            shape: MaterialShapeItem.Cookie9Sided
            animationDuration: 500
            color: root.bg
            Connections {
                target: mouseArea
            }
            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 4000
                loops: Animation.Infinite
                running: mouseArea.containsMouse
            }
        }
    }

    MaterialSymbol {
        id: icon
        code: 0xE86F
        fill: 1
        anchors.centerIn: parent
        color: root.fg
        font.pixelSize: Appearance.font.pixelSize.large
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    PopupTooltip {
        extraVisibleCondition: mouseArea.containsMouse
        anchorEdges: Edges.Bottom
        verticalPadding: 100
        contentItem: Item {
            implicitHeight: tooltipRect.height + (Appearance.space.big * 2)
            implicitWidth: tooltipRect.width + (Appearance.space.big * 2)
            Rectangle {
                id: tooltipRect
                anchors.centerIn: parent
                implicitHeight: content.height + (Appearance.space.big * 2)
                implicitWidth: content.width + (Appearance.space.big * 2)
                radius: Appearance.round.large
                color: Appearance.material.myBackground

                ColumnLayout {
                    id: content
                    anchors.centerIn: parent
                    StyledText {
                        text: "Tmux Sessions"
                        font {
                            family: Appearance.font.family.title
                            pixelSize: Appearance.font.pixelSize.large
                        }
                    }
                    Rectangle {
                        implicitHeight: table.height + (Appearance.space.big * 2)
                        implicitWidth: table.width + (Appearance.space.big * 2)
                        radius: Appearance.round.big - 2
                        color: Appearance.material.mySurfaceContainer
                        Table {
                            id: table
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
    }
    component Table: ColumnLayout {
        Repeater {
            model: Tmux.sessions
            RowLayout {
                id: session
                required property TmuxSession modelData
                Rectangle {
                    visible: session.modelData.active
                    radius: Appearance.round.full
                    implicitWidth: Appearance.space.small
                    implicitHeight: Appearance.space.small
                    color: Appearance.material.myPrimary
                }

                StyledText {
                    text: session.modelData.name
                    color: Appearance.material.myOnSurface
                }

                Rectangle {
                    implicitHeight: windows.height + (Appearance.space.tiny * 2)
                    implicitWidth: windows.width + (Appearance.space.medium * 2)
                    radius: Appearance.round.little
                    color: Appearance.material.mySurface
                    StyledText {
                        id: windows
                        anchors.centerIn: parent
                        text: `${session.modelData.windows}`
                        color: Appearance.material.myOnSurface
                        shouldUseNumberFont: true
                        font {
                            family: Appearance.font.family.numbers
                            pixelSize: Appearance.font.pixelSize.smallest
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
                Item {
                    implicitWidth: Appearance.space.medium
                }

                StyledText {
                    text: session.modelData.lastActivity
                    color: session.modelData.lastActivity === "Now" ? Appearance.material.myPrimary : Appearance.material.myOnSurfaceVariant
                    font {
                        pixelSize: Appearance.font.pixelSize.smaller
                    }
                }
            }
        }
    }
}
