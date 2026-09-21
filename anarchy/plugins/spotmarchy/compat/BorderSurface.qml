import QtQuick
import qs.Common

// Omarchy's themed surface: a rounded fill with the theme's outline on top.
// `borderSpec` describes the edge; DMS draws a uniform hairline.
Rectangle {
    property var borderSpec: ({ width: 1 })
    property color borderColor: Theme.outline

    radius: Theme.cornerRadius
    color: Theme.surfaceContainer
    border.width: borderSpec && borderSpec.width !== undefined ? borderSpec.width : 1
    border.color: borderColor
}
