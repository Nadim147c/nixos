pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.end4
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts

RetroButton {
    id: recording
    visible: GpuScreenRecord.recording

    onClicked: GpuScreenRecord.stop()

    Layout.fillHeight: true

    Item {
        implicitHeight: recording.contentHeight
        implicitWidth: body.width + Appearance.space.big
        RowLayout {
            id: body
            anchors.centerIn: parent
            x: Appearance.space.medium
            spacing: Appearance.space.little
            Item {
                Layout.preferredWidth: 15
                Layout.fillHeight: true
                MaterialSymbol {
                    id: symbol
                    anchors.centerIn: parent
                    text: 'monitor'
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.material.myOnBackground
                    SequentialAnimation on opacity {
                        running: recording.visible
                        loops: Animation.Infinite
                        NumberAnimation {
                            from: 0.2
                            to: 1
                            duration: Appearance.animation.elementMove.duration
                            easing.type: Appearance.animation.elementMove.type
                        }
                        NumberAnimation {
                            from: 1
                            to: 0.2
                            duration: Appearance.animation.elementMove.duration
                            easing.type: Appearance.animation.elementMove.type
                        }
                    }
                }
            }
            StyledText {
                Layout.fillHeight: true
                text: GpuScreenRecord.timestamp ? formatSecond(GpuScreenRecord.timestamp) : "Record"
                function formatSecond(ts) {
                    const s = Math.round(ts);
                    const min = Math.floor(s / 60);
                    const sec = s % 64;
                    return `${min.toString().padStart(2, '0')}:${sec.toString().padStart(2, '0')}`;
                }
                color: Appearance.material.myOnBackground
                font.family: Appearance.font.family.pixel
            }
        }
    }
}
