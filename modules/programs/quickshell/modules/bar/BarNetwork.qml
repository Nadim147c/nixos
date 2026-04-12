import qs.modules.common
import qs.modules.end4

import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root

    implicitWidth: volume.width + (Appearance.space.medium * 2)
    implicitHeight: parent.height

    readonly property real high: 1024 * 1024 * 10

    color: {
        if (mouseArea.containsMouse) {
            return Appearance.material.mySecondary;
        } else if (SystemUsage.netTotal > root.high) {
            return Appearance.material.myPrimary;
        } else {
            return Appearance.material.mySurfaceContainerHighest;
        }
    }
    property color fg: {
        if (mouseArea.containsMouse) {
            return Appearance.material.myOnSecondary;
        } else if (SystemUsage.netTotal > root.high) {
            return Appearance.material.myOnPrimary;
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

    radius: Appearance.round.medium

    RowLayout {
        id: volume
        y: (parent.height - volume.implicitHeight) / 2
        x: Appearance.space.medium

        spacing: Appearance.space.tiny
        MaterialSymbol {
            text: SystemUsage.netUp > SystemUsage.netDown ? "arrow_upward" : "arrow_downward"
            color: root.fg
            font.weight: 800
        }
        StyledText {
            text: SystemUsage.netTotalString + " "
            color: root.fg
            font {
                pixelSize: Appearance.font.pixelSize.small
            }
        }
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
                radius: Appearance.round.larger
                color: Appearance.material.myBackground
                RowLayout {
                    id: content
                    x: Appearance.space.big
                    y: Appearance.space.big
                    spacing: Appearance.space.small
                    ColumnLayout {
                        Item {
                            implicitWidth: downProgress.width
                            implicitHeight: downText.height
                            StyledText {
                                id: downText
                                width: parent.width
                                text: "Download"
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                        CircularProgress {
                            id: downProgress
                            colPrimary: Appearance.material.myPrimary
                            colSecondary: Appearance.material.mySurfaceContainerHigh
                            gapAngle: 10
                            implicitSize: 120
                            lineWidth: 6
                            value: SystemUsage.netDown / (1024 * 1024 * 100)
                            waveHeight: 4
                            wavy: value > 0.1
                            Text {
                                anchors.centerIn: parent
                                color: Appearance.material.myPrimary
                                text: SystemUsage.netDownString
                                font.family: Appearance.font.family.main
                                font.pixelSize: Appearance.font.pixelSize.small
                            }
                        }
                    }
                    ColumnLayout {
                        Item {
                            implicitWidth: upProgress.width
                            implicitHeight: upText.height
                            StyledText {
                                id: upText
                                width: parent.width
                                text: "Upload"
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                        CircularProgress {
                            id: upProgress
                            colPrimary: Appearance.material.myPrimary
                            colSecondary: Appearance.material.mySurfaceContainerHigh
                            gapAngle: 10
                            implicitSize: 120
                            lineWidth: 6
                            value: SystemUsage.netUp / (1024 * 1024 * 100)
                            waveHeight: 4
                            wavy: value > 0.1
                            Text {
                                anchors.centerIn: parent
                                color: Appearance.material.myPrimary
                                text: SystemUsage.netUpString
                                font.family: Appearance.font.family.main
                                font.pixelSize: Appearance.font.pixelSize.small
                            }
                        }
                    }
                }
            }
        }
    }
}
