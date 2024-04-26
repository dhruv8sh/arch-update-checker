 
import QtQuick
import QtQuick.Layouts
import org.kde.kquickcontrolsaddons as KQuickControlsAddons
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents

MouseArea {
    height: detailsGrid.implicitHeight
    property var details : ["","","","","","","","","","","","","","","","","","","","","","",]
    acceptedButtons: Qt.RightButton
    onPressed: mouse => {
        const item = detailsGrid.childAt(mouse.x, mouse.y);
        if (!item || !item.isContent) {
            return;
        }
        contextMenu.show(this, item.text, mouse.x, mouse.y);
    }
    KQuickControlsAddons.Clipboard {
        id: clipboard
    }
    PlasmaExtras.Menu {
        id: contextMenu
        property string text

        function show(item, text, x, y) {
            contextMenu.text = text
            visualParent = item
            open(x, y)
        }

        PlasmaExtras.MenuItem {
            text: i18n("Copy \'Name - New Version\'")
            icon: "edit-copy"
            enabled: contextMenu.text !== ""
            onClicked: clipboard.content = PackageName + " - " + ToVersion
        }
    }
    GridLayout {
        id: detailsGrid
        width: parent.width
        columns: 2
        rows: 12
        rowSpacing: Kirigami.Units.smallSpacing / 4
        Repeater {
            id: repeater
            model: details
            PlasmaComponents.Label {
                Layout.fillWidth: true
                readonly property bool isContent: index % 2
                elide: isContent ? Text.ElideRight : Text.ElideNone
                font: Kirigami.Theme.smallFont
                text: isContent ? details[index] : `${details[index]}:`
                textFormat: Text.PlainText
                opacity: isContent ? 1 : 0.6
            }
        }
    }
}
