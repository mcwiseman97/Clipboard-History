// ClipboardEntryDelegate.qml — A single clipboard history entry row

import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Rectangle {
    id: root

    // ─── Properties ───────────────────────────────────────────────────────────
    property string text:       ""
    property int    previewLen: 60
    property int    index:      0

    // ─── Signals ──────────────────────────────────────────────────────────────
    signal copyClicked()
    signal deleteClicked()

    // ─── Computed ─────────────────────────────────────────────────────────────
    readonly property bool isMultiLine: root.text.indexOf("\n") !== -1
    readonly property string preview: {
        var t = root.text.replace(/\n/g, " ↵ ")
        return t.length > previewLen ? t.slice(0, previewLen) + "…" : t
    }

    // ─── Appearance ───────────────────────────────────────────────────────────
    implicitHeight: row.implicitHeight + Style.marginS * 2
    color:          hoverArea.containsMouse
                        ? Color.mSurfaceContainerHigh
                        : Color.mSurfaceContainer
    radius:         Style.radiusS

    Behavior on color { ColorAnimation { duration: 100 } }

    // ─── Layout ───────────────────────────────────────────────────────────────
    RowLayout {
        id:              row
        anchors {
            left:   parent.left
            right:  parent.right
            top:    parent.top
            bottom: parent.bottom
            margins: Style.marginS
        }
        spacing: Style.marginS

        // Type badge (multiline vs single)
        NIcon {
            icon:  root.isMultiLine ? "align-left" : "minus"
            color: Color.mOnSurfaceVariant
            size:  Style.iconSizeXS
        }

        // Preview text
        NText {
            text:             root.preview
            color:            Color.mOnSurface
            pointSize:        Style.fontSizeS
            elide:            Text.ElideRight
            Layout.fillWidth: true
        }

        // Action buttons — visible on hover
        RowLayout {
            spacing: Style.marginXS
            opacity: hoverArea.containsMouse ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }

            // Copy button
            NIconButton {
                icon:    "copy"
                tooltip: "Copy to clipboard"
                size:    Style.iconSizeS
                onClicked: root.copyClicked()
            }

            // Delete button
            NIconButton {
                icon:    "trash"
                tooltip: "Remove entry"
                size:    Style.iconSizeS
                color:   Color.mError
                onClicked: root.deleteClicked()
            }
        }
    }

    // ─── Hover + tap ──────────────────────────────────────────────────────────
    HoverHandler { id: hoverArea }

    TapHandler {
        // Single click copies the entry
        onTapped: root.copyClicked()
    }

    ToolTip {
        visible: hoverArea.containsMouse && root.text.length > root.previewLen
        text:    root.text
        delay:   600
    }
}
