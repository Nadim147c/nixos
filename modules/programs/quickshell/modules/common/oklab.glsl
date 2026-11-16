const float OKLCH_ACHROMATIC_EPS = 1e-4;
const float GAMUT_EPS = 1e-5;

vec3 srgb_to_linear(vec3 rgb) {
    vec3 a = abs(rgb);
    vec3 lo = a / 12.92;
    vec3 hi = pow((a + 0.055) / 1.055, vec3(2.4));
    return sign(rgb) * mix(lo, hi, step(vec3(0.04045), a));
}

vec3 linear_to_srgb(vec3 lin) {
    vec3 a = abs(lin);
    vec3 lo = a * 12.92;
    vec3 hi = 1.055 * pow(a, vec3(1.0 / 2.4)) - 0.055;
    return sign(lin) * mix(lo, hi, step(vec3(0.0031308), a));
}

vec3 oklab_from_linear(vec3 lin) {
    const mat3 M1 = mat3(0.4122214708, 0.2119034982, 0.0883024619,
                         0.5363325363, 0.6806995451, 0.2817188376,
                         0.0514459929, 0.1073969566, 0.6299787005);

    const mat3 M2 = mat3(+0.2104542553, +1.9779984951, +0.0259040371,
                         +0.7936177850, -2.4285922050, +0.7827717662,
                         -0.0040720468, +0.4505937099, -0.8086757660);

    vec3 lms = M1 * lin;
    vec3 lms_ = sign(lms) * pow(abs(lms), vec3(1.0 / 3.0));
    return M2 * lms_;
}

vec3 linear_from_oklab(vec3 lab) {
    const mat3 IM1 = mat3(+1.0000000000, +1.0000000000, +1.0000000000,
                          +0.3963377774, -0.1055613458, -0.0894841775,
                          +0.2158037573, -0.0638541728, -1.2914855480);

    const mat3 IM2 = mat3(+4.0767416621, -1.2684380046, -0.0041960863,
                          -3.3077115913, +2.6097574011, -0.7034186147,
                          +0.2309699292, -0.3413193965, +1.7076147010);

    vec3 lms_ = IM1 * lab;
    return IM2 * (lms_ * lms_ * lms_);
}

vec3 oklab_to_oklch(vec3 lab) {
    float C = length(lab.yz);
    float h = 0.0;
    if (C > OKLCH_ACHROMATIC_EPS) {
        h = mod(degrees(atan(lab.z, lab.y)) + 360.0, 360.0);
    }
    return vec3(lab.x, C, h);
}

vec3 oklch_to_oklab(vec3 lch) {
    float h = radians(lch.z);
    return vec3(lch.x, lch.y * cos(h), lch.y * sin(h));
}

vec3 srgb_to_oklab(vec3 srgb) {
    return oklab_from_linear(srgb_to_linear(srgb));
}

vec3 oklab_to_srgb(vec3 lab) {
    return linear_to_srgb(linear_from_oklab(lab));
}

vec3 srgb_to_oklch(vec3 srgb) {
    return oklab_to_oklch(srgb_to_oklab(srgb));
}

vec3 oklch_to_srgb(vec3 lch) {
    return oklab_to_srgb(oklch_to_oklab(lch));
}

bool linear_in_gamut(vec3 lin) {
    return all(greaterThanEqual(lin, vec3(-GAMUT_EPS))) &&
           all(lessThanEqual(lin, vec3(1.0 + GAMUT_EPS)));
}

vec3 oklch_to_srgb_gamut_mapped(vec3 lch) {
    float L = lch.x;
    float C = max(lch.y, 0.0);

    if (L >= 1.0) return vec3(1.0);
    if (L <= 0.0) return vec3(0.0);

    vec3 lin = linear_from_oklab(oklch_to_oklab(vec3(L, C, lch.z)));
    if (linear_in_gamut(lin)) {
        return linear_to_srgb(clamp(lin, 0.0, 1.0));
    }

    float lo = 0.0;
    float hi = C;
    for (int i = 0; i < 12; i++) {
        float mid = 0.5 * (lo + hi);
        vec3 t = linear_from_oklab(oklch_to_oklab(vec3(L, mid, lch.z)));
        if (linear_in_gamut(t)) lo = mid; else hi = mid;
    }

    lin = linear_from_oklab(oklch_to_oklab(vec3(L, lo, lch.z)));
    return linear_to_srgb(clamp(lin, 0.0, 1.0));
}
