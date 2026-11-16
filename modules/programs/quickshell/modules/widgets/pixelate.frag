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
    float imagePixelSize;
    float levels;
};

float bayerMatrix2x2(ivec2 cell) {
    ivec2 p = cell & 1;
    return float((p.x ^ p.y) * 2 + p.x) / 4.0 - 0.375;
}

void main() {
    float effectiveGrid = max(imagePixelSize, 1.0);

    vec2 cell = floor((qt_TexCoord0 * size) / effectiveGrid);
    vec2 pixelizedUV = (cell + 0.5) * (effectiveGrid / size);

    vec4 texColor = texture(imageTexture, pixelizedUV);
    vec3 rgb = texColor.rgb;

    if (levels > 1.0) {
        vec3 lab = oklab_from_linear(srgb_to_linear(rgb));
        float dither = bayerMatrix2x2(ivec2(cell));
        lab.x = clamp(lab.x + (dither / levels), 0.0, 1.0);
        lab.x = round(lab.x * levels) / levels;
        rgb = linear_to_srgb(linear_from_oklab(lab));
    }

    fragColor = vec4(rgb, texColor.a) * qt_Opacity;
}
