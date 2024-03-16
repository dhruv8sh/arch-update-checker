import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

Kirigami.ScrollablePage {
    id: root
    property alias cfg_pollinterval: time.value
    property alias cfg_numberAvailable: numbersVisible.checked
    property alias cfg_packageSeparator: packageSeparator.text
    property alias cfg_updateOnExpand: updateOnExpand.checked
    //commands
    property alias cfg_updateCommand: aurWrapper.text
    property alias cfg_flatpakUpdateCommand: flatpakEnabled.upcmd
    //flags
    property alias cfg_aurFlags: aurFlags.text
    property alias cfg_flatpakFlags: flatpakFlags.text
    //flatpak enabled
    property alias cfg_flatpakEnabled: flatpakEnabled.checked

    property alias cfg_customColorsEnabled: customColorsEnabled.checked
    property alias cfg_dotColor: dotColor.color
    property alias cfg_textColor: textColor.color
    property alias cfg_position: position.currentIndex

    Kirigami.FormLayout {
        anchors.fill: parent
        QQC2.ComboBox {
            id: aurWrapper
            property string text: model[currentIndex].text
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
                switch(plasmoid.configuration.updateCheckCommand) {
                    case "yay"   : return 0;
                    case "paru"  : return 1;
                    case "trizen": return 2;
                    case "pikaur": return 3;
                    case "pacaur": return 4;
                    case "aura"  : return 5;
                    default      : return 0;
                }
            }
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
        QQC2.TextField {
            id: packageSeparator
            Kirigami.FormData.label: i18n("Package seperator:")
            placeholderText: i18n("Example: ->, =>, to, etc.")
            text: plasmoid.configuration.packageSeparator
        }
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: "Higher value recommended for better battery life!"
            type: Kirigami.MessageType.Warning
            visible: time.value < 11
        }
        QQC2.SpinBox {
            id: time
            Kirigami.FormData.label: i18n("Poll Interval:")
            from: 1
            to: 100000
            stepSize: 10
            editable: false
            textFromValue: function(value, locale) {
                if( value == 1 ) return qsTr("%1 min").arg(value);
                else return qsTr("%1 mins").arg(value);
            }
        }
        Item {
            Kirigami.FormData.isSection: true
        }
        QQC2.CheckBox {
            id: numbersVisible
            Kirigami.FormData.label: i18n("Badge:")
            text: i18n("Show numbers on badge")
        }
        QQC2.ComboBox {
            id: position
            textRole: "text"
            model: [
                {text:"Top-Left"},
                {text:"Top-Right"},
                {text:"Bottom-Left"},
                {text:"Bottom-Right"}
            ]
            currentIndex : plasmoid.configuration.position
            onCurrentIndexChanged: cfg_position = currentIndex
        }
        Item { Kirigami.FormData.isSection: true }
        QQC2.CheckBox {
            id: customColorsEnabled
            Kirigami.FormData.label: i18n("Colors:")
            checked: true
            text: i18n("Use custom colors")
        }
        KQuickControls.ColorButton {
            id: dotColor
            Kirigami.FormData.label: i18n("Dot Color:")
            visible: customColorsEnabled.checked
        }
        KQuickControls.ColorButton {
            id: textColor
            Kirigami.FormData.label: i18n("Text Color:")
            visible: customColorsEnabled.checked
        }
        Item { Kirigami.FormData.isSection: true }
    }
}
