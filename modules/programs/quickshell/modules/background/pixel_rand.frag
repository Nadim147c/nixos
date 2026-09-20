
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
    vec2 resolution;
};

layout(binding = 1) uniform sampler2D bottomTex;
layout(binding = 2) uniform sampler2D topTex;

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,96.233))) * 43758.5453);
}

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
    // uv.x *= aspect;

    vec2 origin = cursor;
    origin.x *= aspect;

    float size = 5.0;
    vec2 targetRes = resolution / size;
    vec2 lowresuv = floor(uv * targetRes) / targetRes;

    if (p > rand(lowresuv)) {
      fragColor = toColor * qt_Opacity;
    } else {
      fragColor = fromColor * qt_Opacity;
    }
}
