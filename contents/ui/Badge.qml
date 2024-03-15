import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
Rectangle {
    id: badge
    smooth: true
    property alias text: label.text
    property bool rightAnchor  : plasmoid.configuration.position == 1 || plasmoid.configuration.position == 3
    property bool bottomAnchor : plasmoid.configuration.position == 2 || plasmoid.configuration.position == 3
    anchors {
        right  :  rightAnchor  ? parent.right  : undefined
        bottom :  bottomAnchor ? parent.bottom : undefined
        left   : !rightAnchor  ? parent.left   : undefined
        top    : !bottomAnchor ? parent.top    : undefined
    }
    onWidthChanged : width  = Math.max(parent.width/2, implicitWidth)
    onHeightChanged: height = parent.height/2
    color: plasmoid.configuration.customColorsEnabled ? plasmoid.configuration.dotColor : Kirigami.Theme.textColor

    radius: height / 2
    height: parent.height/2
    width: Math.max(parent.width/2, implicitWidth)
    Label {
        id: label
        color              : plasmoid.configuration.customColorsEnabled ? plasmoid.configuration.textColor : Kirigami.Theme.backgroundColor;
        visible            : plasmoid.configuration.numberAvailable
        font.pixelSize     : Math.max(Math.min(parent.height / 2, parent.width / 2),10)
        anchors.fill       : parent
        anchors.margins    : parent.anchors.margins
        verticalAlignment  : Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
