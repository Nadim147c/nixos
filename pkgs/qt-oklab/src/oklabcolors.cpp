#include "oklabcolors.h"
#include <cmath>
#include <algorithm>

OkLabSingleton::OkLabSingleton(QObject *parent) : QObject(parent) {}

// normalization helpers
double OkLabSingleton::linearized(double component) const {
    if (component <= 0.040449936) {
        return normalize(component / 12.92);
    }
    return normalize(std::pow((component + 0.055) / 1.055, 2.4));
}

double OkLabSingleton::delinearized(double component) const {
    if (component <= 0.0031308) {
        return normalize(component * 12.92);
    }
    return normalize(1.055 * std::pow(component, 1.0 / 2.4) - 0.055);
}

OkLab OkLabSingleton::fromColor(const QColor &c) const {
    const double lr = linearized(c.redF());
    const double lg = linearized(c.greenF());
    const double lb = linearized(c.blueF());

    const double L = 0.4122214708 * lr + 0.5363325363 * lg + 0.0514459929 * lb;
    const double M = 0.2119034982 * lr + 0.6806995451 * lg + 0.1073969566 * lb;
    const double S = 0.0883024619 * lr + 0.2817188376 * lg + 0.6299787005 * lb;

    const double l_ = std::cbrt(L);
    const double m_ = std::cbrt(M);
    const double s_ = std::cbrt(S);

    const double l = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_;
    const double a = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_;
    const double b = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_;

    return OkLab(l, a, b);
}

OkLab OkLabSingleton::blend(const OkLab &src, const OkLab &dst, double r) const {
    const double l = src.l + (dst.l - src.l) * r;
    const double a = src.a + (dst.a - src.a) * r;
    const double b = src.b + (dst.b - src.b) * r;
    return OkLab(l, a, b);
}

QColor OkLabSingleton::blendToColor(const OkLab &src, const OkLab &dst, double r) const {
    return toColor(blend(src, dst, r));
}

QColor OkLabSingleton::blendColors(const QColor &src, const QColor &dst, double t) const {
    const OkLab srcLab = fromColor(src);
    const OkLab dstLab = fromColor(dst);
    return toColor(blend(srcLab, dstLab, t));
}

QColor OkLabSingleton::toColor(const OkLab &lab) const {
    const double l_ = lab.l + 0.3963377774 * lab.a + 0.2158037573 * lab.b;
    const double m_ = lab.l - 0.1055613458 * lab.a - 0.0638541728 * lab.b;
    const double s_ = lab.l - 0.0894841775 * lab.a - 1.2914855480 * lab.b;

    const double l = l_ * l_ * l_;
    const double m = m_ * m_ * m_;
    const double s = s_ * s_ * s_;

    const double lr = +4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
    const double lg = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
    const double lb = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;

    return QColor::fromRgbF(
        delinearized(lr),
        delinearized(lg),
        delinearized(lb)
    );
}
