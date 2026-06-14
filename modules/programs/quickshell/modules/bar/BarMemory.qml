import qs.modules.common
import qs.modules.end4

import QtQuick
import Quickshell

Rectangle {
    id: root

    implicitWidth: progress.width
    implicitHeight: progress.height

    property real usages: Utils.normalize(1 - (SystemUsage.memAvailable / SystemUsage.memTotal)) || 0

    color: "transparent"

    Behavior on fg {
        animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
    }
    readonly property var from: OkLab.fromColor(Appearance.material.myPrimary)
    readonly property var to: OkLab.fromColor(Appearance.material.myError)
    property color fg: {
        const ratio = Utils.cubicBezier([0.75, 0.25, 0.25, 0.75], usages);
        return OkLab.toColor(OkLab.blend(from, to, ratio));
    }

    CircularProgress {
        id: progress
        anchors.centerIn: parent
        lineWidth: 2
        implicitSize: 24
        gapAngle: 10
        colPrimary: root.fg
        colSecondary: Appearance.material.mySurfaceVariant
        value: root.usages
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
        text: "memory_alt"
        anchors.centerIn: parent
        color: root.fg
        iconSize: 16
        fill: 1
    }

    PopupTooltip {
        text: `${SystemUsage.memAvailableString} is available from ${SystemUsage.memTotalString}`
        extraVisibleCondition: mouseArea.containsMouse
        anchorEdges: Edges.Bottom
    }
}
