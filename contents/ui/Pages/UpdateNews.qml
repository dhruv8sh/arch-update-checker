import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import QtQml.XmlListModel
import "../Common/" as Common
ColumnLayout {
    // height: parent.height
    property int kind: 2
    property string title: i18nc("@title", "Update News")
    Layout.fillWidth: true
    XmlListModel {
        id: feedModel
        source: "https://archlinux.org/feeds/news/"
        query: "/rss/channel/item"
        XmlListModelRole { name: "head"; elementName: "title"; attributeName: ""}
        XmlListModelRole { name: "hyperlink"; elementName: "link"; attributeName: "" }
        XmlListModelRole { name: "description"; elementName: "description"; attributeName: "" }
        XmlListModelRole { name: "pubDate"; elementName: "pubDate"; attributeName: "" }
    }
    PlasmaComponents.ScrollView {
        id: scrollView
        Layout.fillHeight: true
	Layout.fillWidth : true
        visible: !main.isUpdating
        contentItem: ListView {
            id: content
            model: feedModel
            currentIndex: -1
            spacing: Kirigami.Units.smallSpacing
            boundsBehavior: Flickable.StopAtBounds
            highlight: PlasmaExtras.Highlight { }
            highlightMoveDuration: 0
            highlightResizeDuration: 0
            delegate: Common.NewsItem {
                title: head
                link: hyperlink
                desc: description;
                subtitle: pubDate.substring(0,16)
                showSeparator: index != 0
            }
        }
    }
    PlasmaComponents.BusyIndicator {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: width / 3
        Layout.bottomMargin: width / 3
        visible: content.model.count == 0
    }
}
