import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid
import "../_toolbox" as Toolbox
import "../service" as Service

PlasmoidItem {
    id: root
    preferredRepresentation : compactRepresentation
    compactRepresentation : Compact{}
    fullRepresentation : Compact{}

    Service.Updater{ id: updater }
    Service.Checker{ id: checker }
    Toolbox.Cmd{ id: cmd }

    function updateTooltipText(text) {
      toolTipSubText : text
    }



    function action_launchUpdate() {
        updater.launchUpdate()
    }
    Plasmoid.contextualActions: [
      PlasmaCore.Action {
        text: i18nd("launchUpdate","Update")
        icon.name: "preferences-other"
        onTriggered: {
          checker.konsole()
          checker.checkupdates()
        }
      }
    ]
    toolTipMainText:"Packages available to update"
    toolTipSubText:"Arch: 0\tAur: 0"
}
