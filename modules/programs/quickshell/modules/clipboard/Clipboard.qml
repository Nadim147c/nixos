pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.end4
import qs.modules.widgets

import M3Shapes
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    WlrLayershell.namespace: "quickshell:clipboard"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    aboveWindows: true
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    exclusiveZone: 0
    color: "transparent"

    // hidden mouse area over entire screen
    MouseArea {
        enabled: true
        anchors.fill: parent
        onClicked: {
            Toggle.clipboard = false;
        }
    }

    Card {
        id: body
        implicitWidth: content.width
        implicitHeight: content.height
        Behavior on implicitHeight {
            animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        anchors.centerIn: parent
        color: Appearance.material.myBackground

        ColumnLayout {
            id: content
            Component.onCompleted: Yankd.search("")
            spacing: 0

            Card {
                id: searchBar
                Layout.preferredWidth: 500
                Layout.preferredHeight: 50
                Layout.margins: Appearance.space.big

                radius: 5
                borderWidth: 1
                borderPixelSize: 2
                color: Appearance.material.myBackground
                borderColor: Appearance.material.myOutline
                property bool isSearching: Yankd.isSearching
                onIsSearchingChanged: {
                    if (isSearching) {
                        borderColor = Appearance.material.myOnBackground;
                        searchAnimTimer.restart();
                    }
                }
                Timer {
                    id: searchAnimTimer
                    interval: 500
                    running: false
                    onTriggered: searchBar.borderColor = Appearance.material.myOutline
                }
                Behavior on borderColor {
                    animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: providerText.width + (Appearance.space.big * 2)
                        color: Appearance.material.mySurfaceContainerHighest
                        StyledText {
                            id: providerText
                            anchors.centerIn: parent
                            text: "Clipboard"
                            font {
                                pixelSize: Appearance.font.pixelSize.larger
                                family: Appearance.font.family.pixel
                            }
                        }
                    }

                    ClippingRectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        TextInput {
                            id: input
                            anchors.fill: parent
                            anchors.margins: Appearance.space.medium
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            color: Appearance.material.myOnSurface
                            focus: true
                            font {
                                family: Appearance.font.family.pixel
                                pixelSize: Appearance.font.pixelSize.larger
                            }
                            onTextChanged: Yankd.search(text)
                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Escape) {
                                    Toggle.clipboard = false;
                                    return;
                                }

                                // Delete remove the current item
                                if (event.key === Qt.Key_Delete) {
                                    Yankd.remove();
                                    event.accepted = true;
                                    return;
                                }

                                // Ctrl+N or Down Arrow → move forward
                                if ((event.key === Qt.Key_N && event.modifiers === Qt.ControlModifier) || event.key === Qt.Key_Down) {
                                    Yankd.next();
                                    event.accepted = true;
                                    return;
                                }

                                // Ctrl+P or Up Arrow → move backward
                                if ((event.key === Qt.Key_P && event.modifiers === Qt.ControlModifier) || event.key === Qt.Key_Up) {
                                    Yankd.previous();
                                    event.accepted = true;
                                    return;
                                }

                                // Enter → trigger action
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    Yankd.set();
                                    Toggle.clipboard = false;
                                    return;
                                }
                            }
                        }
                    }
                }
            }

            ClippingRectangle {
                color: "transparent"
                Layout.preferredHeight: Math.min(300, list.contentHeight)
                Layout.fillWidth: true
                ListView {
                    id: list
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    model: Yankd.searchResult
                    currentIndex: Yankd.searchIndex
                    delegate: Rectangle {
                        id: entry
                        width: list.width
                        height: row.height + 5
                        required property int eventID
                        required property string preview
                        required property string mimeType
                        property bool isCurrent: ListView.isCurrentItem
                        color: entry.isCurrent ? Appearance.material.mySurfaceContainerHighest : "transparent"
                        RowLayout {
                            id: row
                            width: entry.width - 10
                            anchors.centerIn: parent
                            spacing: 10
                            MaterialSymbol {
                                text: entry.mimeType.startsWith("image/") ? "image" : "text_ad"
                                color: Appearance.material.myPrimary
                            }
                            Item {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                StyledText {
                                    anchors.fill: parent
                                    color: Appearance.material.myOnBackground
                                    elide: Text.ElideRight
                                    textFormat: Text.PlainText
                                    text: `${entry.preview}` || `Unknown Content`
                                }
                            }
                        }
                    }
                }
            }

            Card {
                id: previewBox
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                Layout.margins: Appearance.space.big
                Layout.topMargin: 0

                radius: 5
                borderWidth: 1
                borderPixelSize: 2
                color: Appearance.material.mySurfaceContainer
                borderColor: Appearance.material.myOutline
                property bool isSearching: Yankd.isPreviewLoading
                onIsSearchingChanged: {
                    if (isSearching) {
                        borderColor = Appearance.material.myOnBackground;
                        previewAnimTimer.restart();
                    }
                }
                Timer {
                    id: previewAnimTimer
                    interval: 500
                    running: false
                    onTriggered: previewBox.borderColor = Appearance.material.myOutline
                }
                Behavior on borderColor {
                    animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
                }

                Loader {
                    anchors.fill: parent
                    active: Yankd.previewMimeType.startsWith("image/")
                    sourceComponent: Image {
                        anchors.fill: parent
                        source: `data:${Yankd.currentEntry.mimeType};base64,${Yankd.preview}`
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                ColumnLayout {
                    visible: Yankd.preview === "" && !Yankd.isPreviewLoading
                    anchors.centerIn: parent
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: "robot"
                        color: Appearance.material.mySurfaceVariant
                        font {
                            family: Appearance.font.family.iconPixel
                            pixelSize: Appearance.font.pixelSize.hugeass * 3
                        }
                    }
                    StyledText {
                        text: "Error 404: Not found"
                        color: Appearance.material.mySurfaceVariant
                        font {
                            family: Appearance.font.family.pixel2
                        }
                    }
                }

                Loader {
                    anchors.fill: parent
                    anchors.margins: Appearance.space.medium
                    active: !Yankd.previewMimeType.startsWith("image/")
                    sourceComponent: StyledText {
                        animateChange: true
                        verticalAlignment: Text.AlignTop
                        color: Appearance.material.myOnSurface
                        width: parent.width - 10
                        height: parent.height - 10
                        x: 5
                        y: 5
                        function removeIndent(text) {
                            const lines = text.split('\n');
                            let minIndent = Infinity;
                            for (const line of lines) {
                                if (line.trim() === '')
                                    continue; // Skip empty lines
                                const leadingSpaces = line.match(/^[ \t]*/)[0].length;
                                minIndent = Math.min(minIndent, leadingSpaces);
                            }
                            if (minIndent === Infinity)
                                return text;

                            const result = lines.map(line => {
                                if (line.trim() === '')
                                    return line; // Keep empty lines as-is
                                return line.slice(minIndent);
                            });

                            return result.join('\n');
                        }
                        text: removeIndent(Yankd.preview)
                    }
                }
            }
        }
    }
}
