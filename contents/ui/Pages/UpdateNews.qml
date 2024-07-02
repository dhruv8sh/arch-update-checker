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
Kirigami.Page {
    title: i18nc("@title", "Update News")
    padding: 0
    header: QQC2.ToolBar{
        ColumnLayout {
            PlasmaExtras.Heading{
                text: i18n("Official Arch Linux News")
                Layout.fillWidth: true
            }
            PlasmaComponents.ToolButton{
                Layout.alignment: Qt.AlignLeft
                icon.name: "link"
                onClicked: Qt.openUrlExternally("https://www.archlinux.org/news")
                text: i18n("Open Webpage")
            }
        }
    }
    footer: QQC2.ToolBar{
        Layout.fillWidth: true
        RowLayout {
            anchors.fill: parent
            QQC2.Label{ Layout.fillWidth: true }
            PlasmaComponents.ToolButton {
                Layout.alignment: Qt.AlignRight
                icon.name: "draw-arrow-back"
                text: i18n("Go back")
                onClicked: main.pop()
                PlasmaComponents.ToolTip { text: i18n("Package List View") }
            }
        }
    }
    contentItem: Item{
        ColumnLayout {
            enabled: !isBusy
            anchors.fill: parent
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
                visible: !main.isBusy
                contentItem: ListView {
                    id: content
                    model: feedModel
                    currentIndex: -1
                    spacing: Kirigami.Units.smallSpacing
                    boundsBehavior: Flickable.StopAtBounds
                    highlight: PlasmaExtras.Highlight { }
                    delegate: Common.NewsItem {
                        title: head
                        link: hyperlink
                        desc: description;
                        subtitle: pubDate.substring(0,16)
                        showSeparator: index != 0
                    }
                }
            }

        }
        PlasmaComponents.BusyIndicator{
            anchors.centerIn: parent
            visible: feedModel.count == 0
        }
    }
}
