#version 120

/*
RRe36's Shaders, derived from Chocapic13 v4
Place two leading Slashes in front of the following '#define' lines in order to disable an option.
IMPORTANT: Placing Slashes in front of lines like '#define FILTER_LEVEL 15.0' will cause errors!
*/

/* DRAWBUFFERS:024 */

//////////////////////////////ADJUSTABLE VARIABLES
//////////////////////////////ADJUSTABLE VARIABLES
//////////////////////////////ADJUSTABLE VARIABLES

	#define MIN_LIGHTAMOUNT 1.0		//affect the minecraft lightmap (not torches)
	#define MINELIGHTMAP_EXP 2.0		//affect the minecraft lightmap (not torches)
	#define MIX_TEX	0.6		
	vec4 watercolor = vec4(0.0,0.2025,0.4,0.825); 	//water color and opacity (r,g,b,opacity)

//////////////////////////////END OF ADJUSTABLE VARIABLES
//////////////////////////////END OF ADJUSTABLE VARIABLES
//////////////////////////////END OF ADJUSTABLE VARIABLES

const int MAX_OCCLUSION_POINTS = 20;
const float MAX_OCCLUSION_DISTANCE = 96.0;
const float bump_distance = 64.0;				//Bump render distance: tiny = 32, short = 64, normal = 128, far = 256
const float pom_distance = 32.0;				//POM render distance: tiny = 32, short = 64, normal = 128, far = 256
const float fademult = 0.1;
const float PI = 3.1415927;

varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;
varying vec4 position;
varying vec3 binormal;
varying vec3 normal;
varying vec3 tangent;
varying vec3 viewVector;
varying vec3 wpos;
varying float iswater;

uniform sampler2D texture;
uniform sampler2D noisetex;
uniform int worldTime;
uniform float far;
uniform float rainStrength;
uniform float frameTimeCounter;

float timefract = worldTime;

//Calculate Time of Day
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);


float rainx = clamp(rainStrength, 0.0f, 1.0f)/1.0f;

float waterH(vec2 posxz) {

	vec2 coord= posxz/25.0;
	float noise = texture2D(noisetex,fract(coord.xy/3.0)).x;
	noise += texture2D(noisetex,fract(coord.xy)).x/6.0;
	noise += texture2D(noisetex,fract(coord.xy*2.0)).x/9.0;
	noise += texture2D(noisetex,fract(coord.xy*4.0)).x/12.0;

	
	
	return 	0.08 * sin(2 * PI * (frameTimeCounter + posxz.x  + posxz.y / 2.2 + noise*2.3))
	+ 0.08 * sin(2 * PI * (frameTimeCounter*1.2 + posxz.x / 2.2 + posxz.y + noise*2.3));
	//return noise;
}

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {	
	
	vec4 tex = vec4((watercolor*mix(vec4(1.0),texture2D(texture, texcoord.xy),MIX_TEX)*color).rgb,watercolor.a);
	if (iswater < 0.85)  tex = texture2D(texture, texcoord.xy)*color;
	
	vec3 posxz = wpos.xyz;
	
	posxz.x += sin(posxz.z+frameTimeCounter)*0.2;
	posxz.z += cos(posxz.x+frameTimeCounter*0.5)*0.2;
	
	float delpos = 0.4;
	float h0 = waterH(posxz.xz);
	float h1 = waterH(posxz.xz + vec2(delpos,0.0));
	float h2 = waterH(posxz.xz + vec2(-delpos,0.0));
	float h3 = waterH(posxz.xz + vec2(0.0,delpos));
	float h4 = waterH(posxz.xz + vec2(0.0,-delpos));
	
	float xDelta = (h1-h0)+(h0-h2);
	float yDelta = (h3-h0)+(h0-h4);
	float zDelta = h0-(h1+h2+h3+h4)/4.2;
	
	vec3 newnormal = normalize(vec3(xDelta,yDelta,1.0-pow(abs(xDelta+yDelta),2.2)));
	
	vec4 flag2;
		flag2 = vec4((normal) * 0.5f + 0.5f, 1.0f);			
	float NdotE = sqrt(abs(dot(normal,normalize(position.xyz))));
	if (iswater > 0.9) {
		vec3 bump = newnormal;
			bump = bump;
			
float waveStrength = (1.2*TimeSunrise + 1.6*TimeNoon + 1.2*TimeSunset + 0.7*TimeMidnight);
		
	float bumpmult = (waveStrength - (rainStrength*0.5))*NdotE;
	//float bumpmult = 0.0;
		
		bump = bump * vec3(bumpmult, bumpmult, bumpmult) + vec3(0.0f, 0.0f, 1.2f - bumpmult);
		mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
							tangent.y, binormal.y, normal.y,
							tangent.z, binormal.z, normal.z);
		
		flag2 = vec4(normalize(bump * tbnMatrix) * 0.5 + 0.5, 1.0);
	}
	
	gl_FragData[0] = tex;
	
	gl_FragData[1] = flag2;	
	
	gl_FragData[2] = vec4(lmcoord.t, mix(1.0,0.05,iswater), lmcoord.s, 1.0);
}