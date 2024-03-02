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
  toolTipSubText: subtext
  Plasmoid.icon: "package-new"
  compactRepresentation: CompactRepresentation {}
  fullRepresentation: FullRepresentation{}

  ListModel { id: packageModel }


  Plasma5Support.DataSource {
    id: "executable"
    engine: "executable"
    connectedSources: []
    //property string sourceName: ""
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
    property string updateChecker_aur: plasmoid.configuration.updatechecker_aur || "yay -Squa"
    property string updateCommand: plasmoid.configuration.installationcommand || "pacman -Syu"

  }
  property string outputText: ''
  Connections {
    target: executable
    onExited: {
      console.log ("onExited " + executable.sourceName);
      console.log ("onExited " + config.updateChecker);
      console.log( executable.sourceName === config.updateChecker);
      console.log("onExited " + executable.sourceName);
      console.log("exitCode: " + exitCode);
      console.log("exitStatus: " + exitStatus);
      console.log("stdout: " + stdout);
      console.log("stderr: " + stderr);
      if ( sourceName === config.updateChecker ) {
         //console.log ("Updating model")

         var packagelines = stdout.split("\n")
         if ( packagelines.length > packageModel.count ) {
           //new Packages

         }
         packageModel.clear()
         for ( var i = 0; i < packagelines.length; i++) {
           var packagedetails = packagelines[i].split(" ")
           //console.log ("Appending Package: " + packagedetails[0])
           if ( packagelines[i].trim() != "") {
             packageModel.append( { PackageName: packagedetails[0],
                   FromVersion: packagedetails[1],
                   ToVersion: packagedetails[3],
                 })
           }
         }

      } else if (sourceName === config.updateChecker_aur) {
        var packagelines = stdout.split("\n")
        var pregex;
        if( config.updateChecker_aur.includes('pacaur')  ) {
           pregex = /^\S+\s+\S+\s+(\S+)\s+(\S+)\s+\S+\s+(\S+)/;

        } else if ( config.updateChecker_aur.includes('yay') ) {
          pregex = /^\s\S+\s+(\S+):\s+(\S+)\s+==>\s+(\S+)/;
        }
        
        for ( var i = 0; i < packagelines.length; i++) {
          var packageline = packagelines[i];


          var parameters = pregex.exec(packageline);
          if ( parameters != null) {
            packageModel.append( { PackageName: parameters[1],
                  FromVersion: parameters[2],
                  ToVersion: parameters[3]})
          }
        }
        timer.restart()
      }
    }
  }
  Timer {
    id: timer
    interval: config.interval
    running: true
    repeat: true
    onTriggered: {
      executable.exec(config.updateChecker)
      if (config.updateChecker_aur != null) {
        executable.exec(config.updateChecker_aur)
      }
    }
  }
  function action_updateSystem() {
     timer.stop()
     executable.exec('konsole -e "' + plasmoid.configuration.installationcommand + '"')
     packageModel.clear()
     timer.start()
  }
  function action_checkForUpdates() {
    executable.exec(plasmoid.configuration.updatechecker);
    executable.exec(plasmoid.configuration.updatechecker_aur);    
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
