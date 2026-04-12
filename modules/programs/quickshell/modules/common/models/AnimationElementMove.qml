pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root
    readonly property AnimationCurves animationCurves: AnimationCurves {}

    readonly property int duration: animationCurves.expressiveDefaultSpatialDuration
    readonly property int type: Easing.BezierSpline
    readonly property list<real> bezierCurve: animationCurves.expressiveDefaultSpatial
    readonly property int velocity: 650

    readonly property Component numberAnimation: Component {
        NumberAnimation {
            duration: root.duration
            easing.type: root.type
            easing.bezierCurve: root.bezierCurve
        }
    }
    readonly property Component colorAnimation: Component {
        ColorAnimation {
            duration: root.duration
            easing.type: root.type
            easing.bezierCurve: root.bezierCurve
        }
    }
}
