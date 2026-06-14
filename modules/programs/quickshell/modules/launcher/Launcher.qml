pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.end4

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: root

    color: "transparent"
    property color bg: Appearance.material.myBackground
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    WlrLayershell.namespace: "quickshell:launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusiveZone: 0
    aboveWindows: true

    property int index: 0
    property var applications: DesktopEntries.applications.values
    readonly property var searchModel: DesktopEntries.applications.values.map(a => ({
                name: Fuzzy.prepare(`${a.name} ${a.description} ${a.keywords}`),
                entry: a
            }))

    function next() {
        index = (index + 1) % applications.length;
    }

    function previous() {
        index = (index - 1 + applications.length) % applications.length;
    }
    function execute() {
        const entry = applications[index];
        console.log(entry.id + ".desktop");
        Quickshell.execDetached(["control", "gtk-launch", entry.id + ".desktop"]);
    }

    function search(query: string) {
        const options = {
            all: true,
            key: "name"
        };
        const res = Fuzzy.go(query, searchModel, options).map(r => {
            return r.obj.entry;
        });
        root.applications = res;
    }

    // hidden mouse area over entire screen
    MouseArea {
        enabled: true
        anchors.fill: parent
        onClicked: {
            Toggle.launcher = false;
        }
    }

    ClippingRectangle {
        id: body
        opacity: 0.85
        implicitHeight: column.height
        implicitWidth: column.width
        color: root.bg
        radius: Appearance.round.larger
        anchors.centerIn: parent
        Behavior on implicitHeight {
            animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        ColumnLayout {
            id: column
            spacing: Appearance.space.little
            Input {}
            Entries {}
            Item {
                visible: root.applications.length !== 0
                implicitHeight: Appearance.space.big
                Layout.fillWidth: true
            }
        }
    }

    component Entries: ClippingRectangle {
        color: "transparent"
        implicitHeight: list.height
        Behavior on implicitHeight {
            animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        implicitWidth: parent.width
        visible: root.applications.length > 0
        ListView {
            id: list
            implicitHeight: Math.min(300, contentHeight)
            implicitWidth: parent.width - 20
            anchors.centerIn: parent
            model: root.applications
            currentIndex: root.index
            delegate: Item {
                id: entry
                width: list.width
                height: row.height + 5
                required property string name
                required property string icon
                required property string execString
                property var code: Nerdfont.find(icon, name)
                property bool isCurrent: ListView.isCurrentItem
                RowLayout {
                    id: row
                    width: entry.width - 10
                    anchors.centerIn: parent
                    height: 30
                    spacing: 10
                    Item {
                        implicitWidth: 30
                        MaterialSymbol {
                            anchors.centerIn: parent
                            visible: entry.code !== 0
                            code: entry.code
                            color: Appearance.material.myPrimary
                            iconSize: Appearance.font.pixelSize.large
                            font.family: Appearance.font.family.iconNerd
                        }
                        StyledImage {
                            anchors.fill: parent
                            visible: entry.code === 0 && Quickshell.hasThemeIcon(entry.icon)
                            source: Quickshell.iconPath(entry.icon)
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        StyledText {
                            anchors.fill: parent
                            color: Appearance.material.myOnBackground
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                            text: `${entry.name}`
                        }
                    }
                }
                Rectangle {
                    anchors.fill: parent
                    visible: entry.isCurrent
                    color: "transparent"
                    radius: 5
                    border {
                        width: 2
                        color: Appearance.material.myOutline
                    }
                }
            }
        }
    }

    component Input: Item {
        implicitWidth: 500
        implicitHeight: 50
        Rectangle {
            implicitWidth: parent.width - 10
            implicitHeight: parent.height - 10
            anchors.centerIn: parent
            radius: 18
            bottomLeftRadius: root.applications.length === 0 ? radius : 5
            bottomRightRadius: root.applications.length === 0 ? radius : 5
            Behavior on bottomLeftRadius {
                animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
            }
            Behavior on bottomRightRadius {
                animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
            }
            color: Appearance.material.mySurfaceContainer
            TextInput {
                color: Appearance.material.myOnSurface
                width: parent.width - 20
                anchors.centerIn: parent
                focus: true
                onTextChanged: root.search(text)
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        Toggle.launcher = false;
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
                        root.execute();
                        Toggle.launcher = false;
                        return;
                    }
                }
            }
        }
    }
}
