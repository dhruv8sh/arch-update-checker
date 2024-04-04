import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

RowLayout {
    height: 100
    spacing: 0
    Layout.fillWidth: true
    PlasmaComponents.ToolButton {
        visible: plasmoid.configuration.showIntro
        Layout.alignment: Qt.AlignLeft
        text: i18n("Done")
        icon.name: "dialog-ok-apply"
        onClicked: {
            plasmoid.configuration.showIntro = false;
            stack2.clear();
            stack2.push("Pages/ListPage.qml");
        }
    }
    PlasmaComponents.ToolButton {
        visible: plasmoid.configuration.showIntro
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
        visible: plasmoid.configuration.showIntro
        Layout.alignment: Qt.AlignRight
        icon.name: "go-next-view-page"
        text: i18n("Next")
        onClicked: {
            pageNo ++;
            stack2.push(getPage())
        }
        enabled: pageNo < 3
    }
    QQC2.Label {
        visible: !plasmoid.configuration.showIntro
        Layout.alignment: Qt.AlignLeft
        text: "    "+packageModel.count+" updates available"
    }
    PlasmaComponents.ToolButton {
        visible: !plasmoid.configuration.showIntro
        Layout.alignment: Qt.AlignRight
        icon.name: newsEnabled ? "view-list-details":"news-subscribe"
        onClicked: {
            newsEnabled ? stack2.pop() : stack2.push("Pages/UpdateNews.qml");
            newsEnabled = !newsEnabled;
        }
        PlasmaComponents.ToolTip {
            text: !newsEnabled ? i18n("Official Arch Update News") : i18n("Package List View")
        }
    }
}
