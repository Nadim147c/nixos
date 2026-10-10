import QtQuick

SequentialAnimation {
    id: anim

    property QtObject target
    property string property: "borderColor"
    property color baseColor
    property color highlightColor

    property int totalDuration: 2000
    property int stepDuration: 100

    loops: Math.floor(totalDuration / (stepDuration * 2))

    ColorAnimation {
        target: anim.target
        property: anim.property
        to: anim.highlightColor
        duration: anim.stepDuration
        easing.type: Easing.InOutQuad
    }

    ColorAnimation {
        target: anim.target
        property: anim.property
        to: anim.baseColor
        duration: anim.stepDuration
        easing.type: Easing.InOutQuad
    }
}
