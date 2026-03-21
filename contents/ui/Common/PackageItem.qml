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
    required index
    required property var model
    property bool showSeparator
    icon: Util.fetchIcon(model.PackageName, model.Source, model.Group)
    title: model.PackageName
    allowStyledText: true
    subtitle: "<b>" + model.Source + "</b>   |   " + model.FromVersion + cfg.packageSeparator + model.ToVersion
    defaultActionButtonAction: Action {
        icon.name: "showinfo"
        onTriggered: {
            if (model.Source.startsWith("FLATPAK")) Util.commands["showFlatpakInfo"].run(model.FromVersion)
            else if (model.Source === "AUR") Util.commands["showAURInfo"].run(model.PackageName)
            else Util.commands["showPacmanInfo"].run(model.PackageName)
        }
    }
    contextualActions: [
        Action {
            id: singleInstallButton
            icon.name: "run-install"
            text: i18n("Update")
            onTriggered: {
                if (model.Source.startsWith("FLATPAK")) Util.commands["installFlatpak"].run(model.FromVersion)
                else if (model.Source === "AUR") Util.commands["installAUR"].run(model.PackageName)
                else Util.commands["installPacman"].run(model.PackageName)
            }
            enabled: model.Source === "FLATPAK" || cfg.allowSingleModification != 0
        },
        Action {
            text: i18n("Uninstall")
            icon.name: "uninstall"
            onTriggered: {
                if (model.Source.startsWith("FLATPAK")) Util.commands["uninstallFlatpak"].run(model.FromVersion)
                else if (model.Source === "AUR") Util.commands["uninstallAUR"].run(model.PackageName)
                else Util.commands["uninstallPacman"].run(model.PackageName)
            }
        },
        Action {
            text: i18n("Open URL")
            icon.name: "edit-link"
            onTriggered: Qt.openUrlExternally(model.URL)
        }
    ]
    customExpandedViewContent: DetailsText{
        id: detailsText
        details: model.Desc.trim().split('\n')
    }
}
