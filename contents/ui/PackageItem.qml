import QtQuick
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

Item {
  id: packageItem
  enabled: true
  width: parent.width
  height: 50
  Item {
    id: packageItemBase
    height: packagenNameLabel.height + fromVersionLabel.height + Math.round(Kirigami.Units.gridUnit / 2)
    PlasmaComponents.Label {
      id: packagenNameLabel
      height: paintedHeight
      elide: Text.ElideRight
      text: PackageName
      textFormat: Text.PlainText

      anchors {
        bottom: parent.verticalCenter
        left: parent.left
        leftMargin: Math.round(Kirigami.Units.gridUnit / 2)
      }

    }
    PlasmaComponents.Label {
      id: fromVersionLabel

      anchors {
        left: parent.left
        leftMargin: Math.round(Kirigami.Units.gridUnit / 2)
        top: packagenNameLabel.bottom
      }

      height: paintedHeight
      elide: Text.ElideRight
      font.pointSize: Kirigami.Theme.smallestFont.pointSize
      opacity: 0.6
      text: FromVersion

    }
    PlasmaComponents.Label {
      id: toVersionLabel

      anchors {
        left: fromVersionLabel.right
        leftMargin: Math.round(Kirigami.Units.gridUnit / 2)
        top: packagenNameLabel.bottom
      }

      height: paintedHeight
      elide: Text.ElideRight
      font.pointSize: Kirigami.Theme.smallestFont.pointSize
      opacity: 0.6
      text: "=> "+ToVersion

    }
  }
  Rectangle{
    width: parent.width * 0.98
    x: parent.width * 0.01
    height: 1
    color: Kirigami.Theme.disabledTextColor
    opacity: 0.3
  }

}
