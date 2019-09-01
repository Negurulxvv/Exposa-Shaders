#version 120

varying vec3 tintColor;

varying vec3 pos;

uniform vec3 skyColor;
uniform vec3 fogColor;
uniform vec3 upPosition;
uniform vec3 cameraPosition;
uniform vec3 sunPosition;
uniform vec3 moonPosition;

uniform float frameTimeCounter;

uniform int worldTime;

#include "/lib/sky_gradient.glsl"

float timefract = worldTime;

float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);
vec2 wind[4] = vec2[4](vec2(abs(frameTimeCounter/1000.-0.5),abs(frameTimeCounter/1000.-0.5))+vec2(0.5),
					vec2(-abs(frameTimeCounter/1000.-0.5),abs(frameTimeCounter/1000.-0.5)),
					vec2(-abs(frameTimeCounter/1000.-0.5),-abs(frameTimeCounter/1000.-0.5)),
					vec2(abs(frameTimeCounter/1000.-0.5),-abs(frameTimeCounter/1000.-0.5)));



void main() {
                 
	float mix_fog = SkyGradient(cameraPosition, upPosition, sunPosition, moonPosition, pos);

	vec3 nightColor = vec3(0.1, 0.5, 1.0)*0.21;
	vec3 nightFogColor = vec3(0.1, 0.5, 1.0)*0.14;

	vec3 sunsetFogColor = vec3(0.8, 0.66, 0.5)*1.2;

	vec3 customSkyColor = (skyColor*TimeSunrise + skyColor*TimeNoon + skyColor*TimeSunset + nightColor*TimeMidnight);
	vec3 customFogColor = (fogColor*TimeSunrise + fogColor*TimeNoon + sunsetFogColor*TimeSunset + nightFogColor*TimeMidnight);

	gl_FragData[0] = vec4(tintColor, 1.0);
	gl_FragData[0].rgb = mix(customSkyColor, customFogColor, mix_fog);
	gl_FragData[1] = vec4(0.0, 0.0, 0.0, 1.0);
}