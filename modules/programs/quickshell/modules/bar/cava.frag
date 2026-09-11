#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 colorTop;
    vec4 colorBottom;
    vec4 params;
    vec4 cava0;
    vec4 cava1;
    vec4 cava2;
    vec4 cava3;
} ubuf;

float getCavaValue(int index) {
    if (index < 4) return ubuf.cava0[index];
    if (index < 8) return ubuf.cava1[index - 4];
    if (index < 12) return ubuf.cava2[index - 8];
    return ubuf.cava3[index - 12];
}

void main() {
    float totalWidth    = ubuf.params.x;
    float totalGapWidth = ubuf.params.y;
    float numBars       = ubuf.params.z;

    float pixelX = qt_TexCoord0.x * totalWidth;

    float singleGapWidth = totalGapWidth / (numBars - 1.0);
    float remainingWidthForBars = totalWidth - totalGapWidth;
    float singleBarWidth = remainingWidthForBars / numBars;

    float stride = singleBarWidth + singleGapWidth;
    int barIndex = int(floor(pixelX / stride));

    if (barIndex < 0 || barIndex >= int(numBars)) {
        discard;
    }

    float localX = pixelX - float(barIndex) * stride;
    if (localX > singleBarWidth) {
        discard;
    }

    float value = getCavaValue(barIndex);
    float heightThreshold = 1.0 - qt_TexCoord0.y;
    if (heightThreshold > value) {
        discard;
    }

    vec4 barColor = mix(ubuf.colorBottom, ubuf.colorTop, heightThreshold);
    fragColor = barColor * ubuf.qt_Opacity;
}
