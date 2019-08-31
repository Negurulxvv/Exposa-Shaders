#version 120

uniform sampler2D gaux1;
uniform sampler2D colortex0;
uniform sampler2D depthtex0;

uniform vec3 skyColor;

uniform float far;
uniform float near;

varying vec4 texcoord;

#define CustomFog

uniform int isEyeInWater;

float     GetDepthLinear(in vec2 coord) {          
   return 2.0f * near * far / (far + near - (2.0f * texture2D(depthtex0, coord).x - 1.0f) * (far - near));
}

void main() {
    vec3 aux = texture2D(gaux1, texcoord.st).rgb;

    float iswater = float(aux.g > 0.04 && aux.g < 0.07);

    vec3 color = texture2D(colortex0, texcoord.st).rgb;

    float depth = texture2D(depthtex0, texcoord.st).r;

    vec3 fogCol = skyColor;

    vec3 waterfogColor = pow(vec3(0, 255, 355) / 255.0, vec3(2.2));

    vec3 lavafogColor = pow(vec3(195, 87, 0) / 255.0, vec3(2.2));

    bool isTerrain = depth < 1.0;

    if (isEyeInWater == 1) {
        color = mix(color, waterfogColor, min(GetDepthLinear(texcoord.st) * 2.3 / far, 1.0));
    }

    if (isEyeInWater == 2) {
        color = mix(color, lavafogColor, min(GetDepthLinear(texcoord.st) * 2.3 / far, 1.0));
    }

    #ifdef CustomFog
    if (isTerrain) color = mix(color, fogCol, min(GetDepthLinear(texcoord.st) * 0.8 / far, 1.0));
    #endif


    gl_FragData[0] = vec4(color, 1.0);


}