import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
  id: itemIcon
  Kirigami.Icon {
      id: itemIconImage
      anchors.fill: parent
      source: "update-none"
  }
  
  Badge {
    id: packageBadge
    visible: plasmoid.configuration.zeroPackageBadge || packageModel.count > 0
    text: packageModel.count
  }

  MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.MiddleButton
      onClicked:  (mouse) => {
          if (mouse.button === Qt.MiddleButton) {
              main.action_updateSystem()
          } else {
              main.expanded = !main.expanded
          }
      }
      cursorShape: Qt.PointingHandCursor
  }

}
