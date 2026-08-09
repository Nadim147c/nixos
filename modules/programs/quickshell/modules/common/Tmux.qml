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
        if (!str || str.trim() === "")
            return;

        try {
            const data = JSON.parse(str);
            if (!data || !Array.isArray(data))
                return;

            const currentLength = sessions.length;
            const newLength = data.length;

            // 1. If we have MORE existing objects than incoming data, destroy extras
            if (currentLength > newLength) {
                for (let i = newLength; i < currentLength; i++) {
                    if (sessions[i]) {
                        sessions[i].destroy();
                    }
                }
                sessions.splice(newLength, currentLength - newLength);
            }

            for (let i = 0; i < newLength; i++) {
                const itemData = data[i];

                if (i < sessions.length && sessions[i]) {
                    sessions[i].name = itemData.name ?? "";
                    sessions[i].active = itemData.active ?? false;
                    sessions[i].windows = itemData.windows ?? 0;
                    sessions[i].lastActivity = itemData.last_activity ?? "";
                } else {
                    const newObj = tmuxSession.createObject(tmux, {
                        name: itemData.name ?? "",
                        active: itemData.active ?? false,
                        windows: itemData.windows ?? 0,
                        lastActivity: itemData.last_activity ?? ""
                    });
                    sessions.push(newObj);
                }
            }

            sessionsChanged();
        } catch (e) {}
    }
}
