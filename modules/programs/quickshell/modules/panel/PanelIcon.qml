import qs.modules.common
import qs.modules.end4

import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    required property string icon
    required property string text
    property Menu menu
    signal activate

    color: itemMouseArea.containsMouse ? Appearance.material.mySecondary : Appearance.material.mySurfaceContainerHighest
    Behavior on color {
        ColorAnimation {
            duration: 200
        }
    }
    radius: Appearance.round.full
    height: 50
    width: 60
    StyledToolTip {
        text: root.text
        extraVisibleCondition: itemMouseArea.containsMouse
    }
    MaterialSymbol {
        anchors.centerIn: parent
        color: itemMouseArea.containsMouse ? Appearance.material.myOnSecondary : Appearance.material.myPrimary
        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
        text: root.icon
        font.pixelSize: 25
    }
    MouseArea {
        id: itemMouseArea
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        enabled: true
        hoverEnabled: true
        anchors.fill: parent
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton)
                return root.activate();
            if (root.menu)
                root.menu.popup();
        }
    }
}
