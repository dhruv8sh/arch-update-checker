import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    focus: true
    Layout.minimumHeight: 200
    Layout.minimumWidth: 400
    anchors.fill: parent

    RowLayout {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        width: parent.width

        RowLayout {
            spacing: 0

            PlasmaComponents.Switch {
                id: pauseUpdateChecks
                height: Kirigami.Units.iconSizes.medium
                checked: true
                onCheckedChanged : main.requestPause(!checked)
            }
            PlasmaExtras.Heading {
                id: heading
                level: 2
                opacity: 0.6
                text: "Updates" + (pauseUpdateChecks.checked ? "":" Paused")
            }
            PlasmaComponents.Label {
                opacity: 0.6
                text: (packageModel.count == 0 ? "":" ("+packageModel.count+" pending)")
            }
        }
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 0

            PlasmaComponents.ToolButton {
                id: updateIcon
                height: Kirigami.Units.iconSizes.medium
                icon.name: "install"
                onClicked: main.action_updateSystem()
                visible: packageModel.count != 0
            }
            PlasmaComponents.ToolButton {
                id: checkUpdatesIcon
                height: Kirigami.Units.iconSizes.medium
                icon.name: "view-refresh"
                onClicked: main.action_checkForUpdates()
            }
        }
    }
    Rectangle {
        anchors.top: header.bottom
        id: headerSeparator
        width: parent.width
        height: 1
        color: Kirigami.Theme.textColor
        opacity: 0.25
        visible: true
    }
    Connections {
        target: main
        function onUpdatingPackageList() {
            uptodateLabel.visible = false
            busyIndicator.visible = true
        }
        function onStoppedUpdating() {
            busyIndicator.visible = false
            uptodateLabel.visible = packageModel.count == 0
        }
    }
    Kirigami.ScrollablePage {
        id: scrollView;
        background: Rectangle{
            anchors.fill: parent
            color: "transparent"
        }
        anchors.top: headerSeparator.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        ListView {
            id: packageView;
            anchors.rightMargin: Kirigami.Units.gridUnit
            clip: true
            model: packageModel;
            currentIndex: -1;
            boundsBehavior: Flickable.StopAtBounds;
            focus: true
            delegate: PackageItem { pos: index }
            onCountChanged: uptodateLabel.visible = !busyIndicator.visible && count == 0;
        }
    }
    PlasmaExtras.PlaceholderMessage {
        id: uptodateLabel
        text: i18n("You are up to date.")
        iconName: "preferences-system-linux"
        anchors.centerIn: parent
        visible: !busyIndicator.visible && packageView.count == 0
    }
    PlasmaComponents.BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        visible: false
    }
}
