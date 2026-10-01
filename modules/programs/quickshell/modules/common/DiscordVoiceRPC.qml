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

    function mute(id: string, v = true) {
        process.write(`MUTE:${id}:${v}\n`);
    }

    function volume(id: string, v = 100) {
        process.write(`VOLUME:${id}:${v}\n`);
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
        let data = null;
        try {
            data = JSON.parse(str);
        } catch (e) {
            isVoiceActive = false;
            return;
        }

        if (!data) {
            isVoiceActive = false;
            clearMembers();
            return;
        }

        isVoiceActive = !!data;
        channelName = data?.channelName ?? "";
        channelID = data?.channelID ?? "";
        guildID = data?.guildID ?? "";
        userLimit = data?.userLimit ?? 0;

        if (!data?.members || !Array.isArray(data?.members)) {
            clearMembers();
        }

        if (data.members.length === members.length && data.members.every((e, i) => e.id === members[i].userID)) {
            for (let i = 0; i < data.members.length; ++i) {
                const m = data.members[i];
                members[i].userID = m.id;
                members[i].username = m.username;
                members[i].nickname = m.nickname;
                members[i].serverName = m.serverName;
                members[i].avatar = m.avatar;
                members[i].avatarURL = m.avatarURL;
                members[i].isTalking = m.isTalking;
                members[i].isBot = m.isBot;
                members[i].status = m.status;
                members[i].volume = m.volume || 100;
            }
            return;
        }

        clearMembers();
        let objs = [];

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
                status: m.status,
                volume: m.volume || 100
            }));
        }
        members = objs;
    }
}
