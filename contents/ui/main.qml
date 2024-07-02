import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponent
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.notification
import "../Util.js" as Util
import "./Compact/" as Compact

PlasmoidItem {
  id: main
  property string subtext: i18n("Updates")
  property string title: title
  property bool isNotPaused: true
  compactRepresentation: Compact.CompactRepresentation { }
  fullRepresentation:  Full{}

  ListModel { id: packageModel }
  PackageManager{ id: packageManager }

  property bool isBusy: false
  property bool hasUserSeen: false
  property string error: ""
  property bool showAllowSingleModifications: false
  property bool showNotification: false
  property bool missingDependency: false
  property var cfg: plasmoid.configuration
  property string statusMessage: ""
  property string statusIcon: ""
  property double downloadSize: 0
  signal pop();

  toolTipMainText: i18n("Arch Update Checker")
  toolTipSubText: statusMessage
  Plasmoid.status: (packageModel.count >= cfg.activeAmount || isBusy || error !== "") ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus
  Timer {
    id: timer
    interval: cfg.pollInterval * 1000 * 60
    running: isNotPaused
    repeat: true
    onTriggered: {
      hasUserSeen = false
      showNotification = true
      Util.commands["checkUpdates"].run()
    }
  }
  Notification {
      id: notif
      componentName: "archupdatechecker"
      eventId: "sound"
      title: {
        let diff = packageModel.count - cfg.lastCount;
        if( diff > 0 ) return "+"+diff+" new updates available! \n Total: "+packageModel.count;
        else return packageModel.count + " updates available!"
      }
  }
  Timer {
    id: startupTimer
    interval: 5000
    onTriggered: if(!missingDependency) Util.commands["checkUpdates"].run()
    running: false
    repeat: false
  }
  Component.onCompleted : () => {
    hasUserSeen = false;
    Util.notificationInstall()
    Util.checkDependency("pacinfo")
    Util.checkDependency("checkupdates")
    if( cfg.searchOnStart ) startupTimer.start()
  }
  Plasmoid.contextualActions: [
      PlasmaCore.Action {
          text: i18n("Update System")
          icon.name: "install-symbolic"
          onTriggered: Util.updateSystem()
      },
      PlasmaCore.Action {
          text: i18n("Check for Updates")
          icon.name: "view-refresh"
          onTriggered: Util.commands["checkUpdates"].run()
      }
    ]
}
