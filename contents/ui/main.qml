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

  property bool isUpdating: false
  property bool hasUserSeen: false
  property var details: []
  property string error: ""
  property bool wasFlatpakDisabled: false
  property bool showAllowSingleModifications: false
  property bool showNotification: false
  property string outputText: ''
  property var cfg: plasmoid.configuration
  property string sourceList : ""
  property string statusMessage: ""
  property string statusIcon: ""
  property double downloadSize: 0
  signal pop();

  toolTipMainText: i18n("Arch Update Checker")
  toolTipSubText: {
  	if( error !== "" || isUpdating ) return statusMessage;
  	else if( packageModel.count === 0 ) return i18n("No updates available");
  	else if( packageModel.count > 999 ) return i18n("999+ updates available");
	else return i18n(packageModel.count+" updates available");
  }
  Plasmoid.status: (packageModel.count >= cfg.activeAmount || isUpdating || error !== "") ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus
  Item{
    id: config
    property int interval: cfg.pollInterval * 1000 * 60
  }
  Timer {
    id: timer
    interval: config.interval
    running: isNotPaused
    repeat: true
    onTriggered: {
      hasUserSeen = false
      showNotification = true
      Util.action_searchForUpdates()
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
    onTriggered: Util.action_searchForUpdates()
    running: false
    repeat: false
  }
  Component.onCompleted : () => {
    hasUserSeen = false;
    Util.action_notificationInstall()
    if( cfg.searchOnStart ) startupTimer.start()
  }
  Plasmoid.contextualActions: [
      PlasmaCore.Action {
          text: i18n("Update System")
          icon.name: "install-symbolic"
          onTriggered: Util.action_updateSystem()
      },
      PlasmaCore.Action {
          text: i18n("Check for Updates")
          icon.name: "view-refresh"
          onTriggered: Util.action_searchForUpdates()
      }
    ]
}
