import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid as Plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kquickcontrols as KQuickControls
import org.kde.kirigami as Kirigami
import "../Common/" as Common

Common.CustomPage {
	id: appearancePage
	kind: 1
	title: i18nc("@title", "Appearance")
	heading: "Appearance Settings"
	subtitle: ""
	anchors.fill: parent
	PlasmaExtras.Heading {
		Layout.alignment: Qt.AlignCenter
		text: i18n("\nAppearance Settings\n")
		wrapMode: Text.WordWrap
	}
	PlasmaExtras.Heading {
		Layout.alignment: Qt.AlignCenter
		text: i18n("Indicator Position")
		wrapMode: Text.WordWrap
		level: 2
	}
	Item {
		clip: false
		Layout.alignment: Qt.AlignCenter
		Layout.minimumWidth : 100
		Layout.minimumHeight: 100
		QQC2.RadioButton{
		anchors.left: parent.right
		anchors.top: parent.top
		LayoutMirroring.enabled: true
		text: i18n("Top-Left")
		checked: cfg.badgePosition == 0
		onCheckedChanged: {
			if( checked ) cfg.badgePosition = 0;
		}
	}
	QQC2.RadioButton{
		anchors.left: parent.right
		anchors.top: parent.top
		text: i18n("Top-Right")
		checked: cfg.badgePosition == 1
		onCheckedChanged: {
			if( checked ) cfg.badgePosition = 1;
		}
	}
	Kirigami.Icon {
		height: 100
		width: 100
		anchors.centerIn: parent
		source: "update-none-symbolic"
	}
	QQC2.RadioButton{
		anchors.left: parent.right
		anchors.bottom: parent.bottom
		LayoutMirroring.enabled: true
		checked: cfg.badgePosition == 2
		onCheckedChanged: {
			if( checked ) cfg.badgePosition = 2;
		}
		text: i18n("Bottom-Left")
	}
	QQC2.RadioButton{
		anchors.left: parent.right
		anchors.bottom: parent.bottom
		checked: cfg.badgePosition == 3
		onCheckedChanged: {
			if( checked ) cfg.badgePosition = 3;
		}
		text: i18n("Bottom-Right")
		}
	}
	PlasmaExtras.Heading {
		Layout.alignment: Qt.AlignCenter
		text: i18n("\nVersion Seperator")
		wrapMode: Text.WordWrap
		level: 2
	}
	QQC2.TextField{
		id: sprtrText
		horizontalAlignment: TextInput.AlignHCenter
		Layout.alignment: Qt.AlignCenter
		text: cfg.packageSeparator
		onTextChanged: cfg.packageSeparator = text
	}
	QQC2.Label{
		Layout.alignment: Qt.AlignCenter
		text: "v6.9"+sprtrText.text+"v9.6\n"
	}
	RowLayout{
		Layout.alignment: Qt.AlignCenter
		Common.CustomSwitch{
			text:i18n("Custom Colors")
			icon:"settings-configure"
			checked: cfg.useCustomColors
			onCheckedChanged: {
				cfg.useCustomColors = checked
			}
		}
		KQuickControls.ColorButton {
			id: dotColor
			visible: cfg.useCustomColors
			color: cfg.dotColor
			onColorChanged: cfg.dotColor = color
		}
		KQuickControls.ColorButton {
			id: textColor
			visible: cfg.useCustomColors
			color: cfg.textColor
			onColorChanged: cfg.textColor = color
		}
	}
}
