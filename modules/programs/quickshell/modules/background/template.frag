#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;      // Normalized animation progress [0.0 - 1.0]
    bool inversed;       // Direction state: false = bottom->top, true = top->bottom
    float aspect;        // Viewport aspect ratio (width / height, e.g., 16.0 / 9.0 = 1.777)
    vec2 cursor;         // Normalized cursor position [0.0 - 1.0]
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

    float p = inversed ? (1.0 - clamp(progress, 0.0, 1.0)) : clamp(progress, 0.0, 1.0);

    vec4 fromColor = inversed ? texture(topTex, qt_TexCoord0) : texture(bottomTex, qt_TexCoord0);
    vec4 toColor   = inversed ? texture(bottomTex, qt_TexCoord0) : texture(topTex, qt_TexCoord0);

    vec2 uv = qt_TexCoord0;
    uv.x *= aspect;

    vec2 origin = cursor;
    origin.x *= aspect;

    /*
     * CUSTOM TRANSITION LOGIC
     * Compute a `mask` float value based on `p`, `uv`, and `origin`.
     * Return 0.0 for areas that reveal `toColor` (new wallpaper).
     * Return 1.0 for areas that display `fromColor` (old wallpaper).
     */

    float maxDist = max(length(origin), max(length(origin - vec2(aspect, 0.0)),
                    max(length(origin - vec2(0.0, 1.0)), length(origin - vec2(aspect, 1.0)))));
    float dist = length(uv - origin);
    float radius = p * maxDist;

    float mask = step(radius, dist);

    fragColor = mix(toColor, fromColor, mask) * qt_Opacity;
}
