import QtQuick
import qs.Common
import qs.Modules.Plugins

// DankMaterialShell entry point.
//
// DMS places plugin widgets inside a bar pill Component, so the upstream
// Omarchy widget is instantiated there and handed the plugin's settings. All
// the behaviour lives in BarWidget.qml, kept as close to upstream as possible
// so changes there can still be merged.
PluginComponent {
    id: root

    horizontalBarPill: Component {
        BarWidget {
            pluginData: root.pluginData
        }
    }

    verticalBarPill: Component {
        BarWidget {
            pluginData: root.pluginData
        }
    }
}
