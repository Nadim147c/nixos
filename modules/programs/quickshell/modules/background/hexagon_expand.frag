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

float hexDistance(vec2 p) {
    p = abs(p);
    return max(p.x * 0.57735 + p.y, p.x * 1.1547);
}

void main() {
    if (t <= 0.0) {
        fragColor = texture(fromSource, qt_TexCoord0) * qt_Opacity;
        return;
    }
    if (t >= 1.0) {
        fragColor = texture(toSource, qt_TexCoord0) * qt_Opacity;
        return;
    }

    vec2 st = qt_TexCoord0;
    st.x *= aspect;

    vec2 center = cursor;
    center.x *= aspect;

    float maxDist = max(hexDistance(center), max(hexDistance(center - vec2(aspect, 0.0)), max(hexDistance(center - vec2(0.0, 1.0)), hexDistance(center - vec2(aspect, 1.0)))));

    float dist = hexDistance(st - center);
    float radius = t * maxDist;

    float mask = step(radius, dist);

    vec4 fromColor = texture(fromSource, qt_TexCoord0);
    vec4 toColor = texture(toSource, qt_TexCoord0);

    fragColor = mix(toColor, fromColor, mask) * qt_Opacity;
}
