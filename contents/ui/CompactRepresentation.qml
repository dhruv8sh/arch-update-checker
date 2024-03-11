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
        visible: false
        anchors.fill: parent
    }
  Connections {
    target: main
    function onUpdatingPackageList() {
        packageBadge.visible = false
        busyIndicator2.visible = true
    }
    function onStoppedUpdating() {
        packageBadge.visible = packageModel.count !== 0
        busyIndicator2.visible = false
    }
  }
  MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.MiddleButton
      onClicked:  (mouse) => {
          if (mouse.button === Qt.MiddleButton) {
              main.action_updateSystem()
          } else {
              main.expanded = !main.expanded
              if( main.expanded && plasmoid.configuration.updateOnExpand )
                  main.action_checkForUpdates();
          }
      }
      cursorShape: Qt.PointingHandCursor
  }
}
