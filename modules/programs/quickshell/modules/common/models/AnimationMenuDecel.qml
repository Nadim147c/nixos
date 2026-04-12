pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root

    readonly property int duration: 350
    readonly property int type: Easing.OutExpo
}
