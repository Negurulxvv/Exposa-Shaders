#version 120

#include "/lib/framebuffer.glsl"
#include "/lib/torchcolor.glsl"

#define BetterLighting

#define ShadowColor

//#define Shadows //Enable shadows to make this a lil more realistic at a medium peformance cost.
#define ColoredLighting //Makes the lighting look a lil different but It's glitched with the sky.


const float shadowDistance = 128.0; //[32.0 64.0 128.0 256.0 512.0 1024.0]
const float shadowMapBias = 1.0-25.6/shadowDistance;
const float stp = 1.0;			//size of one step for raytracing algorithm
const float ref = 0.05;			//refinement multiplier
const float inc = 2.2;			//increasement factor at each step
const int maxf = 10;				//number of refinements


uniform sampler2D gdepthtex;
uniform sampler2D depthtex1;
uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform sampler2D shadow;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform sampler2D composite;
uniform sampler2D colortex4;


uniform int frameCounter;
uniform int isEyeInWater;
uniform int worldTime;

uniform float aspectRatio;
uniform float blindness;
uniform float far;
uniform float frameTimeCounter;
uniform float near;
uniform float rainStrength;
uniform float timeAngle;
uniform float timeBrightness;
uniform float viewWidth;
uniform float viewHeight;

uniform vec3 skyColor;
uniform vec3 cameraPosition;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;


varying vec3 lightVector;
varying vec3 ambient_color;
varying vec3 sky_color;
varying vec3 fog_color;
varying vec3 sunlight;
varying vec3 colorWaterMurk;
varying vec3 colorWaterBlue;
varying vec4 texcoord;



/* DRAWBUFFERS:012 */


float getDepth = 1.1;

vec4 getCameraSpacePosition(in vec2 coord) {
    float depth = getDepth;
    vec4 positionNdcSpace = vec4(coord.s * 2.0 - 1.0, coord.t * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0);
    vec4 positionCameraSpace = gbufferProjectionInverse * positionNdcSpace;

    return positionCameraSpace / positionCameraSpace.w;
}

vec4 getWorldSpacePosition(in vec2 coord) {
    vec4 positionCameraSpace = getCameraSpacePosition(coord);
    vec4 positionWorldSpace = gbufferModelViewInverse * positionCameraSpace;
    positionWorldSpace.xyz += cameraPosition;

    return positionWorldSpace;
}

vec3 getShadowSpacePosition(in vec2 coord) {
    vec4 positionWorldSpace = getWorldSpacePosition(coord);

    positionWorldSpace.xyz -= cameraPosition;
    vec4 positionShadowSpace = shadowModelView * positionWorldSpace;
    positionShadowSpace = shadowProjection * positionShadowSpace;
    positionShadowSpace /= positionShadowSpace.w;

    return positionShadowSpace.xyz * 0.5 + 0.5;
}

mat2 getRotationMatrix(in vec2 coord) {
    float rotationAmount = texture2D(
        noisetex,
        coord * vec2(
            viewWidth / noiseTextureResolution,
            viewHeight / noiseTextureResolution
        )
    ).r;
    return mat2(
        cos(rotationAmount), -sin(rotationAmount),
        sin(rotationAmount), cos(rotationAmount)
    );
}

vec3 getShadowColor(in vec2 coord) {
    vec3 shadowCoord = getShadowSpacePosition(coord);
    
    mat2 rotationMatrix = getRotationMatrix(coord);
    vec3 shadowColor = vec3(0);
    for(int y = -1; y < 2; y++) {
        for(int x = -1; x <2; x++) {
            vec2 offset = vec2(x, y) / shadowMapResolution;
            offset = rotationMatrix * offset;
            float shadowMapSample = texture2D(shadow, shadowCoord.st + offset).r;
            float visibility = step(shadowCoord.z - shadowMapSample, 0.002);
            
            vec3 colorSample = texture2D(shadowcolor0, shadowCoord.st + offset).rgb;
            #ifdef ColoredLighting
            shadowColor += mix(colorSample, vec3(1.0, 0.5, 0.4), visibility);
            #else
            shadowColor += mix(colorSample, vec3(1.0), visibility);
            #endif
        }
    }
    
    return shadowColor * vec3(0.044);
    
}


vec3 calculateLitSurface(in vec3 color) {
    vec3 sunlightAmount = getShadowColor(texcoord.st);
    float ambientLighting = 0.75; 

    return color * (sunlightAmount + ambientLighting);
}


void main() {
    vec4 sample4 = texture2D(colortex4, texcoord.st);
    vec2 lightmap = sample4.xy;


    getDepth = texture2D(depthtex1, texcoord.st).r;
    vec3 finalComposite = texture2D(gcolor, texcoord.st).rgb;
    vec3 finalCompositeNormal = texture2D(gnormal, texcoord.st).rgb;
    vec3 finalCompositeDepth = texture2D(gdepth, texcoord.st).rgb;
    #ifdef Shadows
    finalComposite = calculateLitSurface(finalComposite);
    #endif

    gl_FragData[0] = vec4(finalComposite, 1.0);
    gl_FragData[1] = vec4(finalCompositeNormal, 1.0);
    gl_FragData[2] = vec4(finalCompositeDepth, 1.0);

}