#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;
    vec4 fillBG;
    vec4 borderCol;
    vec4 shadowCol;
    float radius;
    float pixelSize;
    float borderWidth;
    vec2 shadowOffset;
};

float sdRoundedBox(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + vec2(r);
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

void main() {
    vec2 pos = floor((qt_TexCoord0 * size) / pixelSize) * pixelSize;

    vec2 shadowPadding = max(shadowOffset * pixelSize, vec2(0.0));
    vec2 boxSize = size - shadowPadding;
    vec2 boxCenter = boxSize * 0.5;
    vec2 boxHalfSize = boxCenter;

    vec2 pMain = pos - boxCenter;
    float distMain = sdRoundedBox(pMain, boxHalfSize, radius * pixelSize);

    vec2 pShadow = pMain - (shadowOffset * pixelSize);
    float distShadow = sdRoundedBox(pShadow, boxHalfSize, radius * pixelSize);

    vec4 color = vec4(0.0);

    if (distShadow <= 0.0) {
        color = shadowCol;
    }

    if (distMain <= 0.0) {
        color = borderCol;
    }

    if (distMain <= -borderWidth * pixelSize) {
        color = fillBG;
    }

    fragColor = color * qt_Opacity;
}
