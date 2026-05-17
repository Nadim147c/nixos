import qs.modules.common
import qs.modules.end4

import QtQuick
import Quickshell

Rectangle {
    id: root

    enum Variant {
        Filled,
        FilledTonal,
        Elevated,
        Outlined
    }

    property int variant: MaterialButton.Variant.Filled
    property bool enable: true

    required property string icon
    property real size: 22
    property real containerSize: Math.max(icon.height, icon.width) + (Appearance.space.small * 2)
    property string tooltip: ""
    readonly property bool containsMouse: mouse.containsMouse && enable

    signal clicked
    signal rightClicked

    implicitHeight: containerSize
    implicitWidth: containerSize
    radius: Appearance.round.large

    property real leftRadius: radius
    bottomLeftRadius: leftRadius
    topLeftRadius: leftRadius
    property real rightRadius: radius
    bottomRightRadius: rightRadius
    topRightRadius: rightRadius

    // Hover state overlay opacity added to meet Material 3 guidelines (8% primary/on-surface overlay)
    property color bgCol: {
        if (!enable)
            return Appearance.material.mySurfaceVariant;
        switch (variant) {
        case MaterialButton.Variant.Filled:
            return Appearance.material.myPrimary;
        case MaterialButton.Variant.FilledTonal:
            return Appearance.material.mySecondaryContainer;
        case MaterialButton.Variant.Elevated:
            return Appearance.material.mySurfaceContainerLow;
        case MaterialButton.Variant.Outlined:
            return "transparent";
        default:
            return Appearance.material.myPrimary;
        }
    }
    property color bgHoveredCol: {
        if (!enable)
            return Appearance.material.myOnSurfaceVariant;
        switch (variant) {
        case MaterialButton.Variant.Filled:
            return Qt.lighter(Appearance.material.myPrimary, 1.1); // Brightened variant for hover
        case MaterialButton.Variant.FilledTonal:
            return Qt.darker(Appearance.material.mySecondaryContainer, 1.05);
        case MaterialButton.Variant.Elevated:
            return Appearance.material.mySurfaceContainer;
        case MaterialButton.Variant.Outlined:
            return Qt.rgba(Appearance.material.myPrimary.r, Appearance.material.myPrimary.g, Appearance.material.myPrimary.b, 0.08); // 8% alpha tint
        default:
            return Appearance.material.myPrimary;
        }
    }
    property color fgCol: {
        if (!enable)
            return Appearance.material.myOnSurface;
        switch (variant) {
        case MaterialButton.Variant.Filled:
            return Appearance.material.myOnPrimary;
        case MaterialButton.Variant.FilledTonal:
            return Appearance.material.myOnSecondaryContainer;
        case MaterialButton.Variant.Elevated:
            return Appearance.material.myPrimary;
        case MaterialButton.Variant.Outlined:
            return Appearance.material.myPrimary;
        default:
            return Appearance.material.myOnPrimary;
        }
    }
    property color fgHoveredCol: fgCol

    border.color: variant === MaterialButton.Variant.Outlined ? Appearance.material.myOutline : "transparent"
    border.width: variant === MaterialButton.Variant.Outlined ? 1 : 0

    color: containsMouse ? bgHoveredCol : bgCol
    property color fg: containsMouse ? fgHoveredCol : fgCol
    opacity: enable ? 1.0 : 0.38

    Behavior on color {
        animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
    }
    Behavior on fg {
        animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        cursorShape: root.enable ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: root.enable ? (Qt.LeftButton | Qt.RightButton) : Qt.NoButton
        hoverEnabled: root.enable
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                root.clicked();
            } else {
                root.rightClicked();
            }
        }

        MaterialSymbol {
            id: icon
            x: (root.containerSize - width) / 2
            y: (root.containerSize - height) / 2
            color: root.fg
            iconSize: root.size
            text: root.icon
        }

        PopupTooltip {
            extraVisibleCondition: root.tooltip !== "" && mouse.containsMouse && root.enable
            anchorEdges: Edges.Top
            text: root.tooltip
        }
    }
}
