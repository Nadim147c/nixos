#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    bool inversed;
    vec2 cursor;
    vec2 resolution;
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

    float p = inversed ? 1 - clamp(progress, 0.0, 1.0) : clamp(progress, 0.0, 1.0);

    float aspect = resolution.x / resolution.y;
    vec2 st = qt_TexCoord0;
    st.x *= aspect;

    vec2 center = cursor;
    center.x *= aspect;

    float maxDist = max(length(center), max(length(center - vec2(aspect, 0.0)), max(length(center - vec2(0.0, 1.0)), length(center - vec2(aspect, 1.0)))));

    float dist = length(st - center);
    float radius = p * maxDist;
    float mask = step(radius, dist);

    if (inversed) {
      vec4 toColor = texture(bottomTex, qt_TexCoord0);
      vec4 fromColor = texture(topTex, qt_TexCoord0);

      fragColor = mix(toColor, fromColor, mask) * qt_Opacity;
    } else {
      vec4 fromColor = texture(bottomTex, qt_TexCoord0);
      vec4 toColor = texture(topTex, qt_TexCoord0);

      fragColor = mix(toColor, fromColor, mask) * qt_Opacity;
    }
}
