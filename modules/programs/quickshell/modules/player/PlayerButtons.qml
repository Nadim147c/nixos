pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.end4
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root
    implicitHeight: body.height
    implicitWidth: body.width
    color: "transparent"
    property real buttonHeight: Appearance.space.large * 3

    component PlayerButton: RetroButton {
        id: button
        Layout.fillHeight: true
        Layout.preferredWidth: root.height + 4
        color: Qt.lighter(active ? Appearance.player.mySurfaceContainerHighest : Appearance.player.mySurfaceContainer, 1.7)
        rippleColor: Appearance.player.myPrimary
        required property string icon
        MaterialSymbol {
            text: button.icon
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignHCenter
            color: Appearance.player.myOnBackground
            font.pixelSize: Appearance.font.pixelSize.huge
        }
    }

    RowLayout {
        id: body
        spacing: Appearance.space.little

        PlayerButton {
            enabled: WaybarLyric.player?.shuffleSupported
            onClicked: WaybarLyric.player.shuffle = !WaybarLyric.player.shuffle
            icon: "shuffle"
        }

        PlayerButton {
            enabled: WaybarLyric.player?.canGoPrevious
            onClicked: WaybarLyric.player.previous()
            icon: "skip_previous"
        }

        PlayerButton {
            enabled: WaybarLyric.player?.canTogglePlaying
            onClicked: WaybarLyric.player.togglePlaying()
            icon: WaybarLyric.isPlaying ? "pause" : "play_arrow"
        }

        PlayerButton {
            enabled: WaybarLyric.player?.canGoNext
            onClicked: WaybarLyric.player.next()
            icon: "skip_next"
        }

        PlayerButton {
            onClicked: Quickshell.execDetached(["qs-open-music-player", WaybarLyric.player.dbusName])
            icon: "open_in_browser"
        }
    }
}
