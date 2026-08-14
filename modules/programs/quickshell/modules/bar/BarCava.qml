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
        implicitWidth: body.width + Appearance.space.tiny * 3
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
            RowLayout {
                id: body
                height: parent.height
                spacing: 1
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: Cava.values

                    Item {
                        id: bar
                        implicitWidth: Appearance.space.tiny
                        implicitHeight: body.height
                        required property double modelData

                        ClippingRectangle {
                            anchors.bottom: parent.bottom
                            implicitWidth: bar.implicitWidth
                            implicitHeight: rect.height * bar.modelData

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: root.height

                                gradient: Gradient {
                                    GradientStop {
                                        position: 0.0
                                        color: Appearance.material.myError
                                    }
                                    GradientStop {
                                        position: 1.0
                                        color: Appearance.material.myPrimary
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
