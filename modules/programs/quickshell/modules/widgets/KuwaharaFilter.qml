import QtQuick
import qs.modules.common

Item {
    id: root

    property color targetColor: Appearance.material.myPrimary ?? "#222222"
    property real bitDepth: 4.0
    property real pixelSize: 3.0
    property real kuwaharaStrength: 0.5

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
        property color targetColor: root.targetColor
        property real bitDepth: root.bitDepth
        property real pixelSize: root.pixelSize
        property real kuwaharaStrength: root.kuwaharaStrength
        property vector2d size: Qt.vector2d(width, height)

        fragmentShader: Qt.resolvedUrl("./kuwakara_filter.frag.qsb")
    }
}
