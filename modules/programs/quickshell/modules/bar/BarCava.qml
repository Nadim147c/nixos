import qs.modules.common
import qs.modules.end4

import QtQuick
import QtQuick.Layouts
import Quickshell
import OkLab

Rectangle {
    id: root

    Layout.fillHeight: true
    implicitWidth: Cava.mute ? 0 : body.width + (Appearance.space.small * 2)
    Behavior on implicitWidth {
        animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    color: "transparent"

    readonly property oklab from: OkLab.fromColor(Appearance.material.myPrimary)
    readonly property oklab to: OkLab.fromColor(Appearance.material.mySecondary)

    RowLayout {
        id: body
        spacing: 1
        x: Appearance.space.small

        Repeater {
            model: 0xF

            Item {
                id: bar
                implicitWidth: Appearance.space.tiny
                implicitHeight: root.height

                // Read directly from index rather than modelData
                readonly property double value: Cava.getBar(index)

                Rectangle {
                    y: (parent.height - implicitHeight) / 2
                    radius: Appearance.round.medium
                    implicitWidth: bar.implicitWidth
                    implicitHeight: Cava.mute ? 0 : Math.max(root.height * bar.value, 1)
                    color: OkLab.blendToColor(root.from, root.to, bar.value)
                }
            }
        }
    }
}
