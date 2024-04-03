import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: welcomePage
    readonly property int margins: Kirigami.Units.gridUnit
    title: i18nc("@title", "Welcome")
    topPadding: 0
    leftPadding: margins
    rightPadding: margins
    bottomPadding: margins
    header: Item {
        anchors{
            topMargin: Kirigami.Units.smallSpacing * 2
            bottomMargin: anchors.topMargin
            leftMargin: anchors.topMargin
            rightMargin: anchors.topMargin
        }
        ColumnLayout {
            anchors.fill: parent
            PlasmaExtras.Heading {
                Layout.alignment: Qt.AlignCenter
                text: "\n\nArch Update Checker"
                wrapMode: Text.WordWrap
            }
            PlasmaExtras.Heading {
                Layout.alignment: Qt.AlignCenter
                text: "(Experimental setup)"
                wrapMode: Text.WordWrap
                level: 3
            }
            Kirigami.Icon {
                Layout.alignment: Qt.AlignCenter
                source: "update-none-symbolic"
            }
            QQC2.Label {
                Layout.alignment: Qt.AlignCenter
                text: i18n("This is a basic setup and should take <2 minutes.")
            }
            RowLayout{
                Layout.alignment: Qt.AlignCenter
                Image {
                    Layout.alignment: Qt.AlignCenter
                    source: "./github-konqi.png"
                    sourceSize.width: 200
                    sourceSize.height: 200
                    HoverHandler {
                        id: handlerGithub
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: Qt.openUrlExternally("https://www.github.com/dhruv8sh/arch-update-checker")
                    }

                    QQC2.ToolTip {
                        visible: handlerGithub.hovered
                        text: i18n("Visit Github Repo")
                    }
                }
            }
            Kirigami.UrlButton {
                Layout.alignment: Qt.AlignCenter
                text: i18n("Github")
                url: "https://www.github.com/dhruv8sh/arch-update-checker/"
            }
            Kirigami.UrlButton {
                Layout.alignment: Qt.AlignCenter
                text: i18n("KDE Store")
                url: "https://www.pling.com/p/2130541/"
            }
        }
    }
}
