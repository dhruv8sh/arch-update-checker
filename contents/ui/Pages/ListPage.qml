import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kitemmodels as KItemModels
import "../Full/" as Full

Kirigami.Page {
    id: listPage2
    ColumnLayout{
        spacing: Kirigami.Units.smallSpacing * 2
        Layout.fillWidth: true
        anchors{
            topMargin: Kirigami.Units.smallSpacing * 2
            bottomMargin: anchors.topMargin
            leftMargin: anchors.topMargin
            rightMargin: anchors.topMargin
        }
        Kirigami.InlineMessage {
            id: pausedMessage
            Layout.fillWidth: true
            type: Kirigami.MessageType.Warning
            icon.name: "media-playback-paused-symbolic"
            text: i18n("Not searching for updates automatically")
            visible: !main.isNotPaused
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
            text: i18n("Updating single packages is blocked by default due HIGH RISK OF SYSTEM BREAKAGE.\nDo you want to enable this?")
            visible: main.showAllowSingularModifications
            showCloseButton: true
            actions: [
                Kirigami.Action {
                    text: i18nc("@action:button", "Allow")
                    onTriggered: plasmoid.configuration.allowSingularModifications = 2
                },
                Kirigami.Action {
                    text: i18nc("@action:button", "Don' Allow")
                    onTriggered: plasmoid.configuration.allowSingularModifications = 1
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
            showCloseButton: true
        }
        Kirigami.InlineMessage {
            id: managerNotFoundMessage
            Layout.fillWidth: true
            type: Kirigami.MessageType.Information
            icon.name: "dialog-information"
            text: i18n("Flatpak was not found! It is now disabled.")
            onLinkActivated: Qt.openUrlExternally("https://flathub.org/setup")
            visible: main.wasFlatpakDisabled
            showCloseButton: true
            actions: Kirigami.Action {
                text: i18nc("@action:button", "Re-enable")
                onTriggered: {
                    main.wasFlatpakDisabled = false
                    plasmoid.configuration.flatpakEnabled = true
                }
            }
        }
        PlasmaComponents.ScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !main.isUpdating
            // contentWidth: availableWidth - contentItem.leftMargin - contentItem.rightMargin
            contentItem: ListView {
                id: packageView
                spacing: Kirigami.Units.smallSpacing
                model: fullIntro.filteredModel
                Layout.fillWidth: true
                currentIndex: -1
                boundsBehavior: Flickable.StopAtBounds
                highlight: PlasmaExtras.Highlight { }
                highlightMoveDuration: 0
                highlightResizeDuration: 0
                delegate: Full.PackageItem {
                    showSeparator: index !== 0
                    // width: packageView.width - Kirigami.Units.smallSpacing * 4
                    Layout.fillWidth: true
                }

                // Placeholder message
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
            visible: main.isUpdating
        }
    }
}
