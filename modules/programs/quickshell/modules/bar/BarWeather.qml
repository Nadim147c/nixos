import qs.modules.common
import qs.modules.end4

import QtQuick
import QtQuick.Layouts

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

    RowLayout {
        id: clock
        anchors.centerIn: parent
        spacing: Appearance.space.little
        MaterialSymbol {
            text: "device_thermostat"
            color: root.fg
            font.weight: 800
        }
        StyledText {
            text: `${Weather.weather.tempC}°C `
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
}
