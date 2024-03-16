 
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kitemmodels as KItemModels

ColumnLayout {
    id: listPage
    spacing: Kirigami.Units.smallSpacing * 2
    required property KItemModels.KSortFilterProxyModel filteredModel
    Kirigami.InlineMessage {
        id: pausedMessage
        Layout.fillWidth: true
        Layout.leftMargin: packageView.leftMargin
        Layout.rightMargin: packageView.rightMargin
        Layout.topMargin: Kirigami.Units.smallSpacing * 2
        Layout.preferredHeight: contentItem.implicitHeight + topPadding + bottomPadding
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
        id: errorMessage
        Layout.fillWidth: true
        Layout.leftMargin: packageView.leftMargin
        Layout.rightMargin: packageView.rightMargin
        Layout.topMargin: Kirigami.Units.smallSpacing * 2
        Layout.preferredHeight: contentItem.implicitHeight + topPadding + bottomPadding
        type: Kirigami.MessageType.Error
        icon.name: "data-error"
        text: main.error
        visible: main.error != ""
        actions: Kirigami.Action {
            text: i18nc("@action:button", "Clear")
            onTriggered: main.error = ""
        }
    }
    Kirigami.InlineMessage {
        id: flatpakNotFoundMessage
        Layout.fillWidth: true
        Layout.leftMargin: packageView.leftMargin
        Layout.rightMargin: packageView.rightMargin
        Layout.topMargin: Kirigami.Units.smallSpacing * 2
        Layout.preferredHeight: contentItem.implicitHeight + topPadding + bottomPadding
        type: Kirigami.MessageType.Information
        icon.name: "dialog-information"
        text: i18n("Flatpak was not found! It is now disabled.")
        onLinkActivated: Qt.openUrlExternally("https://flathub.org/setup")
        visible: main.wasFlatpakDisabled
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
        contentWidth: availableWidth - contentItem.leftMargin - contentItem.rightMargin
        contentItem: ListView {
            id: packageView
            topMargin: pausedMessage.visible ? 0 : Kirigami.Units.smallSpacing * 2
            bottomMargin: Kirigami.Units.smallSpacing * 2
            leftMargin: Kirigami.Units.smallSpacing * 2
            rightMargin: Kirigami.Units.smallSpacing * 2
            spacing: Kirigami.Units.smallSpacing
            model: filteredModel
            currentIndex: -1
            boundsBehavior: Flickable.StopAtBounds
            highlight: PlasmaExtras.Highlight { }
            highlightMoveDuration: 0
            highlightResizeDuration: 0
            delegate: PackageItem {
                showSeparator: index !== 0
                width: packageView.width - Kirigami.Units.smallSpacing * 4
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
