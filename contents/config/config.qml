import QtQuick

import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
         name: i18nc("@title", "Arch update notifier configuration")
         icon: "preferences-other"
         source: "config/configInterval.qml"
    }
}
