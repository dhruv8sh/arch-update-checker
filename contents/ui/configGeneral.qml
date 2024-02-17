import QtQuick
import QtQuick.Layouts as QtLayouts
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.kquickcontrols as KQuickControls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami


Item {
    id: configGeneral

    property alias cfg_pollinterval: time.value
    property alias cfg_dotColor: dotColor.color
    property alias cfg_numberAvailable: numbersVisible.checked
    property alias cfg_zeroPackageBadge: zeroPackage.checked

    QtLayouts.ColumnLayout {
        id:mainColumn
        spacing: Kirigami.Units.largeSpacing
        width:parent.width - anchors.leftMargin * 2
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 2

        QtLayouts.GridLayout{
            columns: 2
            Label{
                id: label1
                width: Math.max(0.3 * root.width, 220)
                text: i18n("Poll Interval: ")
                horizontalAlignment: Text.AlignRight
            }

            SpinBox {
                id: time
                from: 1
                to: 240
                x: label1.width + 10
                textFromValue: function(value, locale) {
                            return (value === 1 ? qsTr("%1 min")
                                                : qsTr("%1 mins")).arg(value);
                   }
            }

        }

        QtLayouts.GridLayout{
            columns: 3
            Label {
                width: label1.width
                text: i18n("Badge:")
                horizontalAlignment: Text.AlignRight
            }
            KQuickControls.ColorButton {
                id: dotColor
                enabled: true
                x: label1.width + 10
            }

            Label {
                x: label1.width + 20 + dotColor.width
                text: "Badge Color"
            }
            Label{
                width: label1.width
            }
            CheckBox {
                x: label1.width + 10
                id: numbersVisible
                checked: false
                text: i18n("Show numbers on badge")
            }
            Label{}
            Label{
                width: label1.width
            }
            CheckBox {
                x: label1.width + 10
                id: zeroPackage
                checked: false
                text: i18n("Show when zero packages to update")
            }
        }
    }
}
