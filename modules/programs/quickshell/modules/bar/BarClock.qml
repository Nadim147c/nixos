import qs.modules.common
import qs.modules.end4

import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root

    implicitWidth: clock.width + (Appearance.space.medium * 2)
    implicitHeight: parent.height

    radius: Appearance.round.medium

    color: mouseArea.containsMouse ? Appearance.material.mySecondary : Appearance.material.mySurfaceContainerHighest
    property color fg: mouseArea.containsMouse ? Appearance.material.myOnSecondary : Appearance.material.myPrimary
    Behavior on color {
        animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
    }
    Behavior on fg {
        animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
    }

    SystemClock {
        id: clockData
        precision: SystemClock.Seconds
    }

    RowLayout {
        id: clock
        y: (parent.height - clock.implicitHeight) / 2
        x: Appearance.space.medium
        spacing: Appearance.space.little
        StyledText {
            text: Qt.formatDateTime(clockData.date, "hh:mm AP")
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

        onClicked: {
            console.log("Calendar toggle signal emitted");
        }
    }
}
