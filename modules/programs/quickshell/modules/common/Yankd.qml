pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property alias isSearching: searchProc.running
    readonly property alias isPreviewLoading: previewProc.running
    property int searchIndex: 0
    property string previewMimeType: ""
    property string preview: ""
    property var currentEntry: searchResult[searchIndex]
    property list<YankdSearchEntry> searchResult

    onSearchIndexChanged: updatePreview()
    onSearchResultChanged: searchIndex = 0

    function search(query: string) {
        searchProc.exec(["yankd", "search", "--format=json", "--limit=100", query]);
    }

    function set() {
        Quickshell.execDetached(["yankd", "set", `${currentEntry.eventID}`]);
    }

    function remove() {
        if (searchResult.length === 0) {
            return;
        }
        Quickshell.execDetached(["yankd", "delete", `${currentEntry.eventID}`]);
        const oldIndex = searchIndex;
        let res = Array.from(searchResult);
        let removed = res.splice(searchIndex, 1);
        if (removed.length > 0) {
            removed[0].destroy();
        }
        searchResult = res;
        setIndex(oldIndex);
    }

    function pauseDaemon(state: string) {
        if (!state) {
            state = "toggle";
        }
        Quickshell.execDetached(["yankd", "daemon", "pause", state]);
    }

    function setIndex(i: int) {
        searchIndex = Math.min(Math.max(i, 0), searchResult.length - 1);
    }

    function next() {
        searchIndex = (searchIndex + 1) % searchResult.length;
    }

    function previous() {
        if (searchIndex === 0)
            searchIndex = searchResult.length - 1;
        searchIndex = searchIndex - 1;
    }

    function updatePreview() {
        if (searchResult.length > 0) {
            previewProc.exec(["yankd", "get", "-pqb", `${searchResult[searchIndex].eventID}`]);
        } else {
            preview = "";
            previewMimeType = "";
        }
    }

    Component {
        id: yankdSearchEntry
        YankdSearchEntry {}
    }

    Process {
        id: previewProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.preview = text;
                root.previewMimeType = root.currentEntry.mimeType;
            }
        }
    }

    Process {
        id: searchProc
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0) {
                    return;
                }
                for (const entry of root.searchResult) {
                    entry.destroy();
                }
                const data = JSON.parse(text);
                const res = [];
                for (const entry of data) {
                    res.push(yankdSearchEntry.createObject(root, {
                        eventID: entry.id,
                        mimeType: entry.mime_type,
                        preview: entry.preview
                    }));
                }
                root.searchResult = res;
                root.updatePreview();
            }
        }
    }
}
