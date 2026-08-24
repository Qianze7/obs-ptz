#include "socat_harness.hpp"

#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QThread>

#include <chrono>
#include <iostream>

SocatHarness::SocatHarness()
{
	vport1_ = tempDir_.filePath("vport1");
	vport2_ = tempDir_.filePath("vport2");
}

SocatHarness::~SocatHarness()
{
	kill();
}

bool SocatHarness::isAvailable()
{
	return !QStandardPaths::findExecutable("socat").isEmpty();
}

bool SocatHarness::waitForSymlinks(int waitMs)
{
	auto deadline = std::chrono::steady_clock::now() + std::chrono::milliseconds(waitMs);
	while (std::chrono::steady_clock::now() < deadline) {
		if (QFileInfo::exists(vport1_) && QFileInfo::exists(vport2_))
			return true;
		QThread::msleep(50);
	}
	return false;
}

bool SocatHarness::start(int waitMs)
{
	/* Stale symlinks from a previous run at these same paths make socat
	 * balk at the paths already existing - remove first, matching
	 * scripts/test-uart-disconnect.sh's start_socat(). */
	QFile::remove(vport1_);
	QFile::remove(vport2_);

	process_.setProgram("socat");
	process_.setArguments({"-d", "-d", "pty,raw,echo=0,link=" + vport1_, "pty,raw,echo=0,link=" + vport2_});
	process_.start();
	if (!process_.waitForStarted(waitMs)) {
		std::cerr << "socat failed to start: " << process_.errorString().toStdString() << "\n";
		return false;
	}
	if (!waitForSymlinks(waitMs)) {
		std::cerr << "socat did not create the virtual port pair within " << waitMs << "ms\n";
		return false;
	}
	return true;
}

void SocatHarness::kill()
{
	if (process_.state() != QProcess::NotRunning) {
		process_.kill();
		process_.waitForFinished(2000);
	}
}

bool SocatHarness::restart(int waitMs)
{
	kill();
	return start(waitMs);
}

void ManualPromptTrigger::triggerDisconnect()
{
	std::cout << "\n>>> Unplug the DUT's serial adapter (port A) now, then press Enter... " << std::flush;
	std::cin.get();
}

void ManualPromptTrigger::triggerReconnect()
{
	std::cout << "\n>>> Replug the DUT's serial adapter (port A) now, then press Enter... " << std::flush;
	std::cin.get();
}
