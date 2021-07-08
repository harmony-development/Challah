import QtQuick 2.15
import QtQuick.Layouts 1.10
import QtQuick.Controls 2.12 as QQC2
import org.kde.kirigami 2.14 as Kirigami
import com.github.HarmonyDevelopment.Challah 1.0

QQC2.Control {
	id: textMessageRoot

	topPadding: Kirigami.Units.largeSpacing
	bottomPadding: Kirigami.Units.largeSpacing
	leftPadding: Kirigami.Units.largeSpacing+tailSize
	rightPadding: Kirigami.Units.largeSpacing

	readonly property int tailSize: Kirigami.Units.largeSpacing

	background: Item {
		clip: true

		Rectangle {
			color: Kirigami.Theme.backgroundColor
			anchors.fill: tail
			anchors.topMargin: 4
			anchors.rightMargin: -textMessageRoot.tailSize
			visible: del.showAvatar
		}
		Kirigami.ShadowedRectangle {
			id: tail

			visible: del.showAvatar
			anchors {
				top: parent.top
				bottom: parent.bottom
				left: parent.left
				leftMargin: -textMessageRoot.tailSize*2
			}
			width: textMessageRoot.tailSize*3
			color: Kirigami.Theme.backgroundColor

			corners {
				topLeftRadius: 0
				topRightRadius: 0
				bottomRightRadius: textMessageRoot.tailSize*10
				bottomLeftRadius: 0
			}

			Kirigami.Theme.colorSet: Kirigami.Theme.View
			Kirigami.Theme.inherit: false
		}
		Kirigami.ShadowedRectangle {
			id: mainBG
			corners {
				topLeftRadius: 4
				topRightRadius: 4
				bottomRightRadius: 4
				bottomLeftRadius: 4
			}
			color: Kirigami.Theme.backgroundColor
			anchors.fill: parent
			anchors.leftMargin: textMessageRoot.tailSize
		}
		QQC2.Label {
			id: timestamp
			text: messageData.data.timestamp
			opacity: 0.5

			font.pointSize: -1
			font.pixelSize: Kirigami.Units.gridUnit * (2/3)
			anchors {
				bottom: parent.bottom
				right: mainBG.right
				margins: Kirigami.Units.smallSpacing
			}
		}
		QQC2.Label {
			id: dummy
			text: " "
		}
	}
	contentItem: ColumnLayout {
		QQC2.Label {
			text: del.resolvedName
			color: Kirigami.NameUtils.colorsFromString(text)

			visible: del.separateFromPrevious && !(del.isOwnMessage && Kirigami.Settings.isMobile)

			wrapMode: Text.Wrap

			Layout.fillWidth: true
		}
		TextEdit {
			id: textEdit
			text: textData.data.contentText + paddingT

			readonly property var isEmoji: /^(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+$/
			readonly property bool isEmojiOnly: isEmoji.test(textData.data.contentText)

			readonly property string paddingT: " ".repeat(Math.ceil(timestamp.implicitWidth / dummy.implicitWidth)) + "⠀"

			readOnly: true
			selectByMouse: !Kirigami.Settings.isMobile
			wrapMode: Text.Wrap

			color: Kirigami.Theme.textColor
			selectedTextColor: Kirigami.Theme.highlightedTextColor
			selectionColor: Kirigami.Theme.highlightColor

			function clamp() {
				const l = length - paddingT.length
				if (selectionEnd >= l && selectionStart >= l) {
					select(0, 0)
				} else if (selectionEnd >= l) {
					select(selectionStart, l)
				} else if (selectionStart >= l) {
					select(l, selectionEnd)
				}
			}

			onSelectionStartChanged: clamp()
			onSelectionEndChanged: clamp()

			onLinkActivated: (mu) => {
				Qt.openUrlExternally(mu)
			}

			HoverHandler {
				acceptedButtons: Qt.NoButton
				cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.IBeamCursor
			}

			Layout.fillWidth: true
		}
	}

	RelationalListener {
		id: textData
		model: timelineView.model.store
		key: del.messageID
		shape: QtObject {
			required property string contentText
		}
	}

	Layout.maximumWidth: del.recommendedSize
}
