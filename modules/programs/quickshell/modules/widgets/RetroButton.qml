pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.end4.functions

import QtQuick

Item {
    id: root

    property bool active: false
    property real shadowSize: 4
    property real maxOffset: 2

    property color color: Qt.lighter(Appearance.material.mySurfaceContainer, 1.7)
    property color activeColor: Qt.lighter(color, 1.8)
    property color disabledColor: color
    property color rippleColor: Appearance.material.myPrimary
    property color hoverColor: Qt.lighter(color, 1.3)
    property color shadowColor: Appearance.material.myShadow

    property Item contentItem
    property alias contentHeight: body.height
    property alias contentWidth: body.width
    default property alias dataContent: body.data

    property alias containsMouse: mouseArea.containsMouse
    signal clicked(var mouse)
    signal rightClicked(var mouse)
    signal middleClicked(var mouse)
    signal scrolled(var wheel)

    implicitWidth: (contentItem ? contentItem.implicitWidth : 0) + maxOffset + shadowSize
    implicitHeight: (contentItem ? contentItem.implicitHeight : 0) + maxOffset + shadowSize

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: root.enabled
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: mouse => {
            rippleEffect.clickPos = Qt.vector2d(mouseArea.mouseX / mouseArea.width, mouseArea.mouseY / mouseArea.height);
            rippleAnim.restart();
            if (mouse.button === Qt.LeftButton) {
                root.clicked(mouse);
            } else if (mouse.button === Qt.RightButton) {
                root.rightClicked(mouse);
            } else if (mouse.button === Qt.MiddleButton) {
                root.middleClicked(mouse);
            }
        }

        onWheel: wheel => root.scrolled(wheel)

        Rectangle {
            id: rect

            property real offset: {
                if (mouseArea.pressed) {
                    return 0;
                } else if (root.active) {
                    return -1;
                } else {
                    return -root.maxOffset;
                }
            }

            x: offset + root.maxOffset
            y: offset + root.maxOffset
            width: root.width - root.maxOffset - root.shadowSize
            height: root.height - root.maxOffset - root.shadowSize

            color: {
                if (mouseArea.containsMouse) {
                    return root.hoverColor;
                } else if (root.active) {
                    return root.activeColor;
                } else if (!root.enabled) {
                    return root.disabledColor;
                } else {
                    return root.color;
                }
            }

            Behavior on offset {
                NumberAnimation {
                    duration: 100
                    easing.type: Appearance?.animation.elementMoveFast.type
                    easing.bezierCurve: Appearance?.animation.elementMoveFast.bezierCurve
                }
            }

            ShaderEffect {
                id: rippleEffect
                anchors.fill: parent
                visible: rippleAnim.running

                property vector2d clickPos: Qt.vector2d(0.5, 0.5)
                property vector2d screenSize: Qt.vector2d(width, height)
                property real pixelSize: 5.0
                property real progress: 1
                property real aspectRatio: width / height
                property real waveWidth: 1

                property color centerColor: root.rippleColor
                property color edgeColor: Qt.lighter(root.rippleColor, 1.2)

                fragmentShader: "./ripple.frag.qsb"
            }

            NumberAnimation {
                id: rippleAnim
                target: rippleEffect
                property: "progress"
                from: 0.0
                to: 1.0
                duration: Appearance.animation.clickBounce.duration * 2
                easing.bezierCurve: Appearance.animation.clickBounce.bezierCurve
            }

            Rectangle {
                id: body
                anchors.fill: parent
                color: "transparent"
                border.width: 1
                border.color: ColorUtils.transparentize(root.shadowColor, 0.7)
                onChildrenChanged: {
                    for (var i = 0; i < children.length; i++) {
                        if (children[i] instanceof Item) {
                            root.contentItem = children[i];
                            root.contentItem.anchors.centerIn = body;
                            break;
                        }
                    }
                }
            }

            SharpRectShadow {
                id: shadow
                target: rect
                color: root.shadowColor
                size: root.shadowSize - (root.maxOffset + rect.offset)
            }
        }
    }
}
