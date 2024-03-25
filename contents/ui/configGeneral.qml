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
    property alias cfg_aurWrapper: aurWrapper.value
    //flags
    property alias cfg_aurFlags: aurFlags.text
    property alias cfg_flatpakFlags: flatpakFlags.text
    //flatpak enabled
    property alias cfg_flatpakEnabled: flatpakEnabled.checked

    property alias cfg_customColorsEnabled: customColorsEnabled.checked
    property alias cfg_dotColor: dotColor.color
    property alias cfg_textColor: textColor.color
    property alias cfg_position: position.currentIndex

    property alias cfg_holdKonsole: holdKonsole.checked
    property alias cfg_allowSingularModifications: allowSingularModifications.value

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
            id: holdKonsole
            Kirigami.FormData.label: i18n("Do not close konsole:")
            text: i18n("After update")
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
                onValueChanged: time.value = mins.value + ( value * 60 )
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
                onValueChanged: time.value = value + ( hrs.value * 60 )
            }
            QQC2.Label{
                text: i18n("Minutes")
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
