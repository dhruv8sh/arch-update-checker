import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
Rectangle {
    id: badge
    smooth: true
    property alias text: label.text

    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: Kirigami.Theme.backgroundColor

    radius: height / 2
    height: parent.height/2
    width: Math.max(parent.width/2, implicitWidth)
    Label {
        id: label
        color: plasmoid.configuration.customBadgeColor ? Kirigami.Theme.backgroundColor : plasmoid.configuration.textColor;
        font.pixelSize: Math.max(Math.min(parent.height / 2, parent.width / 2),8)
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        visible: plasmoid.configuration.numberAvailable
        anchors.margins: parent.anchors.margins
    }
}
