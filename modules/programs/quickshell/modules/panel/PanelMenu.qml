pragma ComponentBehavior: Bound
import qs.modules.common

import QtQuick
import QtQuick.Controls

Menu {
    id: item
    background: Rectangle {
        color: Appearance.material.mySurface
        radius: Appearance.space.big
        implicitWidth: 150
    }
}
