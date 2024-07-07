import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kitemmodels as KItemModels
import org.kde.kirigami as Kirigami
import "../Common/" as Common
import "../../Util.js" as Util

Kirigami.Page {
    id: listPage
    property int kind: 0
    title: i18nc("@title", "Update View")
    anchors.fill: parent
    KItemModels.KSortFilterProxyModel {
        id: filterModel
        sourceModel: packageModel
        filterRoleName: "PackageName"
        filterCaseSensitivity: Qt.CaseInsensitive
        sortCaseSensitivity: Qt.CaseInsensitive
        sortRoleName: toolbar.sortBy
        recursiveFilteringEnabled: true
        sortOrder   : toolbar.ascending ? Qt.AscendingOrder : Qt.DescendingOrder
    }

    header:QQC2.ToolBar{
        width: parent.width
        RowLayout{
            id: toolbar
            anchors.fill: parent
            property string sortBy: "PackageName"
            property bool ascending: true
            property alias searchTerm:searchTextField.text
            QQC2.ToolButton{
                text: i18n(isBusy?"Stop":"Refresh")
                icon.name: isBusy?"kt-stop":"view-refresh"
                onClicked: {
                    if( isBusy ) Util.endAll();
                    else Util.commands["checkUpdates"].run()
                }
                PlasmaComponents.ToolTip{ text: parent.text }
                display:QQC2.AbstractButton.IconOnly
            }
            QQC2.ToolButton {
                text: i18n("Update System")
                icon.name: "install"
                onClicked: Util.updateSystem()
                enabled: !isBusy
                display:QQC2.AbstractButton.IconOnly
                PlasmaComponents.ToolTip{ text: parent.text }
            }
            Kirigami.SearchField {
                id: searchTextField
                Layout.fillWidth: true
                enabled: packageModel.count > 0 && !isBusy
                onTextChanged: { filterModel.setFilterFixedString(text) }
                focus: main.expanded && !Kirigami.InputMethod.willShowOnActive
                Layout.alignment: Qt.AlignRight
            }
            QQC2.ToolButton {
                id: sortButton
                icon.name: sortButton.sortable[parseInt(curr)][toolbar.ascending?2:3]
                enabled: packageModel.count > 0 && !isBusy
                property var sortable : [["PackageName", "Package Name", "view-sort-ascending-name","view-sort-descending-name"],
                ["Source", "Source Name", "vcs-commit-cvs-cervisia", "vcs-update-cvs-cervisia"],
                ["Size", "Download Size", "view-sort-ascending", "view-sort-descending"]]
                property int curr: 0
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    toolbar.ascending = !toolbar.ascending
                    if(toolbar.ascending) curr ++;
                    if( curr > 2 ) curr = 0;
                    toolbar.sortBy = sortable[curr][0];
                }
                display:QQC2.AbstractButton.IconOnly
                PlasmaComponents.ToolTip{
                    text: i18n(sortButton.sortable[parseInt(sortButton.curr)][1]+(toolbar.ascending?"":"(Descending)"))
                }
            }
        }}
        footer:QQC2.ToolBar{
            RowLayout{
                anchors.fill: parent
                Kirigami.Icon {
                    source: statusIcon
                    opacity: 0.7
                }
                QQC2.Label {
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: statusMessage
                    opacity: 0.7
                }
                PlasmaComponents.ToolButton {
                    id: clearOrphansButton
                    icon.name: "edit-clear-all"
                    onClicked: Util.commands["cleanupPacman"].run()
                    PlasmaComponents.ToolTip { text: i18n("Clear orphans") }
                }
                PlasmaComponents.ToolButton {
                    Layout.alignment: Qt.AlignRight
                    icon.name: "news-subscribe"
                    onClicked: stack.push("UpdateNews.qml");
                    PlasmaComponents.ToolTip { text: i18n("Official Arch Update News") }
                }
                PlasmaComponents.ToolButton {
                    icon.name: "media-playback-pause"
                    checkable: true
                    checked: !isNotPaused
                    onCheckedChanged: main.isNotPaused = !checked
                    PlasmaComponents.ToolTip { text: i18n(isNotPaused?"Automatically searching for updates":"Automatic updates paused") }
                }
            }
        }

        contentItem: Item{
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.bottom: footer.top

            ColumnLayout{
                enabled: !isBusy
                anchors.fill: parent
                spacing: 0
                Kirigami.InlineMessage {
                    id: pausedMessage
                    Layout.fillWidth: true
                    type: Kirigami.MessageType.Warning
                    icon.name: "media-playback-paused-symbolic"
                    text: i18n("Not searching for updates automatically")
                    visible: !main.isNotPaused && !isBusy
                    actions: Kirigami.Action {
                        text: i18nc("@action:button", "Resume")
                        onTriggered: main.isNotPaused = true
                    }
                }
                Kirigami.InlineMessage {
                    id: singleInstallMessage
                    Layout.fillWidth: true
                    type: Kirigami.MessageType.Warning
                    icon.name: "data-warning"
                    text: i18n("Updating single packages is blocked by default due HIGH RISK OF SYSTEM BREAKAGE.\nYou have been warned.\nDo you want to enable this?")
                    visible: showAllowSingleModifications
                    actions: [
                        Kirigami.Action {
                            text: i18nc("@action:button", "Allow")
                            onTriggered: {
                                cfg.allowSingleModification = 2
                                showAllowSingleModifications = false
                            }
                        },
                        Kirigami.Action {
                            text: i18nc("@action:button", "Don't Allow")
                            onTriggered: {
                                cfg.allowSingleModification = 0
                                showAllowSingularModifications = false
                            }
                        }
                    ]
                }
                Kirigami.InlineMessage {
                    id: errorMessage
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentItem.implicitHeight + topPadding + bottomPadding
                    type: Kirigami.MessageType.Error
                    icon.name: "data-error"
                    text: main.error
                    visible: main.error != ""
                    actions: Kirigami.Action {
                        text: i18nc("@action:button","Clear")
                        onTriggered: error = ""
                    }
                }
                Kirigami.InlineMessage {
                    id: dependencyMissing
                    Layout.fillWidth: true
                    type: Kirigami.MessageType.Error
                    icon.name: "dependency"
                    text: i18n("Dependencies missing!")
                    visible: missingDependency
                    actions: Kirigami.Action {
                        text: i18nc("@action:button", "Install")
                        onTriggered: Util.commands["pacmanInstall"].run("pacutils pacman-contrib")
                    }
                }
                PlasmaComponents.ScrollView {
                    id: scrollView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentItem: ListView {
                        id: packageView
                        spacing: Kirigami.Units.smallSpacing
                        model: filterModel
                        currentIndex: -1
                        boundsBehavior: Flickable.StopAtBounds
                        highlight: PlasmaExtras.Highlight { }
                        delegate: Common.PackageItem {
                            showSeparator: index !== 0
                            width: packageView.width //- Kirigami.Units.smallSpacing * 4
                        }
                        Kirigami.PlaceholderMessage {
                            anchors.centerIn: parent
                            width: parent.width - (Kirigami.Units.largeSpacing * 4)
                            visible: packageView.count === 0 && !isBusy
                            text: {
                                if(toolbar.searchTerm!=="") return "No results."
                                else if(error !== "") return "Some error occurred."
                                else return "You are up to date!"
                            }
                            icon.name: {
                                if(toolbar.searchTerm!=="") return "edit-none"
                                else if(error !== "") return "data-error"
                                else return "checkmark"
                            }
                        }
                    }
                }
            }
            PlasmaComponents.BusyIndicator{
                anchors.centerIn: parent
                visible: isBusy
            }
        }
    }
