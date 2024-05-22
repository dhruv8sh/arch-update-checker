import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../Util.js" as Util

StackLayout {
    // spacing: 0
    Layout.fillWidth: true
    RowLayout {
    	Kirigami.Icon {
	    source: statusIcon
	    opacity: 0.7
	}
        QQC2.Label {
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth: true
            text: statusMessage
            opacity: 0.7
        }
        PlasmaComponents.ToolButton {
            id: clearOrphansButton
            icon.name: "node-delete"
            onClicked: Util.action_clearOrphans()
            PlasmaComponents.ToolTip { text: i18n("Clear orphans") }
        }
        PlasmaComponents.ToolButton {
            Layout.alignment: Qt.AlignRight
            icon.name: "news-subscribe"
            onClicked: stack2.push("Pages/UpdateNews.qml");
            PlasmaComponents.ToolTip { text: i18n("Official Arch Update News") }
        }
    }
    RowLayout {
        QQC2.Label{ Layout.fillWidth: true }
        PlasmaComponents.ToolButton {
            Layout.alignment: Qt.AlignRight
            icon.name: pageNo == 0 ? "dialog-cancel":"go-previous-view-page"
            text: pageNo == 0 ? i18n("Skip") : i18n("Previous")
            onClicked: {
                if( pageNo > 0 ) {
                    pageNo --;
                    stack2.pop();
                } else {
                    cfg.showIntro = false;
                    stack2.clear();
                    stack2.push("Pages/ListPage.qml");
		    Util.action_searchForUpdates()
                }
            }
        }
        PlasmaComponents.ToolButton {
            Layout.alignment: Qt.AlignRight
            icon.name: pageNo == 3?"checkmark":"go-next-view-page"
            text: pageNo == 3?i18n("Done"):i18n("Next")
            onClicked: {
                if( pageNo < 3 ) {
                    pageNo ++;
                    stack2.push(getPage())
                } else {
                    cfg.showIntro = false;
                    stack2.clear();
                    stack2.push("Pages/ListPage.qml");
                    Util.action_searchForUpdates();
                }
            }
        }
    }
    RowLayout {
        QQC2.Label{ Layout.fillWidth: true }
        PlasmaComponents.ToolButton {
            Layout.alignment: Qt.AlignRight
            icon.name: "view-list-details"
            onClicked: stack2.pop()
            PlasmaComponents.ToolTip { text: i18n("Package List View") }
        }
    }
}
