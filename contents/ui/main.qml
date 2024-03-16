import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponent
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.notification

PlasmoidItem {
  id: main
  property string subtext: i18n("Updates")
  property string title: title
  property alias isNotPaused: timer.running
  Plasmoid.icon: "package-new"
  preferredRepresentation: compactRepresentation
  compactRepresentation: CompactRepresentation { }
  fullRepresentation: FullRepresentation{ }
  ListModel { id: packageModel }
  signal updatingPackageList()
  signal stoppedUpdating()
  signal requestPause(bool pause)
  property bool isUpdating: false
  property bool hasUserSeen: false
  property var details
  property string error: ""
  property bool wasFlatpakDisabled: false

  PackageManager{ id: packageManager }

  toolTipMainText: i18n("Arch Update Checker")
  toolTipSubText: i18n("Updates available: "+packageModel.count)
  Plasmoid.status: (packageModel > 0 || isUpdating || error !== "") ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus

  property string outputText: ''
  Item{
    id: config
    property int interval: plasmoid.configuration.pollinterval * 1000 * 60
  }
  Timer {
    id: timer
    interval: config.interval
    running: true
    repeat: true
    onTriggered: {
      hasUserSeen = false
      packageManager.action_checkForUpdates()
    }
  }
  // Notification {
  //     id: notification
  //     componentName: "archupdatechecker"
  //     eventId: "popup"
  //     title: "Arch Update Checker"
  //     text: packageModel.count + "updates available!"
  //     iconName: "update-high"
  // }
  Component.onCompleted : {
    hasUserSeen = false;
    packageManager.action_checkForUpdates()
  }
  Plasmoid.contextualActions: [
      PlasmaCore.Action {
          text: i18n("Update System")
          icon.name: "install-symbolic"
          onTriggered: action_updateSystem()
      },
      PlasmaCore.Action {
          text: i18n("Check for Updates")
          icon.name: "view-refresh"
          onTriggered: action_checkForUpdates()
      }
    ]
}
