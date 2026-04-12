pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.end4

import QtQuick
import Quickshell
import M3Shapes

Rectangle {
    id: root

    visible: DiscordVoiceRPC.members.length !== 0

    property real baseWidth: icon.width + (Appearance.space.tiny * 2)
    property bool pressed: false
    implicitWidth: pressed ? baseWidth * 2 : baseWidth
    implicitHeight: parent.height

    Behavior on implicitWidth {
        animation: Appearance?.animation.clickBounce.numberAnimation.createObject(this)
    }

    radius: Appearance.round.medium
    color: "transparent"

    property color bg: {
        if (mouseArea.containsMouse) {
            return Appearance.material.mySecondary;
        } else if (Toggle.discord) {
            return Appearance.material.myPrimaryContainer;
        } else {
            return "transparent";
        }
    }
    property color fg: {
        if (mouseArea.containsMouse) {
            return Appearance.material.myOnSecondary;
        } else if (Toggle.discord) {
            return Appearance.material.myOnPrimaryContainer;
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
            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 4000
                loops: Animation.Infinite
                running: mouseArea.containsMouse
            }
        }
    }
    Item {
        anchors.centerIn: parent
        implicitHeight: parent.height - 4
        implicitWidth: parent.height - 4
        StyledText {
            id: icon
            anchors.fill: parent
            text: ""
            color: root.fg
            font.preferShaping: true
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font {
                family: Appearance.font.family.iconNerd
                pixelSize: 100
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Toggle.discord = !Toggle.discord
        onPressed: root.pressed = true
        onReleased: root.pressed = false
        onCanceled: root.pressed = false
    }

    PopupTooltip {
        text: `Click to toggle Discord voice overlay`
        extraVisibleCondition: mouseArea.containsMouse
        anchorEdges: Edges.Bottom
    }
}
