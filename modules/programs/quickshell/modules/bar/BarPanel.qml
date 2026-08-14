import qs.modules.common
import qs.modules.widgets
import qs.modules.end4

import QtQuick
import QtQuick.Layouts

RetroButton {
    id: root
    Layout.fillHeight: true
    onClicked: Toggle.panel = !Toggle.panel

    Item {
        implicitHeight: root.contentHeight
        implicitWidth: height
        MaterialSymbol {
            anchors.centerIn: parent
            color: Appearance.material.myOnSurface
            text: "menu"
            font.weight: 800
        }
    }
}
