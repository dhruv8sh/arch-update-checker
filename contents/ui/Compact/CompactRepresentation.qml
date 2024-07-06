import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../../Util.js" as Util

MouseArea {
    id: compact
    property bool wasExpanded: false
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    hoverEnabled: true
    onPressed: wasExpanded = expanded
    onClicked: mouse => {
        if (mouse.button == Qt.MiddleButton) Util.updateSystem()
        else {
            expanded = !wasExpanded;
            if( expanded && cfg.searchOnExpand )
                Util.searchForUpdates();
            if( !cfg.rememberState )
                main.pop();
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
        id: updateIcon
        source: "update-none"
        active: compact.containsMouse
        color: error === "" ? Kirigami.Theme.textColor : Kirigami.Theme.negativeTextColor
        activeFocusOnTab: true
        anchors.fill: parent
    }
    states:[
        State {
            name: "updating"
            when: isBusy
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
                visible: cfg.showBadgeAlways
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
                text: packageModel.count
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

