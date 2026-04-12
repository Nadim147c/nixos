import QtQuick
import QtQuick.Shapes
import qs.modules.common
import qs.modules.widgets

/**
 * Material 3 circular progress. See https://m3.material.io/components/progress-indicators/specs
 */
Item {
    id: root

    property int implicitSize: 30
    property int lineWidth: 2
    property real value: 0
    property color colPrimary: Appearance.material.myPrimary
    property color colSecondary: Appearance.material.myTertiary
    property real gapAngle: 360 / 18
    property bool fill: false
    property int fillOverflow: 2
    property bool enableAnimation: true
    property int animationDuration: 800
    property var easingType: Easing.OutCubic

    property bool wavy: true
    property bool animateWave: true
    property real waveFrequency: 13
    property real waveSpeed: 3
    property real waveHeight: lineWidth
    property bool waveAnimation: true

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    property real degree: value * 360
    property real centerX: root.width / 2
    property real centerY: root.height / 2
    property real arcRadius: root.implicitSize / 2 - root.lineWidth
    property real startAngle: -90

    Behavior on degree {
        enabled: root.enableAnimation
        NumberAnimation {
            duration: root.animationDuration
            easing.type: root.easingType
        }
    }

    Loader {
        active: root.fill
        anchors.fill: parent

        sourceComponent: Rectangle {
            radius: 9999
            color: root.colSecondary
        }
    }

    Shape {
        visible: root.wavy
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            id: wavySecondaryPath
            strokeColor: root.colSecondary
            strokeWidth: root.lineWidth
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathAngleArc {
                centerX: root.centerX
                centerY: root.centerY
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: root.startAngle - root.gapAngle
                sweepAngle: -(360 - root.degree - 2 * root.gapAngle)
            }
        }
    }

    Loader {
        active: root.wavy
        anchors.fill: parent
        WavyCircle {
            id: wavyCircle
            visible: root.wavy
            anchors.fill: parent
            waveHeight: root.waveHeight
            animate: root.waveAnimation
            lineWidth: root.lineWidth
            frequency: root.waveFrequency
            degree: root.degree
            speed: root.waveSpeed
            startDegree: root.startAngle
            color: root.colPrimary
            Connections {
                target: root
                function onValueChanged() {
                    wavyCircle.requestPaint();
                }
                function onDegreeChanged() {
                    wavyCircle.requestPaint();
                }
            }
            FrameAnimation {
                running: root.animateWave
                onTriggered: {
                    wavyCircle.requestPaint();
                }
            }
        }
    }

    Shape {
        visible: !root.wavy
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            id: secondaryPath
            strokeColor: root.colSecondary
            strokeWidth: root.lineWidth
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathAngleArc {
                centerX: root.centerX
                centerY: root.centerY
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: root.startAngle - root.gapAngle
                sweepAngle: -(360 - root.degree - 2 * root.gapAngle)
            }
        }
        ShapePath {
            id: primaryPath
            strokeColor: root.colPrimary
            strokeWidth: root.lineWidth
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathAngleArc {
                centerX: root.centerX
                centerY: root.centerY
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: root.startAngle
                sweepAngle: root.degree
            }
        }
    }
}
