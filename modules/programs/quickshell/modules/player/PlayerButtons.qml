import qs.modules.common
import qs.modules.end4

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    implicitHeight: body.height
    implicitWidth: body.width
    color: "transparent"
    property real buttonHeight: Appearance.space.large * 3

    RowLayout {
        id: body
        spacing: Appearance.space.little

        PlayerButton {
            id: previousButton
            iconName: "skip_previous"
            buttonHeight: root.buttonHeight
            buttonWidth: 30
            buttonRadius: Appearance.round.large * 2
            onReleased: WaybarLyric.player.previous()
            StyledToolTip {
                extraVisibleCondition: previousButton.mouseArea.containsMouse
                text: "Previous"
            }
        }
        PlayerButton {
            iconName: WaybarLyric.isPlaying ? "pause" : "play_arrow"
            content: WaybarLyric.isPlaying ? "pause" : "play"
            property bool playing: WaybarLyric.isPlaying
            buttonRadius: playing ? Appearance.round.large * 2 : Appearance.round.large
            toggled: !WaybarLyric.isPlaying
            onReleased: {
                playing = !WaybarLyric.isPlaying; // change radius immediately
                WaybarLyric.player.togglePlaying();
            }
            buttonHeight: root.buttonHeight
            buttonWidth: root.buttonHeight * 2.5
        }
        PlayerButton {
            id: nextButton
            iconName: "skip_next"
            buttonRadius: Appearance.round.large * 2
            buttonHeight: root.buttonHeight
            buttonWidth: 30
            onReleased: WaybarLyric.player.next()
            StyledToolTip {
                extraVisibleCondition: nextButton.mouseArea.containsMouse
                text: "Previous"
            }
        }
    }
}
