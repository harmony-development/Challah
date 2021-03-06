#include <QJsonArray>

#include "state.h"

#include "members_store_p.h"

enum Role {
	Name,
	AvatarURL,
};

MembersStore::MembersStore(State* state) : ChallahAbstractRelationalModel(state), d(new Private), s(state)
{

}

MembersStore::~MembersStore()
{

}

QPair<QString, quint64> from(const QVariant& hi)
{
	const auto js = hi.value<QVariantList>();
	return qMakePair(js[0].toString(), js[1].toString().toULongLong());
}

QVariant to(const QPair<QString, quint64>& v)
{
	QJsonArray it;
	it << v.first << QString::number(v.second);
	return it;
}

bool MembersStore::checkKey(const QVariant& key)
{
	auto it = from(key);
	return d->data.contains(it.first) && d->data[it.first].contains(it.second);
}

bool MembersStore::canFetchKey(const QVariant& key)
{
	Q_UNUSED(key);

	return true;
}

void MembersStore::fetchKey(const QVariant& key)
{
	auto it = from(key);

	if (it.second == 0) return;

	protocol::chat::v1::GetUserRequest req;
	req.set_user_id(it.second);

	s->api()->clientForHomeserver(it.first).then([req, it, this](auto r) {
		if (!r.ok()) {
			return;
		}

		auto c = r.value();

		c->chatKit()->GetUser(req).then([this, it](auto r) {
			if (!resultOk(r)) {
				return;
			}
			protocol::chat::v1::GetUserResponse resp = unwrap(r);
			d->data[it.first][it.second] = resp;
			Q_EMIT keyAdded(to(it));
		});
	});
}

QVariant MembersStore::data(const QVariant& key, int role)
{
	auto it = from(key);

	if (!checkKey(key)) {
		return QVariant();
	}

	switch (role) {
	case Role::Name:
		return QString::fromStdString(d->data[it.first][it.second].user_name());
	case Role::AvatarURL:
		return QString::fromStdString(d->data[it.first][it.second].user_avatar());
	}

	return QVariant();
}

QHash<int,QByteArray> MembersStore::roleNames()
{
	return {
		{ Name,"name" },
		{ AvatarURL, "avatarURL" },
	};
}
