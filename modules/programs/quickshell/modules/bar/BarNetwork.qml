import qs.modules.common
import qs.modules.end4
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts

RetroButton {
    id: root
    Layout.fillHeight: true
    enabled: false

    readonly property real high: 1024 * 1024 * 10

    Item {
        implicitWidth: network.width + Appearance.space.big
        RowLayout {
            id: network
            spacing: Appearance.space.tiny
            anchors.centerIn: parent
            MaterialSymbol {
                color: Appearance.material.myOnBackground
                text: SystemUsage.netUp > SystemUsage.netDown ? "arrow_upward" : "arrow_downward"
                font.weight: 800
            }
            Item {
                implicitWidth: 80
                Layout.fillHeight: true
                StyledText {
                    anchors.fill: parent
                    text: SystemUsage.netTotalString || "--"
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
