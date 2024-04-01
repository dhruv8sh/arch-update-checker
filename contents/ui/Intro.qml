import QtQuick
import QtQuick.Layouts

import QtQuick.Controls as QQC2
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import "./Pages/" as Pages

PlasmaExtras.Representation {
    id: fullIntro
    collapseMarginsHint: true
    Layout.minimumHeight: 500
    Layout.minimumWidth: 500
    property int pageNo: 0;
    anchors.fill: parent
    header: PlasmaExtras.PlasmoidHeading {
        focus: true
        contentItem:PlasmaExtras.Heading {
            id: pageNameText
            Layout.alignment: Qt.AlignCenter
            text: i18n("Welcome")
            Behavior on text {
                NumberAnimation {
                    id: animateOpacity
                    target: pageNameText
                    properties: "opacity"
                    from: 0
                    to: 1.0
                    easing.type: Easing.InOutQuad
                    duration: 1500
                }
            }
        }
    }
    footer: PlasmaExtras.PlasmoidHeading {
        focus: true
        contentItem: RowLayout {
            Layout.fillWidth: true
            PlasmaComponents.ToolButton {
                Layout.alignment: Qt.AlignLeft
                text: i18n("Done")
                icon.name: "dialog-ok-apply"
                onClicked: {}
            }
            PlasmaComponents.ToolButton {
                Layout.alignment: Qt.AlignRight
                icon.name: "go-previous-view-page"
                text: i18n("Previous")
                onClicked: {
                    pageNo --;
                    updateHeading();
                    stack2.pop();
                }
                enabled: pageNo != 0
            }
            PlasmaComponents.ToolButton {
                Layout.alignment: Qt.AlignRight
                icon.name: "go-next-view-page"
                text: i18n("Next")
                onClicked: {
                    pageNo ++;
                    stack2.push(getPage())
                }
                enabled: pageNo != 5
            }
        }
    }
    QQC2.StackView {
        id: stack2
        anchors.fill: parent
        initialItem: Pages.Welcome{}
    }

    function getPage() {
        updateHeading();
        switch( pageNo ) {
            case 0: return "Pages/Welcome.qml";
            case 1: return "Pages/Pacman.qml";
            case 2: return "Pages/AUR.qml";
            case 3: return "Pages/Behavior.qml";
            case 4: return "Pages/Appearance.qml";
            case 5: return "Pages/Donate.qml";
        }
    }
    function updateHeading() {
        switch( pageNo ) {
            case 0: pageNameText.text = "Welcome"; break;
            case 1: pageNameText.text = "Pacman"; break;
            case 2: pageNameText.text = "AUR"; break;
            case 3: pageNameText.text = "Behavior"; break;
            case 4: pageNameText.text = "Appearance"; break;
            case 5: pageNameText.text = "Donate"; break;
        }
    }
}
