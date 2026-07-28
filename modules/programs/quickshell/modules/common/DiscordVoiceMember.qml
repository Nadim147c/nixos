import QtQuick

// This component is used to store the data of a voice member.

QtObject {
    id: root

    property string userID: ""
    property string username: ""
    property string nickname: ""
    property string serverName: ""
    property string avatar: ""
    property string avatarURL: ""
    property bool isTalking: false
    property bool isBot: false
    property int status: 0

    readonly property int statusMute: 1 << 0
    readonly property int statusSelfMute: 1 << 1
    readonly property int statusDeaf: 1 << 2
    readonly property int statusSelfDeaf: 1 << 3
    readonly property int statusSuppress: 1 << 4

    // checks if user is muted or self muted.
    function isMute() {
        return (status & (statusMute | statusSelfMute)) !== 0;
    }

    // checks if user is deaf or self deaf.
    function isDeaf() {
        return (status & (statusDeaf | statusSelfDeaf)) !== 0;
    }

    // checks if user is suppressed.
    function isSuppressed() {
        return (status & statusSuppress) !== 0;
    }
}
