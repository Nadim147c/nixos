import qs.modules.common
import qs.modules.end4

import QtQuick

Rectangle {
    id: root

    required property string icon
    property real size: 22
    property real containerSize: Math.max(icon.height, icon.width) + (Appearance.space.small * 2)
    readonly property bool containsMouse: mouse.containsMouse

    signal clicked
    signal rightClicked

    implicitHeight: containerSize
    implicitWidth: containerSize
    radius: Appearance.round.big

    property color bgCol: Appearance.material.mySurfaceVariant
    property color bgHoveredCol: Appearance.material.myPrimary
    property color fgCol: Appearance.material.myOnSurfaceVariant
    property color fgHoveredCol: Appearance.material.myOnPrimary

    color: mouse.containsMouse ? bgHoveredCol : bgCol
    property color fg: mouse.containsMouse ? fgHoveredCol : fgCol
    Behavior on color {
        animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
    }
    Behavior on fg {
        animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton)
                root.clicked();
            else
                root.rightClicked();
        }

        MaterialSymbol {
            id: icon
            x: (root.containerSize - width) / 2
            y: (root.containerSize - height) / 2
            color: root.fg
            iconSize: root.size
            text: root.icon
        }
    }
}
