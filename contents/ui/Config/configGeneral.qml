import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls
import "../Pages/" as Pages

Kirigami.ScrollablePage {
    id: root
    property alias cfg_pollinterval: time.value
    property alias cfg_updateOnExpand: updateOnExpand.checked
    //commands
    property alias cfg_aurWrapper: aurWrapper.value
    //flags
    property alias cfg_aurFlags: aurFlags.text
    property alias cfg_flatpakFlags: flatpakFlags.text
    //flatpak enabled
    property alias cfg_flatpakEnabled: flatpakEnabled.checked
    property alias cfg_holdKonsole: holdKonsole.checked
    property alias cfg_allowSingularModifications: allowSingularModifications.value
    property alias cfg_terminal: terminal.value
    property alias cfg_updateOnStartup: updateOnStartup.checked

    Kirigami.FormLayout {
        anchors.fill: parent
        QQC2.ComboBox {
            id: aurWrapper
            property string value: model[currentIndex].text
            Kirigami.FormData.label: i18n("AUR Wrapper:")
            textRole: "text"
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
        QQC2.TextField {
            id: aurFlags
            Kirigami.FormData.label: i18n("AUR Flags:")
        }
        QQC2.CheckBox {
            id: flatpakEnabled
            property string upcmd
            Kirigami.FormData.label: i18n("Flatpak:")
            enabled: true
            onCheckedChanged: update()
            function update() {
                if( checked ) upcmd = "flatpak update "+flatpakFlags.text
                else upcmd = ""
            }
        }
        QQC2.TextField {
            id: flatpakFlags
            Kirigami.FormData.label: i18n("Flatpak flags:")
            onTextChanged: flatpakEnabled.update()
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
        QQC2.ComboBox {
            id: terminal
            property string value: model[currentIndex].text
            Kirigami.FormData.label: i18n("Terminal:")
            textRole: "text"
            model: [
                {text: "konsole"},
                {text: "alacritty"}
            ];
            currentIndex: {
                switch(plasmoid.configuration.terminal) {
                    case "konsole"   : return 0;
                    case "alacritty" : return 1;
                    default      : return 0;
                }
            }
            onCurrentIndexChanged: value = model[currentIndex].text
        }
        QQC2.CheckBox {
            id: holdKonsole
            Kirigami.FormData.label: i18n("Do not close terminal:")
            text: i18n("After update")
        }
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: "Higher value recommended for better battery life!"
            type: Kirigami.MessageType.Warning
            visible: time.value < 11
        }
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
        Item { Kirigami.FormData.isSection: true }
        QQC2.CheckBox {
            id: allowSingularModifications
            property int value: 0
            Kirigami.FormData.label: i18n("USE AT YOUR OWN RISK\n(Risk of system breakage!):")
            text: i18n("Allow modification of singlular native packages")
            checked: value == 2
            onCheckedChanged: value = checked ? 2 : 1
        }
    }
}
