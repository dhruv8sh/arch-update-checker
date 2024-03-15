import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents

Item {
    id: itemIcon
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
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked:  (mouse) => {
            if (mouse.button === Qt.MiddleButton) {
                packageManager.action_updateSystem()
            } else {
                main.expanded = !main.expanded
                if( main.expanded && plasmoid.configuration.updateOnExpand && main.hasUserSeen )
                    packageManager.action_checkForUpdates();
                main.hasUserSeen = true
            }
        }
        cursorShape: Qt.PointingHandCursor
    }
}
