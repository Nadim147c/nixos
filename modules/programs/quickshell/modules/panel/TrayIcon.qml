pragma ComponentBehavior: Bound
import qs.modules.end4
import qs.modules.common

import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import Quickshell.Services.SystemTray

Item {
    id: root

    required property SystemTrayItem item

    property int size: 24
    property color color: Appearance.material.myPrimary

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

        // --- Wi-Fi signal handling ---
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
            // nm-device-wired-secure
            "kdeconnectindicatordark": "",
            "kdeconnectindicatorlight": "",
            "com.spotify.Client-symbolic": "󰓇",
            "steam_tray_mono": "󰓓"
        };

        const parts = icon.split("?")[0].split("/");
        const iconName = parts[parts.length - 1];
        const name = nerds[iconName];
        if (name) {
            return name;
        }

        const tooltips = {
            "Discord": "",
            "GoofCord": "",
            "OBS Studio": ""
        };

        const tooltipName = root.item.tooltipTitle;

        if (!name && tooltips[tooltipName]) {
            return tooltips[tooltipName];
        }

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
        color: root.color
    }

    MaterialSymbol {
        id: nerdIcon
        anchors.centerIn: parent
        visible: root.nerdSymbol !== ""
        text: root.nerdSymbol
        font.pixelSize: root.size * 0.5
        font.family: Appearance.font.family.iconNerd
        color: root.color
    }

    Loader {
        active: root.materialName === "" && root.nerdSymbol === ""
        anchors.centerIn: parent
        sourceComponent: IconImage {
            id: fallbackIcon
            anchors.centerIn: root
            implicitSize: root.size * 0.5
            source: root.item.icon
            smooth: true
            layer.enabled: true
            layer.effect: MultiEffect {
                contrast: 0.2
                brightness: 0
                saturation: -1
            }
        }
    }
}
