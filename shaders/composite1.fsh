#version 120

uniform mat4 gbufferModelView;
uniform mat4 gbufferProjection;

uniform mat4 shadowModelView;

#include "/lib/framebuffer.glsl"
#include "/lib/torchcolor.glsl"
#include "/lib/poisson.glsl"
#include "/lib/dither.glsl"
const int noiseTextureResolution = 256; //Resolution of the noise

const bool 		shadowcolor0Mipmap = true;
const bool 		shadowcolor0Nearest = false;

#define BetterLighting

#define AmbientOcclusion



const float shadowDistance = 128.0; //[32.0 64.0 128.0 256.0 512.0 1024.0]
const float shadowMapBias = 0.85;
const float stp = 1.0;			//size of one step for raytracing algorithm
const float ref = 0.05;			//refinement multiplier
const float inc = 2.2;			//increasement factor at each step
const int maxf = 10;				//number of refinements


uniform sampler2D gdepthtex;
uniform sampler2D depthtex1;
uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D shadowtex0;
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
uniform mat4 shadowProjection;


varying vec3 lightVector;
varying vec4 texcoord;




float ld(float depth) {
   return (2.0 * near) / (far + near - depth * (far - near));
}

#include "/lib/SSAO.glsl"

//Worldtime
float timefract = worldTime;

//Get the time of the day
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);
//Depth
float getDepth = 1.1;

//Get position of the camera in live
vec4 getCameraSpacePosition(in vec2 coord) {
    float depth = getDepth;
    vec4 positionNdcSpace = vec4(coord.s * 2.0 - 1.0, coord.t * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0);
    vec4 positionCameraSpace = gbufferProjectionInverse * positionNdcSpace;

    return positionCameraSpace / positionCameraSpace.w;
}

//Get position of the world in live
vec4 getWorldSpacePosition(in vec2 coord) {
    vec4 positionCameraSpace = getCameraSpacePosition(coord);
    vec4 positionWorldSpace = gbufferModelViewInverse * positionCameraSpace;
    positionWorldSpace.xyz += cameraPosition;

    return positionWorldSpace;
}


#define SHADOW_MAP_BIAS 0.85
vec4 BiasShadowProjection(in vec4 projectedShadowSpacePosition) {

	vec2 pos = abs(projectedShadowSpacePosition.xy * 1.165);
	vec2 posSQ = pos*pos;
	
	float dist = pow(posSQ.x*posSQ.x*posSQ.x + posSQ.y*posSQ.y*posSQ.y, 1.0 / 6.0);

	float distortFactor = (1.0 - SHADOW_MAP_BIAS) + dist * SHADOW_MAP_BIAS;

	projectedShadowSpacePosition.xy /= distortFactor*0.92;



	return projectedShadowSpacePosition;
}


//What gets the shadow position
vec3 getShadowSpacePosition(in vec2 coord) {
    vec4 positionWorldSpace = getWorldSpacePosition(coord);

    positionWorldSpace.xyz -= cameraPosition;
    vec4 positionShadowSpace = shadowModelView * positionWorldSpace;
    positionShadowSpace = shadowProjection * positionShadowSpace;
    positionShadowSpace = BiasShadowProjection(positionShadowSpace);

    return positionShadowSpace.xyz * 0.5 + 0.5;
}

//Rotation for the shadows
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

#define PCSS_SAMPLE_COUNT 3

float getPenumbraWidth(in vec3 shadowCoord, in sampler2D shadowTexture, in mat2 rot) {
    float dFragment = shadowCoord.z; //distance from pixel to light
    float dBlocker = 0.0; //distance from blocker to light
    float penumbra = 0.0;
    
    float shadowMapSample; //duh
    float numBlockers = 0.0;

    float lightSize  = 105.0;
    float searchSize = lightSize / 120.0;

    for (int x = -PCSS_SAMPLE_COUNT; x < PCSS_SAMPLE_COUNT; x++) {
        for (int y = -PCSS_SAMPLE_COUNT; y < PCSS_SAMPLE_COUNT; y++) {
            vec2 sampleCoord = shadowCoord.st + rot * (vec2(x, y) * searchSize / (shadowMapResolution));
            shadowMapSample = texture2D(shadowTexture, sampleCoord, 2.0).r;

            dBlocker += shadowMapSample;
            numBlockers += 1.0;
        }
    }

    if(numBlockers > 0.0) {
		dBlocker /= numBlockers;
		penumbra = (dFragment - dBlocker) * lightSize;
	}

    return clamp(max(penumbra, 0.5), 0.0, lightSize);
}

