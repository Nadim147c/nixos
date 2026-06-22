pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.end4

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

    ClippingRectangle {
        id: body
        opacity: 0.85
        implicitWidth: content.width
        implicitHeight: content.height
        Behavior on implicitHeight {
            animation: Appearance?.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        anchors.centerIn: parent
        color: Appearance.material.myBackground
        radius: 20
        Body {
            id: content
        }
    }
    component Body: ColumnLayout {
        id: col
        Component.onCompleted: Yankd.search("")
        Input {}
        Entries {}
        Preview {}
    }

    component Input: Item {
        implicitWidth: 500
        implicitHeight: 50
        Rectangle {
            implicitWidth: parent.width - 10
            implicitHeight: parent.height - 10
            anchors.centerIn: parent
            radius: 18
            bottomLeftRadius: 5
            bottomRightRadius: 5
            color: Appearance.material.mySurfaceContainer
            RowLayout {
                width: parent.width - 20
                anchors.centerIn: parent
                spacing: Appearance.space.big
                Item {
                    implicitHeight: parent.height
                    implicitWidth: implicitHeight
                    MaterialShape {
                        id: materialShape
                        implicitWidth: implicitHeight
                        implicitHeight: parent.height + 10
                        anchors.centerIn: parent
                        shape: MaterialShape.Cookie7Sided
                        color: animate ? Appearance.material.myPrimary : Appearance.material.mySurfaceVariant
                        Behavior on color {
                            animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
                        }
                        property bool isSearching: Yankd.isSearching
                        onIsSearchingChanged: {
                            animate = true;
                            timer.restart();
                        }
                        property bool animate: false
                        Timer {
                            id: timer
                            interval: 200
                            repeat: false
                            triggeredOnStart: false
                            onTriggered: materialShape.animate = false
                        }
                        RotationAnimation on rotation {
                            from: 0
                            to: 360
                            duration: 1500
                            loops: Animation.Infinite
                            running: materialShape.animate
                        }
                    }
                    MaterialSymbol {
                        code: 0xE8B6
                        anchors.centerIn: parent
                        color: materialShape.animate ? Appearance.material.myOnPrimary : Appearance.material.myOnSurfaceVariant
                        Behavior on color {
                            animation: Appearance?.animation.elementMoveFast.colorAnimation.createObject(this)
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    implicitHeight: input.height
                    TextInput {
                        id: input
                        width: parent.width
                        color: Appearance.material.myOnSurface
                        focus: true
                        onTextChanged: Yankd.search(text)
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                Toggle.clipboard = false;
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
    }

    component Preview: Item {
        visible: Yankd.preview !== ""
        implicitWidth: 500
        implicitHeight: 200
        ClippingRectangle {
            implicitWidth: parent.width - 10
            implicitHeight: parent.height - 10
            anchors.centerIn: parent
            radius: 18
            topLeftRadius: 5
            topRightRadius: 5
            color: Appearance.material.mySurfaceContainer
            Loader {
                anchors.fill: parent
                active: Yankd.previewMimeType.startsWith("image/")
                sourceComponent: Image {
                    anchors.fill: parent
                    source: `data:${Yankd.currentEntry.mimeType};base64,${Yankd.preview}`
                    fillMode: Image.PreserveAspectCrop
                }
            }
            Loader {
                anchors.fill: parent
                active: !Yankd.previewMimeType.startsWith("image/")
                sourceComponent: StyledText {
                    animateChange: true
                    verticalAlignment: Text.AlignTop
                    color: Appearance.material.myOnSurface
                    width: parent.width - 10
                    height: parent.height - 10
                    x: 5
                    y: 5
                    text: Yankd.preview
                }
            }
        }
    }

    component Entries: ClippingRectangle {
        color: "transparent"
        implicitHeight: 300
        implicitWidth: parent.width
        ListView {
            id: list
            implicitHeight: parent.height
            implicitWidth: parent.width - 20
            anchors.centerIn: parent
            model: Yankd.searchResult
            currentIndex: Yankd.searchIndex
            delegate: Item {
                id: entry
                width: list.width
                height: row.height + 5
                required property int eventID
                required property string preview
                required property string mimeType
                property bool isCurrent: ListView.isCurrentItem
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
                            text: `${entry.preview}`
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
}
