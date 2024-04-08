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
    title: i18nc("@title", "Package Management")
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
                text: i18n("\n\nPackage Management\n\n")
                wrapMode: Text.WordWrap
            }
            Common.CustomSwitch{
                id: flatpakSwitch
                icon: "flatpak-discover"
                text: i18n("Flatpaks")
                checked: plasmoid.configuration.useFlatpak
                onCheckedChanged: plasmoid.configuration.useFlatpak = checked
            }
            RowLayout {
                enabled: flatpakSwitch.checked
                Layout.alignment: Qt.AlignCenter
                QQC2.Label {
                    text: i18n("Flags:")
                    wrapMode: Text.WordWrap
                }
                QQC2.TextField {
                    text: plasmoid.configuration.flatpakFlags
                    onTextChanged : plasmoid.configuration.flatpakFlags = text
                }
            }
            QQC2.Label{}

            Common.CustomComboBox{
                text: "AUR: "
                icon: "package"
                model: [
                    {"text": "yay"},
                    {"text": "paru"},
                    {"text": "trizen"},
                    {"text": "pikaur"},
                    {"text": "pacaur"},
                    {"text": "aura"}
                ];
                function onIndexChanged(newindex){
                    plasmoid.configuration.aurWrapper = model[newindex].text
                }
                index: model.findIndex(item => item.text === plasmoid.configuration.aurWrapper)
            }
            RowLayout {
                Layout.alignment: Qt.AlignCenter
                QQC2.Label {
                    text: i18n("Flags:")
                    wrapMode: Text.WordWrap
                }
                QQC2.TextField {
                    text: plasmoid.configuration.aurFlags
                    onTextChanged : plasmoid.configuration.aurFlags = text
                }
            }
        }
    }
}
