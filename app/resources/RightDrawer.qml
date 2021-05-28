// SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.10
import QtQuick.Dialogs 1.3
import org.kde.kirigami 2.13 as Kirigami
import com.github.HarmonyDevelopment.Challah 1.0

Item {
	id: drawer

	implicitWidth: !!model ? 250 : 0

	Kirigami.Theme.inherit: true
	Kirigami.Theme.colorSet: Kirigami.Theme.View

	Rectangle {
		anchors.fill: parent

		color: Kirigami.Theme.backgroundColor

		Kirigami.Separator {
			anchors {
				top: parent.top
				left: parent.left
				bottom: parent.bottom
			}
		}
	}

	property var model: (HState.channelsModel(routerInstance.params.guildID, routerInstance.params.homeserver) || {members: null}).members

	ColumnLayout {
		spacing: 0
		anchors.fill: parent

		Kirigami.ApplicationHeader {
			z: 2
			Layout.fillWidth: true

			contentItem: ColumnLayout {
				anchors {
					verticalCenter: parent.verticalCenter
					left: parent.left
					right: parent.right
				}

				Kirigami.Heading {
					leftPadding: Kirigami.Units.largeSpacing
					//: a heading for the right drawer which shows guild info
					text: qsTr("Guild Info")
					Layout.fillWidth: true
				}
			}
			pageDelegate: Item {}
		}

		ListView {
			id: listy

			model: drawer.model
			clip: true

			Kirigami.Theme.inherit: true
			Kirigami.Theme.colorSet: Kirigami.Theme.View

			Layout.fillWidth: true
			Layout.fillHeight: true

			header: Control {
				leftPadding: Kirigami.Units.largeSpacing
				topPadding: Kirigami.Units.largeSpacing
				bottomPadding: Kirigami.Units.largeSpacing
				Kirigami.Theme.colorSet: Kirigami.Theme.Header

				width: parent.width

				background: Rectangle {
					color: Kirigami.Theme.backgroundColor
					Kirigami.Theme.colorSet: Kirigami.Theme.Header

					Kirigami.Separator {
						anchors {
							left: parent.left
							top: parent.top
							bottom: parent.bottom
						}
					}
				}

				contentItem: ColumnLayout {
					Kirigami.Theme.colorSet: Kirigami.Theme.Header
					Kirigami.Avatar {
						source: (drawer.model || {picture: ""}).picture
						name: (drawer.model || {name: ""}).name

						FileDialog {
							id: fileDialog
							title: "Please choose a file"
							folder: shortcuts.pictures
							onAccepted: {
								drawer.model.parentModel.uploadFile(
									fileDialog.fileUrl,
									function(url) {
										drawer.model.parentModel.setGuildPicture(url)
									},
									function() {
										root.showPassiveNotification(qsTr("Failed to upload file"))
									},
									function(progress) {},
									function() {}
								)
							}
						}

						ImagePopup {
							id: imagePopup
							source: (drawer.model || {picture: ""}).picture
						}

						actions.main: Kirigami.Action {
							onTriggered: imagePopup.open()
						}
						actions.secondary: Kirigami.Action {
							icon.name: "camera-photo-symbolic"
							onTriggered: fileDialog.open()
						}

						Layout.preferredWidth: Kirigami.Units.gridUnit * 5
						Layout.preferredHeight: Kirigami.Units.gridUnit * 5
						Layout.alignment: Qt.AlignHCenter
					}

					Kirigami.Heading {
						text: (drawer.model || {name: ""}).name
						level: 2

						horizontalAlignment: Text.AlignHCenter
						Layout.fillWidth: true
					}
					Label {
						text: qsTr("%L1 members").arg(listy.count)
						opacity: 0.7

						horizontalAlignment: Text.AlignHCenter
						Layout.fillWidth: true
					}
				}
			}

			delegate: Kirigami.AbstractListItem {
				hoverEnabled: false
				highlighted: false
				contentItem: RowLayout {
					Kirigami.Avatar {
						name: display
						source: decoration

						Layout.preferredWidth: Kirigami.Units.gridUnit * 2
						Layout.preferredHeight: Kirigami.Units.gridUnit * 2
					}
					Label {
						text: display
						verticalAlignment: Text.AlignVCenter

						Layout.fillWidth: true
						Layout.fillHeight: true
					}
				}
			}
		}
	}

}
