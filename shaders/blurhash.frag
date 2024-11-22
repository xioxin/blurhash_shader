#version 460 core
#include <flutter/runtime_effect.glsl>
#define PI 3.14159265358979323846
#define MAX_LOOP 10.0

out vec4 fragColor;
uniform vec2 iResolution;
uniform vec2 num;
uniform sampler2D iChannel0;

float sRGBToLinear(float v) {
    if (v <= 0.04045) {
        return v / 12.92;
    } else {
        return pow((v + 0.055) / 1.055, 2.4);
    }
}

float linearTosRGB(float value) {
    float v = max(0, min(1, value));
    if (v <= 0.0031308) {
        return v * 12.92;
    } else {
        return pow(v, 1.0 / 2.4) * 1.055 - 0.055;
    }
}

void main() {
    vec2 fragCoord = FlutterFragCoord();
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 color = vec3(0.0);
    vec2 uvpi = uv * PI;
    for (float j = 0.; j < MAX_LOOP; j++) {
        if (j >= num.y) break;
        for (float i = 0.; i < MAX_LOOP; i++) {
            if (i >= num.x) break;
            vec2 loopPos = vec2(i, j);
            vec2 sPos = (loopPos + 0.5) / num;
            vec4 sColor = texture(iChannel0, sPos);
            vec2 basics = uvpi * loopPos;
            vec3 linearColor = vec3(
            sRGBToLinear(sColor.r),
            sRGBToLinear(sColor.g),
            sRGBToLinear(sColor.b)
            );
            color += linearColor * cos(basics.x) * cos(basics.y);
        }
    }
    fragColor = vec4(
    linearTosRGB(color.r),
    linearTosRGB(color.g),
    linearTosRGB(color.b),
    1.0);
}