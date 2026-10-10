#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D imageTexture;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;
    vec4 targetColor;
    float bitDepth;
    float pixelSize;
    float kuwaharaStrength;
};

vec3 srgb_to_linear(vec3 rgb) {
    vec3 c = max(rgb, vec3(0.0));
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

vec3 linear_to_srgb(vec3 c) {
    vec3 linear = max(c, vec3(0.0));
    return mix(linear * 12.92, 1.055 * pow(linear, vec3(1.0 / 2.4)) - 0.055, step(vec3(0.0031308), linear));
}

vec3 oklab_from_linear(vec3 linear) {
    const mat3 im1 = mat3(0.4121656120, 0.2118591070, 0.0883097947,
                          0.5362752080, 0.6807189584, 0.2818474174,
                          0.0514575653, 0.1074065790, 0.6302613616);

    const mat3 im2 = mat3(+0.2104542553, +1.9779984951, +0.0259040371,
                          +0.7936177850, -2.4285922050, +0.7827717662,
                          -0.0040720468, +0.4505937099, -0.8086757660);

    vec3 lms = im1 * linear;
    return im2 * (sign(lms) * pow(abs(lms), vec3(1.0 / 3.0)));
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

vec3 oklab_to_oklch(vec3 lab) {
    float c = length(lab.yz);
    float h = atan(lab.z, lab.y);
    return vec3(lab.x, c, h);
}

vec3 oklch_to_oklab(vec3 lch) {
    return vec3(lch.x, lch.y * cos(lch.z), lch.y * sin(lch.z));
}

vec3 srgb_to_oklch(vec3 rgb) {
    return oklab_to_oklch(oklab_from_linear(srgb_to_linear(rgb)));
}

vec3 oklch_to_srgb(vec3 lch) {
    return clamp(linear_to_srgb(linear_from_oklab(oklch_to_oklab(lch))), 0.0, 1.0);
}

vec4 kuwaharaPass(sampler2D tex, vec2 uv, vec2 invTexSize, int r) {
    vec3 mean[4];
    vec3 variance[4];

    for (int i = 0; i < 4; ++i) {
        mean[i] = vec3(0.0);
        variance[i] = vec3(0.0);
    }

    ivec4 bounds[4];
    bounds[0] = ivec4(-r, 0, -r, 0);
    bounds[1] = ivec4( 0, r, -r, 0);
    bounds[2] = ivec4(-r, 0,  0, r);
    bounds[3] = ivec4( 0, r,  0, r);

    float samplesPerQuadrant = float((r + 1) * (r + 1));

    for (int q = 0; q < 4; ++q) {
        for (int x = bounds[q].x; x <= bounds[q].y; ++x) {
            for (int y = bounds[q].z; y <= bounds[q].w; ++y) {
                vec3 c = texture(tex, uv + vec2(x, y) * invTexSize).rgb;
                mean[q] += c;
                variance[q] += c * c;
            }
        }
        mean[q] /= samplesPerQuadrant;
        variance[q] = abs(variance[q] / samplesPerQuadrant - mean[q] * mean[q]);
    }

    float minVar = variance[0].r + variance[0].g + variance[0].b;
    vec3 finalColor = mean[0];

    for (int i = 1; i < 4; ++i) {
        float varVal = variance[i].r + variance[i].g + variance[i].b;
        if (varVal < minVar) {
            minVar = varVal;
            finalColor = mean[i];
        }
    }

    float alpha = texture(tex, uv).a;
    return vec4(finalColor, alpha);
}

vec4 kuwaharaFilter(sampler2D tex, vec2 uv, vec2 invTexSize, float strength) {
    float blendFactor = clamp(strength, 0.0, 1.0);
    vec4 rad1 = kuwaharaPass(tex, uv, invTexSize, 1);

    if (blendFactor <= 0.001) {
        return rad1;
    }

    vec4 rad2 = kuwaharaPass(tex, uv, invTexSize, 2);
    return mix(rad1, rad2, blendFactor);
}

float quantizeValue(float value, float bitDepth) {
    float levels = pow(2.0, bitDepth) - 1.0;
    return floor(value * levels + 0.5) / levels;
}

void main() {
    float effectiveGrid = max(pixelSize, 1.0);
    vec2 pixelizedUV = (floor((qt_TexCoord0 * size) / effectiveGrid) + 0.5) * (effectiveGrid / size);

    vec4 texColor = kuwaharaFilter(imageTexture, pixelizedUV, 1.0 / size, kuwaharaStrength);

    vec3 srcOklch = srgb_to_oklch(texColor.rgb);
    vec3 targetOklch = srgb_to_oklch(targetColor.rgb);

    float finalChroma = srcOklch.y;
    if (targetOklch.y < 0.05) {
        finalChroma = targetOklch.y;
    }

    vec3 finalOklch = vec3(quantizeValue(srcOklch.x, bitDepth), finalChroma, targetOklch.z);
    vec3 finalRgb = oklch_to_srgb(finalOklch);

    fragColor = vec4(finalRgb * texColor.a, texColor.a) * qt_Opacity;
}
