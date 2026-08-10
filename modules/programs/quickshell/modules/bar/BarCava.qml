pragma ComponentBehavior: Bound

import qs.modules.common

import QtQuick
import QtQuick.Layouts
import OkLab
import Cava

Rectangle {
    id: root

    Layout.fillHeight: true
    implicitWidth: mute ? 0 : body.width + (Appearance.space.small * 2)
    Behavior on implicitWidth {
        animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    color: "transparent"

    property bool mute: true
    property double total: Cava.total
    onTotalChanged: {
        if (total === 0) {
            muteTimer.start();
        } else {
            mute = false;
        }
    }

    Timer {
        id: muteTimer
        interval: 2000
        onTriggered: root.mute = !root.total
    }

    readonly property oklab from: OkLab.fromColor(Appearance.material.myPrimary)
    readonly property oklab to: OkLab.fromColor(Appearance.material.mySecondary)

    RowLayout {
        id: body
        spacing: 1
        x: Appearance.space.small

        Repeater {
            model: Cava.values
            Item {
                id: bar
                implicitWidth: Appearance.space.tiny
                implicitHeight: root.height
                required property double modelData
                Rectangle {
                    y: (parent.height - implicitHeight) / 2
                    radius: Appearance.round.medium
                    implicitWidth: bar.implicitWidth
                    implicitHeight: root.mute ? 0 : Math.max(root.height * bar.modelData, 1)
                    color: OkLab.blendToColor(root.from, root.to, bar.modelData)
                }
            }
        }
    }
}
