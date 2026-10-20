pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Menu {
    id: item
    contentItem: Card {
        implicitWidth: row.width
        implicitHeight: row.height
        color: Appearance.material.myBackground
        RowLayout {
            id: row
            children: item.contentItem
        }
    }
}
