#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float t;
};

layout(binding = 1) uniform sampler2D fromSource;
layout(binding = 2) uniform sampler2D toSource;

void main() {
    vec4 fromTex = texture(fromSource, qt_TexCoord0);
    vec4 toTex = texture(toSource, qt_TexCoord0);

    fragColor = mix(fromTex, toTex, t) * qt_Opacity;
}
