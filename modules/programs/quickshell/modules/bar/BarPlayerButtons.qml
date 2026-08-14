pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.end4
import qs.modules.widgets

RowLayout {
    id: root
    spacing: 1
    height: parent.height

    RetroButton {
        Layout.fillHeight: true
        Layout.preferredWidth: root.height + 4
        enabled: WaybarLyric.player?.canGoPrevious
        onClicked: WaybarLyric.player.previous()
        MaterialSymbol {
            text: "skip_previous"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignHCenter
            color: Appearance.material.myOnBackground
            font.pixelSize: Appearance.font.pixelSize.huge
        }
    }

    RetroButton {
        Layout.fillHeight: true
        Layout.preferredWidth: root.height + 4
        enabled: WaybarLyric.player?.canTogglePlaying
        onClicked: WaybarLyric.player.togglePlaying()
        MaterialSymbol {
            text: WaybarLyric.isPlaying ? "pause" : "play_arrow"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignHCenter
            color: Appearance.material.myOnBackground
            font.pixelSize: Appearance.font.pixelSize.huge
        }
    }

    RetroButton {
        Layout.fillHeight: true
        Layout.preferredWidth: root.height + 4
        enabled: WaybarLyric.player?.canGoNext
        onClicked: WaybarLyric.player.next()
        MaterialSymbol {
            text: "skip_next"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignHCenter
            color: Appearance.material.myOnBackground
            font.pixelSize: Appearance.font.pixelSize.huge
        }
    }
}
