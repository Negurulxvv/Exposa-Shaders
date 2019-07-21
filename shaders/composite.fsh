#version 120

const int noiseTextureResolution = 1024;

//I am from 2020 and I can confirm that we friccin did it boiis, we got em aliens


varying vec3 lightVector;
varying vec3 colSky;
varying vec3 colFog;
varying vec3 sunlight;

//varying float SdotU;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
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

//those do not exist
/*
varying vec3 cloudCol;
uniform vec3 sunColor;
uniform vec3 nsunColor;
uniform vec2 texelSize;
*/
uniform float far;

uniform vec3 sunPosition;

uniform float rainStrength;

float getDepth = 1.1;



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

void main() {

    vec3 sceneCol   = texture2D(colortex0, texcoord.st).rgb;

    getDepth = texture2D(depthtex1, texcoord.st).r;

    vec3 worldPos = getWorldSpacePositionFromCoord(texcoord.st).xyz;
    
    float sceneDepth = texture2D(depthtex0, texcoord.st).r;

    bool isTerrain = sceneDepth < 1.0;

    if (!isTerrain) sceneCol     = pow(sceneCol, vec3(2.2));    //gamma correction on sky color
    
    clouds_2D(worldPos, cameraPosition, lightVector, sunlight*1.5, colSky, isTerrain, sceneCol);

    /*DRAWBUFFERS:0*/
    gl_FragData[0] = vec4(sceneCol, 1.0);
   
}