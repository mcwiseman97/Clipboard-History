// BarWidget.qml — Clipboard History bar widget
// Shows an icon + clipboard count; click to open the panel.

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

Rectangle {
    id: root

    // ─── Plugin API (injected by Noctalia) ────────────────────────────────────
    property var pluginApi: null

    // ─── Required bar widget properties ──────────────────────────────────────
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""

    // ─── Convenience access to background instance ────────────────────────────
    readonly property var main: pluginApi?.mainInstance ?? null
    readonly property int count: main?.history?.length ?? 0

    // ─── Appearance ───────────────────────────────────────────────────────────
    implicitWidth:  row.implicitWidth + Style.marginM * 2
    implicitHeight: Style.barHeight
    color:          hoverArea.containsMouse ? Style.capsuleColorHover : Style.capsuleColor
    radius:         Style.radiusM

    Behavior on color { ColorAnimation { duration: 120 } }

    // ─── Layout ───────────────────────────────────────────────────────────────
    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Style.marginS

        NIcon {
            icon:  "clipboard"
            color: Color.mPrimary
            size:  Style.iconSizeS
        }

        NText {
            text:      root.count > 0 ? root.count.toString() : ""
            color:     Color.mOnSurface
            pointSize: Style.fontSizeS
            visible:   root.count > 0
        }
    }

    // ─── Interaction ──────────────────────────────────────────────────────────
    HoverHandler { id: hoverArea }

    TapHandler {
        onTapped: pluginApi?.togglePanel(root.screen, root)
    }
}
