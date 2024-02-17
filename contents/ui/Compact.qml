import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.workspace.components as WorkspaceComponents
import org.kde.plasma.plasmoid

Item {
    id: buttonView
    property string archAmount: "0"
    property string aurAmount: "0"

    property string updateAvailableIcon: "software-update-available.svg"
    property string refreshIcon: "arch-unknown.svg"

    property bool debug: plasmoid.configuration.debugMode
    property bool dotVisible: plasmoid.configuration.dotVisible

    property bool isUpdating: false
    property bool isRefreshing: false

    property bool isVertical: plasmoid.formFactor == PlasmaCore.Types.Vertical

    function updateIcon() {
        if ( isRefreshing ) {
            dotIcon.source = refreshIcon
        } else {
            dotIcon.source = updateAvailableIcon
        }
    }
    function updateToolTipText() {
        if(isRefreshing) {
            root.updateToolTipText("Hold on... ↻")
        }
        root.updateToolTipText("Arch: " + archAmount + " Aur: " + aurAmount)
        console.log(archAmount)
        console.log(aurAmount)
    }
    function updateNeeded() {
        return (parseInt(archAmount, 10) + parseInt(aurAmount, 10)) > 0
    }
    Connections {
        target: cmd
        function onConnected(source) {
            if (debug) console.log('ARCHUPDATE - cmd connected: ', source)
            isRefreshing = true
            updateIcon()
        }
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            if (debug) console.log('ARCHUPDATE - cmd exited: ', JSON.stringify({cmd, exitCode, exitStatus, stdout, stderr}))
            // update the count after the update
            if (isUpdating || stdout === '') {
                isUpdating = false
                onLClick()
            }

            const cmdIsAur = cmd === plasmoid.configuration.countAurCommand
            const cmdIsArch = cmd === plasmoid.configuration.countArchCommand
            if (cmdIsArch) archAmount =  stdout.replace(/\n/g, '')
            if (cmdIsAur) aurAmout =  stdout.replace(/\n/g, '')
            // handle the result for the checker
            if (cmd === "konsole -v") checker.validateKonsole(stderr)
            if (cmd === "checkupdates --version") checker.validateCheckupdates(stderr)

            isRefreshing = false
            updateIcon()
        }
    }
    Item {
        id: container
        height: parent.height
        width: height
        anchors.centerIn: parent

    }
    PlasmoidIcon {
        id: dotIcon
        height: container.height
        width: height
        source: updateAvailableIcon
    }
    OverlayBadge{
        aurAmount: ` ${parseInt(aurAmount)} `
        archAmount: ` ${parseInt(archAmount)} `
    }

    MouseArea{
        anchors.fill: buttonView
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: (mouse) => {
            if( mouse.button == Qt.LeftButton ) {
                isRefreshing = true
                updateIcon()
                updater.countAll()
                isRefreshing = false
                humanMomentTimer.start()
            } else if( mouse.button == Qt.MiddleButton ) {
                isUpdating = true;
                updateIcon()
                updater.launchUpdate()
                isUpdating = false
                humanMomentTimer.start()
            }
        }
        Timer {
            id: humanMomentTimer
            interval: Kirigami.Units.humanMoment;
            onTriggered: updateIcon()
            running: true;
            repeat: false;
        }
    }
}
