pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.widgets
import qs.modules.end4

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: root

    color: "transparent"
    property color bg: Appearance.material.myBackground
    anchors {
        left: true
        top: true
        right: true
        bottom: true
    }

    WlrLayershell.namespace: "quickshell:launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusiveZone: 0
    aboveWindows: true

    component Entry: QtObject {
        property string identifier
        property string text
        property string subtext
        property string icon
        property string provider
        property var actions
    }

    Component {
        id: entry
        Entry {}
    }

    property int currentIndex: 0
    onResultsChanged: currentIndex = 0
    function next() {
        currentIndex = (currentIndex + 1) % results.length;
    }
    function previous() {
        let idx = currentIndex - 1;
        currentIndex = idx >= 0 ? idx : results.length - idx;
    }
    function nextProvider() {
        providerIndex = (providerIndex + 1) % providers.length;
        for (const result of root.results) {
            result.destroy();
        }
        results = [];
    }

    property list<Entry> results: []
    property list<Entry> tempResults: []

    function search(q: string) {
        searcher.exec(["elephant", "query", "--json", `${provider};${q};100;false`]);
    }

    function primaryAction() {
        action(0);
    }
    function secondaryAction() {
        action(1);
    }
    function tertiaryAction() {
        action(2);
    }

    function action(idx: int) {
        const {
            provider,
            identifier,
            actions
        } = results[currentIndex];
        console.log(JSON.stringify(["elephant", "activate", `${provider};${identifier};${actions[idx]};;`]));
        Quickshell.execDetached(["elephant", "activate", `${provider};${identifier};${actions[idx]};;`]);
    }

    Component.onCompleted: search("")

    Process {
        id: searcher
        onRunningChanged: {
            if (running) {
                root.tempResults = [];
            } else {
                for (const result of root.results) {
                    result.destroy();
                }
                root.results = root.tempResults;
            }
        }
        stdout: SplitParser {
            onRead: data => {
                if (!data) {
                    return;
                }
                const e = JSON.parse(data.toString());

                root.tempResults.push(entry.createObject(root, {
                    identifier: e.item.identifier,
                    text: e.item.text,
                    subtext: e.item.subtext ?? "",
                    icon: e.item.icon ?? "",
                    provider: e.item.provider,
                    actions: e.item.actions
                }));
            }
        }
    }

    // readonly property list<string> providers: ["desktopapplications", "websearch", "files", "bookmarks", "symbols", "windows", "runner", "wireplumber", "unicode", "calc", "todo",]
    readonly property list<string> providers: ["desktopapplications", "symbols", "calc", "files", "windows"]
    property int providerIndex: 0

    property string provider: providers[providerIndex]
    property string providerName: {
        const humanReadableNames = {
            websearch: "Web Search",
            files: "Files",
            snippets: "Snippets",
            playerctl: "Media Player Control",
            clipboard: "Clipboard",
            bookmarks: "Bookmarks",
            symbols: "Symbols",
            bluetooth: "Bluetooth",
            windows: "Windows",
            runner: "Runner",
            wireplumber: "Audio Control",
            unicode: "Unicode",
            calc: "Calculator",
            todo: "To-Do",
            desktopapplications: "Applications"
        };
        return humanReadableNames[provider];
    }

    Card {
        anchors.centerIn: parent
        implicitWidth: body.width
        implicitHeight: body.height
        Behavior on implicitHeight {
            animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        color: Appearance.material.myBackground
        ColumnLayout {
            id: body
            spacing: 0
            Card {
                Layout.preferredWidth: 500
                Layout.preferredHeight: 50
                Layout.margins: Appearance.space.big

                radius: 5
                borderWidth: 1
                borderPixelSize: 2

                RowLayout {
                    anchors.fill: parent

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: providerText.width + (Appearance.space.big * 2)
                        color: Appearance.material.mySurfaceContainerHighest
                        StyledText {
                            id: providerText
                            anchors.centerIn: parent
                            text: root.providerName
                            font {
                                pixelSize: Appearance.font.pixelSize.normal
                                family: Appearance.font.family.pixel
                            }
                        }
                    }

                    ClippingRectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        TextInput {
                            anchors.fill: parent
                            anchors.margins: Appearance.space.medium
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            color: Appearance.material.myOnSurface
                            focus: true
                            font {
                                family: root.provider === "calc" ? Appearance.font.family.numbers : Appearance.font.family.pixel
                                pixelSize: Appearance.font.pixelSize.larger
                            }
                            onTextChanged: root.search(text)
                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Escape) {
                                    Toggle.launcher = false;
                                    return;
                                }

                                if (event.key === Qt.Key_Tab) {
                                    root.nextProvider();
                                    event.accepted = true;
                                    return;
                                }

                                // Ctrl+N or Down Arrow → move forward
                                if ((event.key === Qt.Key_N && event.modifiers === Qt.ControlModifier) || event.key === Qt.Key_Down) {
                                    root.next();
                                    event.accepted = true;
                                    return;
                                }

                                // Ctrl+P or Up Arrow → move backward
                                if ((event.key === Qt.Key_P && event.modifiers === Qt.ControlModifier) || event.key === Qt.Key_Up) {
                                    root.previous();
                                    event.accepted = true;
                                    return;
                                }

                                // Enter → trigger action
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    if (event.modifiers === (Qt.ShiftModifier | Qt.ControlModifier)) {
                                        console.log("tertiary action");
                                        root.tertiaryAction();
                                    } else if (event.modifiers === Qt.ControlModifier) {
                                        root.secondaryAction();
                                    } else {
                                        root.primaryAction();
                                    }
                                    Toggle.launcher = false;
                                    return;
                                }
                            }
                        }
                    }
                }
            }

            ClippingRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(view.contentHeight, 500)
                Layout.leftMargin: Appearance.space.big
                Layout.rightMargin: Appearance.space.big
                Layout.bottomMargin: Appearance.space.big
                visible: root.results.length
                color: "transparent"
                ListView {
                    id: view
                    anchors.fill: parent
                    model: root.results
                    currentIndex: root.currentIndex
                    spacing: 2
                    delegate: Item {
                        id: item
                        required property string provider
                        required property string text
                        required property string icon
                        required property string subtext
                        property bool isCurrent: ListView.isCurrentItem
                        implicitWidth: view.width
                        implicitHeight: 50

                        Rectangle {
                            anchors.fill: parent
                            color: item.isCurrent ? Appearance.material.mySurfaceContainerHighest : "transparent"

                            RowLayout {
                                id: viewRow
                                anchors.fill: parent
                                anchors.margins: Appearance.space.small

                                Pixelate {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    visible: !["symbols", "calc"].includes(item.provider) && !!item.icon
                                    pixelSize: 2
                                    color: "transparent"
                                    Image {
                                        anchors.fill: parent
                                        source: Quickshell.iconPath(item.icon)
                                        fillMode: Image.PreserveAspectCrop
                                    }
                                }

                                StyledText {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    text: item.icon
                                    visible: item.provider === "symbols" && !!item.icon
                                    font.pixelSize: Appearance.font.pixelSize.hugeass
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 2

                                    StyledText {
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignLeft
                                        text: item.text
                                        font {
                                            family: item.provider === "calc" ? Appearance.font.family.numbers : Appearance.font.family.pixel
                                            pixelSize: Appearance.font.pixelSize.large
                                        }
                                    }
                                    StyledText {
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignLeft
                                        text: item.subtext
                                        visible: text !== ""
                                        color: Appearance.material.myOnSurfaceVariant
                                        font {
                                            family: item.provider === "calc" ? Appearance.font.family.numbers : Appearance.font.family.pixel
                                            pixelSize: Appearance.font.pixelSize.smallie
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
