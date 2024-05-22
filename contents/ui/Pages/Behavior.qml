import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "../Common/" as Common

Kirigami.Page {
    id: welcomePage
    property int kind: 1
    readonly property int margins: Kirigami.Units.gridUnit
    title: i18nc("@title", "Behavior")
    topPadding: 0
    leftPadding: margins
    rightPadding: margins
    bottomPadding: margins
    header: Item {
        anchors{
            topMargin: Kirigami.Units.smallSpacing * 2
            bottomMargin: anchors.topMargin
            leftMargin: anchors.topMargin
            rightMargin: anchors.topMargin
        }
        ColumnLayout {
            anchors.fill: parent

            PlasmaExtras.Heading {
                Layout.alignment: Qt.AlignCenter
                text: i18n("\nBehavior\n")
                wrapMode: Text.WordWrap
            }
            Kirigami.InlineMessage {
                Layout.fillWidth: true
                text: "Higher value recommended for better battery life!"
                type: Kirigami.MessageType.Warning
                visible: time.value < 11
            }
            RowLayout{
                id: time
                property int value: cfg.pollInterval
                Layout.alignment: Qt.AlignCenter
                Kirigami.Icon {
                    source: "accept_time_event"
                }
                PlasmaExtras.Heading {
                    text: i18n("Search Interval ")
                    wrapMode: Text.WordWrap
                    level: 2
                }
                QQC2.SpinBox {
                    id: hrs
                    from: 0
                    to: 999
                    stepSize: 1
                    value: time.value/60
                    onValueChanged: time.value = mins.value + ( hrs.value * 60 )
                }
                QQC2.Label{
                    text: i18n("h:")
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
                    text: i18n("m")
                }
            }
            Common.CustomSwitch {
                icon : "view-refresh"
                checked: cfg.searchOnStart
                onCheckedChanged: cfg.searchOnStart = checked
                text: i18n("Search on startup")
            }
            Common.CustomSwitch {
                icon : "zoom-out-y-symbolic"
                text: i18n("Search on expand")
                checked: cfg.searchOnExpand
                onCheckedChanged: cfg.searchOnExpand = checked
            }
            QQC2.Label{}
            Common.CustomComboBox{
                text: "Terminal: "
                icon: "akonadiconsole"
                model: [
                    {text: "konsole"},
                    {text: "alacritty"},
                    {text: "kitty"}
                ];
                function onIndexChanged(newindex){
                    cfg.terminal = model[newindex].text
                }
                index: model.findIndex(item => item.text === cfg.terminal)
            }
            Common.CustomSwitch {
                icon : "project-development-close"
                text: i18n("Close after update")
                checked: cfg.holdTerminal
                onCheckedChanged: cfg.holdTerminal = checked
            }
        }
    }
}
