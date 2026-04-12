pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: tmux
    property list<TmuxSession> sessions: []

    Process {
        id: process
        running: true
        command: ["qs-tmux-session-info"]
        stdout: StdioCollector {
            onStreamFinished: tmux.parseJSON(this.text)
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 2000
        onTriggered: process.running = true
    }

    Component {
        id: tmuxSession
        TmuxSession {}
    }
    function parseJSON(str: string) {
        const data = JSON.parse(str);
        const objs = [];
        if (data && Array.isArray(data)) {
            for (const session of data) {
                objs.push(tmuxSession.createObject(tmux, {
                    name: session.name ?? "",
                    active: session.active ?? false,
                    windows: session.windows ?? 0,
                    lastActivity: session.last_activity ?? ""
                }));
            }
        }
        sessions = objs;
    }
}
