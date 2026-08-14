import qs.modules.common
import qs.modules.end4
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import OkLab

RetroButton {
    id: root

    Layout.fillHeight: true

    property real value: SystemUsage.cpuUtilization / 100
    Behavior on value {
        animation: Appearance?.animation.elementMove.numberAnimation.createObject(this)
    }

    readonly property oklab from: OkLab.fromColor(Appearance.material.myPrimary)
    readonly property oklab to: OkLab.fromColor(Appearance.material.myError)
    property color fg: {
        const ratio = Utils.cubicBezier([0.75, 0.25, 0.25, 0.75], SystemUsage.cpuUtilization / 100);
        return OkLab.blendToColor(from, to, ratio);
    }
    Behavior on fg {
        animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
    }

    Item {
        implicitWidth: row.width + Appearance.space.big
        implicitHeight: root.contentHeight
        RowLayout {
            id: row
            implicitHeight: root.contentHeight
            anchors.centerIn: parent
            Rectangle {
                id: rect
                Layout.fillHeight: true
                Layout.preferredWidth: 5
                Layout.topMargin: 3
                Layout.bottomMargin: 3

                color: Appearance.material.mySurfaceVariant
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height * root.value
                    color: root.fg
                }
                SharpRectShadow {
                    target: rect
                    size: 3
                    color: Qt.darker(rect.color, 1.8)
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: 60

                StyledText {
                    id: cpuText

                    function formatCpuFrequency(khz) {
                        if (!khz || khz <= 0)
                            return "--";
                        let mhz = khz / 1000;
                        if (mhz >= 1000) {
                            return (mhz / 1000).toFixed(1) + " GHz";
                        }
                        return Math.round(mhz) + " MHz";
                    }

                    anchors.fill: parent
                    property int freq: SystemUsage.cpuFrequency
                    property int animatedFreq: freq

                    onFreqChanged: stepAnim.restart()

                    SequentialAnimation {
                        id: stepAnim

                        property real fromVal: cpuText.animatedFreq
                        property real toVal: cpuText.freq
                        property real duration: 160
                        property real stepDuration: duration / 2

                        PauseAnimation {
                            duration: stepAnim.stepDuration
                        }
                        PropertyAction {
                            target: cpuText
                            property: "animatedFreq"
                            value: stepAnim.fromVal + (stepAnim.toVal - stepAnim.fromVal) * 0.50
                        }

                        PauseAnimation {
                            duration: stepAnim.stepDuration
                        }
                        PropertyAction {
                            target: cpuText
                            property: "animatedFreq"
                            value: stepAnim.toVal
                        }
                    }

                    text: formatCpuFrequency(animatedFreq)
                    color: Appearance.material.myOnBackground
                    horizontalAlignment: Text.AlignRight
                    fontSizeMode: Text.Fit
                    font.family: Appearance.font.family.pixel
                }
            }
        }
    }
}
