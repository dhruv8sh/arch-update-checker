import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls
import "../Pages/" as Pages

Kirigami.ScrollablePage {
    id: root
    property alias cfg_pollInterval    : time.value
    property alias cfg_searchOnExpand  : updateOnExpand.checked
    property alias cfg_searchOnStart   : updateOnStartup.checked
    property alias cfg_terminal        : terminal.text
    property alias cfg_useNotifications: notificationsToggle.checked
    property alias cfg_customScript    : customScript.text
    property alias cfg_useCustomInstall: useCustomScript.checked
    property alias cfg_activeAmount    : activeWhen.value
    property alias cfg_rememberState   : rememberState.checked
    ColumnLayout{
        anchors.fill: parent
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: "Higher value recommended for better battery life!"
            type: Kirigami.MessageType.Warning
            visible: time.value < 11
        }
        Kirigami.FormLayout {
            RowLayout{
                id: time
                Kirigami.FormData.label: i18n("Poll Interval:")
                property int value: plasmoid.configuration.pollinterval
                QQC2.SpinBox {
                    id: hrs
                    from: 0
                    to: 999
                    stepSize: 1
                    value: time.value/60
                    onValueChanged: time.value = mins.value + ( hrs.value * 60 )
                }
                QQC2.Label{
                    text: i18n("Hours :")
                }
                QQC2.SpinBox {
                    id: mins
                    from: 0
                    to: 59
                    stepSize: 5
                    value: time.value % 60
                    onValueChanged: time.value = mins.value + ( hrs.value * 60 )
                }
                QQC2.Label{
                    text: i18n("Minutes")
                }
            }
            Item {
                Kirigami.FormData.isSection: true
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Show in tray when:")
                QQC2.SpinBox {
                    id: activeWhen
                    from: 0
                    to: 2000
                }
                QQC2.Label{ text: i18n("update(s) available.")}
            }
            Item {
                Kirigami.FormData.isSection: true
            }
            QQC2.CheckBox {
                id: updateOnExpand
                Kirigami.FormData.label: i18n("Search on expand:")
            }
            QQC2.CheckBox {
                id: updateOnStartup
                Kirigami.FormData.label: i18n("Search on startup:")
            }
            QQC2.CheckBox {
                id: rememberState
                Kirigami.FormData.label: i18n("Remember if News Page is opened:")
            }
            Item {
                Kirigami.FormData.isSection: true
            }
            QQC2.CheckBox {
                id: notificationsToggle
                Kirigami.FormData.label: i18n("Notifications:")
                text: i18n("Enabled")
            }
            Item {
                Kirigami.FormData.isSection: true
            }
            QQC2.TextField {
                id: terminal
                Kirigami.FormData.label: i18n("Terminal Command:")
                placeholderText: "konsole -e"
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Custom `update system` command:")
                QQC2.CheckBox {
                    id: useCustomScript
                }
                QQC2.TextField {
                    id: customScript
                    placeholderText: i18n("Custom Command")
                    enabled: useCustomScript.checked
                }
            }
        }
    }
}
