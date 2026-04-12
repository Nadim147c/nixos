import qs.modules.common
import qs.modules.end4

import QtQuick

Rectangle {
    id: root

    property real baseWidth: parent.height + (Appearance.space.little * 2)
    property bool pressed: false
    implicitWidth: pressed ? baseWidth * 2 : baseWidth
    implicitHeight: parent.height

    Behavior on implicitWidth {
        animation: Appearance?.animation.clickBounce.numberAnimation.createObject(this)
    }

    radius: Appearance.round.large
    bottomLeftRadius: Appearance.round.medium
    topLeftRadius: Appearance.round.medium

    color: mouseArea.containsMouse ? Appearance.material.mySecondary : Appearance.material.mySurfaceContainerHighest
    property color fg: mouseArea.containsMouse ? Appearance.material.myOnSecondary : Appearance.material.myPrimary
    Behavior on color {
        animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
    }
    Behavior on fg {
        animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
    }

    MaterialSymbol {
        anchors.centerIn: parent
        color: root.fg
        text: "menu"
        font.weight: 800
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Toggle.panel = true
        onPressed: root.pressed = true
        onReleased: root.pressed = false
        onCanceled: root.pressed = false
    }
}
