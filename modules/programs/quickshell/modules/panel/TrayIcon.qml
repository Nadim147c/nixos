pragma ComponentBehavior: Bound
import qs.modules.end4
import qs.modules.common
import qs.modules.widgets

import QtQuick
import Quickshell.Services.SystemTray

Item {
    id: root

    required property SystemTrayItem item

    property int size: 24
    property color fg: Appearance.material.myOnBackground

    width: size
    height: size

    function materialNameFromIcon(icon) {
        const staticNames = {
            "blueman-tray": "bluetooth",
            "blueman-disabled": "bluetooth_disabled",
            "blueman-active": "bluetooth_connected",
            "nm-no-connection": "signal_disconnected"
        };

        const parts = icon.split("?")[0].split("/");
        const iconName = parts[parts.length - 1];

        if (iconName.startsWith("nm-stage")) {
            return "pending";
        }

        if (iconName.startsWith("nm-signal-")) {
            const signal = parseInt(iconName.substring("nm-signal-".length), 10);
            if (isNaN(signal))
                return "signal_wifi_bad";
            const signals = ["wifi_1_bar", "wifi_2_bar", "android_wifi_3_bar", "android_wifi_4_bar"];
            const index = Math.min(signals.length - 1, Math.floor(signal / 100 * signals.length));
            return signals[index];
        }

        return staticNames[iconName] || "";
    }

    function nerdSymbolFromIcon(icon) {
        const nerds = {
            "nm-device-wired": "󰈀",
            "kdeconnectindicatordark": "",
            "kdeconnectindicatorlight": "",
            "com.spotify.Client-symbolic": "󰓇"
        };

        const parts = icon.split("?")[0].split("/");
        const iconName = parts[parts.length - 1];
        const name = nerds[iconName];
        if (name) {
            return name;
        }

        const tooltipName = root.item.tooltipTitle;

        return "";
    }

    property string materialName: materialNameFromIcon(item.icon)
    property string nerdSymbol: nerdSymbolFromIcon(item.icon)

    MaterialSymbol {
        id: materialIcon
        anchors.centerIn: parent
        visible: root.materialName !== ""

        text: root.materialName
        font.pixelSize: root.size * 0.5
        color: root.fg
    }

    MaterialSymbol {
        id: nerdIcon
        anchors.centerIn: parent
        visible: root.nerdSymbol !== ""
        text: root.nerdSymbol
        font.pixelSize: root.size * 0.5
        font.family: Appearance.font.family.iconNerd
        color: root.fg
    }

    Loader {
        active: root.materialName === "" && root.nerdSymbol === ""
        anchors.centerIn: parent
        sourceComponent: Monochrome {
            anchors.centerIn: parent
            implicitWidth: fallbackIcon.width
            implicitHeight: fallbackIcon.height
            color: Appearance.material.myOnBackground
            Image {
                id: fallbackIcon
                anchors.centerIn: parent
                height: root.size * 0.5
                width: root.size * 0.5
                source: root.item.icon
            }
        }
    }
}
