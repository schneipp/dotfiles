# Spotmarchy Lyrics — ported to DankMaterialShell

Upstream: <https://github.com/schneipp/omarchy-spotmarchy-lyrics-plugin>
Pinned at the commit in `UPSTREAM_COMMIT`.

Upstream targets **Omarchy 4's own Quickshell shell**, whose plugin API is not
the one DankMaterialShell uses:

| | Omarchy | DankMaterialShell |
|---|---|---|
| manifest | `manifest.json`, `kinds` / `entryPoints` | `plugin.json`, `type` / `capabilities` / `component` |
| widget root | `Panel` from `qs.Ui` | `PluginComponent` from `qs.Modules.Plugins` |
| theming | `Style`, `Color`, `Border` from `qs.Commons` | `Theme` from `qs.Common` |
| settings | `setting(key, fallback)` | `pluginData` |

Rather than rewrite 1,200 lines of upstream QML, `compat/` reimplements the
handful of Omarchy types the widget actually touches against DMS's `Theme`:

```
compat/Style.qml               space(), font.*, spacing.*, cornerRadius, bar.*
compat/Color.qml               accent, foreground, popups
compat/Border.qml              top()/bottom()/left()/right()
compat/Panel.qml               the widget root: setting(), opened/open/close/toggle, bar
compat/PopupCard.qml           the panel, backed by a Quickshell PopupWindow
compat/Button.qml              transport and toggle buttons
compat/PanelSlider.qml         seek and volume
compat/PanelSeparator.qml      hairline rules
compat/PanelSectionHeader.qml  section labels
compat/BorderSurface.qml       themed rounded surface
```

`BarWidget.qml`, `Model.js` and `Lyrics.js` are upstream. The only edit to
`BarWidget.qml` is its import block:

```diff
-import qs.Ui
-import qs.Commons
+import "compat"
```

so upstream changes can still be merged with almost no conflict.

`SpotmarchyWidget.qml` is the DMS entry point — it puts the upstream widget in
the bar pill and passes `pluginData` through as the settings source.
`SpotmarchySettings.qml` is generated from upstream's `manifest.json` schema, so
the setting keys are identical to the ones `setting()` reads.

## Install

The `plugins` install step links this into `~/.config/DankMaterialShell/plugins`.
Then add it to a bar:

```bash
dms ipc call plugins enable spotLyrics
```

and put `spotLyrics` in a bar section (Settings → Bar → Widgets, or edit
`barConfigs` in `~/.config/DankMaterialShell/settings.json`).

## Requirements

`curl` for lyrics (LRCLIB), `imagemagick` for the album-cover backdrop, and any
MPRIS Spotify client — the desktop app, `spotifyd` or `spotify-player`.
