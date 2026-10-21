#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D imageTexture;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 targetColor;
};

float luma(vec3 color) {
  return dot(color, vec3(0.299, 0.587, 0.114));
}

float luma(vec4 color) {
  return dot(color.rgb, vec3(0.299, 0.587, 0.114));
}

void main() {
    vec4 texColor = texture(imageTexture, qt_TexCoord0);
    float threshold = 0.5;
    float lum = luma(texColor);

    float afWidth = fwidth(lum);
    float alpha = smoothstep(threshold - afWidth, threshold + afWidth, lum);

    fragColor = targetColor * alpha * qt_Opacity;
}
