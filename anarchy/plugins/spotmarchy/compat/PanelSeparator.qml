import QtQuick
import qs.Common

// A hairline rule between panel sections.
Rectangle {
    property color foreground: Theme.surfaceText
    implicitHeight: 1
    color: Theme.withAlpha(foreground, 0.12)
}
