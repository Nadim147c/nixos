#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float t;
    float angle;
    vec2 cursor;
    vec2 size;
    float aspect;
};

layout(binding = 1) uniform sampler2D fromSource;
layout(binding = 2) uniform sampler2D toSource;

void main() {
    if (t <= 0.0) {
        fragColor = texture(fromSource, qt_TexCoord0) * qt_Opacity;
        return;
    }
    if (t >= 1.0) {
        fragColor = texture(toSource, qt_TexCoord0) * qt_Opacity;
        return;
    }

    vec4 fromColor = texture(fromSource, qt_TexCoord0);
    vec4 toColor = texture(toSource, qt_TexCoord0);

    vec2 uv = qt_TexCoord0;
    uv.x *= aspect;

    vec2 diamondSize = vec2(0.067);
    vec2 fraction = fract(uv / diamondSize);

    float xDistance = abs(fraction.x - 0.5);
    float yDistance = abs(fraction.y - 0.5);

    float threshold = (uv.x + uv.y + xDistance + yDistance) / 3.7;

    float mask = step(t, threshold);

    fragColor = mix(toColor, fromColor, mask) * qt_Opacity;
}
