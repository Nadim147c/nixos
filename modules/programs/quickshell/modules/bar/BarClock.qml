import qs.modules.common
import qs.modules.end4
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import Quickshell

RetroButton {
    id: root
    Layout.fillHeight: true
    enabled: false

    SystemClock {
        id: clockData
        precision: SystemClock.Seconds
    }

    Item {
        implicitWidth: 100
        implicitHeight: root.contentHeight
        StyledText {
            anchors.fill: parent
            text: Qt.formatDateTime(clockData.date, "hh:mm:ss AP")
            color: Appearance.material.myOnBackground
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.Fit
            font.family: Appearance.font.family.pixel
        }
    }
}
