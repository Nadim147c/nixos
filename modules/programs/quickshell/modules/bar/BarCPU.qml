import qs.modules.common
import qs.modules.end4

import QtQuick
import Quickshell
import OkLab

Rectangle {
    id: root

    implicitWidth: progress.width
    implicitHeight: progress.height

    color: "transparent"

    Behavior on fg {
        animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
    }
    readonly property oklab from: OkLab.fromColor(Appearance.material.myPrimary)
    readonly property oklab to: OkLab.fromColor(Appearance.material.myError)
    property color fg: {
        const ratio = Utils.cubicBezier([0.75, 0.25, 0.25, 0.75], SystemUsage.cpuUtilization / 100);
        return OkLab.blendToColor(from, to, ratio);
    }

    CircularProgress {
        id: progress
        anchors.centerIn: parent
        lineWidth: 2
        implicitSize: 24
        gapAngle: 10
        colPrimary: root.fg
        colSecondary: Appearance.material.mySurfaceVariant
        value: SystemUsage.cpuUtilization / 100
        wavy: false
        waveHeight: 1.2
        waveFrequency: 8
    }

    MouseArea {
        id: mouseArea
        anchors.fill: progress
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    MaterialSymbol {
        text: "memory"
        anchors.centerIn: parent
        color: root.fg
        iconSize: 16
        fill: 1
    }

    PopupTooltip {
        text: `${SystemUsage.cpuUtilizationString}% CPU Usages`
        extraVisibleCondition: mouseArea.containsMouse
        anchorEdges: Edges.Bottom
    }
}
