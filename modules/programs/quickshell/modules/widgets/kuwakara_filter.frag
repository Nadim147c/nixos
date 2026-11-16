#version 440
#extension GL_GOOGLE_include_directive : require
#include "../common/oklab.glsl"

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

float bayerMatrix2x2(ivec2 cell) {
    ivec2 p = cell & 1;
    return float((p.x ^ p.y) * 2 + p.x) / 4.0 - 0.375;
}

// Works on premultiplied RGBA (what Qt textures contain) and returns premultiplied RGBA.
vec4 kuwaharaPass(sampler2D tex, vec2 uv, vec2 invTexSize, int r) {
    vec4 mean[4];
    vec3 variance[4];

    for (int i = 0; i < 4; ++i) {
        mean[i] = vec4(0.0);
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
                vec4 c = texture(tex, uv + vec2(x, y) * invTexSize);
                mean[q] += c;
                variance[q] += c.rgb * c.rgb;
            }
        }
        mean[q] /= samplesPerQuadrant;
        variance[q] = abs(variance[q] / samplesPerQuadrant - mean[q].rgb * mean[q].rgb);
    }

    float minVar = variance[0].r + variance[0].g + variance[0].b;
    vec4 result = mean[0];

    for (int i = 1; i < 4; ++i) {
        float varVal = variance[i].r + variance[i].g + variance[i].b;
        if (varVal < minVar) {
            minVar = varVal;
            result = mean[i];
        }
    }

    return result;
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

void main() {
    float effectiveGrid = max(pixelSize, 1.0);
    vec2 cell = floor((qt_TexCoord0 * size) / effectiveGrid);
    vec2 pixelizedUV = (cell + 0.5) * (effectiveGrid / size);

    vec4 texColor = kuwaharaFilter(imageTexture, pixelizedUV, 1.0 / size, kuwaharaStrength);

    float alpha = texColor.a;
    vec3 srcRgb = (alpha > 1e-4) ? clamp(texColor.rgb / alpha, 0.0, 1.0) : vec3(0.0);
    vec3 targetRgb = (targetColor.a > 1e-4) ? targetColor.rgb / targetColor.a : targetColor.rgb;

    vec3 srcOklch = srgb_to_oklch(srcRgb);
    vec3 targetOklch = srgb_to_oklch(targetRgb);

    float finalChroma = srcOklch.y;
    if (targetOklch.y < 0.05) {
        finalChroma = targetOklch.y;
    }

    float lightness = srcOklch.x;

    if (bitDepth >= 1.0) {
        float dither = bayerMatrix2x2(ivec2(cell));
        lightness = clamp(lightness + (dither / bitDepth), 0.0, 1.0);
        lightness = round(lightness * bitDepth) / bitDepth;
    }

    vec3 finalOklch = vec3(lightness, finalChroma, targetOklch.z);
    vec3 finalRgb = oklch_to_srgb(finalOklch);

    fragColor = vec4(finalRgb * alpha, alpha) * qt_Opacity;
}
