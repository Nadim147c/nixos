import qs.modules.common
import qs.modules.end4

import QtQuick
import QtQuick.Layouts

GroupButton {
    id: root
    required property string iconName
    property string content
    property real buttonHeight
    property real buttonWidth

    colBackground: Appearance?.player.myPrimary
    colBackgroundHover: Appearance?.player.myTertiary
    colBackgroundActive: Appearance?.player.myPrimary
    colBackgroundToggled: Appearance?.player.mySecondary
    colBackgroundToggledHover: Appearance?.player.myTertiary
    colBackgroundToggledActive: Appearance?.player.myTertiary
    colOnBackground: Appearance?.player.myOnPrimary
    colOnBackgroundHover: Appearance?.player.myOnTertiary
    colOnBackgroundActive: Appearance?.player.myOnPrimary
    colOnBackgroundToggled: Appearance?.player.myOnSecondary
    colOnBackgroundToggledHover: Appearance?.player.myOnTertiary
    colOnBackgroundToggledActive: Appearance?.player.myOnTertiary

    contentItem: Item {
        implicitHeight: root.buttonHeight
        implicitWidth: root.buttonWidth
        RowLayout {
            anchors.centerIn: parent
            MaterialSymbol {
                iconSize: Appearance.font.pixelSize.hugeass
                text: root.iconName
                color: root.fg
                fill: 1
            }
            StyledText {
                visible: root.content != ""
                text: root.content + " "
                color: root.fg
                font {
                    bold: true
                    family: Appearance.font.family.expressive
                }
            }
        }
    }
}
