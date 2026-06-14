pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    function linearized(component: double): double {
        if (component <= 0.040449936) {
            return Utils.normalize(component / 12.92);
        }
        return Utils.normalize(Math.pow((component + 0.055) / 1.055, 2.4));
    }

    function delinearized(component: double): double {
        if (component <= 0.0031308) {
            return Utils.normalize(component * 12.92);
        }
        return Utils.normalize(1.055 * Math.pow(component, 1.0 / 2.4) - 0.055);
    }

    function fromColor(c: color): var {
        const lr = linearized(c.r);
        const lg = linearized(c.g);
        const lb = linearized(c.b);
        const l = 0.4122214708 * lr + 0.5363325363 * lg + 0.0514459929 * lb;
        const m = 0.2119034982 * lr + 0.6806995451 * lg + 0.1073969566 * lb;
        const s = 0.0883024619 * lr + 0.2817188376 * lg + 0.6299787005 * lb;

        const l_ = Math.cbrt(l);
        const m_ = Math.cbrt(m);
        const s_ = Math.cbrt(s);

        const lab = {
            l: 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
            a: 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
            b: 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_
        };
        return lab;
    }

    function blendColors(src: color, dst: color, t: double): color {
        const srcLab = fromColor(src);
        const dstLab = fromColor(dst);
        const lab = blend(srcLab, dstLab, t);
        return toColor(lab);
    }

    function blend(src: var, dst: var, t: double): var {
        const lab = {
            l: src.l + (dst.l - src.l) * t,
            a: src.a + (dst.a - src.a) * t,
            b: src.b + (dst.b - src.b) * t
        };
        return lab;
    }

    function toColor(lab: var): color {
        const l_ = lab.l + 0.3963377774 * lab.a + 0.2158037573 * lab.b;
        const m_ = lab.l - 0.1055613458 * lab.a - 0.0638541728 * lab.b;
        const s_ = lab.l - 0.0894841775 * lab.a - 1.2914855480 * lab.b;

        const l = l_ * l_ * l_;
        const m = m_ * m_ * m_;
        const s = s_ * s_ * s_;

        const lr = +4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
        const lg = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
        const lb = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;

        const r = delinearized(lr);
        const g = delinearized(lg);
        const b = delinearized(lb);

        return Qt.rgba(r, g, b);
    }
}
