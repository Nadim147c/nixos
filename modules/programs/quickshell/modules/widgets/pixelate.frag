#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D imageTexture;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 fallbackColor;
    vec2 size;
    float imagePixelSize;
    float colorsPerChannel;
};

void main() {
    float effectiveGrid = max(imagePixelSize, 1.0);
    vec2 pixelizedUV = (floor((qt_TexCoord0 * size) / effectiveGrid) + 0.5) * (effectiveGrid / size);

    vec4 texColor = texture(imageTexture, pixelizedUV);

    vec3 unpremulTexRGB = texColor.a > 0.0 ? texColor.rgb / texColor.a : vec3(0.0);
    vec3 blendedRGB = mix(fallbackColor.rgb, unpremulTexRGB, texColor.a);
    float blendedAlpha = mix(fallbackColor.a, 1.0, texColor.a);

    if (colorsPerChannel > 1.0) {
        float levels = max(colorsPerChannel - 1.0, 1.0);
        blendedRGB = floor(blendedRGB * levels + 0.5) / levels;
    }

    fragColor = vec4(blendedRGB * blendedAlpha, blendedAlpha) * qt_Opacity;
}
