pragma Singleton

import QtQuick
import Quickshell
import qs.Common

// Omarchy's qs.Commons Color, mapped onto DMS's Theme.
Singleton {
    readonly property color accent:     Theme.primary
    readonly property color foreground: Theme.surfaceText
    readonly property color popups:     Theme.surfaceContainer
}
