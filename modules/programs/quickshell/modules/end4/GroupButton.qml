import qs.modules.common
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * Material 3 button with expressive bounciness.
 * See https://m3.material.io/components/button-groups/overview
 */
Button {
    id: root
    property bool toggled
    property string buttonText
    property real buttonRadius: Appearance?.round?.small ?? 8
    property real buttonRadiusPressed: Appearance?.round?.small ?? 6
    property var downAction // When left clicking (down)
    property var releaseAction // When left clicking (release)
    property var altAction // When right clicking
    property var middleClickAction // When middle clicking
    property bool bounce: true
    property real baseWidth: contentItem.implicitWidth + horizontalPadding * 2
    property real baseHeight: contentItem.implicitHeight + verticalPadding * 2
    property bool enableImplicitWidthAnimation: true
    property bool enableImplicitHeightAnimation: true
    property real clickedWidth: baseWidth + (isAtSide ? 10 : 20)
    property real clickedHeight: baseHeight
    property var parentGroup: root.parent
    property int indexInParent: parentGroup?.children.indexOf(root) ?? -1
    property int clickIndex: parentGroup?.clickIndex ?? -1
    property bool isAtSide: indexInParent === 0 || indexInParent === (parentGroup?.childrenCount - 1)

    Layout.fillWidth: (clickIndex - 1 <= indexInParent && indexInParent <= clickIndex + 1)
    Layout.fillHeight: (clickIndex - 1 <= indexInParent && indexInParent <= clickIndex + 1)
    implicitWidth: (root.down && bounce) ? clickedWidth : baseWidth
    implicitHeight: (root.down && bounce) ? clickedHeight : baseHeight

    property color colBackground: Appearance?.material.myPrimary
    property color colBackgroundHover: Appearance?.material.myTertiary
    property color colBackgroundActive: Appearance?.material.myPrimary
    property color colBackgroundToggled: Appearance?.material.myTertiary
    property color colBackgroundToggledHover: Appearance?.material.myPrimary
    property color colBackgroundToggledActive: Appearance?.material.myTertiary
    property color colOnBackground: Appearance?.material.myOnPrimary
    property color colOnBackgroundHover: Appearance?.material.myOnTertiary
    property color colOnBackgroundActive: Appearance?.material.myOnPrimary
    property color colOnBackgroundToggled: Appearance?.material.myOnTertiary
    property color colOnBackgroundToggledHover: Appearance?.material.myOnPrimary
    property color colOnBackgroundToggledActive: Appearance?.material.myOnTertiary

    property real radius: root.down ? root.buttonRadiusPressed : root.buttonRadius
    property real leftRadius: root.down ? root.buttonRadiusPressed : root.buttonRadius
    property real rightRadius: root.down ? root.buttonRadiusPressed : root.buttonRadius

    property color color: root.enabled ? (root.toggled ? (root.down ? colBackgroundToggledActive : root.hovered ? colBackgroundToggledHover : colBackgroundToggled) : (root.down ? colBackgroundActive : root.hovered ? colBackgroundHover : colBackground)) : colBackground
    property color fg: root.enabled ? (root.toggled ? (root.down ? colOnBackgroundToggledActive : root.hovered ? colOnBackgroundToggledHover : colOnBackgroundToggled) : (root.down ? colOnBackgroundActive : root.hovered ? colOnBackgroundHover : colOnBackground)) : colOnBackground

    onDownChanged: {
        if (root.down) {
            if (root.parent.clickIndex !== undefined) {
                root.parent.clickIndex = parent.children.indexOf(root);
            }
        }
    }

    Behavior on implicitWidth {
        enabled: root.enableImplicitWidthAnimation
        animation: Appearance.animation.clickBounce.numberAnimation.createObject(this)
    }

    Behavior on implicitHeight {
        enabled: root.enableImplicitHeightAnimation
        animation: Appearance.animation.clickBounce.numberAnimation.createObject(this)
    }

    Behavior on leftRadius {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }
    Behavior on rightRadius {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    property alias mouseArea: buttonMouseArea
    MouseArea {
        id: buttonMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onPressed: event => {
            if (event.button === Qt.RightButton) {
                if (root.altAction)
                    root.altAction();
                return;
            }
            if (event.button === Qt.MiddleButton) {
                if (root.middleClickAction)
                    root.middleClickAction();
                return;
            }
            root.down = true;
            if (root.downAction)
                root.downAction();
        }
        onReleased: event => {
            root.down = false;
            if (event.button != Qt.LeftButton)
                return;
            if (root.releaseAction)
                root.releaseAction();
        }
        onClicked: event => {
            if (event.button != Qt.LeftButton)
                return;
            root.click();
        }
        onCanceled: event => {
            root.down = false;
        }

        onPressAndHold: () => {
            altAction();
            root.down = false;
            root.clicked = false;
        }
    }

    property bool tabbedTo: root.focus && (focusReason === Qt.TabFocusReason || focusReason === Qt.BacktabFocusReason)
    background: Rectangle {
        id: buttonBackground
        topLeftRadius: root.leftRadius
        topRightRadius: root.rightRadius
        bottomLeftRadius: root.leftRadius
        bottomRightRadius: root.rightRadius
        implicitHeight: 50

        color: root.color
        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        border.width: root.tabbedTo ? 2 : 0
        border.color: Appearance.material.mySecondary
    }

    contentItem: StyledText {
        text: root.buttonText
        color: root.fg
    }
}
