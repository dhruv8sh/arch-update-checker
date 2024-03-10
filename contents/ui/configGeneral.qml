import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

QQC2.Pane {
    id: root
    property alias cfg_pollinterval: time.value
    property alias cfg_numberAvailable: numbersVisible.checked
    property alias cfg_packageSeparator: packageSeparator.text
    property alias cfg_updateOnExpand: updateOnExpand.checked
    property alias cfg_updateCommand: aurWrapper.upcmd
    property alias cfg_updateCheckCommand: aurWrapper.upcheckcmd


    Kirigami.FormLayout {
        anchors.fill: parent
        QQC2.ComboBox {
            id: aurWrapper
            property string upcmd
            property string upcheckcmd
            Kirigami.FormData.label: i18n("AUR Wrapper:")
            textRole: "text"
            model: [
                {text: "yay", value: "yay"},
                {text: "paru", value: "paru"},
                {text: "trizen", value: "trizen"},
                {text: "pikaur", value: "pikaur"},
                {text: "pacaur", value: "pacaur"}
            ];
            currentIndex: {
                switch(plasmoid.configuration.updateCheckCommand) {
                    case "yay -Qua":
                        return 0;
                    case "paru -Qua":
                        return 1;
                    case "trizen -Qua":
                        return 2;
                    case "pikaur -Qua":
                        return 3;
                    case "pacaur -Qua":
                        return 4;
                    default:
                        return 0;
                }
            }
            onCurrentIndexChanged: {
                let curr = model[currentIndex].text;
                if( curr ) {
                    upcheckcmd = curr + " -Qua";
                    upcmd = curr + " -Syu --noconfirm"
                }
            }
        }
        Item {
            Kirigami.FormData.isSection: true
        }
        QQC2.CheckBox {
            id: updateOnExpand
            Kirigami.FormData.label: i18n("Update list on expand:")
        }
        QQC2.SpinBox {
            id: time
            Kirigami.FormData.label: i18n("Poll Interval:")
            from: 1
            to: 1000
            textFromValue: function(value, locale) {
                            return (value === 1 ? qsTr("%1 min")
                                                : qsTr("%1 mins")).arg(value);}
        }
        Item {
            Kirigami.FormData.isSection: true
        }
        QQC2.CheckBox {
            id: numbersVisible
            Kirigami.FormData.label: i18n("Badge:")
            text: i18n("Show numbers on badge")
        }
        // QQC2.RadioButton {
        //     id:
        // }
        // QQC2.ColorBox {
        //     id: badgeColor
        // }
        // QQC2.ColorBox {
        //     id: textColor
        // }

        Item {
            Kirigami.FormData.isSection: true
        }
        QQC2.TextField {
            id: packageSeparator
            Kirigami.FormData.label: i18n("Package seperator:")
            placeholderText: i18n("Example: ->, =>, to, etc.")
            text: plasmoid.configuration.packageSeparator
        }
    }
}
