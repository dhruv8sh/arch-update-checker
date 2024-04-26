
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import QtQuick.Controls as QQC2

StackLayout {
    property string headName: ""
    property bool sortByName: false
    property alias searchTextField: searchTextField
    Layout.fillWidth: true
    onCurrentIndexChanged: opacityAnimation.running = true
    onHeadNameChanged: opacityAnimation.running = true
    NumberAnimation on opacity {
        id: opacityAnimation
        from: 0.6
        to: 1
        duration: 500
    }


    RowLayout {
        width: parent.width
        spacing: Kirigami.Units.smallSpacing * 3
        RowLayout {
            Layout.leftMargin: Kirigami.Units.smallSpacing
            spacing: parent.spacing
            PlasmaComponents.Switch {
                id: pauseButton
                icon.name: "media-playback-pause"
                checked: !main.isNotPaused
                onToggled: main.isNotPaused = !checked
                PlasmaComponents.ToolTip { text: i18n("Pause Updates") }
            }
            PlasmaComponents.ToolButton {
                id: searchButton
                icon.name: "view-refresh"
                onClicked: {
                    packageManager.action_checkForUpdates()
                    main.hasUserSeen = true
                }
                PlasmaComponents.ToolTip { text: i18n("Check for updates") }
            }
            PlasmaComponents.ToolButton {
                id: installButton
                icon.name: "install"
                onClicked: {
                    localTooltip.visible = !visible
                    packageManager.action_updateSystem()
                }
                PlasmaComponents.ToolTip {
                    id: localTooltip
                    text: i18n("Update your system")
                }
            }
        }

        PlasmaExtras.SearchField {
            id: searchTextField
            Layout.fillWidth: true
            enabled: packageModel.count > 0
            onTextChanged: { filterModel.setFilterFixedString(text) }
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
            PlasmaComponents.ToolTip { text: sortByName ? i18n("Currently sorted by: Package Name\nSort by Repository name") : i18n("Currently sorted by: Repository Name\nSort by Package name") }
        }
    }
    PlasmaExtras.Heading {
        text: headName
        Layout.alignment: Qt.AlignHCenter
    }
    RowLayout {
        PlasmaExtras.Heading {
            text: headName
            Layout.alignment: Qt.AlignHCenter
        }
        QQC2.Label{
            Layout.fillWidth: true
        }
        PlasmaComponents.ToolButton {
            Layout.alignment: Qt.AlignRight
            icon.name: "link"
            onClicked: Qt.openUrlExternally("https://www.archlinux.org/news")
            PlasmaComponents.ToolTip { text: i18n("Open Arch Linux News Webpage")+"\narchlinux.org/news" }
        }
    }
}



