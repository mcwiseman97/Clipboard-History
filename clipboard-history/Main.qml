// Main.qml — Background service for Clipboard History plugin
// Runs wl-paste --watch to monitor clipboard changes on Wayland (Niri/CachyOS)

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // Plugin API injected by Noctalia
    property var pluginApi: null

    // ─── State ────────────────────────────────────────────────────────────────
    property var history: []
    property int maxItems: pluginApi?.pluginSettings?.maxHistory ?? 50

    // ─── Clipboard watcher ────────────────────────────────────────────────────
    // wl-paste --watch echoes the clipboard content every time it changes.
    Process {
        id: watcher
        command: ["wl-paste", "--watch", "cat"]
        running: pluginApi?.pluginSettings?.monitorClipboard ?? true
        stdout: SplitParser {
            // Each clipboard change arrives as a block of text terminated by newlines.
            // We collect the full chunk between empty-line separators.
            onRead: function(data) {
                root._appendEntry(data.trim())
            }
        }
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
        var text = history[index]
        // Write the selected entry back to clipboard via wl-copy
        copyProcess.text = text
        copyProcess.running = false
        copyProcess.running = true
    }

    // ─── Internal helpers ─────────────────────────────────────────────────────

    function _appendEntry(text) {
        if (!text || text.length === 0) return

        // De-duplicate: remove existing copy and push to front
        var copy = history.slice().filter(function(e) { return e !== text })
        copy.unshift(text)

        // Trim to max
        if (copy.length > maxItems) {
            copy = copy.slice(0, maxItems)
        }

        history = copy
        _persist()
    }

    function _persist() {
        if (!pluginApi) return
        pluginApi.pluginSettings.history = JSON.stringify(history)
        pluginApi.saveSettings()
    }

    // ─── wl-copy process ──────────────────────────────────────────────────────
    Process {
        id: copyProcess
        property string text: ""
        command: ["bash", "-c", "printf '%s' " + JSON.stringify(text) + " | wl-copy"]
        running: false
    }

    // ─── Restore history on startup ───────────────────────────────────────────
    Component.onCompleted: {
        if (!pluginApi) return
        var saved = pluginApi.pluginSettings?.history
        if (saved) {
            try {
                history = JSON.parse(saved)
            } catch(e) {
                history = []
            }
        }
    }
}
