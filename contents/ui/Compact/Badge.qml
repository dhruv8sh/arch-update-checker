import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
Rectangle {
    id: badge
    smooth: true
    property alias text: label.text
    states: [
        State{
            name: "bottomright"
            when: cfg.badgePosition == 3
            AnchorChanges{
                target: badge
                anchors.bottom: undefined
                anchors.right : undefined
                anchors.top   : compact.verticalCenter
                anchors.left  : compact.horizontalCenter
            }
        },
        State{
            name: "topleft"
            when: cfg.badgePosition == 0
            AnchorChanges{
                target: badge
                anchors.bottom: compact.verticalCenter
                anchors.right : compact.horizontalCenter
                anchors.top   : undefined
                anchors.left  : undefined
            }
        },
        State{
            name: "bottomleft"
            when: cfg.badgePosition == 2
            AnchorChanges{
                target: badge
                anchors.bottom: undefined
                anchors.right : compact.horizontalCenter
                anchors.top   : compact.verticalCenter
                anchors.left  : undefined
            }
        },
        State{
            name: "topright"
            when: cfg.badgePosition == 1
            AnchorChanges{
                target: badge
                anchors.bottom: compact.verticalCenter
                anchors.right : undefined
                anchors.top   : undefined
                anchors.left  : compact.horizontalCenter
            }
        }
    ]
    color : cfg.useCustomColors ? cfg.dotColor : Kirigami.Theme.textColor
    radius: cfg.useBadgeNumber ? height / 4 : height / 2
    // DO NOT CHANGE THIS
    width : Math.max(Math.min(parent.width / 2, parent.height/2),label.implicitWidth+2)
    height: Math.min(parent.height / 2, width)
    // Layout.maximumHeight: parent.height / 1.5
    // Layout.maximumWidth: parent.width / 1.5
    Label {
        id: label
        color              : cfg.useCustomColors ? cfg.textColor : Kirigami.Theme.backgroundColor;
        visible            : cfg.useBadgeNumber
        font.pixelSize     : Math.max(10,Math.min(width,height)*0.5)
        antialiasing       : true
        font.bold          : true
        anchors.fill       : parent
        anchors.margins    : parent.anchors.margins
        verticalAlignment  : Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
