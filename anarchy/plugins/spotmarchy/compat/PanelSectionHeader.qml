import QtQuick
import qs.Common

// Small capitalised label introducing a panel section.
Text {
    property color foreground: Theme.surfaceText
    property string fontFamily: Theme.fontFamily !== undefined ? Theme.fontFamily : "Noto Sans"

    color: Theme.withAlpha(foreground, 0.65)
    font.family: fontFamily
    font.pixelSize: Math.round(Theme.fontSizeSmall * 0.85)
    font.capitalization: Font.AllUppercase
    font.letterSpacing: 0.8
}
