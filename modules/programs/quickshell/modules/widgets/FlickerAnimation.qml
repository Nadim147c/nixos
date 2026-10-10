import QtQuick

SequentialAnimation {
    id: anim

    property QtObject target
    property string property: "borderColor"
    property color baseColor
    property color highlightColor

    property int totalDuration: 2000
    property int stepDuration: totalDuration / (loops * 2)
    property var easingType: Easing.InOutQuad

    loops: 5

    ColorAnimation {
        target: anim.target
        property: anim.property
        to: anim.highlightColor
        duration: anim.stepDuration
        easing.type: anim.easingType
    }

    ColorAnimation {
        target: anim.target
        property: anim.property
        to: anim.baseColor
        duration: anim.stepDuration
        easing.type: anim.easingType
    }
}
