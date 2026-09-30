import qs.modules.common
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts

RetroButton {
    id: root
    Layout.fillHeight: true

    visible: DiscordVoiceRPC.isVoiceActive

    onClicked: Toggle.discord = !Toggle.discord

    Item {
        implicitWidth: row.width + Appearance.space.big
        implicitHeight: root.contentHeight
        RowLayout {
            id: row
            implicitHeight: root.contentHeight
            anchors.centerIn: parent
            spacing: Appearance.space.tiny
            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: 20
                Text {
                    anchors.centerIn: parent
                    color: Appearance.material.myOnBackground
                    text: "discord"
                    font.family: Appearance.font.family.iconPixel
                    font.pixelSize: Appearance.font.pixelSize.large
                }
            }
        }
    }
}
