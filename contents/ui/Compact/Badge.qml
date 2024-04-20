import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
Rectangle {
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
    color: plasmoid.configuration.useCustomColors ? plasmoid.configuration.dotColor : Kirigami.Theme.textColor

    radius: height / 3
    width: Math.max(Math.min(parent.width/2, parent.height/2),label.implicitWidth*1.1)
    height: Math.min(label.implicitHeight, parent.height)
    // Layout.maximumHeight: parent.height / 1.5
    // Layout.maximumWidth: parent.width / 1.5
    onWidthChanged : height = width
    Label {
        id: label
        color              : plasmoid.configuration.useCustomColors ? plasmoid.configuration.textColor : Kirigami.Theme.backgroundColor;
        visible            : plasmoid.configuration.useBadgeNumber
        font.pixelSize     : 8
        anchors.fill       : parent
        anchors.margins    : parent.anchors.margins
        verticalAlignment  : Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
