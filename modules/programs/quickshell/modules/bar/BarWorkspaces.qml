pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.modules.common
import qs.modules.end4
import qs.modules.widgets

RowLayout {
    id: root
    spacing: 1
    height: parent.height

    signal firstActive(bool b)

    Repeater {
        model: Hyprland.workspaces
        RetroButton {
            id: workspaceButton
            required property var modelData
            required property real index

            active: modelData.active
            Layout.fillHeight: true
            Layout.preferredWidth: root.height + 4

            onClicked: modelData.activate()

            StyledText {
                text: workspaceButton.modelData.name
                font.family: Appearance.font.family.pixel
                color: Appearance.material.myOnBackground
            }
        }
    }
}
