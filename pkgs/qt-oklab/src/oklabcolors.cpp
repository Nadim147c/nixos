#include "oklabcolors.h"
#include <cmath>
#include <algorithm>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

OkLabSingleton::OkLabSingleton(QObject *parent) : QObject(parent) {}

double OkLabSingleton::linearized(double component) {
    if (component <= 0.040449936) {
        return normalize(component / 12.92);
    }
    return normalize(std::pow((component + 0.055) / 1.055, 2.4));
}

double OkLabSingleton::delinearized(double component) {
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

OkLchSingleton::OkLchSingleton(QObject *parent) : QObject(parent) {}

OkLch OkLchSingleton::fromLab(const OkLab &lab) const {
    const double c = std::sqrt(lab.a * lab.a + lab.b * lab.b);
    double h = std::atan2(lab.b, lab.a) * (180.0 / M_PI);
    if (h < 0.0) {
        h += 360.0;
    }
    return OkLch(lab.l, c, h);
}

OkLab OkLchSingleton::toLab(const OkLch &lch) const {
    const double hRad = lch.h * (M_PI / 180.0);
    const double a = lch.c * std::cos(hRad);
    const double b = lch.c * std::sin(hRad);
    return OkLab(lch.l, a, b);
}

OkLch OkLchSingleton::fromColor(const QColor &c) const {
    static OkLabSingleton labSingleton;
    return fromLab(labSingleton.fromColor(c));
}

OkLch OkLchSingleton::blend(const OkLch &src, const OkLch &dst, double r) const {
    const double l = src.l + (dst.l - src.l) * r;
    const double c = src.c + (dst.c - src.c) * r;

    double dh = dst.h - src.h;
    if (dh > 180.0) {
        dh -= 360.0;
    } else if (dh < -180.0) {
        dh += 360.0;
    }

    double h = src.h + dh * r;
    if (h < 0.0) h += 360.0;
    if (h >= 360.0) h -= 360.0;

    return OkLch(l, c, h);
}

OkLch OkLchSingleton::blendHue(const OkLch &from, const OkLch &to, double ratio) const {
    double dh = to.h - from.h;

    if (dh > 180.0) {
        dh -= 360.0;
    } else if (dh < -180.0) {
        dh += 360.0;
    }

    double blendedHue = from.h + dh * ratio;

    if (blendedHue < 0.0) {
        blendedHue += 360.0;
    } else if (blendedHue >= 360.0) {
        blendedHue -= 360.0;
    }

    return OkLch(from.l, from.c, blendedHue);
}

QColor OkLchSingleton::blendToColor(const OkLch &src, const OkLch &dst, double r) const {
    return toColor(blend(src, dst, r));
}

QColor OkLchSingleton::blendColors(const QColor &src, const QColor &dst, double t) const {
    const OkLch srcLch = fromColor(src);
    const OkLch dstLch = fromColor(dst);
    return toColor(blend(srcLch, dstLch, t));
}

QColor OkLchSingleton::toColor(const OkLch &lch) const {
    static OkLabSingleton labSingleton;
    return labSingleton.toColor(toLab(lch));
}
