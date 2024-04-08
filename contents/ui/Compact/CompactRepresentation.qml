import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Kirigami.Icon {
    property PlasmoidItem plasmoidItem
    source: "update-none"
    active: mouseArea.containsMouse
    activeFocusOnTab: true
    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Space:
        case Qt.Key_Enter:
        case Qt.Key_Return:
        case Qt.Key_Select:
            Plasmoid.activated();
            event.accepted = true;
            break;
        }
    }
    MouseArea {
        id: mouseArea
        property bool wasExpanded: false
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        anchors.fill: parent
        hoverEnabled: true
        onPressed: wasExpanded = expanded
        onClicked: mouse => {
            if (mouse.button == Qt.MiddleButton) packageManager.action_updateSystem()
            else {
                expanded = !wasExpanded;
                if( expanded && plasmoid.configuration.searchOnExpand && main.hasUserSeen )
                    packageManager.action_checkForUpdates();
                main.hasUserSeen = true
            }
        }
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

