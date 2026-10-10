import qs.modules.common
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts

RetroButton {
    id: root
    Layout.fillHeight: true
    visible: Kdeconnect.hasDevice

    // Timer to delay single-click execution until double-click threshold passes
    Timer {
        id: clickTimer
        interval: 250
        repeat: false
        onTriggered: {
            Kdeconnect.ping();
        }
    }

    onClicked: function (mouse) {
        if (clickTimer.running) {
            clickTimer.stop();
            Kdeconnect.ring();
        } else {
            clickTimer.start();
        }
    }

    DropArea {
        id: dropArea

        implicitWidth: item.width + Appearance.space.big
        implicitHeight: root.contentHeight

        onDropped: function (drop) {
            if (drop.hasUrls) {
                const fileUrl = drop.urls[0];
                const url = new URL(fileUrl);
                Kdeconnect.shareFile(url.pathname);
            }
        }

        Item {
            id: item
            anchors.centerIn: parent
            implicitHeight: root.contentHeight
            implicitWidth: 20

            Text {
                anchors.centerIn: parent
                color: Appearance.material.myOnBackground
                text: "smartphone"
                font.family: Appearance.font.family.iconPixel
                font.pixelSize: Appearance.font.pixelSize.large
            }
        }
    }
}
