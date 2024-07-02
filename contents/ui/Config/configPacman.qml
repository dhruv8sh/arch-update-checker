import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls
import "../Pages/" as Pages

Kirigami.ScrollablePage {
    id: root
    property alias cfg_useAUR          : useAUR.checked
    property alias cfg_useFlatpak      : useFlatpak.checked
    property alias cfg_aurWrapper      : aurWrapper.value
    property alias cfg_aurFlags        : aurFlags.text
    property alias cfg_flatpakFlags    : flatpakFlags.text

    Kirigami.FormLayout {
        anchors.fill: parent
        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: useAUR
            Kirigami.FormData.label: i18n("AUR:")
            enabled: true
        }
        QQC2.ComboBox {
            id: aurWrapper
            property string value: model[currentIndex].text
            Kirigami.FormData.label: i18n("AUR Wrappers:")
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
            Kirigami.FormData.label: i18n("PACMAN/AUR Flags:")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: useFlatpak
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
            onTextChanged: useFlatpak.update()
        }
    }
}
