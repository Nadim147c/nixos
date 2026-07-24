import qs.modules.common
import qs.modules.end4

import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root

    Layout.fillHeight: true
    implicitWidth: Cava.total === 0 ? 0 : body.width + (Appearance.space.small * 2)
    Behavior on implicitWidth {
        animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    color: "transparent"

    readonly property var from: OkLab.fromColor(Appearance.material.myPrimary)
    readonly property var to: OkLab.fromColor(Appearance.material.mySecondary)

    RowLayout {
        id: body
        spacing: 1
        x: Appearance.space.small
        Repeater {
            model: Cava.bars
            Item {
                id: bar
                implicitWidth: Appearance.space.tiny
                implicitHeight: root.height
                required property double modelData
                Rectangle {
                    y: (parent.height - implicitHeight) / 2
                    radius: Appearance.round.medium
                    color: OkLab.toColor(OkLab.blend(root.from, root.to, bar.modelData))
                    implicitWidth: bar.implicitWidth
                    implicitHeight: root.height * bar.modelData
                }
            }
        }
    }
}
