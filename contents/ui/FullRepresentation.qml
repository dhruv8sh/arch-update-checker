import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels

PlasmaExtras.Representation {
    id: full
    collapseMarginsHint: true
    Layout.minimumHeight: 400
    Layout.minimumWidth: 400
    KItemModels.KSortFilterProxyModel {
        id: filterModel
        sourceModel: packageModel
        filterRoleName: "PackageName"
        sortRoleName: "PackageName"
        filterRowCallback: function(sourceRow, sourceParent) {
            let value = sourceModel.data(sourceModel.index(sourceRow, 0, sourceParent), filterRole);
            return value.toString().includes(toolbar.searchTextField.text);
        }
    }
    header: PlasmaExtras.PlasmoidHeading {
        focus: true
        contentItem: RowLayout {
            Layout.fillWidth: true

            Toolbar {
                id: toolbar
                Layout.fillWidth: true
                visible: stack.depth === 1
            }
            PlasmaComponents.Button {
                Layout.fillWidth: true
                icon.name: mirrored ? "go-next" : "go-previous"
                text: i18nc("@action:button", "Return to Network Connections")
                visible: stack.depth > 1
                onClicked: {
                    stack.pop()
                }
            }

            Loader {
                sourceComponent: stack.currentItem?.headerItems
                visible: !!item
            }
        }
    }
    QQC2.StackView {
        id: stack
        anchors.fill: parent
        initialItem: ListPage {
            id: listPage
            filteredModel: filterModel
        }
    }
}














































