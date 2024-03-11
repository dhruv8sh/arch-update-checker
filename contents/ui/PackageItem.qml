import QtQuick
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

PlasmaExtras.ExpandableListItem {
  id: packageItem
  enabled: true
  width: scrollView.width
  height: packageItemBase.height
  property int pos: 0

  // showDefaultActionButtonWhenBusy: true
  // defaultActionButtonAction: Action {
  //     id: stateChangeButton
  //     icon.name: "showinfo"
  //     text: i18n("Info")
  // }
  // MouseArea {
  //   hoverEnabled: true
  //   anchors.fill: parent
  //   id: mousearea
  // }
  // PlasmaExtras.Highlight {
  //   id: highlight
  //     anchors.fill: parent
  //     hovered: mousearea.containsMouse
  //     visible: mousearea.containsMouse
  //}
  Item {
    id: packageItemBase
    height: packagenNameLabel.height + fromVersionLabel.height + Math.round(Kirigami.Units.gridUnit / 2)
    anchors.top: parent.top
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
      text: "    "+FromVersion + plasmoid.configuration.packageSeparator + ToVersion
      // color: Kirigami.Theme.negativeTextColor
    }
  }
}
