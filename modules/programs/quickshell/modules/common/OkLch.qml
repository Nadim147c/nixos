pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {

    function fromColor(color: color): var {
        const lab = OkLab.fromColor(color);
        const a = lab.a;
        const b = lab.b;
        const c = Math.sqrt(a * a + b * b);
        const h = Math.atan2(b, a);
        return {
            l: lab.l,
            c,
            h
        };
    }

    function blendHue(src: color, dst: color, ratio: double): color {
        const a = fromColor(src);
        const b = fromColor(dst);

        const diff = Utils.degreeDistance(a.h, b.h);
        const h = Utils.normalizeDegree(a.h + diff * ratio);

        const finalLch = {
            l: a.l,
            c: b.c,
            h
        };
        return toColor(finalLch);
    }

    function toColor(lch: var): color {
        const l = lch.l;
        const a = lch.c * Math.cos(lch.h);
        const b = lch.c * Math.sin(lch.h);
        const lab = {
            l,
            a,
            b
        };
        return OkLab.toColor(lab);
    }
}
