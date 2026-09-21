import QtQuick
import qs.Common

// Omarchy's panel slider — used upstream for seek and volume.
//
// `moved` fires continuously while dragging (upstream previews the seek
// position with it) and `released` fires once on let-go (upstream commits the
// seek there), so the two are kept distinct rather than collapsed into one.
Item {
    id: slider

    property real value: 0
    property real minimum: 0
    property real maximum: 1
    property real step: 0
    property color fillColor: Theme.primary
    property color knobColor: Theme.primary
    property bool enabled: true
    property var bar: null

    signal moved(real value)
    signal released(real value)

    readonly property real span: Math.max(0.0001, maximum - minimum)
    readonly property real fraction: Math.max(0, Math.min(1, (value - minimum) / span))
    readonly property bool active: drag.active || hover.hovered

    implicitHeight: Theme.spacingM
    implicitWidth: 120
    opacity: enabled ? 1 : 0.4

    function valueAt(px: real): real {
        const f = Math.max(0, Math.min(1, px / Math.max(1, slider.width)));
        let v = slider.minimum + f * slider.span;
        if (slider.step > 0)
            v = slider.minimum + Math.round((v - slider.minimum) / slider.step) * slider.step;
        return Math.max(slider.minimum, Math.min(slider.maximum, v));
    }

    // Track
    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: Math.max(3, Math.round(slider.height * 0.28))
        radius: height / 2
        color: Theme.withAlpha(Theme.surfaceText, 0.18)

        Rectangle {
            width: Math.round(track.width * slider.fraction)
            height: parent.height
            radius: parent.radius
            color: slider.fillColor
        }
    }

    // Knob — only while the pointer is on it, so a resting bar stays a hairline.
    Rectangle {
        x: Math.round(track.width * slider.fraction) - width / 2
        anchors.verticalCenter: parent.verticalCenter
        width: slider.active ? Math.round(slider.height * 0.9) : 0
        height: width
        radius: width / 2
        color: slider.knobColor
        visible: width > 0

        Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    HoverHandler { id: hover; enabled: slider.enabled }

    DragHandler {
        id: drag
        enabled: slider.enabled
        target: null
        xAxis.enabled: true
        yAxis.enabled: false
        onCentroidChanged: if (active) slider.moved(slider.valueAt(centroid.position.x))
        onActiveChanged: if (!active) slider.released(slider.valueAt(centroid.position.x))
    }

    TapHandler {
        enabled: slider.enabled
        onTapped: eventPoint => {
            const v = slider.valueAt(eventPoint.position.x);
            slider.moved(v);
            slider.released(v);
        }
    }
}
