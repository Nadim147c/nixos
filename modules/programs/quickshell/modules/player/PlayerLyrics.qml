pragma ComponentBehavior: Bound
import qs.modules.common

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

MouseArea {
    id: root
    implicitWidth: parent.width
    implicitHeight: 200
    hoverEnabled: true

    ScrollView {
        id: view
        width: parent.width
        implicitHeight: 200
        contentWidth: width
        ScrollBar.vertical: ScrollBar {
            id: lyricsBar
            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
            }
            contentItem: Rectangle {
                visible: lyricsBar.active
                implicitWidth: 5
                radius: 3
                color: Appearance.player.myPrimary
            }
            Behavior on position {
                animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
            }
        }

        ColumnLayout {
            id: lyricColumn
            width: parent.width
            Repeater {
                model: WaybarLyric.lines
                MouseArea {
                    id: lyricLine
                    implicitHeight: lyricLineText.height
                    implicitWidth: view.width
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: WaybarLyric.setPosition(modelData.time)

                    required property int index
                    required property var modelData

                    Text {
                        id: lyricLineText
                        property bool active: lyricLine.index === WaybarLyric.lineIndex
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: lyricLine.modelData.line || "󰎇"
                        color: active ? Appearance.player.myOnSurface : Appearance.player.myOutline
                        Behavior on color {
                            animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
                        }
                        onActiveChanged: {
                            if (!active || root.containsMouse)
                                return;
                            const linePos = lyricLine.y + lyricLine.height - (view.height / 2);
                            let pos;
                            if (lyricColumn.height - linePos < view.height) {
                                pos = (lyricColumn.height - view.height) / lyricColumn.height;
                            } else {
                                pos = linePos / lyricColumn.height;
                            }
                            lyricsBar.position = Math.max(pos, 0);
                        }
                        font {
                            family: Appearance.font.family.main
                            pixelSize: Appearance.font.pixelSize.small
                        }
                    }
                }
            }
        }
    }
}
