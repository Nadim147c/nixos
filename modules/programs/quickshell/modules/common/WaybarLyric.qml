pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common.models
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
    id: root

    property string playerName: ""
    onPlayerNameChanged: {
        const mprisPlayer = Mpris.players.values.filter(p => p.dbusName == playerName)[0];
        if (mprisPlayer) {
            player = mprisPlayer;
        }
    }
    property MprisPlayer player
    Timer {
        running: root.isPlaying
        interval: 1000 / 6
        repeat: true
        onTriggered: root.player?.positionChanged()
    }

    property string title: player?.trackTitle ?? "Unknonw Title"
    property string artist: player?.trackArtist ?? "Unknown Artist"
    property string album: player?.trackAlbum ?? "Single"
    property bool isPlaying: player?.isPlaying ?? false

    property double position: player?.position ?? 0
    onPositionChanged: {
        if (player && lines.length) {
            let idx = 0;
            for (let i = 0; i < lines.length; i++) {
                if (lines[i].time > position) {
                    lineIndex = i - 1;
                    break;
                }
            }
        }
    }

    property string mprisCoverURL: player?.trackArtUrl ?? 0
    onMprisCoverURLChanged: downloadCover.exec(["qs-coverdb", mprisCoverURL])

    property string trackID: ""
    onTrackIDChanged: {
        lines = [];
        importLines.exec(["waybar-lyric", "export", "--format=json", trackID]);
    }
    Timer {
        running: root.isPlaying
        interval: 1000 * 2
        repeat: true
        onTriggered: importLines.exec(["waybar-lyric", "export", "--format=json", root.trackID])
    }

    property string text: ""
    property string alt: ""
    property string icon: ""

    property int lineIndex: 0
    property list<LyricLine> lines: []

    property string cover: ""
    onCoverChanged: coverColors.exec(["rong", "image", "--dry-run", "--json", cover])

    Process {
        id: downloadCover
        running: false
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.length === 0)
                    return;
                root.cover = data.toString().trim();
            }
        }
    }

    Process {
        id: coverColors
        running: false
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.length === 0)
                    return;
                Appearance.applyPlayerColors(data.toString());
            }
        }
    }

    Component {
        id: lyricLine
        LyricLine {}
    }
    Component {
        id: lyricWord
        LyricWord {}
    }

    Process {
        id: importLines
        running: false
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.length === 0)
                    return;
                const parsed = JSON.parse(data);

                const lines = [];
                const SECOND = 1000_000_000;

                for (const lyric of parsed.lyrics) {
                    const words = [];
                    for (const word of lyric.words ?? []) {
                        words.push(lyricWord.createObject(root, {
                            start: word.start / SECOND,
                            end: word.end / SECOND,
                            word: word.word
                        }));
                    }
                    lines.push(lyricLine.createObject(root, {
                        time: lyric.time / SECOND,
                        line: lyric.line,
                        words: words
                    }));
                }
                if (root.lines.length == lines.length) {
                    for (let i = 0; i < lines.length; i++) {
                        if (root.lines[i].line !== lines[i].line) {
                            root.lines = lines;
                            break;
                        }
                    }
                    return;
                }
                root.lines = lines;
            }
        }
    }

    Component {
        id: linesComponent
        QtObject {
            property string line: ""
            property real time: 0
        }
    }

    function setPosition(pos) {
        return Quickshell.execDetached(["waybar-lyric", "position", `${pos}`]);
    }

    Component.onCompleted: {
        const player = Mpris.players.values.filter(p => p.dbusName == playerName)[0];
        if (player != undefined) {
            root.player = player;
        }
    }

    Process {
        id: commandProcess
        running: true
        command: ["waybar-lyric", "--no-tooltip", "--quiet", "-fpartial"]

        stdout: SplitParser {
            onRead: data => {
                try {
                    if (!data || data.length === 0)
                        return;

                    const jsonText = data.toString();
                    const waybar = JSON.parse(jsonText);

                    root.text = waybar.text ?? "";
                    root.alt = waybar.alt ?? "";
                    root.trackID = waybar.id ?? "";
                    root.playerName = waybar.player ?? "";

                    const icons = {
                        playing: "play_arrow",
                        paused: "pause",
                        lyric: "lyrics",
                        music: "music_note",
                        no_lyric: "mic_off",
                        getting: "downloading"
                    };
                    root.icon = icons[waybar.alt] ?? "";
                } catch (e) {}
            }
        }
    }
}
