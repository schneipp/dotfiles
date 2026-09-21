import QtQuick
import Quickshell
import qs.Common

// Stand-in for Omarchy's qs.Ui PopupCard: the themed card the widget hangs
// below the bar. Backed by a Quickshell PopupWindow anchored to the bar item,
// so it is a real Wayland popup rather than an overlay drawn inside the bar.
//
// Upstream puts its content straight inside the card, so `data` is forwarded
// into the padded content area. The backdrop child anchors to `parent` and
// negates `padding` to bleed the album art to the card edges — which works
// because that content area is the parent it sees.
PopupWindow {
    id: card

    // --- Omarchy's surface
    property Item anchorItem: null
    property var bar: null
    property var owner: null
    property bool open: false
    property int contentWidth: 320
    property int contentHeight: 200
    property int padding: Theme.spacingL
    property var borderSpec: ({ width: 1 })

    default property alias content: contentArea.data

    // Keep the card on screen: never taller or wider than the display it
    // opens on, less a margin so it does not butt against the edge.
    function fittedContentWidth(want: real): real {
        const screenW = card.screen ? card.screen.width : 1920;
        return Math.round(Math.min(want, screenW - padding * 2 - 40));
    }

    function fittedContentHeight(want: real): real {
        const screenH = card.screen ? card.screen.height : 1080;
        return Math.round(Math.min(want, screenH - padding * 2 - 80));
    }

    anchor {
        item: card.anchorItem
        edges: Edges.Bottom
        gravity: Edges.Bottom
        adjustment: PopupAdjustment.Slide
    }

    visible: open && anchorItem !== null
    color: "transparent"

    implicitWidth: contentWidth + padding * 2
    implicitHeight: contentHeight + padding * 2

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Theme.surfaceContainer
        border.width: borderSpec && borderSpec.width !== undefined ? borderSpec.width : 1
        border.color: Theme.outline
        clip: true

        Item {
            id: contentArea
            anchors.fill: parent
            anchors.margins: card.padding
        }
    }

    // Click outside or press Escape to dismiss, matching every other panel.
    HoverHandler { id: inside }

    Connections {
        target: card.owner
        ignoreUnknownSignals: true
    }
}
