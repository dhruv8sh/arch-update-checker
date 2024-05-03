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
    icon: {
        if( !plasmoid.configuration.useCustomIcons ) return "server-database"
        let ans = "";
        const tempname = PackageName.startsWith("lib") ? PackageName.substring(3) : PackageName
        let lines = plasmoid.configuration.customIcons.split('\n');
        for (let line of lines) {
            let info = line.split('>');
            if (info.length < 3) continue; // Use continue instead of return
            let type = info[0].trim();
            let name = info[1].trim();
            let tempans = info[2].trim();
            if (type === "name" && (name === tempname || (name.endsWith('...') && tempname.startsWith(name.substring(0, name.length - 3))))) {
                ans = tempans;
                break;
            } else if (type === "source" && name === Source.toLowerCase()) {
                ans = tempans;
                break;
            } else if (type === "group" && name === Group.toLowerCase()) {
                ans = tempans === "~" ? tempname : tempans;
                break;
            }
        }
        return ans;
    }
    title: PackageName
    allowStyledText: true
    subtitle: "<b>"+Source+"</b>   |   " + FromVersion + plasmoid.configuration.packageSeparator + ToVersion
    defaultActionButtonAction: Action {
            text: i18n("More Info")
            icon.name: "showinfo"
            onTriggered: Util.action_showDetailedInfo(Source === "FLATPAK"?ToVersion:PackageName,Source)
        }
    contextualActions: [
        Action {
            id: singleInstallButton
            icon.name: "run-install"
            text: i18n("Update")
            onTriggered: Util.action_installOne(PackageName,Source)
            enabled: Source === "FLATPAK"|| plasmoid.configuration.allowSingleModification != 0
        },
        Action {
            text: i18n("Uninstall")
            icon.name: "uninstall"
            onTriggered: Util.action_uninstall(Source === "FLATPAK"?ToVersion:PackageName,Source)
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
        details: Util.fetchDetails(PackageName, Source)
    }
    Timer{
        id: humanMomentTimer
        interval: 200
        running: false
        repeat: false
        onTriggered: {
            localDataCache = main.details
            if( localDataCache.length === 0 ) humanMomentTimer.start()
        }
    }
}
