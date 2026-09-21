pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Material-ish dark palette, matched to DankMaterialShell's defaults.
    readonly property color bg:        "#12131a"
    readonly property color bgPanel:   "#1b1d26"
    readonly property color bgRaised:  "#252836"
    readonly property color fg:        "#e4e6f0"
    readonly property color fgDim:     "#9aa0b5"
    readonly property color accent:    "#a5b4fc"
    readonly property color danger:    "#f38ba8"
    readonly property color ok:        "#a6e3a1"
    readonly property color border:    "#ffffff1a"

    readonly property int radius:      16
    readonly property int radiusItem:  10
    readonly property int pad:         16
    readonly property int rowHeight:   48

    readonly property string fontFamily: "Noto Sans"
    readonly property string monoFamily: "JetBrainsMono Nerd Font"
}
