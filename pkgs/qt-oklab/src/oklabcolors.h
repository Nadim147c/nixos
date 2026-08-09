#ifndef OKLABCOLORS_H
#define OKLABCOLORS_H

#include <QObject>
#include <QColor>
#include <QtQml/qqmlregistration.h>

struct OkLab {
    Q_GADGET
    QML_VALUE_TYPE(oklab)

    Q_PROPERTY(double l MEMBER l)
    Q_PROPERTY(double a MEMBER a)
    Q_PROPERTY(double b MEMBER b)

public:
    double l = 0.0;
    double a = 0.0;
    double b = 0.0;

    OkLab() = default;
    OkLab(double l, double a, double b) : l(l), a(a), b(b) {}

    bool operator==(const OkLab &other) const {
        return l == other.l && a == other.a && b == other.b;
    }
    bool operator!=(const OkLab &other) const { return !(*this == other); }
};

class OkLabSingleton : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(OkLab)

public:
    explicit OkLabSingleton(QObject *parent = nullptr);

    Q_INVOKABLE OkLab fromColor(const QColor &c) const;
    Q_INVOKABLE OkLab blend(const OkLab &src, const OkLab &dst, double r) const;
    Q_INVOKABLE QColor blendToColor(const OkLab &src, const OkLab &dst, double r) const;
    Q_INVOKABLE QColor blendColors(const QColor &src, const QColor &dst, double t) const;
    Q_INVOKABLE QColor toColor(const OkLab &lab) const;

private:
    double linearized(double component) const;
    double delinearized(double component) const;

    static inline double normalize(double val) {
        return std::clamp(val, 0.0, 1.0);
    }
};

#endif // OKLABCOLORS_H
