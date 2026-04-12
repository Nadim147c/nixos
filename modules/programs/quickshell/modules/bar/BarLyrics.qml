import qs.modules.common
import qs.modules.end4

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    implicitWidth: lyrics.width + (Appearance.space.medium * 2)
    implicitHeight: parent.height

    radius: Appearance.round.medium

    color: lyricArea.containsMouse ? Appearance.material.mySecondary : "transparent"

    property color fg: {
        if (lyricArea.containsMouse) {
            return Appearance.material.myOnSecondary;
        } else if (!WaybarLyric.isPlaying) {
            return Appearance.material.myOnSurfaceVariant;
        } else {
            return Appearance.material.myPrimary;
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Appearance.time.quick
        }
    }
    Behavior on fg {
        ColorAnimation {
            duration: Appearance.time.quick
        }
    }

    MouseArea {
        id: lyricArea
        y: (parent.height - lyrics.implicitHeight) / 2
        x: Appearance.space.medium

        implicitWidth: lyrics.implicitWidth + (Appearance.space.little * 2)
        implicitHeight: parent.height

        cursorShape: Qt.PointingHandCursor

        hoverEnabled: true
        enabled: true

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                Toggle.player = true;
            }
            if (mouse.button === Qt.RightButton) {
                WaybarLyric.player.togglePlaying();
            }
        }

        RowLayout {
            id: lyrics

            spacing: Appearance.space.little
            MaterialSymbol {
                text: WaybarLyric.icon
                visible: WaybarLyric.icon.length != 0
                color: root.fg
                iconSize: Appearance.font.pixelSize.large
                fill: 1
            }
            Text {
                text: WaybarLyric.text
                color: root.fg
                font {
                    family: Appearance.font.family.main
                    italic: !WaybarLyric.isPlaying
                    pixelSize: Appearance.font.pixelSize.small
                }
            }
        }
    }
}
