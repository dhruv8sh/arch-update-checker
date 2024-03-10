import QtQuick
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

Item {
  id: packageItem
  enabled: true
  width: parent.width
  height: packageItemBase.height
  property int pos: 0

  MouseArea {
    anchors.fill: parent
  }

  KSvg.SvgItem {
      id: separatorLine
      anchors {
          horizontalCenter: parent.horizontalCenter
          top: parent.top
          topMargin: Kirigami.Units.smallSpacing
      }
      imagePath: "widgets/line"
      elementId: "horizontal-line"
      width: parent.width - Kirigami.Units.gridUnit
      visible: pos != 0
  }
  Item {
    id: packageItemBase
    height: packagenNameLabel.height + fromVersionLabel.height + Math.round(Kirigami.Units.gridUnit / 2)
    anchors.top: separatorLine.bottom
    PlasmaComponents.Label {
      id: packagenNameLabel
      height: paintedHeight
      elide: Text.ElideRight
      textFormat: Text.RichText
      text: ( IsAUR ? "<sup><b>AUR</b></sup>   ":"" ) + PackageName
      anchors {
        bottom: parent.verticalCenter
        left: parent.left
        leftMargin: Math.round(Kirigami.Units.gridUnit / 2)
      }
    }
    PlasmaComponents.Label {
      id: fromVersionLabel

      anchors {
        leftMargin: Kirigami.Units.gridUnit
        top: packagenNameLabel.bottom
      }

      height: paintedHeight
      elide: Text.ElideRight
      font.pointSize: Kirigami.Theme.smallFont.pointSize
      opacity: 0.6
      text: "    "+FromVersion
      // color: Kirigami.Theme.negativeTextColor
    }

    PlasmaComponents.Label {
      id: arrow
      anchors {
        left: fromVersionLabel.right
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
        top: packagenNameLabel.bottom
      }
      height: paintedHeight
      elide: Text.ElideRight
      font.pointSize: Kirigami.Theme.smallFont.pointSize
      opacity: 0.6
      text: ToVersion
    }
  }
}
