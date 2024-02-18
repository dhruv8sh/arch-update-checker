import QtQuick
import QtQuick.Controls
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
      font.pointSize: Kirigami.Theme.smallFont.pointSize
      opacity: 0.6
      text: FromVersion
      // color: Kirigami.Theme.negativeText
    }

    PlasmaComponents.Label {
      id: arrow
      anchors {
        left: fromVersionLabel.right
        leftMargin: Math.round(Kirigami.Units.gridUnit / 2)
        top: packagenNameLabel.bottom
      }
      height: paintedHeight
      elide: Text.ElideRight
      font.pointSize: Kirigami.Theme.smallFont.pointSize
      opacity: 0.6
      text: plasmoid.configuration.packageSeparator
    }
    PlasmaComponents.Label {
      id: toVersionLabel

      anchors {
        left: arrow.right
        leftMargin: Math.round(Kirigami.Units.gridUnit / 2)
        top: packagenNameLabel.bottom
      }
      height: paintedHeight
      elide: Text.ElideRight
      font.pointSize: Kirigami.Theme.smallFont.pointSize
      opacity: 0.6
      text: ToVersion
      // color: Kirigami.Theme.positiveText
    }
  }
  Rectangle{
    width: parent.width * 0.98
    height: 1
    color: Kirigami.Theme.disabledTextColor
    opacity: 0.3
  }

}
