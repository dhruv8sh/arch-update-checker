import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents

Item {
    id: pacmanPage

    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_updatechecker: updatechecker.text
    property alias cfg_updatechecker_aur: updatechecker_aur.text
    property alias cfg_installationcommand: installationcommand.text

    GridLayout {
        columns: 2
        anchors.left: parent.left

        Layout.fillWidth: true

        Label {
            id: label_updatechecker
            text: i18n("Update Checker: ")
            //text: "UPDATE CHECKER: "
        }

        TextField {
            id: updatechecker
            focus: true
            text: plasmoid.configuration.updatechecker
            Layout.fillWidth: true
            Layout.preferredWidth: 400
            
        }

        Label {
           text: i18n("Update Checker AUR: ")

        }
        TextField {
          id: updatechecker_aur
          text: plasmoid.configuration.updatechecker_aur
          Layout.fillWidth: true
          Layout.preferredWidth: 400
        }

        Label {
          text: i18n("Installation Command: ")
        }

        TextField {
          id: installationcommand
          text: plasmoid.configuration.installationcommand
          Layout.fillWidth: true
          Layout.preferredWidth: 400
        }

    }
    Component.onCompleted: {
      console.log("loaded configPacman.qml");
      
    }
}
