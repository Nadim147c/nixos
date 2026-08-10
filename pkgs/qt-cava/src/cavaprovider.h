#ifndef CAVAPROVIDER_H
#define CAVAPROVIDER_H

#include <QObject>
#include <QProcess>
#include <QVariantList>
#include <QtQml/qqmlregistration.h>

class CavaSingleton : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(Cava)

    Q_PROPERTY(QVariantList values READ values NOTIFY valuesChanged)
    Q_PROPERTY(double total READ total NOTIFY valuesChanged)
    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)

public:
    explicit CavaSingleton(QObject *parent = nullptr);
    ~CavaSingleton() override;

    QVariantList values() const { return m_values; }
    double total() const { return m_total; }
    bool isRunning() const { return m_process && m_process->state() == QProcess::Running; }

    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();

signals:
    void valuesChanged();
    void runningChanged();

private slots:
    void handleReadyRead();
    void handleProcessError(QProcess::ProcessError error);

private:
    QProcess *m_process = nullptr;
    QByteArray m_buffer;
    QVariantList m_values;
    double m_total = 0.0;
};

#endif // CAVAPROVIDER_H
