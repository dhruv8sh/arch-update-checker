import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponent
import org.kde.plasma.plasma5support as Plasma5Support


PlasmoidItem {
  id: main
  property string subtext: i18n("Updates")
  property string title: title
  property bool stillUpdating: false
  toolTipSubText: subtext
  Plasmoid.icon: "package-new"
  compactRepresentation: CompactRepresentation {}
  fullRepresentation: FullRepresentation{ }

  ListModel { id: packageModel }

  signal updatingPackageList()
  signal stoppedUpdating()

  Plasma5Support.DataSource {
    id: "executable"
    engine: "executable"
    connectedSources: []
    onNewData: {
      var exitCode = data["exit code"]
      var exitStatus = data["exit status"]
      var stdout = data["stdout"]
      var stderr = data["stderr"]
      exited(sourceName, exitCode, exitStatus, stdout, stderr)
      disconnectSource(sourceName)
    }
    function exec(cmd) {
        console.log("exec " + cmd)
        connectSource(cmd)
    }
    signal exited(string sourceName, int exitCode, int exitStatus, string stdout, string stderr )
  }

  Item {
    id: config
    property int interval: plasmoid.configuration.pollinterval * 1000 * 60
    property string updateChecker: plasmoid.configuration.updatechecker || "checkupdates"
    property string updateChecker_aur: plasmoid.configuration.updatechecker_aur || "yay -Qua"
    property string updateCommand: plasmoid.configuration.installationcommand || "yay -Syu"

  }
  property string outputText: ''
  function removeANSIEscapeCodes(str) {
    return str.replace(/\u001b\[[0-9;]*[m|K]/g, '');
  }
  Connections {
    target: executable
    onExited: {
      console.log ("onExited " + sourceName);
      console.log ("onExited " + config.updateChecker);
      console.log("onExited " + sourceName);
      console.log("exitCode: " + exitCode);
      console.log("exitStatus: " + exitStatus);
      console.log("stdout: " + stdout);
      console.log("stderr: " + stderr);
      var packagelines = stdout.split("\n")
      packagelines.forEach(line => {
          line = main.removeANSIEscapeCodes(line.trim());
          if( line.startsWith(":: aur") )
            line = line.substring(8);
          const packageDetails = line.split(/\s+/);
          const packageName = packageDetails[0];
          const fromVersion = packageDetails[1];
          const toVersion = packageDetails[3];
          if( packageName.trim() != "" )
          packageModel.append({
              PackageName: packageName,
              FromVersion: fromVersion,
              ToVersion: toVersion
          });
      });

      if( stillUpdating ) main.stoppedUpdating()
      stillUpdating = !stillUpdating
    }
  }
  Timer {
    id: timer
    interval: config.interval
    running: true
    repeat: true
    onTriggered: action_checkForUpdates()
  }
  function action_updateSystem() {
     timer.stop()
     executable.exec('konsole -e "' + plasmoid.configuration.updateCommand + '"')
     packageModel.clear()
     main.stoppedUpdating()
     timer.start()
  }
  function action_checkForUpdates() {
    packageModel.clear()
    main.updatingPackageList()
    executable.exec("checkupdates");
    executable.exec(plasmoid.configuration.updateCheckCommand);
  }
  function onConfigChanged() {
    config.interval = plasmoid.readConfig("pollinterval");
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
