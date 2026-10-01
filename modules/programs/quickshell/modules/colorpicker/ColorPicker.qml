pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.end4.functions

import OkLab
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "quickshell:colorpicker"
    color: "transparent"

    property color activeColor: OkLch.toColor(activeOkLch)
    property oklch activeOkLch: OkLch.fromColor(Appearance.material.myPrimary)
    property alias lightness: root.activeOkLch.l
    property alias chroma: root.activeOkLch.c
    property alias hue: root.activeOkLch.h
    property real maxChroma: 0.37

    MouseArea {
        enabled: true
        anchors.fill: parent
        onClicked: Toggle.colorpicker = false
    }

    Rectangle {
        anchors.fill: mainLayout
        anchors.margins: -16
        radius: Appearance.round.little
        color: Appearance.material.myBackground
        MouseArea {
            anchors.fill: mainLayout
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors.centerIn: parent
        spacing: Appearance.space.large

        Text {
            text: "OkLch Color Picker"
            color: Appearance.material.myOnBackground
            font {
                family: Appearance.font.family.pixel
                pixelSize: Appearance.font.pixelSize.huge
                weight: 600
            }
        }

        RowLayout {
            id: row
            spacing: Appearance.space.large

            ShaderEffect {
                id: colorRing
                Layout.preferredWidth: 250
                Layout.preferredHeight: 250

                property real ringPadding: 2
                property real ringSize: 30
                property alias chroma: root.chroma
                property alias lightness: root.lightness
                property bool clampColors: true
                property color fallback: Appearance.material.mySurfaceVariant
                property vector2d size: Qt.vector2d(width, height)
                fragmentShader: "./ring.frag.qsb"

                Rectangle {
                    id: hueHandle
                    width: 14
                    height: 14
                    radius: 7
                    color: Appearance.material.myPrimary
                    border.color: Appearance.material.myBackground
                    border.width: 2

                    property real radiusPx: (Math.min(colorRing.width, colorRing.height) / 2.0) - colorRing.ringPadding - (colorRing.ringSize / 2.0)
                    property real angleRad: (root.hue * Math.PI) / 180.0

                    x: (colorRing.width / 2.0) - (Math.cos(angleRad) * radiusPx) - (width / 2.0)
                    y: (colorRing.height / 2.0) - (Math.sin(angleRad) * radiusPx) - (height / 2.0)
                }

                MouseArea {
                    id: ringMouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    property real angle: 0
                    property bool inRing: false
                    onInRingChanged: {
                        cursorShape = inRing ? Qt.PointingHandCursor : Qt.ArrowCursor;
                    }
                    onPressed: mouse => {
                        inRing = updateHue(mouse);
                    }
                    onPositionChanged: mouse => {
                        inRing = updateHue(mouse, pressed);
                    }

                    function updateHue(mouse, updateHue = true) {
                        let centerX = width / 2.0;
                        let centerY = height / 2.0;

                        let dx = -mouse.x + centerX;
                        let dy = -mouse.y + centerY;

                        let dist = Math.sqrt(dx * dx + dy * dy);

                        let boxRadius = Math.min(width, height) / 2.0;
                        let outerRadius = boxRadius - colorRing.ringPadding;
                        let innerRadius = outerRadius - colorRing.ringSize;

                        if (dist >= innerRadius && dist <= outerRadius) {
                            if (updateHue) {
                                let angle = Math.atan2(dy, dx);
                                if (angle < 0) {
                                    angle += 2.0 * Math.PI;
                                }
                                root.hue = angle * (180 / Math.PI);
                            }
                            return true;
                        }
                        return false;
                    }
                }

                Rectangle {
                    id: colorPreviewBox
                    anchors.centerIn: parent
                    implicitWidth: 120
                    implicitHeight: 120
                    color: root.activeColor
                    radius: height
                    scale: centerMouseArea.pressed ? 1.05 : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }
                    }

                    MouseArea {
                        id: centerMouseArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.clipboardText = hexInput.text
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2

                        TextInput {
                            id: hueCenterInput
                            Layout.alignment: Qt.AlignHCenter
                            text: Math.round(root.hue) + "°"
                            font {
                                family: Appearance.font.family.pixel
                                pixelSize: Appearance.font.pixelSize.norml
                            }
                            selectByMouse: true

                            color: hexInput.color

                            onEditingFinished: {
                                let val = parseFloat(text.replace("°", ""));
                                if (!isNaN(val)) {
                                    let normalized = val % 360;
                                    if (normalized < 0)
                                        normalized += 360;
                                    root.hue = normalized;
                                }
                                text = Math.round(root.hue) + "°";
                            }
                        }

                        TextInput {
                            id: hexInput
                            Layout.alignment: Qt.AlignHCenter
                            font {
                                family: Appearance.font.family.pixel
                                pixelSize: Appearance.font.pixelSize.larger
                            }
                            text: root.activeColor.toString().toUpperCase()
                            selectByMouse: true

                            color: {
                                let l = root.activeOkLch.l;
                                let fgL = l >= 0.5 ? l - 0.5 : l + 0.5;
                                return OkLch.toColor(OkLch.oklch(fgL, root.activeOkLch.c, root.activeOkLch.h));
                            }

                            onEditingFinished: {
                                let formatted = text.trim();
                                if (!formatted.startsWith("#")) {
                                    formatted = "#" + formatted;
                                }
                                let parsed = Qt.color(formatted);
                                if (parsed.valid) {
                                    root.activeOkLch = OkLch.fromColor(parsed);
                                } else {
                                    text = root.activeColor.toString().toUpperCase();
                                }
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: 4

                TextInput {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 20
                    text: Math.round(root.lightness * 100) + "%"
                    color: Appearance.material.myOnBackground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font {
                        family: Appearance.font.family.pixel
                        pixelSize: Appearance.font.pixelSize.larger
                    }
                    selectByMouse: true
                    onEditingFinished: {
                        let val = parseFloat(text.replace("%", ""));
                        if (!isNaN(val)) {
                            root.lightness = Math.max(0, Math.min(100, val)) / 100.0;
                        }
                        text = Math.round(root.lightness * 100) + "%";
                    }
                }

                ShaderEffect {
                    id: lightnessSlider
                    Layout.fillHeight: true
                    Layout.preferredWidth: 24
                    property real chroma: root.chroma
                    property real hue: root.hue
                    property bool clampColors: true
                    property color fallback: Appearance.material.mySurfaceVariant
                    property vector2d size: Qt.vector2d(width, height)
                    fragmentShader: "./lightness.frag.qsb"

                    Rectangle {
                        width: parent.width + 6
                        height: 6
                        radius: 3
                        x: -3
                        y: (1.0 - root.lightness) * parent.height - (height / 2.0)
                        color: Appearance.material.myPrimary
                        border.color: Appearance.material.myBackground
                        border.width: 1
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        function updateLightness(mouse) {
                            let clampedY = Math.max(0, Math.min(height, mouse.y));
                            root.lightness = 1.0 - (clampedY / height);
                        }

                        onPressed: mouse => updateLightness(mouse)
                        onPositionChanged: mouse => {
                            if (pressed)
                                updateLightness(mouse);
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: 4

                TextInput {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 20
                    text: Math.round((root.chroma / root.maxChroma) * 100) + "%"
                    color: Appearance.material.myOnBackground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font {
                        family: Appearance.font.family.pixel
                        pixelSize: Appearance.font.pixelSize.larger
                    }
                    selectByMouse: true
                    onEditingFinished: {
                        let val = parseFloat(text.replace("%", ""));
                        if (!isNaN(val)) {
                            let clamped = Math.max(0, Math.min(100, val)) / 100.0;
                            root.chroma = clamped * root.maxChroma;
                        }
                        text = Math.round((root.chroma / root.maxChroma) * 100) + "%";
                    }
                }

                ShaderEffect {
                    id: chromaSlider
                    Layout.fillHeight: true
                    Layout.preferredWidth: 24
                    property real lightness: root.lightness
                    property real hue: root.hue
                    property real maxChroma: root.maxChroma
                    property bool clampColors: true
                    property color fallback: Appearance.material.mySurfaceVariant
                    property vector2d size: Qt.vector2d(width, height)
                    fragmentShader: "./chroma.frag.qsb"

                    Rectangle {
                        width: parent.width + 6
                        height: 6
                        radius: 3
                        x: -3
                        y: (1.0 - (root.chroma / root.maxChroma)) * parent.height - (height / 2.0)
                        color: Appearance.material.myPrimary
                        border.color: Appearance.material.myBackground
                        border.width: 1
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        function updateChroma(mouse) {
                            let clampedY = Math.max(0, Math.min(height, mouse.y));
                            root.chroma = (1.0 - (clampedY / height)) * root.maxChroma;
                        }

                        onPressed: mouse => updateChroma(mouse)
                        onPositionChanged: mouse => {
                            if (pressed)
                                updateChroma(mouse);
                        }
                    }
                }
            }
        }
    }
}
