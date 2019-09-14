#version 120

uniform sampler2D depthtex0;
uniform sampler2D colortex0;

uniform vec3 skyColor;

uniform float far;
uniform float near;
uniform float frameTimeCounter;

varying vec4 texcoord;

#define CustomFog

uniform int isEyeInWater;
uniform int worldTime;

float     GetDepthLinear(in vec2 coord) {          
   return 2.0f * near * far / (far + near - (2.0f * texture2D(depthtex0, coord).x - 1.0f) * (far - near));
}


float timefract = worldTime;

float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);

void main() {

    vec3 color = texture2D(colortex0, texcoord.st).rgb;

    float depth = texture2D(depthtex0, texcoord.st).r;

    vec3 nightFogCol = vec3(0.1, 0.5, 1.0)*0.14;

    vec3 sunsetFogCol = vec3(0.8, 0.66, 0.5)*1.2;

    vec3 fogCol = skyColor;
    vec3 customFogColor = (sunsetFogCol*TimeSunrise + fogCol*TimeNoon + sunsetFogCol*TimeSunset + nightFogCol*TimeMidnight);

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
    if (isTerrain) color = mix(color, customFogColor, min(GetDepthLinear(texcoord.st) * 0.8 / far, 1.0));
    #endif

    gl_FragData[0] = vec4(color, 1.0);

}