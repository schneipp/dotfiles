pragma Singleton

import QtQuick
import Quickshell
import qs.Common

// Omarchy's qs.Commons Style, backed by DankMaterialShell's Theme.
//
// Upstream BarWidget.qml is kept as close to the original as possible, so
// rather than rewriting 50-odd call sites this maps Omarchy's vocabulary onto
// the equivalent DMS values. Only the members the widget actually uses are
// here; anything else is a deliberate omission, not an oversight.
Singleton {
    id: style

    // Omarchy scales every hardcoded pixel through space(). DMS has no global
    // UI scale, so this is the identity with rounding — which is exactly what
    // Omarchy does at scale 1.
    function space(n: real): int {
        return Math.round(n);
    }

    readonly property int cornerRadius: Theme.cornerRadius

    readonly property QtObject font: QtObject {
        readonly property string family: Theme.fontFamily !== undefined
            ? Theme.fontFamily : "Noto Sans"
        readonly property int caption:   Math.round(Theme.fontSizeSmall * 0.85)
        readonly property int bodySmall: Theme.fontSizeSmall
        readonly property int body:      Theme.fontSizeMedium
        readonly property int subtitle:  Theme.fontSizeLarge
        readonly property int display:   Math.round(Theme.fontSizeLarge * 1.4)
        readonly property int iconLarge: Theme.iconSize
    }

    readonly property QtObject spacing: QtObject {
        readonly property int controlPaddingX: Theme.spacingM
        readonly property int panelGap:        Theme.spacingL
        readonly property int labelGap:        Theme.spacingXS
    }

    readonly property QtObject bar: QtObject {
        // DMS bars are configurable; 40px is its default horizontal height and
        // the widget only uses this as a fallback when no bar is attached.
        readonly property int sizeHorizontal: 40
    }

    // The resting fill of a control drawn on top of `base`.
    function normalFillFor(base: color): color {
        return Theme.withAlpha(Theme.surfaceContainerHigh, 0.75);
    }
}
