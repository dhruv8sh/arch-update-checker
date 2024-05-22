import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import "../../Util.js" as Util

PlasmaExtras.ExpandableListItem {
    id: packageItem
    property bool showSeparator
    icon: Util.fetchIcon(PackageName, Source, Group)
    title: PackageName
    allowStyledText: true
    subtitle: "<b>"+Source+"</b>   |   " + FromVersion + cfg.packageSeparator + ToVersion
    defaultActionButtonAction: Action {
            text: i18n("More Info")
            icon.name: "showinfo"
            onTriggered: Util.action_showDetailedInfo(Source==="FLATPAK"?FromVersion:PackageName,Source)
        }
    contextualActions: [
        Action {
            id: singleInstallButton
            icon.name: "run-install"
            text: i18n("Update")
            onTriggered: Util.action_installOne(Source==="FLATPAK"?FromVersion:PackageName, Source)
            enabled: Source === "FLATPAK"|| cfg.allowSingleModification != 0
        },
        Action {
            text: i18n("Uninstall")
            icon.name: "uninstall"
            onTriggered: Util.action_uninstall(Source==="FLATPAK"?FromVersion:PackageName,Source)
        },
	Action {
	    text: i18n("Open URL")
	    icon.name: "edit-link"
	    onTriggered: Qt.openUrlExternally(URL)
	}
    ]

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
    customExpandedViewContent: DetailsText{
        id: detailsText
        details: Desc.trim().split('\n')
    }
}
