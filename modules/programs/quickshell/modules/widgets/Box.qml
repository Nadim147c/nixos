import QtQuick
import qs.modules.common

Item {
    id: root

    property real borderSize: 3
    property real shadowSize: 4

    property color borderColor: Appearance.material.myPrimary
    property color shadowColor: Qt.darker(Appearance.material.myPrimary, 1.4)
    property color color: Appearance.material.mySurfaceContainerHighest

    property Item contentItem

    default property alias dataContent: body.data

    implicitWidth: (contentItem ? contentItem.implicitWidth : 0) + borderSize * 3 + shadowSize
    implicitHeight: (contentItem ? contentItem.implicitHeight : 0) + borderSize * 3 + shadowSize

    Rectangle {
        id: rect
        x: 0
        y: 0
        width: root.width - root.shadowSize
        height: root.height - root.shadowSize
        color: root.borderColor

        Rectangle {
            id: body
            x: root.borderSize
            y: root.borderSize
            width: rect.width - root.borderSize * 2
            height: rect.height - root.borderSize * 2
            color: root.color

            onChildrenChanged: {
                for (var i = 0; i < children.length; i++) {
                    if (children[i] instanceof Item) {
                        root.contentItem = children[i];
                        root.contentItem.anchors.fill = body;
                        break;
                    }
                }
            }
        }

        SharpRectShadow {
            id: shadow
            target: rect
            size: root.shadowSize
            color: root.shadowColor
        }
    }
}
