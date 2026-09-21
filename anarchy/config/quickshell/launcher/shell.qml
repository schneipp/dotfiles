//@ pragma UseQApplication

// anarchy — a Quickshell menu-launcher for Hyprland.
//
// Opens on an Omarchy-style root menu rather than a wall of applications:
// Apps, Capture, Install, Remove, Style, Setup, Update, System.
//
//   Enter            activate
//   Esc              back one screen, then close
//   Delete           (in Apps) uninstall the package that owns the entry
//   Ctrl+J/K         move down/up, as do the arrows
//
// Anything needing sudo is handed to a floating terminal (class qsl-term) so
// pacman can prompt for a password and show its own output.

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

Scope {
    id: root

    // ---------------------------------------------------------------- state

    property bool active: false

    // root | apps | capture | managers | search | remove | confirm
    //      | style | setup | update | system
    property string mode: "root"
    property var history: []
    property string query: ""

    // install flow
    property var managers: []
    property string manager: ""
    property string managerLabel: ""
    property var searchResults: []
    property bool searching: false

    // details for the highlighted package
    property string infoPkg: ""
    property var infoFields: ({})
    property bool infoLoading: false

    // uninstall flow
    property string targetApp: ""
    property string targetKind: ""   // pkg | file | none
    property string targetValue: ""

    // dynamic lists
    property var captureActions: []
    property var installedPkgs: []
    property var wallpapers: []

    readonly property string terminal: "foot"
    readonly property string termClass: "qsl-term"

    readonly property bool showsInfoPane: mode === "search" || mode === "wallpaper"
    readonly property bool searchable: ["root", "apps", "search", "remove", "wallpaper"].indexOf(mode) >= 0

    // ------------------------------------------------------------ lifecycle

    function reset(): void {
        mode = "root";
        history = [];
        query = "";
        manager = ""; managerLabel = "";
        searchResults = []; searching = false;
        infoPkg = ""; infoFields = ({}); infoLoading = false;
        targetApp = ""; targetKind = ""; targetValue = "";
        wallpapers = [];
    }

    function open(): void {
        reset();
        managersProc.running = true;
        active = true;
    }

    function close(): void { active = false; }

    function goTo(next: string): void {
        history = history.concat([mode]);
        mode = next;
        query = "";

        if (next === "capture") { captureProc.running = false; captureProc.running = true; }
        if (next === "remove")  { installedProc.running = false; installedProc.running = true; }
        if (next === "wallpaper" && wallpapers.length === 0) {
            wallProc.running = false; wallProc.running = true;
        }
    }

    // Install goes straight to searching with the first source qsl-pkg offers —
    // paru when it is installed, which covers the repos and the AUR at once.
    // The picker is pushed onto the history first, so Esc still reveals it when
    // you want to narrow the source.
    function startInstall(): void {
        if (!managers.length) { goTo("managers"); return; }
        goTo("managers");
        manager = managers[0].id;
        managerLabel = managers[0].label;
        mode = "search";
        query = "";
    }

    function goBack(): void {
        if (history.length === 0) { close(); return; }
        const prev = history[history.length - 1];
        history = history.slice(0, -1);
        mode = prev;
        query = "";
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void { root.active ? root.close() : root.open(); }
        function open(): void { root.open(); }
        function close(): void { root.close(); }

        function install(): void { root.open(); root.startInstall(); }
        function capture(): void { root.open(); root.goTo("capture"); }
        function wallpaper(): void { root.open(); root.goTo("wallpaper"); }

        // Open any screen directly, e.g. `qs -c launcher ipc call launcher go system`.
        function go(mode: string): void { root.open(); root.goTo(mode); }

        // Open at the root with a query already typed.
        function search(text: string): void { root.open(); root.query = text; }

        function installSearch(mgr: string, q: string): void {
            root.open();
            root.manager = mgr;
            root.managerLabel = mgr === "aur" ? "AUR" : "Official repos";
            root.goTo("search");
            root.query = q;
        }

        function uninstall(appId: string): void {
            root.open();
            const entry = DesktopEntries.byId(appId);
            if (entry) root.askUninstall(entry);
        }
    }

    // ------------------------------------------------------------ processes

    Process {
        id: managersProc
        command: ["qsl-pkg", "managers"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.trim().split("\n")) {
                    if (!line) continue;
                    const f = line.split("\t");
                    out.push({ id: f[0], label: f[1] ?? f[0], desc: f[2] ?? "" });
                }
                root.managers = out;
            }
        }
    }

    Process {
        id: captureProc
        command: ["qsl-capture", "menu"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.trim().split("\n")) {
                    if (!line) continue;
                    // id \t\t label \t desc
                    const f = line.split("\t").filter(s => s.length > 0);
                    if (f.length < 2) continue;
                    out.push({ id: f[0], label: f[1], desc: f[2] ?? "" });
                }
                root.captureActions = out;
            }
        }
    }

    Process {
        id: installedProc
        command: ["qsl-pkg", "installed"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.trim().split("\n")) if (line) out.push(line);
                root.installedPkgs = out;
            }
        }
    }

    Process {
        id: wallProc
        command: ["qsl-wall", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.trim().split("\n")) if (line) out.push(line);
                root.wallpapers = out;
            }
        }
    }

    Process {
        id: ownerProc
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split("\t");
                root.targetKind = f[0] ?? "none";
                root.targetValue = f[1] ?? "";
                root.goTo("confirm");
            }
        }
    }

    Process {
        id: searchProc
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.trim().split("\n")) if (line) out.push(line);
                root.searchResults = out.slice(0, 200);
                root.searching = false;
            }
        }
    }

    Process {
        id: infoProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.infoFields = root.parseInfo(text);
                root.infoLoading = false;
            }
        }
    }

    // `pacman -Si` prints "Key : Value" with indented continuation lines.
    function parseInfo(text: string): var {
        const out = {};
        let lastKey = null;
        for (const line of text.split("\n")) {
            if (!line.trim()) continue;
            const m = line.match(/^(\S[^:]*?)\s*:\s?(.*)$/);
            if (m && !/^\s/.test(line)) {
                lastKey = m[1].trim();
                out[lastKey] = m[2].trim();
            } else if (lastKey && /^\s/.test(line)) {
                out[lastKey] += "  " + line.trim();
            }
        }
        return out;
    }

    Timer {
        id: searchDebounce
        interval: 180
        onTriggered: {
            const q = root.query.trim();
            if (q.length < 2) {
                root.searchResults = []; root.searching = false; return;
            }
            root.searching = true;
            searchProc.running = false;
            searchProc.command = ["qsl-pkg", "search", root.manager, q];
            searchProc.running = true;
        }
    }

    Timer {
        id: infoDebounce
        interval: 140
        onTriggered: {
            const lv = root.listRef;
            if (root.mode !== "search" || !lv || lv.count === 0) {
                root.infoPkg = ""; root.infoFields = ({}); return;
            }
            const item = lv.model[lv.currentIndex];
            if (!item || !item.label) return;
            root.infoPkg = item.label;
            root.infoFields = ({});
            root.infoLoading = true;
            infoProc.running = false;
            infoProc.command = ["qsl-pkg", "info", root.manager, item.label];
            infoProc.running = true;
        }
    }

    // ------------------------------------------------------------- actions

    function runDetached(cmd: list<string>): void {
        Quickshell.execDetached(cmd);
        root.close();
    }

    // foot takes the command straight after its options; kitty needs -e. The
    // app-id is what the Hyprland rule floats on.
    function runInTerminal(args: list<string>): void {
        const head = root.terminal === "foot"
            ? [root.terminal, "--app-id=" + root.termClass]
            : [root.terminal, "--class", root.termClass, "-e"];
        runDetached(head.concat(args));
    }

    function askUninstall(entry): void {
        if (!entry) return;
        root.targetApp = entry.name;
        ownerProc.running = false;
        ownerProc.command = ["qsl-pkg", "owner", entry.id];
        ownerProc.running = true;
    }

    function askRemovePackage(pkg: string): void {
        root.targetApp = pkg;
        root.targetKind = "pkg";
        root.targetValue = pkg;
        root.goTo("confirm");
    }

    function confirmUninstall(): void {
        if (root.targetKind === "pkg")       runInTerminal(["qsl-pkg", "remove", root.targetValue]);
        else if (root.targetKind === "file") runInTerminal(["qsl-pkg", "forget", root.targetValue]);
        else                                 root.goBack();
    }

    // ----------------------------------------------------------- list model

    function score(haystack: string, q: string): int {
        if (!q) return 1;
        const name = haystack.toLowerCase();
        const idx = name.indexOf(q);
        if (idx === 0) return 1000;
        if (idx > 0) return 800 - idx;
        let i = 0;
        for (const ch of name) {
            if (ch === q[i]) i++;
            if (i === q.length) return 100;
        }
        return 0;
    }

    // Applications matching `q`, best first. Shared by the Apps screen and by
    // the root menu, which searches itself and the app list together.
    function appRows(q: string): var {
        const scored = [];
        for (const e of DesktopEntries.applications.values) {
            if (e.noDisplay) continue;
            let s = score(e.name, q);
            if (s === 0 && q) {
                if ((e.comment ?? "").toLowerCase().includes(q)) s = 300;
                else for (const kw of e.keywords ?? [])
                    if (kw.toLowerCase().includes(q)) { s = 250; break; }
            }
            if (s > 0) scored.push({ s: s, e: e });
        }
        scored.sort((a, b) => b.s - a.s || a.e.name.localeCompare(b.e.name));
        return scored.map(x => ({
            icon: "", iconSource: x.e.icon
                ? Quickshell.iconPath(x.e.icon, "application-x-executable") : "",
            label: x.e.name, desc: x.e.comment ?? "",
            kind: "app", payload: x.e,
        }));
    }

    // Every screen produces the same item shape, so one delegate covers all of
    // them: { icon, iconSource, label, desc, kind, payload }
    readonly property var rows: {
        const q = query.trim().toLowerCase();

        switch (mode) {
        case "apps":
            return appRows(q);

        case "capture":
            return captureActions.map(a => ({
                icon: a.id.indexOf("record") === 0 ? "\uf03d" : "\uf030",
                iconSource: "", label: a.label, desc: a.desc,
                kind: "capture", payload: a.id,
            }));

        case "managers":
            return managers.map(m => ({
                icon: "\uf187", iconSource: "", label: m.label, desc: m.desc,
                kind: "manager", payload: m.id,
            }));

        case "search":
            return searchResults.map(p => ({
                icon: "\uf187", iconSource: "", label: p, desc: "",
                kind: "pkg", payload: p,
            }));

        case "wallpaper": {
            const actions = Menus.wallpaperActions.map(m => ({
                icon: m.icon, iconSource: "", label: m.label, desc: m.desc,
                kind: "menu", payload: m,
            }));
            const hits = [];
            for (const w of wallpapers) {
                const base = w.slice(w.lastIndexOf("/") + 1);
                if (score(base, q) > 0) hits.push(w);
            }
            const files = hits.slice(0, 400).map(w => {
                const base = w.slice(w.lastIndexOf("/") + 1);
                const dir = w.slice(0, w.lastIndexOf("/"));
                return {
                    icon: "\uf03e", iconSource: "",
                    label: base.replace(/\.[^.]+$/, ""),
                    desc: dir.replace(/^\/home\/[^/]+/, "~"),
                    kind: "wallpaper", payload: w,
                };
            });
            // Hide the next/prev/clear actions once you start filtering.
            return q ? files : actions.concat(files);
        }

        case "remove": {
            const hits = [];
            for (const p of installedPkgs) {
                if (score(p, q) > 0) hits.push(p);
            }
            hits.sort((a, b) => score(b, q) - score(a, q) || a.localeCompare(b));
            return hits.slice(0, 300).map(p => ({
                icon: "\uf014", iconSource: "", label: p, desc: "",
                kind: "installed", payload: p,
            }));
        }

        default: {
            const entries = Menus.forMode(mode).map(m => ({
                icon: m.icon, iconSource: "", label: m.label, desc: m.desc,
                kind: "menu", payload: m,
            }));

            if (!q)
                return entries;

            // Typing at the root searches the menu and the applications at
            // once, so you never have to step into Apps first. Menu entries
            // match on their description too, and stay above the apps.
            const menuHits = entries.filter(e =>
                score(e.label, q) > 0 || (e.desc ?? "").toLowerCase().includes(q));

            return mode === "root" ? menuHits.concat(appRows(q)) : menuHits;
        }
        }
    }

    function activate(): void {
        const lv = root.listRef;

        if (mode === "confirm") { confirmUninstall(); return; }
        if (!lv || lv.count === 0) return;

        const item = lv.model[lv.currentIndex];
        if (!item) return;

        switch (item.kind) {
        case "menu": {
            const m = item.payload;
            if (m.go === "managers") startInstall();
            else if (m.go)   goTo(m.go);
            else if (m.run)  runDetached(m.run);
            else if (m.term) runInTerminal(m.term);
            break;
        }
        case "app":
            item.payload.execute();
            close();
            break;
        case "capture":
            // The launcher must be gone before slurp draws its overlay.
            runDetached(["qsl-capture", item.payload]);
            break;
        case "manager":
            manager = item.payload;
            managerLabel = item.label;
            goTo("search");
            break;
        case "pkg":
            runInTerminal(["qsl-pkg", "install", manager, item.payload]);
            break;
        case "installed":
            askRemovePackage(item.payload);
            break;
        case "wallpaper":
            runDetached(["dms", "ipc", "call", "wallpaper", "set", item.payload]);
            break;
        }
    }

    // ------------------------------------------------------------------ UI

    property var listRef: null

    function move(delta: int): void {
        const lv = root.listRef;
        if (!lv || lv.count === 0) return;
        let i = lv.currentIndex + delta;
        if (i < 0) i = lv.count - 1;
        if (i >= lv.count) i = 0;
        lv.currentIndex = i;
    }

    function handleKey(event): void {
        const ctrl = (event.modifiers & Qt.ControlModifier) !== 0;

        switch (event.key) {
        case Qt.Key_Escape: goBack();   event.accepted = true; return;
        case Qt.Key_Return:
        case Qt.Key_Enter:  activate(); event.accepted = true; return;
        case Qt.Key_Up:     move(-1);   event.accepted = true; return;
        case Qt.Key_Down:   move(1);    event.accepted = true; return;

        case Qt.Key_Delete:
            if (root.mode === "apps") {
                const lv = root.listRef;
                if (lv && lv.count > 0) {
                    const item = lv.model[lv.currentIndex];
                    if (item && item.kind === "app") root.askUninstall(item.payload);
                }
                event.accepted = true;
            }
            return;

        case Qt.Key_K: if (ctrl) { move(-1); event.accepted = true; } return;
        case Qt.Key_P: if (ctrl) { move(-1); event.accepted = true; } return;
        case Qt.Key_J: if (ctrl) { move(1);  event.accepted = true; } return;
        case Qt.Key_N: if (ctrl) { move(1);  event.accepted = true; } return;

        case Qt.Key_Backspace:
            // Backspace on an empty query steps back a screen.
            if (root.query.length === 0 && root.history.length > 0) {
                goBack(); event.accepted = true;
            }
            return;
        }
    }

    onQueryChanged: { if (mode === "search") searchDebounce.restart(); }

    LazyLoader {
        active: root.active

        PanelWindow {
            id: win

            screen: {
                const m = Hyprland.focusedMonitor;
                if (!m) return null;
                for (const s of Quickshell.screens) if (s.name === m.name) return s;
                return null;
            }

            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "qsl"

            anchors { top: true; bottom: true; left: true; right: true }

            MouseArea { anchors.fill: parent; onClicked: root.close() }

            Rectangle {
                id: card

                anchors.horizontalCenter: parent.horizontalCenter
                y: Math.round(parent.height * 0.16)

                width: root.showsInfoPane ? 1120 : 720
                Behavior on width { NumberAnimation { duration: 130; easing.type: Easing.OutQuad } }

                height: root.mode === "confirm"
                    ? header.height + confirmPane.implicitHeight + footer.height + Theme.pad * 3
                    : Math.min(
                        Math.max(header.height + list.contentHeight + footer.height + Theme.pad * 2,
                                 root.showsInfoPane ? 460 : 0),
                        Math.round(parent.height * 0.62))
                Behavior on height { NumberAnimation { duration: 110; easing.type: Easing.OutQuad } }

                radius: Theme.radius
                color: Theme.bg
                border.width: 1
                border.color: Theme.border

                focus: true
                Keys.onPressed: event => root.handleKey(event)

                MouseArea { anchors.fill: parent }

                // The search field must own the keyboard the moment the window
                // exists. Opening at the root is not a mode *change*, so relying
                // on onModeChanged alone left the card focused and swallowed
                // every keystroke until you navigated somewhere.
                Component.onCompleted: input.forceActiveFocus()

                Connections {
                    target: root
                    function onModeChanged(): void {
                        if (root.mode === "confirm") card.forceActiveFocus();
                        else input.forceActiveFocus();
                    }
                    function onActiveChanged(): void {
                        if (root.active && root.mode !== "confirm")
                            input.forceActiveFocus();
                    }
                }

                // ------------------------------------------------- header

                Column {
                    id: header
                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: Theme.pad }
                    spacing: 12

                    // ---- ANARCHY logo
                    Item {
                        width: parent.width
                        height: 40

                        Image {
                            anchors.centerIn: parent
                            source: Qt.resolvedUrl("assets/anarchy-word.png")
                            height: 30
                            width: height * (sourceSize.width / Math.max(1, sourceSize.height))
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                        }

                        // Breadcrumb sits on the same line, left-aligned.
                        Rectangle {
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                            visible: root.mode !== "root"
                            radius: 6
                            height: 22
                            width: crumb.width + 16
                            color: root.mode === "confirm" ? Qt.rgba(0.95, 0.55, 0.66, 0.16)
                                                           : Qt.rgba(0.65, 0.71, 0.99, 0.16)

                            Text {
                                id: crumb
                                anchors.centerIn: parent
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                color: root.mode === "confirm" ? Theme.danger : Theme.accent
                                text: {
                                    const t = Menus.titles[root.mode] ?? root.mode;
                                    return root.mode === "search" ? t + " · " + root.managerLabel : t;
                                }
                            }
                        }

                        // Recording indicator, so it's obvious one is running.
                        Rectangle {
                            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                            visible: root.mode === "capture"
                                     && root.captureActions.length > 0
                                     && root.captureActions[0].id === "record-stop"
                            radius: 6
                            height: 22
                            width: recText.width + 16
                            color: Qt.rgba(0.95, 0.55, 0.66, 0.16)

                            Text {
                                id: recText
                                anchors.centerIn: parent
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                color: Theme.danger
                                text: "● REC"
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Theme.border }

                    // ---- search field
                    Rectangle {
                        visible: root.mode !== "confirm"
                        width: parent.width
                        height: 46
                        radius: 12
                        color: Theme.bgRaised

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 10

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.searchable ? "󰍉" : "󰅂"
                                font.family: Theme.monoFamily
                                font.pixelSize: 15
                                color: Theme.accent
                            }

                            TextInput {
                                id: input
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 60
                                focus: true
                                // Never `enabled: false` — a disabled item gets no key events.
                                readOnly: !root.searchable
                                color: Theme.fg
                                font.family: Theme.fontFamily
                                font.pixelSize: 15
                                selectionColor: Theme.accent
                                selectedTextColor: Theme.bg
                                clip: true

                                text: root.query
                                onTextChanged: if (text !== root.query) root.query = text

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: input.text.length === 0
                                    color: Theme.fgDim
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 15
                                    text: {
                                        switch (root.mode) {
                                        case "root":   return "Where to?";
                                        case "apps":   return "Search apps…  (Delete uninstalls)";
                                        case "search": return "Search " + root.managerLabel + "…";
                                        case "remove": return "Search installed packages…";
                                        default:       return "Choose…";
                                        }
                                    }
                                }

                                Keys.priority: Keys.BeforeItem
                                Keys.onPressed: event => root.handleKey(event)
                            }
                        }
                    }
                }

                // ------------------------------------------------- content

                ListView {
                    id: list
                    anchors {
                        top: header.bottom
                        left: parent.left
                        right: root.showsInfoPane ? infoPane.left : parent.right
                        bottom: footer.top
                        topMargin: Theme.pad
                        leftMargin: Theme.pad
                        rightMargin: Theme.pad
                    }
                    visible: root.mode !== "confirm"
                    clip: true
                    spacing: 4
                    currentIndex: 0
                    highlightMoveDuration: 90
                    preferredHighlightBegin: 0
                    preferredHighlightEnd: height
                    highlightRangeMode: ListView.ApplyRange
                    boundsBehavior: Flickable.StopAtBounds

                    model: root.rows

                    onModelChanged: {
                        currentIndex = 0;
                        if (root.mode === "search") infoDebounce.restart();
                    }
                    onCurrentIndexChanged: if (root.mode === "search") infoDebounce.restart()
                    Component.onCompleted: root.listRef = list

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: ListView.view.width
                        height: Theme.rowHeight
                        radius: Theme.radiusItem
                        color: index === list.currentIndex ? Theme.accent : "transparent"

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: list.currentIndex = index
                            onClicked: root.activate()
                        }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 12

                            Image {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: modelData.iconSource !== ""
                                width: visible ? 26 : 0
                                height: 26
                                sourceSize.width: 26
                                sourceSize.height: 26
                                fillMode: Image.PreserveAspectFit
                                source: modelData.iconSource
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: modelData.iconSource === ""
                                width: visible ? 26 : 0
                                horizontalAlignment: Text.AlignHCenter
                                text: modelData.icon
                                font.family: Theme.monoFamily
                                font.pixelSize: 17
                                color: index === list.currentIndex ? Theme.bg : Theme.fgDim
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 60
                                spacing: 1

                                Text {
                                    width: parent.width
                                    elide: Text.ElideRight
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    color: index === list.currentIndex ? Theme.bg : Theme.fg
                                    text: modelData.label
                                }

                                Text {
                                    width: parent.width
                                    elide: Text.ElideRight
                                    visible: text.length > 0
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    opacity: index === list.currentIndex ? 0.75 : 1
                                    color: index === list.currentIndex ? Theme.bg : Theme.fgDim
                                    text: modelData.desc
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: list.count === 0
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgDim
                        text: {
                            if (root.searching) return "Searching…";
                            if (root.mode === "search" && root.query.trim().length < 2)
                                return "Type at least two characters";
                            return "No results";
                        }
                    }
                }

                // ------------------------------------------ package details

                Rectangle {
                    id: infoPane
                    anchors {
                        top: header.bottom
                        right: parent.right
                        bottom: footer.top
                        topMargin: Theme.pad
                        rightMargin: Theme.pad
                    }
                    width: root.showsInfoPane ? 520 : 0
                    visible: root.showsInfoPane
                    clip: true
                    radius: 12
                    color: Theme.bgPanel

                    Text {
                        anchors.centerIn: parent
                        width: parent.width - 32
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        visible: root.mode === "search" && root.infoPkg === "" && !root.infoLoading
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgDim
                        text: "Highlight a package to see its description"
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: root.mode === "search" && root.infoLoading
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgDim
                        text: "Loading…"
                    }

                    // ---- wallpaper preview
                    Item {
                        anchors.fill: parent
                        anchors.margins: 12
                        visible: root.mode === "wallpaper"

                        Image {
                            id: wallPreview
                            anchors { top: parent.top; left: parent.left; right: parent.right
                                      bottom: wallCaption.top; bottomMargin: 10 }
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: false
                            // Decode at display size; these are full-resolution photos.
                            sourceSize.width: 520
                            source: {
                                const lv = root.listRef;
                                if (!lv || lv.count === 0) return "";
                                const item = lv.model[lv.currentIndex];
                                if (!item || item.kind !== "wallpaper") return "";
                                return "file://" + item.payload;
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: wallPreview.source === ""
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            color: Theme.fgDim
                            text: "Highlight a wallpaper to preview it"
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: wallPreview.source !== ""
                                     && wallPreview.status === Image.Loading
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            color: Theme.fgDim
                            text: "Loading…"
                        }

                        Text {
                            id: wallCaption
                            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideMiddle
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.fgDim
                            text: {
                                const lv = root.listRef;
                                if (!lv || lv.count === 0) return "";
                                const item = lv.model[lv.currentIndex];
                                if (!item || item.kind !== "wallpaper") return "";
                                return item.payload.replace(/^\/home\/[^/]+/, "~");
                            }
                        }
                    }

                    Flickable {
                        anchors.fill: parent
                        anchors.margins: 16
                        visible: root.mode === "search" && root.infoPkg !== "" && !root.infoLoading
                        contentHeight: infoCol.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        Column {
                            id: infoCol
                            width: parent.width
                            spacing: 10

                            Row {
                                width: parent.width
                                spacing: 8

                                Text {
                                    id: infoName
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 17
                                    font.bold: true
                                    color: Theme.fg
                                    text: root.infoPkg
                                }

                                Text {
                                    anchors.baseline: infoName.baseline
                                    font.family: Theme.monoFamily
                                    font.pixelSize: 12
                                    color: Theme.accent
                                    text: root.infoFields["Version"] ?? ""
                                }
                            }

                            Text {
                                width: parent.width
                                wrapMode: Text.Wrap
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                lineHeight: 1.25
                                color: Theme.fg
                                text: root.infoFields["Description"] ?? "No description available."
                            }

                            Rectangle { width: parent.width; height: 1; color: Theme.border }

                            Repeater {
                                model: {
                                    const f = root.infoFields;
                                    const rows = [];
                                    const add = (label, key) => { if (f[key]) rows.push({ label: label, value: f[key] }); };
                                    add("Repository", "Repository");
                                    add("Installed",  "Installed Size");
                                    add("Download",   "Download Size");
                                    add("Licenses",   "Licenses");
                                    add("URL",        "URL");
                                    return rows;
                                }

                                Row {
                                    required property var modelData
                                    width: infoCol.width
                                    spacing: 10

                                    Text {
                                        width: 84
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        color: Theme.fgDim
                                        text: modelData.label
                                    }

                                    Text {
                                        width: infoCol.width - 94
                                        wrapMode: Text.Wrap
                                        elide: Text.ElideRight
                                        maximumLineCount: 2
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        color: Theme.fg
                                        text: modelData.value
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width; height: 1; color: Theme.border
                                visible: (root.infoFields["Depends On"] ?? "") !== ""
                            }

                            Text {
                                width: parent.width
                                visible: (root.infoFields["Depends On"] ?? "") !== ""
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                color: Theme.fgDim
                                text: "Depends on"
                            }

                            Text {
                                width: parent.width
                                visible: (root.infoFields["Depends On"] ?? "") !== ""
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                maximumLineCount: 4
                                font.family: Theme.monoFamily
                                font.pixelSize: 10
                                color: Theme.fgDim
                                text: root.infoFields["Depends On"] ?? ""
                            }
                        }
                    }
                }

                // -------------------------------------------- confirm pane

                Column {
                    id: confirmPane
                    anchors {
                        top: header.bottom
                        horizontalCenter: parent.horizontalCenter
                        topMargin: Theme.pad
                    }
                    width: parent.width - Theme.pad * 4
                    visible: root.mode === "confirm"
                    spacing: 14

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Theme.monoFamily
                        font.pixelSize: 34
                        color: Theme.danger
                        text: "\uf014"
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        font.family: Theme.fontFamily
                        font.pixelSize: 17
                        font.bold: true
                        color: Theme.fg
                        text: {
                            if (root.targetKind === "pkg")  return "Uninstall " + root.targetValue + "?";
                            if (root.targetKind === "file") return "Remove the " + root.targetApp + " launcher?";
                            return "Can't uninstall " + root.targetApp;
                        }
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgDim
                        text: {
                            if (root.targetKind === "pkg")
                                return "A terminal will open so pacman can confirm dependencies "
                                     + "and ask for your password.";
                            if (root.targetKind === "file")
                                return "No package owns this entry — it's a standalone .desktop file.\n"
                                     + root.targetValue;
                            return "No .desktop file was found for this entry, so there's nothing to remove.";
                        }
                    }

                    Item { width: 1; height: 4 }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 10

                        Rectangle {
                            width: 130; height: 38; radius: 10
                            color: Theme.bgRaised
                            Text {
                                anchors.centerIn: parent
                                font.family: Theme.fontFamily; font.pixelSize: 13
                                color: Theme.fg; text: "Esc  Cancel"
                            }
                            MouseArea { anchors.fill: parent; onClicked: root.goBack() }
                        }

                        Rectangle {
                            width: 170; height: 38; radius: 10
                            visible: root.targetKind !== "none"
                            color: Theme.danger
                            Text {
                                anchors.centerIn: parent
                                font.family: Theme.fontFamily; font.pixelSize: 13; font.bold: true
                                color: Theme.bg; text: "Enter  Uninstall"
                            }
                            MouseArea { anchors.fill: parent; onClicked: root.confirmUninstall() }
                        }
                    }
                }

                // -------------------------------------------------- footer

                Rectangle {
                    id: footer
                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                    height: 34
                    color: "transparent"

                    Text {
                        anchors { left: parent.left; leftMargin: Theme.pad + 4; verticalCenter: parent.verticalCenter }
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.fgDim
                        text: {
                            switch (root.mode) {
                            case "root":     return "Enter open · Esc close";
                            case "apps":     return "Enter launch · Delete uninstall · Esc back";
                            case "search":   return "Enter install in terminal · Esc back";
                            case "remove":   return "Enter uninstall · Esc back";
                            case "confirm":  return "Enter confirm · Esc cancel";
                            default:         return "Enter choose · Esc back";
                            }
                        }
                    }

                    Text {
                        anchors { right: parent.right; rightMargin: Theme.pad + 4; verticalCenter: parent.verticalCenter }
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.fgDim
                        visible: root.mode !== "confirm" && root.mode !== "root"
                        text: list.count + (list.count === 1 ? " result" : " results")
                    }
                }
            }
        }
    }
}
