#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float t;
    bool inversed;
    float angle;
    vec2 size;
    float aspect;
};

layout(binding = 1) uniform sampler2D fromSource;
layout(binding = 2) uniform sampler2D toSource;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 96.233))) * 43758.5453);
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

    vec4 fromColor = texture(fromSource, qt_TexCoord0);
    vec4 toColor = texture(toSource, qt_TexCoord0);

    vec2 uv = qt_TexCoord0;
    vec2 targetRes = size / 5.0;
    vec2 lowresuv = floor(uv * targetRes) / targetRes;

    if (t > rand(lowresuv)) {
        fragColor = toColor * qt_Opacity;
    } else {
        fragColor = fromColor * qt_Opacity;
    }
}
