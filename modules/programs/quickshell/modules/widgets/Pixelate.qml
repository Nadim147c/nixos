import QtQuick

Item {
    id: root

    property real pixelSize: 3.0
    property real levels: 0

    property alias color: contentItem.color
    default property alias data: contentItem.data
    property alias children: contentItem.children
    readonly property alias contentItem: contentItem

    Rectangle {
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
        property real levels: root.levels
        property vector2d size: Qt.vector2d(width, height)

        fragmentShader: Qt.resolvedUrl("./pixelate.frag.qsb")
    }
}
