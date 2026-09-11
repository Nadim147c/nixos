pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Cava

RetroButton {
    id: root
    Layout.fillHeight: true

    enabled: false

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

    Item {
        implicitWidth: body.width + Appearance.space.little * 2
        implicitHeight: root.contentHeight
        Rectangle {
            id: rect
            anchors.fill: parent
            anchors.margins: Appearance.space.tiny
            color: Appearance.material.mySurfaceContainerHighest
            Loader {
                active: root.mute
                anchors.fill: parent
                sourceComponent: Item {
                    anchors.fill: parent
                    Item {
                        id: textContainer
                        anchors.fill: parent
                        visible: false

                        Text {
                            anchors.fill: parent
                            text: "OwO"
                            color: Appearance.material.myOnBackground
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font {
                                family: Appearance.font.family.pixel
                                pixelSize: Appearance.font.pixelSize.larger
                            }
                        }
                    }

                    ShaderEffectSource {
                        id: textSource
                        sourceItem: textContainer
                        hideSource: true
                        live: true
                    }

                    ShaderEffect {
                        id: glitchEffect
                        anchors.fill: parent

                        property variant source: textSource
                        property real time: 0
                        property real glitchAmount: 0.0

                        fragmentShader: "glitch.frag.qsb"

                        NumberAnimation on time {
                            from: 0
                            to: 100
                            duration: 10000
                            loops: Animation.Infinite
                            running: true
                        }
                    }

                    Timer {
                        interval: 150
                        running: true
                        repeat: true
                        onTriggered: {
                            glitchEffect.glitchAmount = Math.random() > 0.6 ? Math.random() : 0.0;
                        }
                    }
                }
            }
            Loader {
                id: body
                active: !root.mute
                width: Cava.values.length * Appearance.space.little
                height: parent.height
                anchors.centerIn: parent
                sourceComponent: ShaderEffect {
                    id: cavaShader
                    anchors.fill: parent

                    property color colorTop: Appearance.material.myError
                    property color colorBottom: Appearance.material.myPrimary

                    property real totalGapWidth: 15
                    property vector4d params: Qt.vector4d(width, totalGapWidth, 16.0, 0)

                    property vector4d cava0: Qt.vector4d(Cava.values[0] || 0, Cava.values[1] || 0, Cava.values[2] || 0, Cava.values[3] || 0)
                    property vector4d cava1: Qt.vector4d(Cava.values[4] || 0, Cava.values[5] || 0, Cava.values[6] || 0, Cava.values[7] || 0)
                    property vector4d cava2: Qt.vector4d(Cava.values[8] || 0, Cava.values[9] || 0, Cava.values[10] || 0, Cava.values[11] || 0)
                    property vector4d cava3: Qt.vector4d(Cava.values[12] || 0, Cava.values[13] || 0, Cava.values[14] || 0, Cava.values[15] || 0)

                    fragmentShader: "cava.frag.qsb"
                }
            }
        }
    }
}
