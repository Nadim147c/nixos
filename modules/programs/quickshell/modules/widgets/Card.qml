import qs.modules.common
import QtQuick

Item {
    id: root

    property color borderColor: Appearance.material.myOutline ?? "#222222"
    property color color: Appearance.material.myBackground ?? "#222222"
    property real radius: 5.0
    property real borderWidth: 2
    property real borderPixelSize: 3

    default property alias data: contentItem.data
    property alias children: contentItem.children
    readonly property alias contentItem: contentItem

    Item {
        id: contentItem
        anchors.fill: parent
    }

    ShaderEffectSource {
        id: bodySource
        sourceItem: root.contentItem
        hideSource: true
        live: true
    }

    ShaderEffect {
        anchors.fill: root.contentItem

        property variant imageTexture: bodySource
        property color borderColor: root.borderColor
        property color fallbackColor: root.color
        property real radius: root.radius
        property real borderWidth: root.borderWidth
        property real borderPixelSize: root.borderPixelSize
        property vector2d size: Qt.vector2d(width, height)

        fragmentShader: Qt.resolvedUrl("./card.frag.qsb")
    }
}
