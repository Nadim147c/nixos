import QtQuick

Item {
    id: root

    property color color: "white"
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
        smooth: true

        property variant imageTexture: bodySource
        property point size: Qt.point(width, height)
        property color targetColor: root.color

        fragmentShader: Qt.resolvedUrl("./monochrome.frag.qsb")
    }
}
