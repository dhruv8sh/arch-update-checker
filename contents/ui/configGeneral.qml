import QtQuick
import QtQuick.Layouts as QtLayouts
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.kquickcontrols as KQuickControls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item{
    property alias cfg_pollinterval: time.value
    property alias cfg_dotColor: dotColor.color
    property alias cfg_numberAvailable: numbersVisible.checked
    property alias cfg_zeroPackageBadge: zeroPackage.checked
    property alias cfg_packageSeparator: packageSeparator.text
    QtLayouts.ColumnLayout {
        id: root
        x: parent.width * 0.05
        spacing: 12


        Kirigami.InlineMessage {
            width: parent.width * 2
            text: "Consider switching this to a higher value for better battery performance!"
            type: Kirigami.MessageType.Warning
            visible: time.value < 10
        }
        QtLayouts.RowLayout {
            PlasmaComponents.Label {
                id: label1
                horizontalAlignment: Label.AlignRight
                text: i18n("Poll Interval:")
                width: Math.max(0.3 * root.width, 100)
            }
            PlasmaComponents.SpinBox {
                id: time
                from: 1
                to: 240
                x: label1.width + 10
                anchors.left: label1.right + 10
                textFromValue: function(value, locale) {
                            return (value === 1 ? qsTr("%1 min")
                                                : qsTr("%1 mins")).arg(value);}
            }
        }
        QtLayouts.RowLayout {
            PlasmaComponents.Label {
                horizontalAlignment: Label.AlignRight
                text: i18n("Version Separator:")
                width: label1.width
            }
            PlasmaComponents.TextField {
                id: packageSeparator
                x: label1.width + 10
                placeholderText: i18n("Separator")
                anchors.left: label1.right
            }
        }

        QtLayouts.ColumnLayout{
            QtLayouts.GridLayout{
                rows: 3
                columns: 3
                Label{
                    width: label1.width
                    text: i18n("Badge:")
                    horizontalAlignment: Label.AlignRight
                }

                KQuickControls.ColorButton {
                    id: dotColor
                    enabled: true
                    x: label1.width + 10
                    anchors.left: label1.right
                }

                PlasmaComponents.Label {
                    horizontalAlignment: Label.AlignRight
                    text: i18n(dotColor.color)
                    anchors.left: dotColor.right
                }
                Label{}
                PlasmaComponents.CheckBox {
                    x: label1.width + 10
                    id: numbersVisible
                    checked: false
                    anchors.left: label1.right
                    text: i18n("Show numbers on badge")
                }
                Label{}
                Label{}
                PlasmaComponents.CheckBox {
                    x: label1.width + 10
                    id: zeroPackage
                    checked: false
                    anchors.left: label1.right
                    text: i18n("Show when zero packages to update")
                }
            }
        }

    }
}
