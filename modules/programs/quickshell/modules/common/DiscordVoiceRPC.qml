pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// This singleton is used to store the data of discord voice rpc.

Singleton {
    id: discordVoiceRPC
    property bool isVoiceActive: false
    property string channelName
    property string channelID
    property string guildID
    property int userLimit
    property list<DiscordVoiceMember> members

    Component {
        id: discordVoiceMember
        DiscordVoiceMember {}
    }

    Process {
        id: process
        running: true
        command: ["discord-voice-rpc"]
        stdout: SplitParser {
            onRead: msg => {
                discordVoiceRPC.parseJSON(msg);
            }
        }
    }

    function clearMembers() {
        for (let i = 0; i < members.length; ++i) {
            if (members[i]) {
                members[i].destroy();
            }
        }
        members = [];
    }

    function parseJSON(str: string) {
        clearMembers();

        let data = null;
        try {
            data = JSON.parse(str);
        } catch (e) {
            isVoiceActive = false;
            return;
        }

        isVoiceActive = !!data;
        channelName = data?.channelName ?? "";
        channelID = data?.channelID ?? "";
        guildID = data?.guildID ?? "";
        userLimit = data?.userLimit ?? 0;

        const objs = [];
        if (data?.members && Array.isArray(data?.members)) {
            for (let i = 0; i < data.members.length; ++i) {
                const m = data.members[i];
                objs.push(discordVoiceMember.createObject(discordVoiceRPC, {
                    userID: m.id,
                    username: m.username,
                    nickname: m.nickname,
                    serverName: m.serverName,
                    avatar: m.avatar,
                    avatarURL: m.avatarURL,
                    isTalking: m.isTalking,
                    isBot: m.isBot,
                    status: m.status
                }));
            }
        }
        members = objs;
    }
}
