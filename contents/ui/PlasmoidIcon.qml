import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

Item {
    id: root
    anchors.centerIn: parent
    property var source

    KSvg.SvgItem {
        id: svgItem
        opacity: 1
        width: parent.width
        height: parent.height
        property int sourceIndex: 0
        anchors.centerIn: parent
        smooth: true
        // colorGroup: Kirigami.Theme.colorSet
        imagePath: Qt.resolvedUrl("../assets/" + source)
    }

}
