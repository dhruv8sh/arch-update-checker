
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import QtQuick.Controls as QQC2
import "../Util.js" as Util

StackLayout {
    property string headName: ""
    property string sortBy: "PackageName"
    property alias searchTextField: searchTextField
    property bool ascending: true
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
                checked: !isNotPaused 
                onToggled: main.isNotPaused = !checked
                PlasmaComponents.ToolTip { text: i18n("Pause Updates") }
            }
            PlasmaComponents.ToolButton {
                id: searchButton
                icon.name: "view-refresh"
                onClicked: {
                    Util.action_searchForUpdates()
                    main.hasUserSeen = true
                }
		enabled: !isUpdating
                PlasmaComponents.ToolTip { text: i18n("Check for updates") }
            }
            PlasmaComponents.ToolButton {
                id: installButton
                icon.name: "install"
                onClicked: {
                    localTooltip.visible = !visible
                    Util.action_updateSystem()
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
            enabled: packageModel.count > 0 && !isUpdating
	    property var sortable : ["PackageName", "Source", "Size"];
	    property var names    : ["Package Name", "Source Name", "Download Size"];
	    property var icons    : ["view-sort-ascending-name","view-sort-descending-name","view-sort-ascending-name","view-sort-descending-name","view-sort-ascending","view-sort-descending"];
	    property int curr: 0
            onClicked: {
		curr ++;
		if( curr > 5 ) curr = 0;
		ascending  = curr % 2 == 0;
		sortBy = sortable[parseInt(curr/2)];
		icon.name = icons[curr];
            }
            PlasmaComponents.ToolTip { text: i18n("Sorted by: "+sortButton.names[sortButton.curr]+(sortButton.curr%2==1?"(Descending)":"")) }
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



