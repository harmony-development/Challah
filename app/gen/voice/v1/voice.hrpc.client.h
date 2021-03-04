#include <QByteArray>
#include <QCoreApplication>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QString>
#include <variant>
#include "voice/v1/voice.pb.h"
#include <QWebSocket>
#include "google/protobuf/empty.pb.h"

class Receive__protocol_voice_v1_Signal__Send__protocol_voice_v1_ClientSignal__Stream : public QWebSocket {
	
	Q_OBJECT

	public: Q_SIGNAL void receivedMessage(protocol::voice::v1::Signal msg);

	public: Receive__protocol_voice_v1_Signal__Send__protocol_voice_v1_ClientSignal__Stream(const QString &origin = QString(), QWebSocketProtocol::Version version = QWebSocketProtocol::VersionLatest, QObject *parent = nullptr) : QWebSocket(origin, version, parent)
	{
		connect(this, &QWebSocket::binaryMessageReceived, [=](const QByteArray& msg) {
			protocol::voice::v1::Signal incoming;

			if (!incoming.ParseFromArray(msg.constData(), msg.length())) {
				return;
			}

			Q_EMIT receivedMessage(incoming);
		});
	}


	public: [[nodiscard]] bool send(const protocol::voice::v1::ClientSignal& in) {
		std::string strData;
		if (!in.SerializeToString(&strData)) {
			return false;
		}
		QByteArray data = QByteArray::fromStdString(strData);

		auto count = sendBinaryMessage(data);
		return count == data.length();
	}
};

class VoiceServiceServiceClient {
	QString host;
	bool secure;
	QString httpProtocol() const { return secure ? QStringLiteral("https://") : QStringLiteral("http://"); }
	QString wsProtocol() const { return secure ? QStringLiteral("wss://") : QStringLiteral("ws://"); }
	public: explicit VoiceServiceServiceClient(const QString& host, bool secure) : host(host), secure(secure) {}
public:
	template<typename T> using Result = std::variant<T, QString>;
	[[ nodiscard ]] Receive__protocol_voice_v1_Signal__Send__protocol_voice_v1_ClientSignal__Stream* Connect(QMap<QByteArray,QString> headers = {});
};
