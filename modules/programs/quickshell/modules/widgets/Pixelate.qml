import QtQuick
import qs.modules.common

Item {
    id: root

    property color color: Appearance.material.myBackground ?? "#222222"
    property real pixelSize: 3.0
    property real colorsPerChannel: 0

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
        property color fallbackColor: root.color
        property real imagePixelSize: root.pixelSize
        property real colorsPerChannel: root.colorsPerChannel
        property vector2d size: Qt.vector2d(width, height)

        fragmentShader: Qt.resolvedUrl("./pixelate.frag.qsb")
    }
}
