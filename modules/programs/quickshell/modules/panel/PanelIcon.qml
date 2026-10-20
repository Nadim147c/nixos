import qs.modules.common
import qs.modules.widgets
import qs.modules.end4

import QtQuick

RetroButton {
    id: root
    property string icon
    property real size: 30
    implicitWidth: height
    Item {
        visible: root.icon !== ""
        implicitWidth: icon.width + (Appearance.space.small * 2)
        implicitHeight: icon.height + (Appearance.space.small * 2)
        MaterialSymbol {
            id: icon
            anchors.centerIn: parent
            text: root.icon
            iconSize: root.size
        }
    }
}
