import QtQuick
import qs.Common

// Omarchy's panel button: an optional glyph, optional label, and the two
// visual modes upstream uses — `bordered` for transport controls and
// `selected` for the toggles (shuffle, repeat).
Item {
    id: button

    property string text: ""
    property string iconText: ""
    property int iconSize: Theme.fontSizeMedium
    property color accent: Theme.primary
    property color foreground: Theme.surfaceText
    property bool bordered: false
    property bool selected: false
    property bool enabled: true
    property int horizontalPadding: Theme.spacingM
    property string tooltipText: ""
    property string fontFamily: Theme.fontFamily !== undefined ? Theme.fontFamily : "Noto Sans"

    signal clicked

    readonly property bool hovered: hover.hovered

    implicitHeight: Math.round(iconSize * 2.1)
    implicitWidth: Math.max(implicitHeight,
                            Math.round(row.implicitWidth + horizontalPadding * 2))

    opacity: enabled ? 1 : 0.4

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: button.selected ? Theme.withAlpha(button.accent, 0.20)
             : button.hovered  ? Theme.withAlpha(button.foreground, 0.10)
             : bordered        ? Theme.withAlpha(Theme.surfaceContainerHigh, 0.75)
                               : "transparent"
        border.width: button.bordered ? 1 : 0
        border.color: Theme.withAlpha(button.foreground, 0.14)

        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: button.text !== "" && button.iconText !== "" ? Theme.spacingXS : 0

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: button.iconText !== ""
            text: button.iconText
            color: button.selected ? button.accent : button.foreground
            font.family: button.fontFamily
            font.pixelSize: button.iconSize
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: button.text !== ""
            text: button.text
            color: button.selected ? button.accent : button.foreground
            font.family: button.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    HoverHandler { id: hover; enabled: button.enabled }

    TapHandler {
        enabled: button.enabled
        onTapped: button.clicked()
    }
}
