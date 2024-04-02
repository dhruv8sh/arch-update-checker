import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid as Plasmoid
import QtQuick.Controls as QQC2
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels
import "./Pages/" as Pages
import "./Full/" as Full

PlasmaExtras.Representation {
    id: fullIntro
    collapseMarginsHint: true
    Layout.minimumHeight: 500
    Layout.minimumWidth: 500
    property int pageNo: 0;
    anchors.fill: parent
    KItemModels.KSortFilterProxyModel {
        id: filterModel
        sourceModel: packageModel
        filterRoleName: "PackageName"
        sortRoleName: toolbar.sortByName?"PackageName":"Source"
        filterRowCallback: function(sourceRow, sourceParent) {
            let value = sourceModel.data(sourceModel.index(sourceRow, 0, sourceParent), filterRole);
            return value.toString().includes(toolbar.searchTextField.text);
        }
    }
    header: PlasmaExtras.PlasmoidHeading {
        focus: true
        contentItem: TopToolbar{ id: toolbar }
        Loader {
            sourceComponent: stack2.currentItem?.headerItems
        }
    }
    footer: PlasmaExtras.PlasmoidHeading {
        focus: true
        visible: plasmoid.configuration.showIntro
        contentItem: RowLayout {
            Layout.fillWidth: true
            PlasmaComponents.ToolButton {
                Layout.alignment: Qt.AlignLeft
                text: i18n("Done")
                icon.name: "dialog-ok-apply"
                onClicked:{
                    plasmoid.configuration.showIntro = false;
                    stack2.clear();
                    stack2.push("Pages/ListPage2.qml");
                }
            }
            PlasmaComponents.ToolButton {
                Layout.alignment: Qt.AlignRight
                icon.name: "go-previous-view-page"
                text: i18n("Previous")
                onClicked: {
                    pageNo --;
                    stack2.pop();
                }
                enabled: pageNo > 0
            }
            PlasmaComponents.ToolButton {
                Layout.alignment: Qt.AlignRight
                icon.name: "go-next-view-page"
                text: i18n("Next")
                onClicked: {
                    pageNo ++;
                    stack2.push(getPage())
                }
                enabled: pageNo < 3
            }
        }
    }
    Component.onCompleted: {
        console.log(packageModel);
        if(plasmoid.configuration.showIntro) {

        } else {
            stack2.clear();
            stack2.push("Pages/ListPage2.qml");
        }
    }
    QQC2.StackView {
        id: stack2
        anchors.fill: parent
        initialItem: Pages.Welcome{}
    }
    function getPage() {
        switch( pageNo ) {
            case 0: return "Pages/Welcome.qml";
            case 1: return "Pages/PackageManagement.qml";
            case 2: return "Pages/Behavior.qml";
            case 3: return "Pages/Appearance.qml";
        }
    }
}
