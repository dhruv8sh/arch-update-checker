import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.workspace.components as WorkspaceComponents


Item {
    id: overlay
    anchors {
        bottom: parent.bottom
        right: parent.right
    }

    property string dotColor: plasmoid.configuration.dotColor == "" ? Kirigami.Theme.textColor : plasmoid.configuration.dotColor;
    property int aurAmount
    property int archAmount
    property bool dotVisible: plasmoid.configuration.dotVisible


    Rectangle {
        visible: dotVisible && updateNeeded()
        height: container.height / 2.5
        width: height
        radius: height / 2
        color: dotColor == "" ? PlasmaCore.Theme.textColor : dotColor
        anchors {
            right: container.right
            bottom: container.bottom
        }
    }
    WorkspaceComponents.BadgeOverlay {
        anchors {
            bottom: parent.bottom
            right: parent.right
        }
        text: (archAmount-0+aurAmount)
        visible: !dotVisible
        icon: dotIcon
    }
}


