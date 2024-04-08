import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls
import "../Pages/" as Pages

Kirigami.ScrollablePage {
    id: root
    ColumnLayout {
        Kirigami.InlineMessage {
            text: i18n("These flags are used to either debug the application or are experimental!")
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
                id: allowSingleModification
                Kirigami.FormData.label: i18n("NOT RECOMMENDED\nUSE AT YOUR OWN RISK\nYou have been warned!:")
                text: i18n("Allow updating/uninstalling single native packages.")
            }
        }
    }
}
