#include "test_harness.hpp"

#include "test_config.hpp"

#include <util/base.h>

#include <cstdarg>
#include <cstdio>

bool openAtConfiguredBaud(TestUART &uart)
{
	if (!uart.open())
		return false;
	uart.setBaudRate(testConfig().baud);
	return true;
}

void LogCapture::trampoline(int lvl, const char *msg, va_list args, void *param)
{
	auto *self = static_cast<LogCapture *>(param);

	/* va_list can only be consumed once - copy it for our own
	 * formatting so the original is left intact to forward on below. */
	va_list argsCopy;
	va_copy(argsCopy, args);
	char buf[4096];
	vsnprintf(buf, sizeof(buf), msg, argsCopy);
	va_end(argsCopy);

	{
		std::lock_guard<std::mutex> lock(self->mutex_);
		self->entries_.push_back({lvl, QString::fromUtf8(buf), QDateTime::currentMSecsSinceEpoch()});
	}

	if (self->previousHandler_)
		self->previousHandler_(lvl, msg, args, self->previousParam_);
}

void LogCapture::install()
{
	base_get_log_handler(&previousHandler_, &previousParam_);
	base_set_log_handler(&LogCapture::trampoline, this);
}

QVector<LogEntry> LogCapture::snapshot() const
{
	std::lock_guard<std::mutex> lock(mutex_);
	return entries_;
}

LogCapture &logCapture()
{
	static LogCapture instance;
	return instance;
}

bool containsMessage(const QVector<LogEntry> &entries, int fromIndex, const QString &substring)
{
	for (int i = fromIndex; i < entries.size(); ++i) {
		if (entries[i].message.contains(substring))
			return true;
	}
	return false;
}
