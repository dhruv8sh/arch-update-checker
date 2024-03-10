import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore //Needed for Busy Spinner Widget
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {

    focus: true
    Layout.minimumHeight: 200
    Layout.minimumWidth: 400

    PlasmaExtras.Heading {
        id: heading

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: updateIcon.left
        level: 3
        opacity: 0.6
        text: "Updates " + (pauseUpdateChecks.checked ? "":"(Paused)")
    }

    PlasmaComponents.Switch {
        id: pauseUpdateChecks
        anchors.right: parent.right
        anchors.top: parent.top
        height: Kirigami.Units.iconSizes.medium
        icon.name: checked ? "media-playback-start":"media-playback-pause"
        checked: true
        onCheckedChanged : main.timer.running = checked
    }
    // Component.onCompleted : pauseUpdateChecks.checked = false

    PlasmaComponents.ToolButton {
        id: updateIcon

        anchors.right: pauseUpdateChecks.left
        anchors.top: parent.top
        height: Kirigami.Units.iconSizes.medium
        icon.name: "install"
        onClicked: main.action_updateSystem()
    }

    PlasmaComponents.ToolButton {
        id: checkUpdatesIcon

        anchors.right: updateIcon.left
        anchors.top: parent.top
        height: Kirigami.Units.iconSizes.medium
        icon.name: "view-refresh"
        onClicked: main.action_checkForUpdates()
    }


    Connections {
        target: main
        onUpdatingPackageList: {
            uptodateLabel.visible = false
            busyIndicator.visible = true
        }
        onStoppedUpdating: {
            busyIndicator.visible = false
            uptodateLabel.visible = packageModel.count == 0
        }
    }

    Kirigami.ScrollablePage {
        id: scrollView;
        background: Kirigami.Theme.backgroundColor
        anchors.top: heading.height > updateIcon.height ? heading.bottom : updateIcon.bottom
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
        }
    }
    Text {
        id: uptodateLabel
        text: i18n("You are up to date.")
        anchors.centerIn: parent
        visible: !busyIndicator.visible && packageView.count == 0
        color: Kirigami.Theme.disabledTextColor
    }
    PlasmaComponents.BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        visible: false
    }
}