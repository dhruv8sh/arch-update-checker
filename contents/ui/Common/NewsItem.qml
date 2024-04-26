import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import QtQuick.Controls as QQC2

PlasmaExtras.ExpandableListItem {
    id: packageItem
    property string link
    property string desc
    property bool showSeparator
    icon: "news-subscribe"

    KSvg.SvgItem {
        id: separatorLine
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
        }
        imagePath: "widgets/line"
        elementId: "horizontal-line"
        width: parent.width - Kirigami.Units.gridUnit
        visible: showSeparator
    }
    contextualActions: Action {
            text: i18n("Go to page")
            icon.name: "link"
            onTriggered: Qt.openUrlExternally(link)
        }
    customExpandedViewContent:
        QQC2.Label{
            text: description
            wrapMode: Text.WordWrap
            onLinkActivated: Qt.openUrlExternally(link)
        }
}
