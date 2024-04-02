import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

Kirigami.ScrollablePage {
    id: root
    property alias cfg_numberAvailable: numbersVisible.checked
    property alias cfg_packageSeparator: packageSeparator.text
    property alias cfg_customColorsEnabled: customColorsEnabled.checked
    property alias cfg_dotColor: dotColor.color
    property alias cfg_textColor: textColor.color
    property alias cfg_position: position.currentIndex



    Kirigami.FormLayout {
        QQC2.TextField {
            id: packageSeparator
            Kirigami.FormData.label: i18n("Package seperator:")
            placeholderText: i18n("Example: ->, =>, to, etc.")
            text: plasmoid.configuration.packageSeparator
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
    }
}
