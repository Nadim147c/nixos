pragma Singleton

import Quickshell

Singleton {
    function clamp(low: real, value: real, high: real): real {
        if (value > high)
            return high;
        if (value < low)
            return low;
        return value;
    }

    function normalize(value: real): real {
        return clamp(0, value, 1);
    }

    function degreeDistance(a: real, b: real): real {
        return ((a - b) + 180) % 360 - 180;
    }

    function normalizeDegree(deg: real): real {
        // The double modulo ensures negative numbers wrap around correctly
        return ((deg % 360) + 360) % 360;
    }

    function blend(from: real, to: real, ratio: real): real {
        return from + (to - from) * ratio;
    }

    function cubicBezier(curve, x): real {
        const x1 = curve[0], y1 = curve[1], x2 = curve[2], y2 = curve[3];
        x = normalize(x);

        const getCoord = (t, p1, p2) => {
            return 3 * Math.pow(1 - t, 2) * t * p1 + 3 * (1 - t) * Math.pow(t, 2) * p2 + Math.pow(t, 3);
        };
        const getSlope = (t, p1, p2) => {
            return 3 * Math.pow(1 - t, 2) * p1 + 6 * (1 - t) * t * (p2 - p1) + 3 * Math.pow(t, 2) * (1 - p2);
        };

        let t = x;
        for (let i = 0; i < 8; i++) {
            const tx = getCoord(t, x1, x2) - x;
            const slope = getSlope(t, x1, x2);
            if (Math.abs(slope) < 1e-6)
                break;
            t -= tx / slope;
        }

        return getCoord(t, y1, y2);
    }
}
