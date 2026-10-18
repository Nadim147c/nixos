#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D imageTexture;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 borderColor;
    vec2 size;
    float radius;
    float borderPixelSize;
    float borderWidth;
};

float sdOctagonalBox(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b;
    float d = max(q.x, q.y);
    float chamfer = (q.x + q.y + r) * 0.70710678118;
    return max(d, chamfer);
}

void main() {
    vec2 pos = (floor((qt_TexCoord0 * size) / borderPixelSize) + 0.5) * borderPixelSize;

    vec2 boxCenter = size * 0.5;
    vec2 pMain = pos - boxCenter;

    float effectiveRadius = floor(radius) * borderPixelSize;
    float effectiveBorder = floor(borderWidth) * borderPixelSize;

    float dist = sdOctagonalBox(pMain, boxCenter, effectiveRadius);

    vec4 color = vec4(0.0);

    if (dist <= 0.0) {
        if (dist <= -effectiveBorder) {
            color = texture(imageTexture, qt_TexCoord0);
        } else {
            color = borderColor;
        }
    }

    fragColor = color * qt_Opacity;
}

