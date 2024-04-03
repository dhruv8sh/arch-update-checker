import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponent
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.notification
import "./Compact/" as Compact
import "./Full/" as Full

PlasmoidItem {
  id: main
  property string subtext: i18n("Updates")
  property string title: title
  property alias isNotPaused: timer.running
  compactRepresentation: Compact.CompactRepresentation { }
  fullRepresentation:  Intro{}

  ListModel { id: packageModel }
  property bool isUpdating: false
  property bool hasUserSeen: false
  property var details: []
  property string error: ""
  property bool wasFlatpakDisabled: false
  property bool showAllowSingularModifications: false
  property bool showNotification: false
  property string outputText: ''
  signal clearProperties();

  PackageManager{ id: packageManager }

  toolTipMainText: i18n("Arch Update Checker")
  toolTipSubText: i18n("Updates available: "+packageModel.count)
  Plasmoid.status: (packageModel.count > 0 || isUpdating || error !== "") ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus
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
      showNotification = true
      packageManager.action_checkForUpdates()
    }
  }
  Notification {
      id: notif
      componentName: "plasma_workspace"
      eventId: "warning"
      iconName: "update-high"
      title: i18n("Arch Update Checker")
      text: i18n(packageModel.count+" updates available")
  }
  Component.onCompleted : {
    hasUserSeen = false;
    packageManager.action_checkForUpdates()
  }
  Plasmoid.contextualActions: [
      PlasmaCore.Action {
          text: i18n("Update System")
          icon.name: "install-symbolic"
          onTriggered: packageManager.action_updateSystem()
      },
      PlasmaCore.Action {
          text: i18n("Check for Updates")
          icon.name: "view-refresh"
          onTriggered: packageManager.action_checkForUpdates()
      }
    ]
}
