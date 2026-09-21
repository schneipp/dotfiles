import QtQuick
import qs.Common

// Stand-in for Omarchy's qs.Ui Panel, the base every Omarchy bar widget
// derives from. Upstream uses it for four things: settings lookup, the
// open/closed state of its popup, a handle on the bar it lives in, and the
// IPC plumbing it opts out of.
//
// DankMaterialShell has no equivalent base type — plugin widgets are plain
// items placed in a bar pill — so this supplies the same surface and the DMS
// entry point (SpotmarchyWidget.qml) feeds it.
Item {
    id: panel

    // --- identity. Unused here, but upstream sets them and QML requires the
    // properties to exist.
    property string moduleName: ""
    property string ipcTarget: ""
    property bool manageIpc: true

    // --- settings, injected by the host. DMS hands plugins a `pluginData`
    // object keyed exactly like Omarchy's settings, so the lookup is direct.
    property var pluginData: ({})

    function setting(key: string, fallback) {
        if (!pluginData)
            return fallback;
        const v = pluginData[key];
        return v === undefined || v === null ? fallback : v;
    }

    // --- popup state
    property bool opened: false
    function open(): void   { opened = true; }
    function close(): void  { opened = false; }
    function toggle(): void { opened = !opened; }

    // --- the bar this widget sits in.
    //
    // Omarchy passes a live bar object; DMS does not expose one to plugins, so
    // this is a fixed description with the same shape. `run` and the tooltip
    // calls are no-ops rather than missing, so upstream's guarded calls to
    // them stay harmless.
    property var bar: QtObject {
        readonly property string fontFamily: Theme.fontFamily !== undefined
            ? Theme.fontFamily : "Noto Sans"
        readonly property color foreground: Theme.surfaceText
        readonly property bool vertical: false
        readonly property int barSize: 40
        readonly property int sizeHorizontal: 40
        readonly property bool foregroundAnimationEnabled: true

        function showTooltip(item, text) {}
        function hideTooltip(item) {}
        function run(cmd) {}
    }
}
