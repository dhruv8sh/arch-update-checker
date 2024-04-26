import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid as Plasmoid
import QtQuick.Controls as QQC2
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels
import "./Pages/" as Pages

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
        contentItem: TopToolbar{
            id: toolbar
            headName: stack2.currentItem?.title
            currentIndex: stack2.currentItem?.kind
        }
    }
    footer: PlasmaExtras.PlasmoidHeading {
        contentItem: BottomToolbar{
            id: bottomToolbar
            currentIndex: stack2.currentItem?.kind
        }
    }
    Component.onCompleted: {
        if(plasmoid.configuration.showIntro) {

        } else {
            stack2.clear();
            stack2.push("Pages/ListPage.qml");
        }
    }
    QQC2.StackView {
        id: stack2
        anchors.fill: parent
        initialItem: Pages.Welcome{}
        Layout.fillWidth: true
    }
    function getPage() {
        if( plasmoid.configuration.debugNormal)
            console.log("Switching to page no.:"+pageNo);
        switch( pageNo ) {
            case 0: return "Pages/Welcome.qml";
            case 1: return "Pages/PackageManagement.qml";
            case 2: return "Pages/Behavior.qml";
            case 3: return "Pages/Appearance.qml";
        }
    }
    Connections {
        target: main
        onPop: stack2.pop();
    }
}
