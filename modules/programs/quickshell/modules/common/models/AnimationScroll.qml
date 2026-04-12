pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root

    readonly property AnimationCurves animationCurves: AnimationCurves {}

    readonly property int duration: 200
    readonly property int type: Easing.BezierSpline
    readonly property list<real> bezierCurve: animationCurves.standardDecel
}
