#include "copyinterceptor.h"
#include "copyinterceptor_p.h"

#include <QClipboard>
#include <QGuiApplication>
#include <QKeyEvent>

CopyInterceptor::CopyInterceptor(QObject* parent) : d(new Private)
{
	parent->installEventFilter(this);
}
CopyInterceptor::~CopyInterceptor()
{

}

QJSValue CopyInterceptor::Private::generateJSValueFromClipboard()
{
	auto ret = paste.engine()->newObject();

	auto clipboard = QGuiApplication::clipboard();
	auto mimedata = clipboard->mimeData();

	ret.setProperty("hasText", mimedata->hasText());
	if (mimedata->hasText()) {
		ret.setProperty("text", mimedata->text());
	}

	ret.setProperty("hasHtml", mimedata->hasHtml());
	if (mimedata->hasHtml()) {
		ret.setProperty("html", mimedata->html());
	}

	ret.setProperty("hasUrls", mimedata->hasUrls());
	if (mimedata->hasUrls()) {
		ret.setProperty("urls", paste.engine()->toScriptValue(QUrl::toStringList(mimedata->urls())));
	}

	ret.setProperty("hasImage", mimedata->hasImage());
	if (mimedata->hasImage()) {
		ret.setProperty("imageData", paste.engine()->toScriptValue(mimedata->imageData()));
	}

	ret.setProperty("hasColor", mimedata->hasColor());
	if (mimedata->hasColor()) {
		ret.setProperty("colorData", paste.engine()->toScriptValue(mimedata->colorData()));
	}

	return ret;
}

QJSValue CopyInterceptor::copy()
{
	return d->copy;
}
QJSValue CopyInterceptor::paste()
{
	return d->paste;
}

void CopyInterceptor::setCopy(QJSValue val)
{
	d->copy = val;
}
void CopyInterceptor::setPaste(QJSValue val)
{
	d->paste = val;
}

bool CopyInterceptor::eventFilter(QObject *object, QEvent *event)
{
	if (auto ev = dynamic_cast<QKeyEvent*>(event)) {
		if (ev->isAutoRepeat() || ev->type() != QEvent::ShortcutOverride)
			return false;

		if (ev == QKeySequence::Copy) {
			if (!d->copy.isUndefined() && !d->copy.isNull()) {
				auto ret = d->copy.call();
				if (!ret.isUndefined() && !ret.isNull() && ret.isBool()) {
					return ret.toBool();
				}
			}
		} else if (ev == QKeySequence::Paste) {
			if (!d->paste.isUndefined() && !d->paste.isNull()) {
				auto ret = d->paste.call({d->generateJSValueFromClipboard()});
				if (!ret.isUndefined() && !ret.isNull() && ret.isBool()) {
					return ret.toBool();
				}
			}
		}
	}
	return false;
}

void CopyInterceptor::copyText(const QString &txt)
{
	QGuiApplication::clipboard()->setText(txt);
}

CopyInterceptor *CopyInterceptor::qmlAttachedProperties(QObject* on)
{
	return new CopyInterceptor(on);
}
