import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("Package Management")
        icon: "akonadi-symbolic"
        source: "Config/configPacman.qml"
    }
    ConfigCategory {
        name: i18n("Behavior")
        icon: "configure"
        source: "Config/configBehavior.qml"
    }
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-theme-global"
        source: "Config/configAppearance.qml"
    }
    ConfigCategory {
        name: i18n("Debug")
        icon: "data-warning"
        source: "Config/configUnsafe.qml"
    }
}
