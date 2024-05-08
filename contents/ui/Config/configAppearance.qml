import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kquickcontrols as KQuickControls
import org.kde.kirigami as Kirigami
import "../Common/" as Common

Kirigami.ScrollablePage {
    id: appearancePage

    property alias cfg_dotColor : dotColor.color
    property alias cfg_textColor: textColor.color
    property alias cfg_useCustomColors: customColors.checked
    property alias cfg_badgePosition: badgePositionItem.position
    property alias cfg_useBadgeNumber: useBadgeNumber.checked
    property alias cfg_packageSeparator: sprtrText.text
    property alias cfg_customIcons: customIconList.text
    property alias cfg_useCustomIcons: useCustomIcons.checked


    property int kind: 1
    readonly property int margins: Kirigami.Units.gridUnit
    title: i18nc("@title", "Appearance")
    ColumnLayout {
        anchors.fill: parent
        PlasmaExtras.Heading {
            Layout.alignment: Qt.AlignCenter
            text: i18n("Indicator Position")
            wrapMode: Text.WordWrap
            level: 2
        }
        Item {
            id: badgePositionItem
            property int position
            clip: false
            Layout.alignment: Qt.AlignCenter
            Layout.minimumWidth : 100
            Layout.minimumHeight: 100
            QQC2.RadioButton{
                anchors.left: parent.right
                anchors.top: parent.top
                LayoutMirroring.enabled: true
                text: i18n("Top-Left")
                checked: parent.position == 0
                onCheckedChanged: {
                    if( checked ) parent.position = 0;
                }
            }
            QQC2.RadioButton{
                anchors.left: parent.right
                anchors.top: parent.top
                text: i18n("Top-Right")
                checked: parent.position == 1
                onCheckedChanged: {
                    if( checked ) parent.position = 1;
                }
            }
            Kirigami.Icon {
                height: 100
                width: 100
                anchors.centerIn: parent
                source: "update-none-symbolic"
            }
            QQC2.RadioButton{
                anchors.left: parent.right
                anchors.bottom: parent.bottom
                LayoutMirroring.enabled: true
                checked: parent.position == 2
                onCheckedChanged: {
                    if( checked ) parent.position = 2;
                }
                text: i18n("Bottom-Left")
            }
            QQC2.RadioButton{
                anchors.left: parent.right
                anchors.bottom: parent.bottom
                checked: parent.position == 3
                onCheckedChanged: {
                    if( checked ) parent.position = 3;
                }
                text: i18n("Bottom-Right")
            }
        }
        PlasmaExtras.Heading {
            Layout.alignment: Qt.AlignCenter
            text: i18n("\nVersion Seperator")
            wrapMode: Text.WordWrap
            level: 2
        }
        QQC2.TextField{
            id: sprtrText
            horizontalAlignment: TextInput.AlignHCenter
            Layout.alignment: Qt.AlignCenter
        }
        QQC2.Label{
            Layout.alignment: Qt.AlignCenter
            text: "v6.9"+sprtrText.text+"v9.6\n"
        }
        RowLayout{
            Layout.alignment: Qt.AlignCenter
            spacing: 20
            Common.CustomSwitch{
                id: customColors
                text:i18n("Custom Colors")
                icon:"color-picker"
            }
            ColumnLayout {
                visible: customColors.checked
                KQuickControls.ColorButton {
                    Layout.alignment: Qt.AlignCenter
                    id: dotColor
                }
                QQC2.Label {
                    text: i18n("Circle color")
                }
            }
            ColumnLayout {
                visible: customColors.checked
                enabled: useBadgeNumber.checked
                KQuickControls.ColorButton {
                    Layout.alignment: Qt.AlignCenter
                    id: textColor
                }
                QQC2.Label {
                    text: i18n("Text color")
                }
            }
        }
        Common.CustomSwitch{
            id: useBadgeNumber
            text:i18n("Show text on badge")
            icon:"draw-number"
        }
        QQC2.Label {}
        RowLayout {
            Layout.alignment: Qt.AlignCenter
            Common.CustomSwitch{
                id: useCustomIcons
                text:i18n("Custom icons")
                icon:"settings-configure"
            }
            PlasmaComponents.ToolButton {
                icon.name: "documentinfo"
                PlasmaComponents.ToolTip {
                    text: i18n("Format: type > name > icon-name\nTypes: group, name, source\nName: '...' at the end matches any following string.\n'lib' and 'lib32-' in the package name match automatically.\nicon-name: '~' is same as package-name.")
                }
            }
        }
        QQC2.TextArea {
            id: customIconList
            Layout.alignment: Qt.AlignCenter
            visible: useCustomIcons.checked
        }
    }
}
