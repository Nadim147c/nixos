import qs.modules.common
import qs.modules.end4

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Scope {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio

        function onVolumeChanged() {
            if (root.start) {
                root.start = false;
                return;
            }
            root.shouldShowOsd = true;
            hideTimer.restart();
        }
    }

    property bool shouldShowOsd: false
    property bool start: true

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: root.shouldShowOsd = false
    }

    LazyLoader {
        active: root.shouldShowOsd
        PanelWindow {
            anchors.bottom: true
            margins.bottom: screen.height / 15
            exclusiveZone: 0

            implicitWidth: body.width
            implicitHeight: body.height
            color: "transparent"

            Rectangle {
                id: body
                implicitHeight: content.height + (Appearance.space.big * 2)
                implicitWidth: content.width + (Appearance.space.big * 2)
                radius: Appearance.round.larger
                color: Appearance.material.myBackground
                Item {
                    id: content
                    anchors.centerIn: parent
                    implicitWidth: 300
                    implicitHeight: 40
                    StyledSlider {
                        id: slider
                        anchors.fill: parent
                        implicitWidth: 300
                        wavy: false
                        configuration: StyledSlider.Configuration.L
                        value: Pipewire.defaultAudioSink?.audio.volume ?? 0
                        onMoved: Pipewire.defaultAudioSink.audio.volume = value
                        stopIndicatorValues: []
                        MaterialSymbol {
                            id: icon
                            property bool nearFull: slider.value >= 0.9
                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: nearFull ? slider.handle.right : parent.right
                                rightMargin: nearFull ? 14 : 8
                            }
                            iconSize: 20
                            color: nearFull ? Appearance.material.myOnPrimary : Appearance.material.myOnSecondaryContainer
                            text: "volume_up"

                            Behavior on color {
                                animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
                            }
                            Behavior on anchors.rightMargin {
                                animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
                            }
                        }
                    }
                }
            }
        }
    }
}
