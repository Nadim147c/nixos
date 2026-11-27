pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.end4
import qs.modules.widgets

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

PanelWindow {
    id: root
    anchors {
        top: true
        right: true
        bottom: true
    }
    margins {
        top: 5
        right: 5
        bottom: 5
    }

    implicitWidth: 420

    // Items of every notification card currently on screen (kept in sync by the
    // Repeater below). Used to build the input mask.
    property var cardItems: []

    readonly property bool hasReplyInput: {
        const list = server.trackedNotifications.values;
        for (let i = 0; i < list.length; i++) {
            if (list[i].hasInlineReply)
                return true;
        }
        return false;
    }

    function stripHtmlTags(raw) {
        if (!raw || typeof raw !== "string")
            return "";
        return raw.replace(/<[^>]*>/g, " ");
    }

    // This function is derived from https://github.com/26JATIN/SecureOTP/blob/9ddca5d32a48b6012a527ede62fd3fbece067abd/app/src/main/java/com/otpextractor/gmail/utils/OtpExtractor.kt
    // licensed under Apache License 2.0.
    // Get a copy of this license from https://github.com/26JATIN/SecureOTP/blob/9ddca5d32a48b6012a527ede62fd3fbece067abd/LICENSE.
    function extractOtpCodes(message) {
        if (!message || typeof message !== "string" || !message.trim()) {
            return [];
        }

        const highPriorityPatterns = [/\b([0-9]{3,12})\s+(?:is|are)\s+(?:otp|code|verification|pin|password|passcode|token)\s+for\b/gi, /(?:is|are|:)\s*([0-9]{3,12})\b/gi, /(?:use|enter|type)\s+(?:otp[\s-])?([0-9]{3,12})\b/gi, /["'\[\(]([0-9]{3,12})["'\]\)]/g, /to\s+(?:accept|verify|confirm|login|signin|complete|proceed)\s+\w*\s*([0-9]{3,12})\b/gi];

        const mediumPriorityPatterns = [/(?:verification|authentication|authorization|access|security|login|confirmation)\s+(?:code|otp|pin|token|password)?\s*(?:is|:|are)?\s*([0-9]{3,12})\b/gi, /\b([0-9]{2,4}[-\s][0-9]{2,4}(?:[-\s][0-9]{2,4})?)\b/g];

        const lowPriorityPatterns = [/\b([0-9]{4,10})\b/g];

        const basicPatterns = [/\b(?:code|otp|pin|passcode)\b[\s:=-]*(?:(?:is|are)\b)?[\s:=-]*([0-9]{3,4}[\s-]?[0-9]{3,4}|[0-9]{4,8})\b/gi, /\b([0-9]{4,8})\s+(?:is|are)\s+(?:your|the|ur)\s+(?:[a-z]+\s+){0,3}?(?:code|otp|pin|passcode)\b/gi];

        const otpKeywords = ["otp", "verification", "code", "pin", "password", "passcode", "token", "authenticate", "verify", "security", "login", "signin", "sign-in", "sign in", "confirm", "confirmation", "activation", "activate", "authorization", "authorize", "2fa", "two-factor", "two factor", "mfa", "multi-factor", "multi factor", "temporary", "one-time", "onetime", "one time", "access", "authentication", "validation", "validate"];

        const ignorePatterns = [/^[0-9]{13,}$/, /^[0-9]{1,3}$/, /^(19|20)[0-9]{2}$/];

        const cleanValue = raw => {
            const trimmed = raw.trim();
            if (/^[0-9\s-]+$/.test(trimmed)) {
                return trimmed.replace(/[-\s]/g, "");
            }
            return trimmed;
        };

        const shouldIgnore = val => {
            if (ignorePatterns.some(p => p.test(val)))
                return true;
            if (val.length < 3 || val.length > 12)
                return true;
            if (/^(.)\1+$/.test(val) && val.length > 4)
                return true;
            return false;
        };

        const lowerMessage = message.toLowerCase();
        const hasOtpContext = otpKeywords.some(kw => lowerMessage.includes(kw));
        const candidates = [];

        const collectMatches = (patterns, basePriority, requireLength4To10) => {
            patterns.forEach((pattern, idx) => {
                pattern.lastIndex = 0;
                let match;
                while ((match = pattern.exec(message)) !== null) {
                    const raw = match[1] ?? match[0];
                    if (!raw)
                        continue;
                    const cleaned = cleanValue(raw);
                    if (shouldIgnore(cleaned))
                        continue;
                    if (requireLength4To10 && (cleaned.length < 4 || cleaned.length > 10))
                        continue;
                    candidates.push({
                        value: cleaned,
                        priority: basePriority - idx
                    });
                }
            });
        };

        collectMatches(highPriorityPatterns, 100);
        if (hasOtpContext) {
            collectMatches(mediumPriorityPatterns, 50);
            collectMatches(lowPriorityPatterns, 10, true);
        }
        collectMatches(basicPatterns, 5);

        candidates.sort((a, b) => b.priority - a.priority);

        const uniqueCodes = [];
        for (const item of candidates) {
            if (!uniqueCodes.includes(item.value)) {
                uniqueCodes.push(item.value);
            }
        }

        return uniqueCodes;
    }

    WlrLayershell.namespace: "quickshell:notifications"
    WlrLayershell.keyboardFocus: root.hasReplyInput ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusiveZone: 0
    aboveWindows: true
    color: "transparent"
    mask: Region {
        regions: maskRegions.instances
    }

    Variants {
        id: maskRegions
        model: root.cardItems

        Region {
            required property var modelData
            item: modelData
        }
    }

    NotificationServer {
        id: server
        keepOnReload: true
        persistenceSupported: true
        imageSupported: true
        // Without these, clients never send actions / inline reply boxes.
        actionsSupported: true
        inlineReplySupported: true
        onNotification: notification => {
            console.log("New notification: " + notification.summary);
            notification.tracked = true;
        }
    }

    ScrollView {
        id: scroll
        width: Math.min(list.implicitWidth, root.width)
        height: Math.min(list.implicitHeight, parent.height)
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        Behavior on y {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }

        ColumnLayout {
            id: list
            spacing: 0

            Repeater {
                model: server.trackedNotifications

                // Keep root.cardItems in sync so the input mask follows the cards.
                onItemAdded: (index, item) => root.cardItems = [...root.cardItems, item]
                onItemRemoved: (index, item) => root.cardItems = root.cardItems.filter(i => i !== item)

                Item {
                    id: entry

                    required property Notification modelData

                    readonly property int gap: 5

                    property real reveal: 0
                    property real enterSlide: 1
                    property real exitSlide: 0

                    readonly property real shown: Math.max(0, reveal)
                    readonly property real slide: Math.max(0, Math.min(1, enterSlide + exitSlide))

                    property bool closing: false
                    property bool expiring: false
                    property bool finished: false

                    function animateClose(expired) {
                        if (closing)
                            return;
                        expiring = !!expired;
                        closing = true;
                        exitSlide = 1;
                        reveal = 0;
                    }

                    onRevealChanged: {
                        if (closing && !finished && reveal <= 0) {
                            finished = true;
                            if (expiring)
                                modelData.expire();
                            else
                                modelData.dismiss();
                        }
                    }

                    Component.onCompleted: {
                        reveal = 1;
                        enterSlide = 0;
                    }

                    Behavior on reveal {
                        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                    }
                    Behavior on enterSlide {
                        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
                    }
                    Behavior on exitSlide {
                        animation: Appearance.animation.elementMoveExit.numberAnimation.createObject(this)
                    }

                    clip: true
                    Layout.alignment: Qt.AlignRight
                    Layout.maximumWidth: root.width
                    Layout.preferredWidth: notification.width
                    Layout.preferredHeight: notification.height * shown
                    Layout.topMargin: gap * shown

                    Card {
                        id: notification

                        readonly property Notification modelData: entry.modelData
                        readonly property real innerWidth: Math.max(0, width - Appearance.space.big * 2)

                        readonly property var detectedCodes: {
                            const combined = [notification.modelData.summary || "", root.stripHtmlTags(notification.modelData.body || "")].join(" ");
                            return root.extractOtpCodes(combined);
                        }

                        readonly property bool hasActions: {
                            const a = modelData.actions;
                            for (let i = 0; i < a.length; i++) {
                                if (a[i].identifier !== "default")
                                    return true;
                            }
                            return false;
                        }

                        readonly property int timeoutMs: {
                            if (modelData.urgency === NotificationUrgency.Critical)
                                return 0;
                            return modelData.expireTimeout > 0 ? modelData.expireTimeout : 5000;
                        }

                        x: entry.slide * width
                        opacity: 1 - entry.slide

                        width: Math.min(root.width, col.implicitWidth + Appearance.space.big * 2)
                        height: col.implicitHeight + Appearance.space.big * 2
                        radius: 5
                        borderWidth: 2
                        borderPixelSize: 2
                        color: Appearance.material.myBackground

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: entry.animateClose(false)
                        }

                        Timer {
                            interval: notification.timeoutMs
                            onIntervalChanged: console.log(`${notification.modelData.id} expires in ${interval}ms`)
                            running: interval > 0 && !mouseArea.containsMouse && !replyField.activeFocus && !entry.closing
                            onTriggered: entry.animateClose(true)
                        }

                        ColumnLayout {
                            id: col
                            x: Appearance.space.big
                            y: Appearance.space.big
                            width: notification.innerWidth
                            spacing: 1

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.maximumWidth: col.width
                                Layout.margins: 0
                                Layout.leftMargin: 5
                                Layout.rightMargin: 5

                                Card {
                                    Layout.preferredHeight: 30
                                    Layout.preferredWidth: 30
                                    visible: !!notification.modelData.appIcon
                                    radius: 4
                                    borderWidth: 1
                                    borderPixelSize: 2
                                    Pixelate {
                                        anchors.fill: parent
                                        pixelSize: 1
                                        levels: 32
                                        StyledImage {
                                            anchors.fill: parent
                                            source: notification.modelData.appIcon
                                        }
                                    }
                                }

                                StyledText {
                                    id: title
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    text: notification.modelData.summary
                                    wrapMode: Text.WordWrap
                                    font {
                                        pixelSize: Appearance.font.pixelSize.large
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.maximumWidth: col.width
                                Layout.margins: 5

                                Card {
                                    Layout.preferredHeight: 100
                                    Layout.preferredWidth: 100
                                    visible: !!notification.modelData.appIcon
                                    radius: 4
                                    borderWidth: 1
                                    borderPixelSize: 2
                                    Pixelate {
                                        anchors.fill: parent
                                        pixelSize: 2.5
                                        levels: 32
                                        StyledImage {
                                            source: notification.modelData.image
                                        }
                                    }
                                }

                                StyledText {
                                    Layout.alignment: Qt.AlignTop
                                    Layout.fillWidth: true
                                    visible: !!notification.modelData.body
                                    text: notification.modelData.body
                                    wrapMode: Text.WordWrap
                                    textFormat: Text.RichText
                                    color: Appearance.material.myOnBackground
                                }
                            }

                            Flow {
                                visible: notification.detectedCodes.length > 0
                                Layout.fillWidth: true
                                Layout.maximumWidth: col.width
                                Layout.margins: 5
                                spacing: 5

                                Repeater {
                                    model: notification.detectedCodes

                                    RetroButton {
                                        id: copyOtpButton
                                        required property string modelData
                                        height: 30
                                        onClicked: {
                                            Quickshell.clipboardText = copyOtpButton.modelData;
                                        }

                                        Item {
                                            anchors.centerIn: parent
                                            implicitWidth: copyOtpLabel.implicitWidth + 16
                                            implicitHeight: copyOtpLabel.implicitHeight

                                            StyledText {
                                                id: copyOtpLabel
                                                anchors.centerIn: parent
                                                text: `Copy "${copyOtpButton.modelData}"`
                                                color: Appearance.material.myOnBackground
                                                font.pixelSize: Appearance.font.pixelSize.large
                                            }
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                visible: notification.hasActions
                                Layout.fillWidth: true
                                Layout.maximumWidth: col.width
                                Layout.margins: 5
                                spacing: 5

                                Repeater {
                                    model: notification.modelData.actions

                                    RetroButton {
                                        id: actionButton
                                        required property NotificationAction modelData

                                        visible: modelData.identifier !== "default"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 30
                                        onClicked: {
                                            modelData.invoke();
                                            entry.animateClose(false);
                                        }

                                        Item {
                                            anchors.centerIn: parent
                                            implicitWidth: actionLabel.implicitWidth + 16
                                            implicitHeight: actionLabel.implicitHeight

                                            StyledText {
                                                id: actionLabel
                                                anchors.centerIn: parent
                                                text: actionButton.modelData.text
                                                color: Appearance.material.myOnBackground
                                                font.pixelSize: Appearance.font.pixelSize.large
                                            }
                                        }
                                    }
                                }
                            }

                            Card {
                                id: replyCard
                                visible: notification.modelData.hasInlineReply
                                Layout.fillWidth: true
                                Layout.maximumWidth: col.width
                                Layout.margins: 5
                                Layout.preferredWidth: replyRow.implicitWidth + 10
                                Layout.preferredHeight: replyRow.implicitHeight + 10
                                radius: 5
                                borderWidth: 2
                                borderPixelSize: 2
                                color: Appearance.material.myBackground

                                function send() {
                                    const text = replyField.text.trim();
                                    if (text.length === 0)
                                        return;
                                    notification.modelData.sendInlineReply(text);
                                    replyField.text = "";
                                    entry.animateClose(false);
                                }

                                RowLayout {
                                    id: replyRow
                                    x: 5
                                    y: 5
                                    width: replyCard.width - 10
                                    spacing: 5

                                    TextField {
                                        id: replyField
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 0
                                        Layout.preferredWidth: 160
                                        Layout.alignment: Qt.AlignVCenter

                                        placeholderText: notification.modelData.inlineReplyPlaceholder || "Reply"
                                        placeholderTextColor: Qt.alpha(Appearance.material.myOnBackground, 0.5)
                                        color: Appearance.material.myOnBackground
                                        font.pixelSize: Appearance.font.pixelSize.large
                                        selectByMouse: true
                                        background: null

                                        onAccepted: replyCard.send()
                                    }

                                    RetroButton {
                                        Layout.preferredHeight: 30
                                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                                        onClicked: replyCard.send()

                                        Item {
                                            anchors.centerIn: parent
                                            implicitHeight: sendIcon.implicitHeight
                                            implicitWidth: 20

                                            Text {
                                                id: sendIcon
                                                anchors.centerIn: parent
                                                color: Appearance.material.myOnBackground
                                                text: "send"
                                                font.family: Appearance.font.family.iconPixel
                                                font.pixelSize: Appearance.font.pixelSize.large
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
