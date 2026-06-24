import qs.modules.common
import qs.modules.widgets
import qs.modules.end4.functions
import qs.modules.end4

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

ClippingRectangle {
    id: root
    radius: Appearance.round.big
    color: Appearance.player.mySurfaceContainerHighest
    border.width: 1
    border.color: Appearance.material.myPrimary

    Image {
        anchors.fill: parent
        source: WaybarLyric.coverUrl
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    Rectangle {
        implicitHeight: 60
        implicitWidth: parent.width
        gradient: Gradient {
            GradientStop {
                position: 1
                color: ColorUtils.transparentize(Appearance.player.myBackground, 1)
            }
            GradientStop {
                position: 0
                color: ColorUtils.transparentize(Appearance.player.myBackground, 0.1)
            }
        }
    }

    Rectangle {
        implicitHeight: 60
        implicitWidth: parent.width
        anchors.bottom: parent.bottom
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: ColorUtils.transparentize(Appearance.player.myBackground, 1)
            }
            GradientStop {
                position: 1.0
                color: ColorUtils.transparentize(Appearance.player.myBackground, 0.1)
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        Item {
            implicitHeight: text.height + (Appearance.space.medium * 2)
            Layout.fillWidth: true
            StyledText {
                id: text
                color: Appearance.player.myPrimary
                x: Appearance.space.medium
                anchors.verticalCenter: parent.verticalCenter
                text: WaybarLyric.title
                font.family: Appearance.font.family.expressive
                font.pixelSize: Appearance.font.pixelSize.smallie
                font.bold: true
            }
        }
        Item {
            Layout.fillHeight: true
        }
        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            MaterialButton {
                variant: MaterialButton.Variant.Text
                scheme: Appearance.player
                icon: "skip_previous"
                onClicked: WaybarLyric.player.previous()
            }
            MaterialButton {
                variant: MaterialButton.Variant.Text
                scheme: Appearance.player
                icon: WaybarLyric.isPlaying ? "pause" : "play_arrow"
                onClicked: WaybarLyric.player.togglePlaying()
            }
            MaterialButton {
                variant: MaterialButton.Variant.Text
                scheme: Appearance.player
                icon: "skip_next"
                onClicked: WaybarLyric.player.next()
            }
        }
    }
}
