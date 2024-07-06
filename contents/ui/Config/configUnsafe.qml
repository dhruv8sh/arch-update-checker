import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls
import "../Pages/" as Pages

Kirigami.ScrollablePage {
    id: root
    property alias cfg_debugNormal      : debugNormal.checked
    property alias cfg_debugCommands    : debugCommands.checked
    property alias cfg_showBadgeAlways  : showBadgeAlways.checked
    property alias cfg_allowSingleModification : singleChange.checkState
    ColumnLayout {
        Kirigami.InlineMessage {
            text: i18n("These flags are used to either debug the applet or are experimental!")
            Layout.fillWidth: true
            visible: true
        }
        Kirigami.InlineMessage {
            text: i18n("Features below are currently under maintainance and might not work due to recent major code refactors.")
            type: Kirigami.MessageType.Warning
            Layout.fillWidth: true
            visible: true
        }
        Kirigami.FormLayout {
            QQC2.CheckBox {
                id: debugNormal
                Kirigami.FormData.label: i18n("Debug:")
                text: i18n("Pages and Models")
            }
            QQC2.CheckBox {
                id: debugCommands
                text: i18n("Commands")
            }
            Item {
                Kirigami.FormData.isSection: true
            }
            QQC2.CheckBox {
                Kirigami.FormData.label: i18n("Always Show Badge:")
                id: showBadgeAlways
            }
            Item {
                Kirigami.FormData.isSection: true
            }
            QQC2.CheckBox {
                id: singleChange
                Kirigami.FormData.label: i18n("NOT RECOMMENDED\nUSE AT YOUR OWN RISK\nYou have been warned!:")
                text: i18n("Allow updating/uninstalling single native packages.")
                tristate: true
            }
        }
    }
}
