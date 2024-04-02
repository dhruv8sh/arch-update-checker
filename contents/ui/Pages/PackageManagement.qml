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
                checked: true
            }
            RowLayout {
                Layout.alignment: Qt.AlignCenter
                QQC2.Label {
                    text: i18n("Flags:")
                    wrapMode: Text.WordWrap
                }
                QQC2.TextField {
                    visible: flatpakSwitch.checked
                    text: "--assumeyes"
                }
            }
            QQC2.Label{}
            Common.CustomSwitch{
                id: aurSwitch
                icon: "package"
                text: i18n("AUR")
                checked: true
            }
            QQC2.ComboBox {
                property string value: model[currentIndex].text
                Layout.alignment: Qt.AlignCenter
                textRole: "text"
                enabled: aurSwitch.checked
                model: [
                    {text: "yay"},
                    {text: "paru"},
                    {text: "trizen"},
                    {text: "pikaur"},
                    {text: "pacaur"},
                    {text: "aura"}
                ];
                currentIndex: {
                    switch(plasmoid.configuration.aurWrapper) {
                        case "yay"   : return 0;
                        case "paru"  : return 1;
                        case "trizen": return 2;
                        case "pikaur": return 3;
                        case "pacaur": return 4;
                        case "aura"  : return 5;
                        default      : return 0;
                    }
                }
                onCurrentIndexChanged: value = model[currentIndex].text
            }

            RowLayout {
                Layout.alignment: Qt.AlignCenter
                QQC2.Label {
                    text: i18n("Flags:")
                    wrapMode: Text.WordWrap
                }
                QQC2.TextField {
                    enabled: flatpakSwitch.checked
                    text: "--noconfirm"
                }
            }
        }
    }
}
