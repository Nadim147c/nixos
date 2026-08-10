#include "cavaprovider.h"
#include <QDebug>

#ifndef CAVA_BAR_COUNT
#define CAVA_BAR_COUNT 16
#endif

#ifndef CAVA_BIN
#define CAVA_BIN "cava"
#endif

CavaSingleton::CavaSingleton(QObject *parent) : QObject(parent) {
    m_process = new QProcess(this);

    m_values.reserve(CAVA_BAR_COUNT);
    for (int i = 0; i < CAVA_BAR_COUNT; ++i) {
        m_values.append(0.0);
    }

    connect(m_process, &QProcess::readyReadStandardOutput, this, &CavaSingleton::handleReadyRead);
    connect(m_process, &QProcess::errorOccurred, this, &CavaSingleton::handleProcessError);
    connect(m_process, &QProcess::stateChanged, this, &CavaSingleton::runningChanged);

    start();
}

CavaSingleton::~CavaSingleton() {
    stop();
}

void CavaSingleton::start() {
    if (m_process->state() == QProcess::NotRunning) {
        m_process->start(CAVA_BIN, QStringList());
    }
}

void CavaSingleton::stop() {
    if (m_process->state() != QProcess::NotRunning) {
        m_process->terminate();
        if (!m_process->waitForFinished(1000)) {
            m_process->kill();
        }
    }
}

void CavaSingleton::handleReadyRead() {
    m_buffer.append(m_process->readAllStandardOutput());

    bool updated = false;
    while (m_buffer.size() >= CAVA_BAR_COUNT) {
        const char *frame = m_buffer.constData();
        double frameSum = 0.0;

        for (int i = 0; i < CAVA_BAR_COUNT; ++i) {
            const auto rawByte = static_cast<uint8_t>(frame[i]);
            const double normalizedVal = static_cast<double>(rawByte) / 255.0;

            m_values[i] = normalizedVal;
            frameSum += normalizedVal;
        }

        // Calculate average magnitude across all bars: sum / (255 * count)
        m_total = frameSum / static_cast<double>(CAVA_BAR_COUNT);

        m_buffer.remove(0, CAVA_BAR_COUNT);
        updated = true;
    }

    if (updated) {
        emit valuesChanged();
    }
}

void CavaSingleton::handleProcessError(QProcess::ProcessError error) {
    if (error == QProcess::FailedToStart) {
        qWarning() << "[CavaPlugin] Failed to start 'cava'. Make sure it is installed in PATH.";
    }
}
