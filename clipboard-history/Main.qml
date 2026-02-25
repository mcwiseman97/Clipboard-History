// Main.qml — Background service for Clipboard History plugin
// Runs wl-paste --watch to monitor clipboard changes on Wayland (Niri/CachyOS)

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // Plugin API injected by Noctalia
    property var pluginApi: null

    // ─── State ────────────────────────────────────────────────────────────────
    property var history: []
    property int maxItems: pluginApi?.pluginSettings?.maxHistory ?? 50

    // ─── Clipboard watcher ────────────────────────────────────────────────────
    Process {
        id: watcher
        command: ["wl-paste", "--watch", "cat"]
        running: pluginApi?.pluginSettings?.monitorClipboard ?? true
        stdout: SplitParser {
            onRead: function(data) {
                var trimmed = data.trim()
                if (trimmed.length > 0)
                    root._appendEntry(trimmed)
            }
        }
    }

    // ─── wl-copy process ──────────────────────────────────────────────────────
    Process {
        id: copyProcess
        property string copyText: ""
        command: ["bash", "-c", "printf '%s' " + JSON.stringify(copyText) + " | wl-copy"]
        running: false
    }

    // ─── Public API (consumed by BarWidget & Panel) ───────────────────────────

    function addEntry(text) {
        _appendEntry(text)
    }

    function removeEntry(index) {
        if (index < 0 || index >= history.length) return
        var copy = history.slice()
        copy.splice(index, 1)
        history = copy
        _persist()
    }

    function clearAll() {
        history = []
        _persist()
    }

    function copyEntry(index) {
        if (index < 0 || index >= history.length) return
        copyProcess.copyText = history[index]
        copyProcess.running = false
        copyProcess.running = true
    }

    // ─── Internal helpers ─────────────────────────────────────────────────────

    function _appendEntry(text) {
        if (!text || text.length === 0) return
        var copy = history.slice().filter(function(e) { return e !== text })
        copy.unshift(text)
        if (copy.length > maxItems)
            copy = copy.slice(0, maxItems)
        history = copy
        _persist()
    }

    function _persist() {
        if (!pluginApi) return
        pluginApi.pluginSettings.history = JSON.stringify(history)
        pluginApi.saveSettings()
    }

    // ─── Restore history on startup ───────────────────────────────────────────
    Component.onCompleted: {
        if (!pluginApi) return
        var saved = pluginApi.pluginSettings?.history
        if (saved) {
            try { history = JSON.parse(saved) }
            catch(e) { history = [] }
        }
    }
}
