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
                text: i18n("\n\nBehavior\n\n")
                wrapMode: Text.WordWrap
            }
            Common.CustomSwitch {
                icon : "view-refresh"
                checked: true
                text: i18n("Search on startup")
            }
            Common.CustomSwitch {
                icon : "zoom-out-y-symbolic"
                checked: true
                text: i18n("Search on expand")
            }
            RowLayout{
                id: time
                property int value: plasmoid.configuration.pollinterval
                Layout.alignment: Qt.AlignCenter
                Kirigami.Icon {
                    source: "accept_time_event"
                }
                PlasmaExtras.Heading {
                    text: i18n("Interval ")
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
            Kirigami.InlineMessage {
                Layout.fillWidth: true
                text: "Higher value recommended for better battery life!"
                type: Kirigami.MessageType.Warning
                visible: time.value < 11
            }
        }
    }
}
