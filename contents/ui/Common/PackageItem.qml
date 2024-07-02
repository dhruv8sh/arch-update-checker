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
        icon.name: "showinfo"
        onTriggered: {
            if(Source.startsWith("FLATPAK")) Util.commands["showFlatpakInfo"].run(FromVersion)
            else if( Source==="AUR" ) Util.commands["showAURInfo"].run(PackageName)
            else Util.commands["showPacmanInfo"].run(PackageName)
        }
    }
    contextualActions: [
        Action {
            id: singleInstallButton
            icon.name: "run-install"
            text: i18n("Update")
            onTriggered: {
                if(Source.startsWith("FLATPAK")) Util.commands["installFlatpak"].run(FromVersion)
                else if( Source==="AUR" ) Util.commands["installAUR"].run(PackageName)
                else Util.commands["installPacman"].run(PackageName)
            }
            enabled: Source === "FLATPAK"|| cfg.allowSingleModification != 0
        },
        Action {
            text: i18n("Uninstall")
            icon.name: "uninstall"
            onTriggered: {
                if(Source.startsWith("FLATPAK")) Util.commands["uninstallFlatpak"].run(FromVersion)
                else if( Source==="AUR" ) Util.commands["uninstallAUR"].run(PackageName)
                else Util.commands["uninstallPacman"].run(PackageName)
            }
        },
        Action {
            text: i18n("Open URL")
            icon.name: "edit-link"
            onTriggered: Qt.openUrlExternally(URL)
        }
    ]
    customExpandedViewContent: DetailsText{
        id: detailsText
        details: Desc.trim().split('\n')
    }
}
