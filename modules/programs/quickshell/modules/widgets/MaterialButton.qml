import qs.modules.common
import qs.modules.common.models
import qs.modules.end4

import QtQuick
import Quickshell

Rectangle {
    id: root

    enum Variant {
        Filled,
        FilledTonal,
        Elevated,
        Outlined,
        Text
    }

    property int variant: MaterialButton.Variant.Filled
    property bool enable: true

    required property string icon
    property real size: 22
    property bool fill: true
    property real containerSize: Math.max(icon.height, icon.width) + (Appearance.space.small * 2)
    property string tooltip: ""
    readonly property bool containsMouse: mouse.containsMouse && enable

    property bool hovered: mouse.containsMouse
    signal clicked
    signal rightClicked
    signal middleClicked

    property RongColors scheme: Appearance.material

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
            return root.scheme.mySurfaceVariant;
        switch (variant) {
        case MaterialButton.Variant.Filled:
            return root.scheme.myPrimary;
        case MaterialButton.Variant.FilledTonal:
            return root.scheme.mySecondaryContainer;
        case MaterialButton.Variant.Elevated:
            return root.scheme.mySurfaceContainerLow;
        case MaterialButton.Variant.Outlined:
            return "transparent";
        case MaterialButton.Variant.Text:
            return "transparent";
        default:
            return root.scheme.myPrimary;
        }
    }
    property color bgHoveredCol: {
        if (!enable)
            return root.scheme.myOnSurfaceVariant;
        switch (variant) {
        case MaterialButton.Variant.Filled:
            return Qt.lighter(root.scheme.myPrimary, 1.1); // Brightened variant for hover
        case MaterialButton.Variant.FilledTonal:
            return Qt.darker(root.scheme.mySecondaryContainer, 1.05);
        case MaterialButton.Variant.Elevated:
            return root.scheme.mySurfaceContainer;
        case MaterialButton.Variant.Outlined:
            return "transparent";
        case MaterialButton.Variant.Text:     // Material 3 states text buttons use an 8% state container on hover
            return Qt.rgba(root.scheme.myPrimary.r, root.scheme.myPrimary.g, root.scheme.myPrimary.b, 0.08);
        default:
            return root.scheme.myPrimary;
        }
    }
    property color fgCol: {
        if (!enable)
            return root.scheme.myOnSurface;
        switch (variant) {
        case MaterialButton.Variant.Filled:
            return root.scheme.myOnPrimary;
        case MaterialButton.Variant.FilledTonal:
            return root.scheme.myOnSecondaryContainer;
        case MaterialButton.Variant.Elevated:
        case MaterialButton.Variant.Outlined:
        case MaterialButton.Variant.Text:     // Text button foreground matches the primary theme color
            return root.scheme.myPrimary;
        default:
            return root.scheme.myOnPrimary;
        }
    }
    property color fgHoveredCol: fgCol

    border.color: variant === MaterialButton.Variant.Outlined ? root.scheme.myOutline : "transparent"
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
            switch (mouse.button) {
            case Qt.LeftButton:
                root.clicked();
                break;
            case Qt.MiddleButton:
                root.middleClicked();
                break;
            case Qt.RightButton:
                root.rightClicked();
                break;
            }
        }

        MaterialSymbol {
            id: icon
            x: (root.containerSize - width) / 2
            y: (root.containerSize - height) / 2
            fill: root.fill || root.variant === MaterialButton.Variant.Text ? 1 : 0
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
