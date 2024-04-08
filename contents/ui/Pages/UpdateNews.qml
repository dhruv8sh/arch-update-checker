import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import QtQml.XmlListModel
import "../Full/" as Full

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
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: !main.isUpdating
        contentWidth: availableWidth
        contentItem: ListView {
            id: content
            width: 180; height: 300
            model: feedModel
            currentIndex: -1
            spacing: Kirigami.Units.smallSpacing
            boundsBehavior: Flickable.StopAtBounds
            highlight: PlasmaExtras.Highlight { }
            highlightMoveDuration: 1000
            highlightResizeDuration: 1000
            delegate: Full.NewsItem {
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
        Layout.topMargin: 150
        Layout.bottomMargin: 150
        visible: content.model.count == 0
    }
}
