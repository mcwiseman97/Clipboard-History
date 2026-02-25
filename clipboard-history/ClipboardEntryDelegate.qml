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
    color:          mouseArea.containsMouse
                        ? Color.mSurfaceContainerHigh
                        : Color.mSurfaceContainer
    radius:         Style.radiusS

    Behavior on color { ColorAnimation { duration: 100 } }

    // ─── Layout ───────────────────────────────────────────────────────────────
    RowLayout {
        id: row
        anchors {
            left:    parent.left
            right:   parent.right
            top:     parent.top
            bottom:  parent.bottom
            margins: Style.marginS
        }
        spacing: Style.marginS

        // Type badge
        NIcon {
            icon:  root.isMultiLine ? "align-left" : "minus"
            color: Color.mOnSurfaceVariant
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
            opacity: mouseArea.containsMouse ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }

            NIconButton {
                icon:     "copy"
                onClicked: root.copyClicked()
            }

            NIconButton {
                icon:     "trash"
                onClicked: root.deleteClicked()
            }
        }
    }

    // ─── Interaction ──────────────────────────────────────────────────────────
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.copyClicked()
    }

    ToolTip {
        visible: mouseArea.containsMouse && root.text.length > root.previewLen
        text:    root.text
        delay:   600
    }
}
