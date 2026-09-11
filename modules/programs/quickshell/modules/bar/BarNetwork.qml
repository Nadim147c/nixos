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
            implicitHeight: root.contentHeight
            anchors.centerIn: parent
            Text {
                color: Appearance.material.myOnBackground
                text: SystemUsage.netUp > SystemUsage.netDown ? "arrow-big-up-dash" : "arrow-big-down-dash"
                font.family: Appearance.font.family.iconPixel
                font.pixelSize: Appearance.font.pixelSize.large
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
