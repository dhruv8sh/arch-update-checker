 
import QtQuick
import QtQuick.Layouts
import org.kde.kquickcontrolsaddons as KQuickControlsAddons
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents

MouseArea {
    required property var details
    acceptedButtons: Qt.RightButton
    height: detailsGrid.height + Kirigami.Units.mediumSpacing
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
            onClicked: clipboard.content = Name + " - " + ToVersion
        }
    }
    ColumnLayout {
        id: detailsGrid
	width: parent.width
        spacing: Kirigami.Units.smallSpacing / 4
        Repeater {
            id: repeater
            model: details
	    RowLayout{
	    	Layout.fillWidth: true
            	PlasmaComponents.Label {
                	font: Kirigami.Theme.smallFont
                	text: details[index].split(':')[0] + ':'
                	textFormat: Text.PlainText
			width: detailsGrid.width*0.2
			Layout.minimumWidth: width
			Layout.alignment: Qt.AlignTop
			horizontalAlignment: Text.AlignRight
                	opacity: 0.6
            	}
            	PlasmaComponents.Label {
                	Layout.fillWidth: true
			Layout.alignment: Qt.AlignTop
                	font: Kirigami.Theme.smallFont
                	text: details[index].split(':')[1]
			elide: Text.ElideRight
                	textFormat: Text.PlainText
                	//wrapMode: Text.WordWrap
                	onLinkActivated: Qt.openUrlExternally(link)
            	}
	    }
        }
    }
}