//Lighting and shadow code
vec3 getShadowColor(in vec2 coord) {
    vec3 shadowCoord = getShadowSpacePosition(coord);
    
    mat2 rotationMatrix = getRotationMatrix(coord);
    float shadowDist = getPenumbraWidth(shadowCoord, shadowtex0, rotationMatrix);
    vec3 shadowColor = vec3(0.0);
    for(int i = 0; i < samplePoints.length(); i++) {
         vec2 offset = samplePoints[i] / shadowMapResolution;
        offset = rotationMatrix * offset;
        offset *= shadowDist;
        float shadowMapSample = texture2D(shadowtex0, shadowCoord.st + offset).r;
        float visibility = step(shadowCoord.z - shadowMapSample, 0.001);
        vec3 colorSample = texture2D(shadowcolor0, shadowCoord.st + offset).rgb;
        shadowColor += mix(colorSample, vec3(1.0), visibility);
    }
    
    return vec3(shadowColor) / samplePoints.length();
    
}

vec3 calculateLitSurface(in vec3 color, in float dither) {
	float torchlight = texture2D(colortex1,texcoord.xy).r;
	float skylight = texture2D(colortex1,texcoord.xy).g;
	torchlight *= torchlight; skylight *= skylight;
    
	vec3 sunsetSkyColor = vec3(0.05);
	vec3 daySkyColor = vec3(0.3, 0.5, 1.1)*0.2;
	vec3 nightSkyColor = vec3(0.001,0.0015,0.0025);
    vec3 ambientLighting = (sunsetSkyColor*TimeSunrise + daySkyColor*TimeNoon + sunsetSkyColor*TimeSunset + nightSkyColor*TimeMidnight) * skylight;
	
    vec3 sunlightAmount = getShadowColor(texcoord.st) * (1.0 - 0.95 * rainStrength);
	
	vec3 sunsetSunColor = vec3(0.8, 0.4, 0.3);
	vec3 daySunColor = vec3(1.0);
	vec3 nightSunColor = vec3(0.02,0.03,0.05);
	vec3 sunlightColor = sunsetSunColor*TimeSunrise + daySunColor*TimeNoon + sunsetSunColor*TimeSunset + nightSunColor*TimeMidnight;

    #ifdef AmbientOcclusion
    float ao = dbao(depthtex0, dither, texcoord.st);
    #else
    float ao = 1.0;
    #endif
	
	vec3 torchcolor = (torchlight * 1.5 + pow(torchlight,7.0)) * vec3(1.0,0.35,0.1);
	
	float minlight = 0.01;

	vec3 finalLighting = (ambientLighting + torchcolor + minlight) * ao + (sunlightAmount * sunlightColor);
	
    return color * finalLighting;
}


void main() {
    vec4 sample4 = texture2D(colortex4, texcoord.st);
    vec2 lightmap = sample4.xy;

    float dither = fract(bayer64(gl_FragCoord.xy)+ frameCounter/8.0);

    getDepth = texture2D(depthtex1, texcoord.st).r;
    vec3 finalComposite = texture2D(gcolor, texcoord.st).rgb;
	finalComposite = pow(finalComposite,vec3(2.2));
    vec3 finalCompositeNormal = texture2D(gnormal, texcoord.st).rgb;
    vec3 finalCompositeDepth = texture2D(gdepth, texcoord.st).rgb;
    
    bool isTerrain = getDepth<1.0;

    if (isTerrain) {
        finalComposite = calculateLitSurface(finalComposite, dither);
    }
	
	finalComposite = pow(finalComposite,vec3(1.0/2.2));
	
/* DRAWBUFFERS:012 */
    gl_FragData[0] = vec4(finalComposite, 1.0);
    gl_FragData[1] = vec4(finalCompositeNormal, 1.0);
    gl_FragData[2] = vec4(finalCompositeDepth, 1.0);

}