import qs.modules.common
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts

RetroButton {
    id: root
    Layout.fillHeight: true
    onClicked: Toggle.panel = !Toggle.panel

    Item {
        implicitHeight: root.contentHeight
        implicitWidth: height + 4
        Text {
            anchors.centerIn: parent
            color: Appearance.material.myOnSurface
            text: "menu-square"
            font.family: Appearance.font.family.iconPixel
            font.pixelSize: Appearance.font.pixelSize.large
        }
    }
}
