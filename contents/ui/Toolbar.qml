 
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras

RowLayout {
    spacing: Kirigami.Units.smallSpacing * 3
    width: parent.width
    property alias searchTextField: searchTextField


    RowLayout {
        Layout.leftMargin: Kirigami.Units.smallSpacing
        spacing: parent.spacing
        PlasmaComponents.Switch {
            id: pauseButton
            icon.name: "media-playback-pause"
            checked: !main.isNotPaused
            onToggled: main.isNotPaused = !checked
            PlasmaComponents.ToolTip {
                text: i18n("Pause Updates")
            }
        }
        PlasmaComponents.ToolButton {
            id: searchButton
            icon.name: "view-refresh"
            onClicked: {
                packageManager.action_checkForUpdates()
                main.hasUserSeen = true
            }
            PlasmaComponents.ToolTip {
                text: i18n("Check for updates")
            }
        }
        PlasmaComponents.ToolButton {
            id: installButton
            icon.name: "install"
            onClicked: packageManager.action_updateSystem()
            PlasmaComponents.ToolTip {
                text: i18n("Update your system")
            }
        }
    }

    PlasmaExtras.SearchField {
        id: searchTextField
        Layout.fillWidth: true
        enabled: packageModel.count > 0
        onTextChanged: {
            filterModel.setFilterFixedString(text)
        }
        focus: main.expanded && !Kirigami.InputMethod.willShowOnActive
    }
}
