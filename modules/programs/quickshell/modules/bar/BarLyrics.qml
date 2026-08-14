import qs.modules.common
import qs.modules.end4
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import OkLab
import Quickshell.Io
import Quickshell.Widgets

RetroButton {
    id: root

    property string fortuneQuote: ""

    Layout.fillHeight: true
    Layout.fillWidth: true

    onClicked: {
        if (!WaybarLyric.text || WaybarLyric.text.trim().length === 0) {
            fortuneProcess.running = false;
            fortuneProcess.running = true;
        } else {
            Toggle.player = !Toggle.player;
        }
    }
    onRightClicked: WaybarLyric.player.togglePlaying()

    Component.onCompleted: fortuneProcess.running = true

    Process {
        id: fortuneProcess
        command: ["bash", "-c", "fortune -s -n 100 | tr '\\n' ' ' | xargs"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim().length > 0) {
                    root.fortuneQuote = data.trim();
                }
            }
        }
    }

    Item {
        implicitWidth: root.contentWidth
        implicitHeight: root.contentHeight

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Appearance.space.medium
            anchors.rightMargin: Appearance.space.medium
            spacing: Appearance.space.little

            MaterialSymbol {
                text: {
                    if (WaybarLyric.icon.length) {
                        return WaybarLyric.icon;
                    } else if (WaybarLyric.text.length) {
                        return "play_arrow";
                    } else {
                        return "auto_awesome";
                    }
                }
                visible: text.length != 0
                color: Appearance.material.myOnBackground
                iconSize: Appearance.font.pixelSize.large
                fill: 1
            }

            ClippingRectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                color: "transparent"
                Text {
                    id: textItem
                    height: parent.height
                    width: parent.width

                    property color highlight: {
                        var c = OkLab.fromColor(color);
                        c.l *= c.l > 0.5 ? 1.5 : 0.5;
                        return OkLab.toColor(c);
                    }

                    property string rawText: WaybarLyric.text
                    property string plainText: WaybarLyric.text.replace(/<\/?\w+[^>]*>/g, "")
                    onPlainTextChanged: textAnimation.restart()
                    text: {
                        if (!rawText || rawText.trim().length === 0) {
                            return root.fortuneQuote;
                        }

                        const colored = rawText.replace(/<b>/g, `<span style="font-weight: 600; color: ${highlight};">`).replace(/<\/b>/g, "</span>");
                        if (WaybarLyric.alt !== "getting") {
                            return colored;
                        }
                        return `${colored} <span style="color: ${Appearance?.material?.mySurfaceVariant};">[Loading lyrics]</span>`;
                    }

                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    textFormat: Text.RichText
                    color: Appearance.material.myOnBackground

                    font {
                        family: Appearance.font.family.pixel
                        italic: WaybarLyric.text.length !== 0 && !WaybarLyric.isPlaying
                        pixelSize: Appearance.font.pixelSize.small
                    }

                    SequentialAnimation {
                        id: textAnimation
                        alwaysRunToEnd: true

                        ParallelAnimation {
                            NumberAnimation {
                                target: textItem
                                property: "y"
                                to: -textItem.height
                                duration: 100
                                easing.type: Easing.InSine
                            }
                            NumberAnimation {
                                target: textItem
                                property: "opacity"
                                to: 0
                                duration: 100
                                easing.type: Easing.InSine
                            }
                        }

                        PropertyAction {}

                        PropertyAction {
                            target: textItem
                            property: "y"
                            value: textItem.height
                        }

                        ParallelAnimation {
                            NumberAnimation {
                                target: textItem
                                property: "y"
                                to: 0
                                duration: 100
                                easing.type: Easing.OutSine
                            }
                            NumberAnimation {
                                target: textItem
                                property: "opacity"
                                to: 1
                                duration: 100
                                easing.type: Easing.OutSine
                            }
                        }
                    }
                }
            }
        }
    }
}
