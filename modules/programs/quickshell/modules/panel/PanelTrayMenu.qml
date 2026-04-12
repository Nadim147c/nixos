pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.end4

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

// This is not the best way to do this but this works!!!

Item {
    id: rootroot
    function popup() {
        while (stackview.depth > 1)
            stackview.pop();
        stackview.currentItem.popup();
    }
    required property var modelData
    StackView {
        id: stackview
        initialItem: customMenu.createObject(null, {
            modelData: rootroot.modelData
        })
    }
    Component {
        id: customMenu
        CustomMenu {}
    }
    component CustomMenu: Item {
        id: root
        function popup() {
            menu.popup();
        }
        required property var modelData
        QsMenuOpener {
            id: menuOpener
            menu: root.modelData
        }
        Menu {
            id: menu
            background: Item {}
            contentItem: Rectangle {
                color: Appearance.material.mySurface
                radius: Appearance.space.big
                implicitHeight: column.height + (Appearance.space.tiny * 2)
                implicitWidth: column.width + (Appearance.space.tiny * 2)
                ColumnLayout {
                    id: column
                    x: Appearance.space.tiny
                    y: Appearance.space.tiny
                    spacing: 1
                    Repeater {
                        id: repeater
                        // filter consecutive and trailing separator
                        model: menuOpener.children.values.filter((item, index, arr) => {
                            if (!item.isSeparator)
                                return true;
                            if (index === 0 || index === arr.length - 1)
                                return false;
                            return !arr[index - 1].isSeparator;
                        })
                        Item {
                            id: menuItem
                            required property QsMenuEntry modelData
                            required property real index
                            property bool onTop: index === 0 || repeater.model[index - 1]?.isSeparator
                            property bool onBottom: index == repeater.model.length - 1 || repeater.model[index + 1]?.isSeparator
                            property real pad: Appearance.space.medium
                            height: menuItem.modelData.isSeparator ? 2 : text.height + (pad * 2)
                            width: row.width + (pad * 2)
                            Rectangle {
                                height: parent.height
                                width: column.width
                                color: {
                                    if (menuItem.modelData.isSeparator) {
                                        return "transparent";
                                    } else if (mouseArea.containsMouse) {
                                        return Appearance.material.myPrimary;
                                    }
                                    return Appearance.material.mySurfaceContainer;
                                }

                                property real bigRound: Appearance.space.big - 2
                                property real smallRound: Appearance.space.little
                                topLeftRadius: menuItem.onTop ? bigRound : smallRound
                                topRightRadius: menuItem.onTop ? bigRound : smallRound
                                bottomLeftRadius: menuItem.onBottom ? bigRound : smallRound
                                bottomRightRadius: menuItem.onBottom ? bigRound : smallRound

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    enabled: menuItem.modelData.enabled
                                    hoverEnabled: true
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    onClicked: mouse => {
                                        if (mouse.button === Qt.LeftButton) {
                                            menuItem.modelData.triggered();
                                            menu.dismiss();
                                            console.log("dismiss");
                                            return;
                                        }
                                        if (menuItem.modelData.hasChildren) {
                                            const obj = customMenu.createObject(null, {
                                                modelData: menuItem.modelData
                                            });
                                            stackview.push(obj);
                                            obj.popup();
                                        }
                                    }
                                }

                                Row {
                                    id: row
                                    x: menuItem.pad
                                    y: menuItem.pad
                                    spacing: Appearance.space.small
                                    Loader {
                                        active: menuItem.modelData.hasChildren
                                        sourceComponent: MaterialSymbol {
                                            id: icon
                                            anchors.centerIn: parent
                                            text: "arrow_drop_down"
                                            font.pixelSize: Appearance.font.pixelSize.smallie
                                            color: text.color
                                        }
                                    }
                                    StyledText {
                                        id: text
                                        text: menuItem.modelData.text
                                        color: {
                                            if (mouseArea.containsMouse) {
                                                return Appearance.material.myOnPrimary;
                                            }
                                            if (!menuItem.modelData.enabled) {
                                                return Appearance.material.myOnSurfaceVariant;
                                            }
                                            return Appearance.material.myOnSurface;
                                        }
                                        font.pixelSize: Appearance.font.pixelSize.smallie
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
