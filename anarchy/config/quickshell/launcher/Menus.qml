pragma Singleton

import Quickshell
import QtQuick

// Static menu definitions, Omarchy-style: a shallow tree you can walk with the
// keyboard. Each entry is one of
//
//   { go:   "<mode>" }        navigate to another screen
//   { run:  [cmd, ...] }      launch detached, then close the launcher
//   { term: [cmd, ...] }      run in the floating terminal, then close
//
// Icons are written as \uXXXX escapes from the Font Awesome block that every
// Nerd Font ships. Pasted glyphs do not survive every editor, escapes do.
Singleton {
    readonly property var root: [
        { icon: "\uf009", label: "Apps",    desc: "Launch an application",             go: "apps" },
        { icon: "\uf030", label: "Capture", desc: "Screenshots and screen recording",  go: "capture" },
        { icon: "\uf019", label: "Install", desc: "Add a package from a repository",   go: "managers" },
        { icon: "\uf014", label: "Remove",  desc: "Uninstall a package",               go: "remove" },
        { icon: "\uf1fc", label: "Style",   desc: "Theme, wallpaper and night mode",   go: "style" },
        { icon: "\uf013", label: "Setup",   desc: "Settings and config files",         go: "setup" },
        { icon: "\uf021", label: "Update",  desc: "Refresh packages",                  go: "update" },
        { icon: "\uf011", label: "System",  desc: "Lock, suspend, reboot, shut down",  go: "system" },
    ]

    readonly property var style: [
        { icon: "\uf03e", label: "Wallpaper",       desc: "Browse and apply a background",
          go: "wallpaper" },
        { icon: "\uf042", label: "Light / dark",    desc: "Switch the whole desktop palette",
          go: "theme" },
        { icon: "\uf1fc", label: "Colours",         desc: "Accent colour and theme settings",
          run: ["dms", "ipc", "call", "settings", "openWith", "theme"] },
        { icon: "\uf186", label: "Night mode",      desc: "Toggle the blue-light filter",
          run: ["dms", "ipc", "call", "night", "toggle"] },
        // The bar IPC needs a selector; "id default" is the stock single bar.
        { icon: "\uf0ca", label: "Toggle bar",      desc: "Show or hide the topbar",
          run: ["dms", "ipc", "call", "bar", "toggle", "id", "default"] },
    ]

    readonly property var theme: [
        { icon: "\uf186", label: "Dark",   desc: "Dark palette everywhere",
          run: ["dms", "ipc", "call", "theme", "dark"] },
        { icon: "\uf185", label: "Light",  desc: "Light palette everywhere",
          run: ["dms", "ipc", "call", "theme", "light"] },
        { icon: "\uf042", label: "Toggle", desc: "Flip to whichever it isn't",
          run: ["dms", "ipc", "call", "theme", "toggle"] },
    ]

    // Shown above the wallpaper list.
    readonly property var wallpaperActions: [
        { icon: "\uf061", label: "Next wallpaper",     desc: "Advance to the next one",
          run: ["dms", "ipc", "call", "wallpaper", "next"] },
        { icon: "\uf060", label: "Previous wallpaper", desc: "Go back one",
          run: ["dms", "ipc", "call", "wallpaper", "prev"] },
        { icon: "\uf014", label: "Clear wallpaper",    desc: "Remove the background",
          run: ["dms", "ipc", "call", "wallpaper", "clear"] },
    ]

    readonly property var setup: [
        { icon: "\uf013", label: "Shell settings", desc: "DankMaterialShell preferences",
          run: ["dms", "ipc", "call", "settings", "open"] },
        { icon: "\uf11c", label: "Keybindings",    desc: "Edit ~/.config/hypr/custom.lua",
          term: ["sh", "-c", "${EDITOR:-nvim} ~/.config/hypr/custom.lua"] },
        { icon: "\uf108", label: "Monitors",       desc: "Edit ~/.config/hypr/monitors.lua",
          term: ["sh", "-c", "${EDITOR:-nvim} ~/.config/hypr/monitors.lua"] },
        { icon: "\uf0ae", label: "Processes",      desc: "Running processes and resource use",
          run: ["dms", "ipc", "call", "processlist", "toggle"] },
    ]

    readonly property var update: [
        { icon: "\uf187", label: "System packages", desc: "sudo pacman -Syu",
          term: ["sh", "-c", "sudo pacman -Syu; printf '\\nPress any key…'; read -rsn1"] },
        { icon: "\uf1b3", label: "AUR packages",    desc: "paru -Sua",
          term: ["sh", "-c", "paru -Sua; printf '\\nPress any key…'; read -rsn1"] },
        { icon: "\uf014", label: "Remove orphans",  desc: "Drop unused dependencies",
          term: ["sh", "-c", "o=$(pacman -Qtdq); if [ -n \"$o\" ]; then echo \"$o\" | sudo pacman -Rns -; else echo 'No orphans.'; fi; printf '\\nPress any key…'; read -rsn1"] },
    ]

    readonly property var system: [
        { icon: "\uf023", label: "Lock",      desc: "Lock the screen",
          run: ["dms", "ipc", "call", "lock", "lock"] },
        { icon: "\uf186", label: "Suspend",   desc: "Sleep",               run: ["systemctl", "suspend"] },
        { icon: "\uf08b", label: "Log out",   desc: "Exit Hyprland",
          run: ["hyprctl", "dispatch", "hl.dsp.exit()"] },
        { icon: "\uf021", label: "Reboot",    desc: "Restart the machine", run: ["systemctl", "reboot"] },
        { icon: "\uf011", label: "Shut down", desc: "Power off",           run: ["systemctl", "poweroff"] },
    ]

    function forMode(mode: string): var {
        switch (mode) {
        case "root":   return root;
        case "style":  return style;
        case "setup":  return setup;
        case "update": return update;
        case "system": return system;
        case "theme":  return theme;
        default:       return [];
        }
    }

    readonly property var titles: ({
        "apps":     "Apps",
        "capture":  "Capture",
        "managers": "Install",
        "search":   "Install",
        "remove":   "Remove",
        "confirm":  "Uninstall",
        "style":    "Style",
        "setup":    "Setup",
        "update":   "Update",
        "system":   "System",
        "theme":     "Light / dark",
        "wallpaper": "Wallpaper",
    })
}
