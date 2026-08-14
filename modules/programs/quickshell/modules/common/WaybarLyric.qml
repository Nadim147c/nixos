pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common.models
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
    id: root

    Component.onCompleted: selectPlayer()
    onLatestUpdatedPlayerNameChanged: selectPlayer()
    onPlayerNameChanged: selectPlayer()

    property string latestUpdatedPlayerName: ""
    property string playerName: ""
    function selectPlayer() {
        let mprisPlayer = Mpris.players.values.find(p => p.dbusName === playerName);
        if (mprisPlayer) {
            player = mprisPlayer;
            return;
        }
        mprisPlayer = Mpris.players.values.find(p => p.dbusName === latestUpdatedPlayerName && p.isPlaying);
        if (mprisPlayer) {
            player = mprisPlayer;
            return;
        }
        if (Mpris.players.values.length) {
            player = Mpris.players.values[0];
        } else {
            player = null;
        }
    }
    property MprisPlayer player

    function setPosition(sec) {
        player.position = sec;
    }

    Timer {
        running: root.isPlaying
        interval: 1000 / 6
        repeat: true
        onTriggered: root.player?.positionChanged()
    }

    property string title: player?.trackTitle ?? "Unknown Title"
    property string artist: player?.trackArtist ?? "Unknown Artist"
    property string album: player?.trackAlbum ?? "Single"
    property bool isPlaying: player?.isPlaying ?? false

    property double position: player?.position ?? 0
    onPositionChanged: {
        if (player && lines.length) {
            let i = 0;
            for (i = 0; i < lines.length; i++) {
                if (lines[i].time > position) {
                    break;
                }
            }
            lineIndex = Math.max(0, i - 1);
        }
    }

    property string mprisCoverURL: player?.trackArtUrl ?? ""
    onMprisCoverURLChanged: {
        if (mprisCoverURL) {
            downloadCover.exec(["qs-coverdb", mprisCoverURL]);
        }
    }

    property string trackID: ""
    onTrackIDChanged: {
        clearLines(); // Clean up old memory immediately on track change
        if (trackID) {
            importLines.exec(["waybar-lyric", "export", "--format=json", trackID]);
        }
    }

    property bool shouldImport: false

    // Increased interval from 2s to 10s to stop spamming process executions
    Timer {
        running: root.isPlaying && root.trackID !== ""
        interval: 1000
        repeat: true
        onTriggered: {
            if (root.shouldImport) {
                importLines.exec(["waybar-lyric", "export", "--format=json", root.trackID]);
                root.shouldImport = false;
            }
        }
    }

    property string wtext: ""
    property string ptext: player?.trackTitle || player?.trackArtist ? `${player.trackArtist} - ${player.trackTitle}` : ""
    property string text: wtext || ptext
    property string alt: ""
    property string icon: ""

    property int lineIndex: 0
    property list<LyricLine> lines: []

    // Helper function to explicitly free memory of dynamic QML objects
    function clearLines() {
        for (let i = 0; i < lines.length; i++) {
            if (lines[i]) {
                if (lines[i].words) {
                    for (let j = 0; j < lines[i].words.length; j++) {
                        if (lines[i].words[j])
                            lines[i].words[j].destroy();
                    }
                }
                lines[i].destroy(); // Destroy C++ QML object!
            }
        }
        lines = [];
    }

    property string cover: ""
    onCoverChanged: {
        if (cover) {
            coverColors.exec(["rong", "image", "--dry-run", "--json", cover]);
        }
    }

    Process {
        running: true
        command: ["qs-mpris-monitor"]
        stdout: SplitParser {
            onRead: data => {
                if (data) {
                    root.latestUpdatedPlayerName = data.toString().trim();
                    root.selectPlayer();
                }
            }
        }
    }

    Process {
        id: downloadCover
        running: false
        stdout: SplitParser {
            onRead: data => {
                if (!data)
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
                if (data) {
                    Appearance.applyPlayerColors(data.toString());
                }
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

                const jsonText = data.toString();
                const parsed = JSON.parse(jsonText);
                if (!parsed.lyrics)
                    return;

                const SECOND = 1000_000_000;

                if (root.lines.length === parsed.lyrics.length && root.lines.length > 0) {
                    let isSame = true;
                    for (let i = 0; i < parsed.lyrics.length; i++) {
                        if (root.lines[i].line !== parsed.lyrics[i].line) {
                            isSame = false;
                            break;
                        }
                    }
                    if (isSame)
                        return; // Exit early without instantiating any new objects!
                }

                root.clearLines();

                const newLines = [];
                for (const lyric of parsed.lyrics) {
                    const words = [];
                    for (const word of lyric.words ?? []) {
                        words.push(lyricWord.createObject(root, {
                            start: word.start / SECOND,
                            end: word.end / SECOND,
                            word: word.word
                        }));
                    }
                    newLines.push(lyricLine.createObject(root, {
                        time: lyric.time / SECOND,
                        line: lyric.line,
                        words: words
                    }));
                }

                root.lines = newLines;
            }
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

                    const waybar = JSON.parse(data.toString());

                    // It is finished downloading
                    root.shouldImport = root.alt === "getting" && waybar.alt !== "no_lyric" && root.alt !== waybar.alt;

                    root.wtext = waybar.text ?? "";
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
