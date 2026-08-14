#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    float glitchAmount;
};

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
    vec2 uv = qt_TexCoord0;

    if (glitchAmount > 0.0) {
        float slice = floor(uv.y * 10.0 + time * 20.0);
        float noise = random(vec2(slice, time));

        if (noise > 0.6) {
            float shift = (random(vec2(time, slice)) - 0.5) * 0.1 * glitchAmount;
            uv.x += shift;
        }
    }

    float r = texture(source, uv + vec2(0.005 * glitchAmount, 0.0)).r;
    float g = texture(source, uv).g;
    float b = texture(source, uv - vec2(0.005 * glitchAmount, 0.0)).b;
    float a = texture(source, uv).a;

    fragColor = vec4(r, g, b, a) * qt_Opacity;
}
