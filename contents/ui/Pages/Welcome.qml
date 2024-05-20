import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "../Common/" as Common

Common.CustomPage {
    id: welcomePage
    kind: 1
    title: i18nc("@title", "Welcome")
    heading: "\nArch Update Checker"
    subtitle: i18n("(Experimental Setup)")
    icon: "update-none"
    QQC2.Label {
        Layout.alignment: Qt.AlignCenter
        text: i18n("This is a basic setup and should take <2 minutes.")
    }
    QQC2.Label{}
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
