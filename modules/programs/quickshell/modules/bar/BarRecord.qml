pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.end4
import qs.modules.end4.functions

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell

// This modules is havily inspired from:
// https://github.com/and-rs/dotfiles/blob/50c01696aa633a0b83913ce68308fabbb1c71d6b/.config/quickshell/Bar/Recording/RecordingService.qml

Rectangle {
    id: recording

    implicitWidth: clock.width + (Appearance.space.medium * 2)
    implicitHeight: parent.height

    // status: disabled, selecting, recording, compressing

    property string status: "disabled"
    property string pid: "do not kill me" // NOTE: the script must reset the pid
    property real perc: 0
    visible: status !== "disabled"

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

    radius: Appearance.round.medium

    color: Appearance.material.myPrimary
    property color fg: Appearance.material.myOnPrimary

    Behavior on color {
        ColorAnimation {
            duration: Appearance.time.quick
        }
    }
    Behavior on fg {
        ColorAnimation {
            duration: Appearance.time.quick
        }
    }

    RowLayout {
        id: clock
        height: parent.height
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
                color: recording.fg
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
                    colPrimary: Appearance.material.myOnPrimary
                    colSecondary: ColorUtils.transparentize(Appearance.material.myOnPrimary, 0.5)
                }
            }
        }
        Text {
            text: {
                if (recording.status === "recording")
                    return timer.formatSecond(timer.seconds);
                if (recording.status === "selecting")
                    return "Selection";
                if (recording.status === "compressing")
                    return "Compressing";
                return "";
            }
            color: recording.fg
            font {
                family: Appearance.font.family.main
                pixelSize: Appearance.font.pixelSize.small
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["kill", "-INT", recording.pid])
    }
}
