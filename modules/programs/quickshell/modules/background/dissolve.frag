#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    bool inverse;
};

layout(binding = 1) uniform sampler2D bottomTex;
layout(binding = 2) uniform sampler2D topTex;

void main() {
    float p = clamp(progress, 0.0, 1.0);

    vec4 fromTex = texture(bottomTex, qt_TexCoord0);
    vec4 toTex = texture(topTex, qt_TexCoord0);

    fragColor = mix(fromTex, toTex, p) * qt_Opacity;
}
