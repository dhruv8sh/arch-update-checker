import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    readonly property int margins: Kirigami.Units.gridUnit
    topPadding: 0
    leftPadding: margins
    rightPadding: margins
    bottomPadding: margins
    default property alias content : column.children
    required property string heading
    required property string subtitle
    required property int kind
    property string icon
    ColumnLayout{
        PlasmaExtras.Heading {
            Layout.alignment: Qt.AlignCenter
            text: heading
            wrapMode: Text.WordWrap
        }
        PlasmaExtras.Heading {
            Layout.alignment: Qt.AlignCenter
            text: subtitle
            wrapMode: Text.WordWrap
            level: 3
        }
        Kirigami.Icon {
            Layout.alignment: Qt.AlignCenter
            source: "update-none"
        }
        ColumnLayout {
            Layout.alignment: Qt.AlignCenter
            id: column
        }
    }
}
