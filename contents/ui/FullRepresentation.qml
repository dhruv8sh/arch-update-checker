import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {

    focus: true

    PlasmaExtras.Heading {
        id: heading

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: updateIcon.left
        level: 3
        opacity: 0.6
        text: main.subtext
    }

    PlasmaComponents.ToolButton {
        id: updateIcon

        anchors.right: parent.right
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
        RotationAnimation on rotation {
            id: rotationAnim
            from: 0
            to: 360
            duration: Kirigami.Units.humanMoment
            running: false
        }
        onClicked: {
            rotationAnim.running = false;
            main.action_checkForUpdates()
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
            delegate: PackageItem {}

        }
    }
}
