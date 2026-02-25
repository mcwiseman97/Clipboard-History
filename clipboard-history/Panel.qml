// Panel.qml — Clipboard History panel
// Lists all clipboard entries; supports copy-to-clipboard, delete, and manual add.

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets

NPanel {
    id: root

    // ─── Plugin API (injected by Noctalia) ────────────────────────────────────
    property var pluginApi: null

    // ─── Convenience access ───────────────────────────────────────────────────
    readonly property var main:    pluginApi?.mainInstance ?? null
    readonly property var history: main?.history ?? []
    readonly property int previewLen: pluginApi?.pluginSettings?.showPreviewLength ?? 60

    // ─── Panel dimensions ─────────────────────────────────────────────────────
    width:  360
    height: Math.min(560, headerColumn.implicitHeight + listView.contentHeight + 24)

    // ─── Local state ──────────────────────────────────────────────────────────
    property string newEntryText: ""
    property bool   showAddField: false

    // ─── Root layout ──────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill:        parent
        anchors.margins:     Style.marginM
        spacing:             Style.marginS

        // ── Header ────────────────────────────────────────────────────────────
        ColumnLayout {
            id: headerColumn
            Layout.fillWidth: true
            spacing: Style.marginXS

            RowLayout {
                Layout.fillWidth: true

                NIcon {
                    icon:  "clipboard"
                    color: Color.mPrimary
                    size:  Style.iconSizeM
                }

                NText {
                    text:      "Clipboard History"
                    color:     Color.mOnSurface
                    pointSize: Style.fontSizeM
                    font.weight: Font.Medium
                    Layout.fillWidth: true
                }

                // Add entry button
                NIconButton {
                    icon:    "plus"
                    tooltip: "Add entry manually"
                    onClicked: {
                        root.showAddField = !root.showAddField
                        if (root.showAddField) addField.forceActiveFocus()
                    }
                }

                // Clear all button
                NIconButton {
                    icon:    "trash"
                    tooltip: "Clear all history"
                    onClicked: confirmClearDialog.open()
                }
            }

            // ── Manual entry field ────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                visible:          root.showAddField
                spacing:          Style.marginS

                NTextField {
                    id:               addField
                    Layout.fillWidth: true
                    placeholderText:  "Type or paste text to add…"
                    text:             root.newEntryText
                    onTextChanged:    root.newEntryText = text
                    Keys.onReturnPressed: root._addManualEntry()
                    Keys.onEscapePressed: {
                        root.showAddField = false
                        root.newEntryText = ""
                    }
                }

                NIconButton {
                    icon:    "check"
                    tooltip: "Add"
                    enabled: root.newEntryText.trim().length > 0
                    onClicked: root._addManualEntry()
                }
            }

            // ── Entry count ───────────────────────────────────────────────────
            NText {
                text:      root.history.length + " item" + (root.history.length !== 1 ? "s" : "")
                color:     Color.mOnSurfaceVariant
                pointSize: Style.fontSizeXS
                visible:   root.history.length > 0
            }
        }

        // ── Divider ───────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height:           1
            color:            Color.mOutlineVariant
            opacity:          0.4
        }

        // ── Empty state ───────────────────────────────────────────────────────
        Item {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            visible:           root.history.length === 0

            ColumnLayout {
                anchors.centerIn: parent
                spacing:          Style.marginS

                NIcon {
                    icon:             "clipboard-off"
                    color:            Color.mOnSurfaceVariant
                    size:             Style.iconSizeXL
                    Layout.alignment: Qt.AlignHCenter
                }
                NText {
                    text:             "No clipboard history yet"
                    color:            Color.mOnSurfaceVariant
                    pointSize:        Style.fontSizeS
                    Layout.alignment: Qt.AlignHCenter
                }
                NText {
                    text:             "Copy something to get started"
                    color:            Color.mOnSurfaceVariant
                    pointSize:        Style.fontSizeXS
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // ── History list ──────────────────────────────────────────────────────
        ListView {
            id:                listView
            Layout.fillWidth:  true
            Layout.fillHeight: true
            visible:           root.history.length > 0
            clip:              true
            model:             root.history
            spacing:           Style.marginXS

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            delegate: ClipboardEntryDelegate {
                width:       listView.width
                text:        modelData
                previewLen:  root.previewLen
                index:       model.index
                onCopyClicked:   root.main?.copyEntry(index)
                onDeleteClicked: root.main?.removeEntry(index)
            }
        }
    }

    // ─── Confirm clear dialog ─────────────────────────────────────────────────
    NDialog {
        id:    confirmClearDialog
        title: "Clear History"
        description: "Remove all " + root.history.length + " clipboard entries?"
        confirmText: "Clear All"
        onConfirmed: root.main?.clearAll()
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────
    function _addManualEntry() {
        var t = root.newEntryText.trim()
        if (t.length === 0) return
        root.main?.addEntry(t)
        root.newEntryText = ""
        root.showAddField = false
    }
}
