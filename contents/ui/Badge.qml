import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
Rectangle {
    id: badge
    smooth: true
    property alias text: label.text
    Connections {
        target: main
        onUpdatingPackageList: {
            busyIndicator.visible = true
            label.visible = false
            badge.color = "transparent"
        }
        onStoppedUpdating: {
            busyIndicator.visible = false
            label.visible = true
            badge.color = Kirigami.Theme.backgroundColor
        }
    }
    PlasmaComponents.BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        visible: false
        anchors.fill: parent
    }

    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: Kirigami.Theme.backgroundColor

    radius: height / 2
    height: parent.height/2
    width: Math.max(parent.width/2, implicitWidth)
    Label {
        id: label
        color: Kirigami.Theme.textColor
        font.pixelSize: Math.min(parent.height / 2, parent.width / 2)
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        visible: plasmoid.configuration.numberAvailable
        anchors.margins: parent.anchors.margins
    }
}
