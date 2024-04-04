
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras


RowLayout {
    width: parent.width
    property alias searchTextField: searchTextField
    property bool sortByName: false
    property string headName: ""
    spacing: Kirigami.Units.smallSpacing * 3
    RowLayout {
        Layout.leftMargin: Kirigami.Units.smallSpacing
        visible: searchTextField.visible
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
        visible: headName === "" && !plasmoid.configuration.showIntro && !newsEnabled
        focus: main.expanded && !Kirigami.InputMethod.willShowOnActive
    }
    PlasmaComponents.ToolButton {
        id: sortButton
        icon.name: "view-sort-ascending-name"
        enabled: packageModel.count > 0
        onClicked: {
            sortByName = !sortByName
            main.clearProperties();
        }
        visible: searchTextField.visible
        PlasmaComponents.ToolTip {
            text: i18n("Sort by name/repository")
        }
    }
    PlasmaExtras.Heading {
        text: headName
        Layout.alignment: Qt.AlignCenter
        visible: headName !== ""
    }
}

