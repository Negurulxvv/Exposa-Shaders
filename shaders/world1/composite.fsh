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

void main() {

     #ifdef ExposaUnique

     #endif

     float height = 0.0;

    vec3 sceneCol   = texture2D(colortex0, texcoord.st).rgb;

    sceneCol    = pow(sceneCol, vec3(2.2));
   

    /*DRAWBUFFERS:0*/
    gl_FragData[0] = vec4(sceneCol, 1.0);
   
}