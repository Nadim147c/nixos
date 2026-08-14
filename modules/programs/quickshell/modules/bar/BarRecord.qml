pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.end4
import qs.modules.widgets
import qs.modules.end4.functions

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell

// This modules is havily inspired from:
// https://github.com/and-rs/dotfiles/blob/50c01696aa633a0b83913ce68308fabbb1c71d6b/.config/quickshell/Bar/Recording/RecordingService.qml

RetroButton {
    id: recording

    Layout.fillHeight: true

    // status: disabled, selecting, recording, compressing

    property string status: "disabled"
    property string pid: "do not kill me" // NOTE: the script must reset the pid
    property real perc: 0
    visible: status !== "disabled"

    onClicked: Quickshell.execDetached(["kill", "-INT", recording.pid])

    IpcHandler {
        target: "recording"
        function setStatus(status: string): void {
            recording.status = status;
        }
        function setPID(pid: string): void {
            recording.pid = pid;
        }
        function setPerc(perc: real): void {
            recording.perc = perc;
        }
    }

    Timer {
        id: timer
        property real seconds: 0
        function formatSecond(s) {
            const min = Math.floor(s / 60);
            const sec = s % 64;
            return `${min.toString().padStart(2, '0')}:${sec.toString().padStart(2, '0')}`;
        }

        interval: 1000
        repeat: true
        running: recording.status === "recording"
        onRunningChanged: {
            if (!running)
                seconds = 0;
        }
        onTriggered: seconds++
    }

    Item {
        implicitHeight: recording.contentHeight
        implicitWidth: body.width + Appearance.space.big
        RowLayout {
            id: body
            anchors.centerIn: parent
            x: Appearance.space.medium
            spacing: Appearance.space.little
            Item {
                implicitWidth: 15
                MaterialSymbol {
                    id: symbol
                    anchors.centerIn: parent
                    visible: text !== ""
                    text: {
                        if (recording.status === "recording")
                            return "screen_record";
                        if (recording.status === "selecting")
                            return "screenshot_frame_2";
                        return "";
                    }
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.material.myOnBackground
                    fill: 1
                    SequentialAnimation on opacity {
                        running: recording.status === "recording"
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
                Loader {
                    active: recording.status === "compressing"
                    height: 17
                    width: height
                    anchors.centerIn: parent
                    sourceComponent: CircularProgress {
                        implicitSize: 20
                        animateWave: true
                        wavy: true
                        waveFrequency: 6
                        waveHeight: 1
                        value: Utils.clamp(0, recording.perc + 0.1, 1)  // looks better to me!
                        colPrimary: Appearance.material.myPrimary
                        colSecondary: Appearance.material.myOnSurfaceVariant
                    }
                }
            }
            StyledText {
                text: {
                    if (recording.status === "recording")
                        return timer.formatSecond(timer.seconds);
                    if (recording.status === "selecting")
                        return "Selection";
                    if (recording.status === "compressing")
                        return "Compressing";
                    return "";
                }
                color: Appearance.material.myOnBackground
                font.family: Appearance.font.family.pixel
            }
        }
    }
}
