import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents

MouseArea {
    id: itemIcon
    property bool wasExpanded
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    onPressed: wasExpanded = expanded
    onClicked:  (mouse) => {
        if (mouse.button === Qt.MiddleButton) {
            packageManager.action_updateSystem()
        } else {
            expanded = !wasExpanded;
            if( expanded && plasmoid.configuration.updateOnExpand && main.hasUserSeen )
                packageManager.action_checkForUpdates();
            main.hasUserSeen = true
        }
    }
    Kirigami.Icon {
        id: itemIconImage
        anchors.fill: parent
        source: "update-none"
    }

    Badge {
        id: packageBadge
        visible: packageModel.count > 0
        text: packageModel.count
    }

    PlasmaComponents.BusyIndicator {
        id: busyIndicator2
        anchors.centerIn: parent
        visible: main.isUpdating
        anchors.fill: parent
    }
}
