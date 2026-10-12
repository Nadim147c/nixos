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
    // Handle fully finished or unstarted states
    if (t <= 0.0) {
        fragColor = texture(fromSource, qt_TexCoord0) * qt_Opacity;
        return;
    }
    if (t >= 1.0) {
        fragColor = texture(toSource, qt_TexCoord0) * qt_Opacity;
        return;
    }

    // Adjust coordinates for aspect ratio
    vec2 uv = qt_TexCoord0;
    uv.x *= aspect;

    vec2 origin = cursor;
    origin.x *= aspect;

    // Fetch textures
    vec4 fromColor = texture(fromSource, qt_TexCoord0);
    vec4 toColor = texture(toSource, qt_TexCoord0);

    // Custom transition logic goes here
    // Compute a mask float value based on t, uv, and origin
    // Return low values to reveal toColor and high values to display fromColor

    float maxDist = max(length(origin), max(length(origin - vec2(aspect, 0.0)),
                        max(length(origin - vec2(0.0, 1.0)), length(origin - vec2(aspect, 1.0)))));
    float dist = length(uv - origin);
    float radius = t * maxDist;

    float mask = step(radius, dist);

    fragColor = mix(toColor, fromColor, mask) * qt_Opacity;
}
