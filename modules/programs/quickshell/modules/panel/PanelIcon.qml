import qs.modules.common
import qs.modules.widgets

import QtQuick
import QtQuick.Controls

MaterialButton {
    id: root
    property Menu menu
    size: 30
    radius: Appearance.round.large * 2
    onRightClicked: menu.popup()
}
