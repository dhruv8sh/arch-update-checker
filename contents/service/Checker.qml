import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid

Item {

  function konsole() {
    cmd.exec("konsole -v")
  }

  function checkupdates() {
    cmd.exec("checkupdates --version")
  }

  function validateKonsole(stderr) {
    plasmoid.configuration.konsoleIsValid = stderr === ''
    if (stderr !== '') cmd.exec("kdialog --passivepopup 'Missing dependency (konsole) for arch update plasmoid'")
  }

  function validateCheckupdates(stderr) {
    plasmoid.configuration.checkupdateIsValid = stderr === ''
    if (stderr !== '') cmd.exec("kdialog --passivepopup 'Missing dependency (pacman-contrib) for arch update plasmoid'")
  }

}
