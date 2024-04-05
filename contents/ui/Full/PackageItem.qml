import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

PlasmaExtras.ExpandableListItem {
    id: packageItem
    property bool showSeparator
    property var localDataCache
    icon: {
        if( Source == "FLATPAK" ) return "flatpak-discover";
        else if( Source == "SNAP" ) return "folder-snap-symbolic";
        else if( Source == "AUR" ) return "package-symbolic";
        else return "folder-database-symbolic";
    }
    title: PackageName
    subtitle: FromVersion + plasmoid.configuration.packageSeparator + ToVersion
    defaultActionButtonAction: Action {
        id: singleInstallButton
        icon.name: "run-install"
        text: i18n("Update")
        onTriggered: packageManager.action_installOne(PackageName,Source)
    }
    enabled: Source === "FLATPAK"|| plasmoid.configuration.allowSingularModifications != 1
    contextualActions: [
        Action {
            text: i18n("Show more information")
            icon.name: "showinfo"
            onTriggered: packageManager.action_showInfo(Source === "FLATPAK"?ToVersion:PackageName,Source)
        },
        Action {
            text: i18n("Uninstall")
            icon.name: "uninstall"
            onTriggered: packageManager.action_uninstall(Source === "FLATPAK"?ToVersion:PackageName,Source)
        }
    ]

    Connections{
        target: main
        function onClearProperties(){
            collapse()
            localDataCache = undefined
        }
    }

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
        details: {
            if( localDataCache ) return localDataCache
            packageManager.fillDetailsFor(Source === "FLATPAK"?ToVersion:PackageName,Source)
            humanMomentTimer.start()
            return ["","","","","","","","","","","","","","","","","","","","","",""];
        }
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
