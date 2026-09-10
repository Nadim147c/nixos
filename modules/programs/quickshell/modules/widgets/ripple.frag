#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 clickPos;
    float progress;
    float aspectRatio;
    float waveWidth;
    vec4 centerColor;
    vec4 edgeColor;
};

void main() {
    vec2 aspectUv = vec2((qt_TexCoord0.x - clickPos.x) * aspectRatio, qt_TexCoord0.y - clickPos.y);
    float dist = length(aspectUv);

    float maxDist = 1.5;
    float currentRadius = progress * maxDist;

    float distFromRing = abs(dist - currentRadius);
    float ringIntensity = smoothstep(waveWidth, 0.0, distFromRing);

    float alpha = ringIntensity * (1.0 - progress);

    float gradientFactor = clamp(dist / maxDist, 0.0, 1.0);
    vec4 gradientColor = mix(centerColor, edgeColor, gradientFactor);

    fragColor = gradientColor * alpha * qt_Opacity;
}
