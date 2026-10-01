#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;
    vec4 fallback;
    float lightness;
    float chroma;
    float ringSize;
    float ringPadding;
    bool clampColors;
};

vec3 srgb_to_linear(vec3 rgb) {
    vec3 c = max(rgb, vec3(0.0));
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

vec3 linear_to_srgb(vec3 c) {
    vec3 linear = max(c, vec3(0.0));
    return mix(linear * 12.92, 1.055 * pow(linear, vec3(1.0 / 2.4)) - 0.055, step(vec3(0.0031308), linear));
}

vec3 linear_from_oklab(vec3 oklab) {
    const mat3 m1 = mat3(+1.000000000, +1.000000000, +1.000000000,
                         +0.396337777, -0.105561346, -0.089484178,
                         +0.215803757, -0.063854173, -1.291485548);

    const mat3 m2 = mat3(+4.076724529, -1.268143773, -0.004111989,
                         -3.307216883, +2.609332323, -0.703476310,
                         +0.230759054, -0.341134429, +1.706862569);
    vec3 lms = m1 * oklab;
    return m2 * (lms * lms * lms);
}

vec3 oklch_to_oklab(vec3 lch) {
    return vec3(lch.x, lch.y * cos(lch.z), lch.y * sin(lch.z));
}

vec3 oklch_to_srgb_raw(vec3 lch) {
    return linear_to_srgb(linear_from_oklab(oklch_to_oklab(lch)));
}

void main() {
    float minDim = min(size.x, size.y);
    float boxRadius = minDim * 0.5;

    float outerRadiusPx = boxRadius - ringPadding;
    float innerRadiusPx = outerRadiusPx - ringSize;

    float outerRadius = outerRadiusPx / boxRadius;
    float innerRadius = innerRadiusPx / boxRadius;

    vec2 st = (qt_TexCoord0 - 0.5) * 2.0;

    if (size.x > size.y) {
        st.x *= size.x / size.y;
    } else {
        st.y *= size.y / size.x;
    }

    float dist = length(st);

    float aa = fwidth(dist);

    float ringAlpha = smoothstep(outerRadius + aa, outerRadius - aa, dist) *
                      smoothstep(innerRadius - aa, innerRadius + aa, dist);

    if (ringAlpha <= 0.0) {
        discard;
    }

    float angle = atan(-st.y, -st.x);
    vec3 lch = vec3(lightness, chroma, angle);

    vec3 rawRgb = oklch_to_srgb_raw(lch);

    bool isInGamut = all(greaterThanEqual(rawRgb, vec3(0.0))) && all(lessThanEqual(rawRgb, vec3(1.0)));

    if (!isInGamut && !clampColors) {
        fragColor = fallback * ringAlpha * qt_Opacity;
    } else {
        vec3 finalRgb = clamp(rawRgb, 0.0, 1.0);
        fragColor = vec4(finalRgb, 1.0) * ringAlpha * qt_Opacity;
    }
}
