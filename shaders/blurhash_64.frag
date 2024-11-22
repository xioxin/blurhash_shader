#version 460 core
#include <flutter/runtime_effect.glsl>
#define PI 3.14159265358979323846
#define MAX_COLOR_COUNT 64

out vec4 fragColor;
uniform vec2 iResolution;
uniform vec2 num;
uniform vec3 colors[MAX_COLOR_COUNT];

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
    float size = num.x * num.y;
    for (int index = 0; index < MAX_COLOR_COUNT; index++) {
        if (index >= size) break;
        vec3 sColor = colors[index];
        float fIndex = float(index);
        float row = floor(fIndex / num.x);
        float col = floor(fIndex - (row * num.x));
        vec2 loopPos = vec2(col, row);
        vec2 basics = uvpi * loopPos;
        color += sColor * cos(basics.x) * cos(basics.y);
    }
    fragColor = vec4(
        linearTosRGB(color.r),
        linearTosRGB(color.g),
        linearTosRGB(color.b),
    1.0);
}