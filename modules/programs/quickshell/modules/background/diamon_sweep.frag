#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    bool inversed;
    float aspect;
    vec2 cursor;
};

layout(binding = 1) uniform sampler2D bottomTex;
layout(binding = 2) uniform sampler2D topTex;

void main() {
    if (progress <= 0.0) {
        fragColor = texture(bottomTex, qt_TexCoord0) * qt_Opacity;
        return;
    }
    if (progress >= 1.0) {
        fragColor = texture(topTex, qt_TexCoord0) * qt_Opacity;
        return;
    }

    float p = inversed ? (1.0 - clamp(progress, 0.0, 1.0)) : clamp(progress, 0.0, 1.0);

    vec4 fromColor = inversed ? texture(topTex, qt_TexCoord0) : texture(bottomTex, qt_TexCoord0);
    vec4 toColor   = inversed ? texture(bottomTex, qt_TexCoord0) : texture(topTex, qt_TexCoord0);

    vec2 uv = qt_TexCoord0;
    uv.x *= aspect;

    vec2 diamondSize = vec2(0.067);

    vec2 fraction = fract(uv / diamondSize);

    float xDistance = abs(fraction.x - 0.5);
    float yDistance = abs(fraction.y - 0.5);

    float threshold = (uv.x + uv.y + xDistance + yDistance) / 3.7;

    float mask = step(p, threshold);

    fragColor = mix(toColor, fromColor, mask) * qt_Opacity;
}
