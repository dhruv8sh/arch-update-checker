import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

Kirigami.ScrollablePage {

  id: intervalConfigPage

  property alias cfg_updateInterval: updateIntervalSpin.value
  property alias cfg_debugMode: debugModeBox.checked
  property alias cfg_notCloseCommand: notCloseBox.checked

  property alias cfg_updateCommand: updateCommandInput.text
  property alias cfg_countArchCommand: countArchCommandInput.text
  property alias cfg_countAurCommand: countAurCommandInput.text

  property alias cfg_dotVisible: dot.checked
  property alias cfg_dotColor: dotColor.color

  ColumnLayout {

    anchors {
      left: parent.left
      top: parent.top
      right: parent.right
    }

    Kirigami.InlineMessage {
      Layout.fillWidth: true
      text: "You must have the <a href=\"https://archlinux.org/packages/extra/x86_64/konsole/\">konsole</a> package installed for this widget to work."
      onLinkActivated: Qt.openUrlExternally(link)
      type: Kirigami.MessageType.Warning
      visible: !plasmoid.configuration.konsoleIsValid
    }

    Kirigami.InlineMessage {
      Layout.fillWidth: true
      text: "You must have the <a href=\"https://archlinux.org/packages/extra/x86_64/pacman-contrib/\">pacman-contrib</a> package installed for this widget to work."
      onLinkActivated: Qt.openUrlExternally(link)
      type: Kirigami.MessageType.Warning
      visible: !plasmoid.configuration.checkupdateIsValid
    }

    Kirigami.InlineMessage {
      Layout.fillWidth: true
      text: "This option enable log for each cmd exec by the plugin. (regex: ARCHUPDATE)"
      visible: debugModeBox.checked
    }

    Kirigami.FormLayout {
      wideMode: false

      Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "General"
      }
    }

    Kirigami.FormLayout {

      Controls.SpinBox {
        id: updateIntervalSpin
        Kirigami.FormData.label: "Update every: "
        from: 1
        to: 1440 // 1 day
        editable: true
        textFromValue: (value) => value + " minute(s)"
        valueFromText: (text) => parseInt(text)
      }

      Controls.CheckBox {
        id: notCloseBox
        Kirigami.FormData.label: "Do not close the terminal at the end: "
        checked: false
      }

      Controls.CheckBox {
        id: debugModeBox
        Kirigami.FormData.label: "Debug: "
        checked: false
      }

    }
 
   Kirigami.FormLayout {
      wideMode: false

      Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Command"
      }
    }

    Kirigami.InlineMessage {
      Layout.fillWidth: true
      text: "Replace yay by paru or with the AUR helper of your choice.\n checkupdates is recommanded for the db sync."
      visible: true
    }

    Kirigami.FormLayout {
      wideMode: false

      Controls.TextField {
        id: countArchCommandInput
        Kirigami.FormData.label: "Count ARCH command: "     
      }
 
      Controls.TextField {
        id: countAurCommandInput
        Kirigami.FormData.label: "Count AUR command: "     
      }

      Controls.TextField {
        id: updateCommandInput
        Kirigami.FormData.label: "Update command: "     
      }

    }

    Kirigami.FormLayout {
      wideMode: false

      Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Display"
      }
    }

    Kirigami.InlineMessage {
      Layout.fillWidth: true
      text: "The dot is shown only if update is needed.\nThis is the recommended option if you want to use the widget in your system tray or if you tend to have a lot of update that the label can't handle."
      visible: true
    }

    Kirigami.FormLayout {
      Controls.CheckBox {
        id: dot
        Kirigami.FormData.label: "Show a dot in place of the label: "
        checked: false
      }

      RowLayout {
        Kirigami.FormData.label: "Custom dot color: "
        visible: dot.checked
        Controls.CheckBox {
          id: dotUseCustomColor
          checked: false
        }

        KQuickControls.ColorButton {
          id: dotColor
          enabled: dotUseCustomColor.checked
        }
      }

    }

    Kirigami.FormLayout {
      wideMode: false

      Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Label display"
      }
    }

    Kirigami.InlineMessage {
      Layout.fillWidth: true
      text: "Expected result: arch + seprator + aur"
      visible: true
    }

    Kirigami.FormLayout {
      Controls.CheckBox {
        id: separateResult
        Kirigami.FormData.label: "Separate result: "
        checked: false
      }
 
      Controls.TextField {
        id: separator
        Kirigami.FormData.label: "Separator: "
        visible: separateResult.checked
      }

    }



  }

}
