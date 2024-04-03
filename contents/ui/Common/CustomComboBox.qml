import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.plasma.extras as PlasmaExtras

RowLayout {
    property alias icon: itemicon.source
    property alias text: head.text
    property alias model: itemList.model
    property alias index: itemList.currentIndex
    Layout.alignment: Qt.AlignCenter
    Kirigami.Icon {
        id: itemicon
    }
    PlasmaExtras.Heading {
        id: head
        wrapMode: Text.WordWrap
        level: 2
    }
    QQC2.ComboBox {
        id: itemList
        textRole: "text"
    }
}

