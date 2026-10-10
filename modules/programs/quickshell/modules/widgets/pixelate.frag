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
    float levels;
};


vec3 srgb_to_linear(vec3 rgb) {
    vec3 c = max(rgb, vec3(0.0));
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

vec3 linear_to_srgb(vec3 c) {
    vec3 linear = max(c, vec3(0.0));
    return mix(linear * 12.92, 1.055 * pow(linear, vec3(1.0 / 2.4)) - 0.055, step(vec3(0.0031308), linear));
}

vec3 oklab_from_linear(vec3 linear) {
    const mat3 im1 = mat3(0.4121656120, 0.2118591070, 0.0883097947,
                          0.5362752080, 0.6807189584, 0.2818474174,
                          0.0514575653, 0.1074065790, 0.6302613616);

    const mat3 im2 = mat3(+0.2104542553, +1.9779984951, +0.0259040371,
                          +0.7936177850, -2.4285922050, +0.7827717662,
                          -0.0040720468, +0.4505937099, -0.8086757660);

    vec3 lms = im1 * linear;
    return im2 * (sign(lms) * pow(abs(lms), vec3(1.0 / 3.0)));
}

vec3 linear_from_oklab(vec3 oklab) {
    const mat3 m1 = mat3(+1.000000000, +1.000000000, +1.000000000,
                         +0.396337777, -0.105561346, -0.089484178,
                         +0.215803757, -0.063854173, -1.291485548);

    const mat3 m2 = mat3(+4.076724529, -1.268143773, -0.004111989,
                         -3.307216883, +2.609332323, -0.703476310,
                         +0.230759054, -0.341134429, +1.706862569);
    vec3 lms = m1 * oklab;
    return m2 * (lms * lms * lms);
}

void main() {
    float effectiveGrid = max(imagePixelSize, 1.0);
    vec2 pixelizedUV = (floor((qt_TexCoord0 * size) / effectiveGrid) + 0.5) * (effectiveGrid / size);

    vec4 texColor = texture(imageTexture, pixelizedUV);

    vec3 unpremulTexRGB = texColor.a > 0.0 ? texColor.rgb / texColor.a : vec3(0.0);
    vec3 blendedRGB = mix(fallbackColor.rgb, unpremulTexRGB, texColor.a);
    float blendedAlpha = mix(fallbackColor.a, 1.0, texColor.a);

    if (levels > 1.0) {
      vec3 lab = oklab_from_linear(srgb_to_linear(blendedRGB));
      lab.x = round(lab.x * levels) / levels;
      blendedRGB = linear_to_srgb(linear_from_oklab(lab));
    }

    fragColor = vec4(blendedRGB * blendedAlpha, blendedAlpha) * qt_Opacity;
}
