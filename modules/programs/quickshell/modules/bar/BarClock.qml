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
        implicitWidth: clock.width + Appearance.space.big
        RowLayout {
            id: clock
            spacing: Appearance.space.tiny
            implicitHeight: root.contentHeight
            anchors.centerIn: parent
            Text {
                color: Appearance.material.myOnBackground
                text: "clock"
                font.family: Appearance.font.family.iconPixel
                font.pixelSize: Appearance.font.pixelSize.large
            }
            Item {
                implicitWidth: 85
                Layout.fillHeight: true
                StyledText {
                    anchors.fill: parent
                    text: Qt.formatDateTime(clockData.date, "hh:mm:ss AP")
                    horizontalAlignment: Text.AlignRight
                    fontSizeMode: Text.Fit
                    color: Appearance.material.myOnBackground
                    font {
                        family: Appearance.font.family.pixel
                        pixelSize: Appearance.font.pixelSize.small
                    }
                }
            }
        }
    }
}
