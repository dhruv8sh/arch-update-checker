import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "../Common/" as Common

ColumnLayout {
    id: listPage
    // height: parent.height
    property int kind: 0
    property string title: i18nc("@title", "Update View")
    Layout.fillWidth: true
    Layout.minimumHeight: 200 
    Kirigami.InlineMessage {
        id: pausedMessage
        Layout.fillWidth: true
        type: Kirigami.MessageType.Warning
        icon.name: "media-playback-paused-symbolic"
        text: i18n("Not searching for updates automatically")
        visible: !main.isNotPaused && !isUpdating
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
        id: managerNotFoundMessage
        Layout.fillWidth: true
        type: Kirigami.MessageType.Information
        icon.name: "dialog-information"
        text: i18n("Flatpak was not found! It is now disabled. ")+"<html><a href=\"https://flathub.org/setup\">Flathub Setup</a></html>"
        onLinkActivated: Qt.openUrlExternally("https://flathub.org/setup")
        visible: main.wasFlatpakDisabled
        showCloseButton: true
        actions: Kirigami.Action {
            text: i18nc("@action:button", "Re-enable")
            onTriggered: {
                main.wasFlatpakDisabled = false
                cfg.useFlatpak = true
            }
        }
    }
    PlasmaComponents.ScrollView {
        id: scrollView
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: !main.isUpdating
        contentItem: ListView {
            id: packageView
            spacing: Kirigami.Units.smallSpacing
            model: filterModel
            currentIndex: -1
            boundsBehavior: Flickable.StopAtBounds
            highlight: PlasmaExtras.Highlight { }
            highlightMoveDuration: 0
            highlightResizeDuration: 0
            delegate: Common.PackageItem {
                showSeparator: index !== 0
                width: packageView.width //- Kirigami.Units.smallSpacing * 4
            }
            Loader {
                anchors.centerIn: parent
                width: parent.width - (Kirigami.Units.largeSpacing * 4)
                active: packageModel.count === 0
                asynchronous: true
                visible: status === Loader.Ready
                sourceComponent: PlasmaExtras.PlaceholderMessage {
                    text: "You are up-to date!"
                    iconName: "checkmark"
                }
            }
        }
    }
    PlasmaComponents.BusyIndicator {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: width / 3
        Layout.bottomMargin: width / 3
        visible: main.isUpdating
    }
}
