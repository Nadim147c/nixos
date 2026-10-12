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

    vec2 uv = qt_TexCoord0;
    uv.x *= aspect;

    vec2 dir = vec2(cos(angle), sin(angle));

    float proj = dot(uv, dir);
    float minProj = 0.0;
    float maxProj = aspect * abs(cos(angle)) + abs(sin(angle));

    float threshold = mix(minProj, maxProj, t);
    float mask = step(proj, threshold);

    vec4 fromColor = texture(toSource, qt_TexCoord0);
    vec4 toColor = texture(fromSource, qt_TexCoord0);

    fragColor = mix(toColor, fromColor, mask) * qt_Opacity;
}
