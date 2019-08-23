#version 120

#define ExposaUnique

#define CloudsType 1 //[0 1 2 3] //0 is no clouds (smoothest), 1 is 2D clouds (smooth), 2 is fake 3D clouds (less smooth). and 3 is volumetric clouds (laggiest)

//I am from 2020 and I can confirm that we friccin did it boiis, we got em aliens
#define altitude 4050.0      //[200.0 300 400.0 500.0 650.0 700.0 750.0 800.0 850.0 900.0 1050.0 1250.0 2050.0 3000.0 4050.0] //if u are using volumetric clouds, do this 200.0 for the best look.
#define thickness 4050.0      //[200.0 300 400.0 500.0 650.0 700.0 750.0 800.0 850.0 900.0 1050.0 1250.0 2050.0 3000.0 4050.0 8050.0] //if u are using volumetric clouds, do this 200.0 for the best look.

#if CloudsType == 0
const int noiseTextureResolution = 512;
#endif

#if CloudsType == 1
const int noiseTextureResolution = 1024;
#endif

#if CloudsType == 2
const int noiseTextureResolution = 1024;
#endif

#if CloudsType == 3
const int noiseTextureResolution = 512;
#endif




varying vec3 lightVector;
varying vec3 colSky;
varying vec3 colFog;
varying vec3 sunlight;

//varying float SdotU;

uniform mat4 gbufferProjection;
uniform mat4 gbufferModelView;

uniform sampler2D colortex0;
uniform sampler2D gaux1;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D texture;

varying vec4 texcoord;
uniform vec3 cameraPosition;

//uniform vec4 lightCol;

uniform float frameTimeCounter;
uniform int frameCounter;
uniform float viewHeight;
uniform float viewWidth;
uniform float far;
uniform float near;


uniform vec3 sunPosition;

uniform float rainStrength;

uniform int worldTime;

float getDepth = 1.1;

float timefract = worldTime;

float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);
vec2 wind[4] = vec2[4](vec2(abs(frameTimeCounter/1000.-0.5),abs(frameTimeCounter/1000.-0.5))+vec2(0.5),
					vec2(-abs(frameTimeCounter/1000.-0.5),abs(frameTimeCounter/1000.-0.5)),
					vec2(-abs(frameTimeCounter/1000.-0.5),-abs(frameTimeCounter/1000.-0.5)),
					vec2(abs(frameTimeCounter/1000.-0.5),-abs(frameTimeCounter/1000.-0.5)));



#include "/lib/framebuffer.glsl"

vec4 getCameraSpacePositionFromCoord(in vec2 coord) {
    float depth = getDepth;
    vec4 positionNdcSpace = vec4(coord.s * 2.0 - 1.0, coord.t * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0);
    vec4 positionCameraSpace = gbufferProjectionInverse * positionNdcSpace;

    return positionCameraSpace / positionCameraSpace.w;
}

vec4 getWorldSpacePositionFromCoord(in vec2 coord) {
    vec4 positionCameraSpace = getCameraSpacePositionFromCoord(coord);
    vec4 positionWorldSpace = gbufferModelViewInverse * positionCameraSpace;
    positionWorldSpace.xyz += cameraPosition.xyz;

    return positionWorldSpace;
}

#include "/lib/clouds.glsl"

#include "/lib/volumeclouds.glsl"
#include "/lib/volumevoid.glsl"

void main() {

     #ifdef ExposaUnique

     #endif

     float height = 0.0;

    vec3 sceneCol   = texture2D(colortex0, texcoord.st).rgb;

    getDepth = texture2D(depthtex1, texcoord.st).r;

    vec3 worldPos = getWorldSpacePositionFromCoord(texcoord.st).xyz;
    
    float sceneDepth = texture2D(depthtex0, texcoord.st).r;

    bool isTerrain = sceneDepth < 1.0;

    sceneCol    = pow(sceneCol, vec3(2.2));
    
    float sunLightBrtness = (1.2*TimeSunrise + 1.5*TimeNoon + 1.2*TimeSunset + 0.65*TimeMidnight);

#if CloudsType == 0

#endif

#if CloudsType == 1
    clouds_2D(worldPos, cameraPosition, lightVector, sunlight*sunLightBrtness, colSky, isTerrain, height, sceneCol);
#endif

#if CloudsType == 2
    pasted2DClouds(worldPos, cameraPosition, lightVector, sunlight*sunLightBrtness, colSky, isTerrain, height, sceneCol);

#endif

#if CloudsType == 3

    if (!isTerrain) volumetric(sceneDepth, lightVector, sceneCol);

#endif

    /*DRAWBUFFERS:0*/
    gl_FragData[0] = vec4(sceneCol, 1.0);
   
}