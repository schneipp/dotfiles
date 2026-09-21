import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

// Generated from upstream manifest.json so the keys stay identical to the
// ones BarWidget.qml reads through setting().
PluginSettings {
    id: root
    pluginId: "spotLyrics"

    SliderSetting {
        settingKey: "maxLabelWidth"
        label: "Maximum label width (px)"
        description: "Track text wider than this scrolls instead of stretching the bar."
        defaultValue: 200
        minimum: 60
        maximum: 600
    }

    ToggleSetting {
        settingKey: "showArtist"
        label: "Show artist next to the title"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "showProgress"
        label: "Show a progress underline in the bar"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "hideWhenClosed"
        label: "Hide the widget when Spotify is not running"
        description: "Turn off to keep a dimmed Spotify icon in the bar that launches the app when clicked."
        defaultValue: true
    }

    SelectionSetting {
        settingKey: "leftClick"
        label: "Left click"
        description: "Which action left click takes. The other of the two lands on right click."
        defaultValue: "Open panel"
        options: ["Open panel", "Play/pause"]
    }

    SelectionSetting {
        settingKey: "scrollAction"
        label: "Mouse wheel over the widget"
        defaultValue: "Previous/next track"
        options: ["Previous/next track", "Volume", "Nothing"]
    }

    ToggleSetting {
        settingKey: "showLyrics"
        label: "Show lyrics in the panel"
        description: "Time-synced lyrics from LRCLIB, scrolling with the song. Needs curl and an internet connection; answers are cached on disk."
        defaultValue: true
    }

    SliderSetting {
        settingKey: "lyricsLines"
        label: "Lyric lines visible"
        description: "How tall the lyric view is. The current line stays centred."
        defaultValue: 6
        minimum: 3
        maximum: 13
    }

    SliderSetting {
        settingKey: "lyricsOffset"
        label: "Lyric timing offset (ms)"
        description: "Positive shows each line earlier. Only needed when a particular LRC file runs consistently ahead of or behind the song."
        defaultValue: 0
        minimum: -3000
        maximum: 3000
    }

    ToggleSetting {
        settingKey: "lyricsPrefetch"
        label: "Fetch lyrics before the panel is opened"
        description: "Off, lyrics are looked up when you open the panel. On, every track you play is looked up as it starts — instant when you open the panel, at the cost of telling LRCLIB what you listen to whether you read them or not."
        defaultValue: false
    }

    SelectionSetting {
        settingKey: "accent"
        label: "Accent color"
        description: "Color of the icon, progress underline, and popup controls. \"Album art\" takes the dominant color of the current cover."
        defaultValue: "Spotify green"
        options: ["Spotify green", "Album art", "Theme accent", "Bar foreground"]
    }

    ToggleSetting {
        settingKey: "artBackground"
        label: "Album cover behind the panel"
        description: "Blurs the current cover into the panel background, tinted and dimmed to whatever keeps the theme's text readable. Needs ImageMagick and curl for the color reading; without them the panel keeps its plain background."
        defaultValue: true
    }

    SliderSetting {
        settingKey: "artIntensity"
        label: "How much cover shows through (%)"
        description: "A starting point, not a fixed opacity — bright covers are still covered more heavily than dark ones from wherever this is set."
        defaultValue: 55
        minimum: 0
        maximum: 100
    }

}
