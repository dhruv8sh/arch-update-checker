import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
Rectangle {
    id: badge
    smooth: true
    property alias text: label.text
    property bool rightAnchor  : plasmoid.configuration.badgePosition == 1 || plasmoid.configuration.badgePosition == 3
    property bool bottomAnchor : plasmoid.configuration.badgePosition == 2 || plasmoid.configuration.badgePosition == 3
    anchors {
        right  :  rightAnchor  ? parent.right  : undefined
        bottom :  bottomAnchor ? parent.bottom : undefined
        left   : !rightAnchor  ? parent.left   : undefined
        top    : !bottomAnchor ? parent.top    : undefined
    }
    onWidthChanged : width  = Math.max(parent.width/2, implicitWidth)
    onHeightChanged: height = parent.height/2
    color: plasmoid.configuration.useCustomColors ? plasmoid.configuration.dotColor : Kirigami.Theme.textColor

    radius: height / 2
    height: Math.max(parent.width/2, label.implicitHeight)
    width: Math.max(parent.width/2, label.implicitWidth)
    Label {
        id: label
        color              : plasmoid.configuration.useCustomColors ? plasmoid.configuration.textColor : Kirigami.Theme.backgroundColor;
        visible            : plasmoid.configuration.useBadgeNumber
        font.pixelSize     : Math.max(Math.min(parent.height / 2, parent.width / 2),10)
        anchors.fill       : parent
        anchors.margins    : parent.anchors.margins
        verticalAlignment  : Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
