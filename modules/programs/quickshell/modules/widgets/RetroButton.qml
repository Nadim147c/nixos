pragma ComponentBehavior: Bound
import QtQuick
import qs.modules.common

Item {
    id: root

    property bool active: false
    property real shadowSize: 4
    property real maxOffset: 2

    property color color: Qt.lighter(active ? Appearance.material.mySurfaceContainerHighest : Appearance.material.mySurfaceContainer, 1.7)
    property color hoverColor: Qt.lighter(color, 1.3)
    property color shadowColor: Qt.darker(color, 1.4)

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

            color: mouseArea.containsMouse ? root.hoverColor : root.color

            Behavior on offset {
                NumberAnimation {
                    duration: 100
                    easing.type: Appearance?.animation.elementMoveFast.type
                    easing.bezierCurve: Appearance?.animation.elementMoveFast.bezierCurve
                }
            }

            Rectangle {
                id: body
                anchors.fill: parent
                color: "transparent"

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
