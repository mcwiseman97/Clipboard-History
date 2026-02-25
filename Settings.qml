// Settings.qml — Clipboard History plugin settings

import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    // ─── Plugin API (injected by settings dialog) ─────────────────────────────
    property var pluginApi: null

    // ─── Local editable state ─────────────────────────────────────────────────
    property int  editMaxHistory:      pluginApi?.pluginSettings?.maxHistory      ?? 50
    property int  editPreviewLength:   pluginApi?.pluginSettings?.showPreviewLength ?? 60
    property bool editMonitorClipboard: pluginApi?.pluginSettings?.monitorClipboard ?? true

    spacing: Style.marginM

    // ─── Monitor toggle ───────────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginXS

            NText {
                text:      "Monitor Clipboard Automatically"
                color:     Color.mOnSurface
                pointSize: Style.fontSizeS
                font.weight: Font.Medium
            }
            NText {
                text:      "Listens for clipboard changes using wl-paste --watch"
                color:     Color.mOnSurfaceVariant
                pointSize: Style.fontSizeXS
            }
        }

        NSwitch {
            checked: root.editMonitorClipboard
            onToggled: root.editMonitorClipboard = checked
        }
    }

    // ─── Max history ──────────────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginXS

            NText {
                text:      "Maximum History Size"
                color:     Color.mOnSurface
                pointSize: Style.fontSizeS
                font.weight: Font.Medium
            }
            NText {
                text:      "How many clipboard entries to remember (1–200)"
                color:     Color.mOnSurfaceVariant
                pointSize: Style.fontSizeXS
            }
        }

        NSpinBox {
            from:    1
            to:      200
            value:   root.editMaxHistory
            onValueChanged: root.editMaxHistory = value
        }
    }

    // ─── Preview length ───────────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginXS

            NText {
                text:      "Preview Length"
                color:     Color.mOnSurface
                pointSize: Style.fontSizeS
                font.weight: Font.Medium
            }
            NText {
                text:      "Number of characters shown in the panel list (20–200)"
                color:     Color.mOnSurfaceVariant
                pointSize: Style.fontSizeXS
            }
        }

        NSpinBox {
            from:    20
            to:      200
            value:   root.editPreviewLength
            onValueChanged: root.editPreviewLength = value
        }
    }

    // ─── Required save function ───────────────────────────────────────────────
    function saveSettings() {
        pluginApi.pluginSettings.maxHistory       = root.editMaxHistory
        pluginApi.pluginSettings.showPreviewLength = root.editPreviewLength
        pluginApi.pluginSettings.monitorClipboard = root.editMonitorClipboard
        pluginApi.saveSettings()
    }
}
