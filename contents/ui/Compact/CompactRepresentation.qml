import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

MouseArea {
    id: mouseArea
    property bool wasExpanded: false
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    hoverEnabled: true
    onPressed: wasExpanded = expanded
    onClicked: mouse => {
        if (mouse.button == Qt.MiddleButton) packageManager.action_updateSystem()
        else {
            expanded = !wasExpanded;
            if( expanded && plasmoid.configuration.searchOnExpand && main.hasUserSeen )
                packageManager.action_checkForUpdates();
            if( !plasmoid.configuration.rememberState )
                main.pop();
            main.hasUserSeen = true
        }
    }
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
    Kirigami.Icon {
        source: "update-none"
        active: mouseArea.containsMouse
        activeFocusOnTab: true
        anchors.fill: parent
    }
    states:[
        State {
            name: "updating"
            when: isUpdating
            PropertyChanges{
                target: badge
                visible: false
            }PropertyChanges{
                target: busyInd
                visible: true
            }
        },
        State {
            name: "noUpdates"
            when: packageModel.count == 0
            PropertyChanges{
                target: badge
                visible: plasmoid.configuration.showBadgeAlways
            }PropertyChanges{
                target: busyInd
                visible: false
            }
        },
        State{
            name: "manyUpdates"
            when: packageModel.count > 999
            PropertyChanges{
                target: badge
                visible: true
                text: "∞"
            }
            PropertyChanges{
                target: busyInd
                visible: false
            }
        },
        State {
            name: "someUpdates"
            when: packageModel.count != 0
            PropertyChanges{
                target: badge
                visible: true
                text: 999//packageModel.count
            }
            PropertyChanges{
                target: busyInd
                visible: false
            }
        }
    ]








    Badge { id: badge}
    PlasmaComponents.BusyIndicator {
        id: busyInd
        anchors.centerIn: parent
        anchors.fill: parent
    }
}

