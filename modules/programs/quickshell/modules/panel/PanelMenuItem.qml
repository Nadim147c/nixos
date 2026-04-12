pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.end4

import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property string text
    property real pad: Appearance.space.small
    property bool first: false
    property bool last: false
    signal activate

    height: rect.height + 2
    width: parent.width
    Rectangle {
        id: rect
        x: 1
        y: 1
        property real bigRound: Appearance.space.big - 2
        property real smallRound: Appearance.space.tiny
        topRightRadius: root.first ? bigRound : smallRound
        topLeftRadius: root.first ? bigRound : smallRound
        bottomRightRadius: root.last ? bigRound : smallRound
        bottomLeftRadius: root.last ? bigRound : smallRound

        color: mouseArea.containsMouse ? Appearance.material.myPrimary : Appearance.material.mySurfaceContainer

        implicitWidth: parent.width - (Appearance.space.visible * 2)
        implicitHeight: text.height + (pad * 2)

        StyledText {
            id: text
            y: root.pad
            x: root.pad
            text: root.text
            color: mouseArea.containsMouse ? Appearance.material.myOnPrimary : Appearance.material.myOnSurface
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.activate()
        }
    }
}
