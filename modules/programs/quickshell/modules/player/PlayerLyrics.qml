pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.end4

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

                    StyledText {
                        id: lyricLineText
                        property bool active: lyricLine.index === WaybarLyric.lineIndex
                        width: parent.width
                        wrapMode: Text.WordWrap
                        textFormat: Text.RichText

                        property color highlight: Appearance.player.myOnSurface

                        text: {
                            if (!active || !lyricLine.modelData.words.length) {
                                return lyricLine.modelData.line || "󰎇";
                            }
                            let text = "";
                            for (const word of lyricLine.modelData.words) {
                                if (word.start < WaybarLyric.position) {
                                    text += `<b style="color: ${highlight};">${word.word}</b>`;
                                } else {
                                    text += word.word;
                                }
                            }
                            return text;
                        }
                        color: active && !lyricLine.modelData.words.length ? Appearance.player.myOnSurface : Appearance.player.myOutline
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
