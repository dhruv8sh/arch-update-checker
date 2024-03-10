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
  height: 45
  property int pos: 0

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
    // For next release
    // PlasmaComponents.Label {
    //   id: aurLabel
    //   anchors.left: parent.left
    //   anchors.bottom: packagenNameLabel.verticalCenter
    //   height: packagenNameLabel / 2
    //   elide: Text.ElideRight
    //   textFormat: Text.PlainText
    //   text: "AUR"
    // }
    PlasmaComponents.Label {
      id: packagenNameLabel
      height: paintedHeight
      elide: Text.ElideRight
      text: PackageName
      textFormat: Text.PlainText

      anchors {
        bottom: parent.verticalCenter
        left: aurLabel.right
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
      // color: Kirigami.Theme.positiveTextColor
    }
  }
  // Rectangle{
  //   width: parent.width * 0.98
  //   height: 1
  //   anchors.topMargin: 45
  //   color: Kirigami.Theme.disabledTextColor
  //   opacity: 0.3
  // }
}
