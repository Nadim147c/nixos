import qs.modules.common
import qs.modules.end4
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import Quickshell

RetroButton {
    id: root

    Layout.fillHeight: true

    onClicked: Quickshell.execDetached(["pavucontrol"])
    onScrolled: wheel => {
        try {
            if (wheel.angleDelta.y > 0) {
                Pipewire.defaultAudioSink.audio.volume += 0.01;
            } else if (wheel.angleDelta.y < 0) {
                Pipewire.defaultAudioSink.audio.volume -= 0.01;
            }
            wheel.accepted = true;
        } catch (e) {
            console.error(e);
        }
    }

    Item {
        implicitWidth: volume.width + Appearance.space.big
        RowLayout {
            id: volume
            anchors.centerIn: parent
            spacing: Appearance.space.little

            Text {
                color: Appearance.material.myOnBackground
                text: {
                    const vol = Pipewire.defaultAudioSink?.audio.volume;
                    if (vol === 0) {
                        return "volume";
                    }
                    return `volume-${Math.ceil(vol / 0.33333333)}`;
                }
                font.family: Appearance.font.family.iconPixel
                font.pixelSize: Appearance.font.pixelSize.large
            }
            StyledText {
                text: Math.round((Pipewire.defaultAudioSink?.audio.volume ?? 0) * 100).toString() + "% " // extra space is intention
                color: Appearance.material.myOnBackground
                font.family: Appearance.font.family.pixel
                font.pixelSize: Appearance.font.pixelSize.small
            }
        }
    }
}
