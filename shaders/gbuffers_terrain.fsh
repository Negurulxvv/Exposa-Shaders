#version 120

uniform sampler2D texture;
uniform sampler2D lightmap;

varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;

uniform int fogMode;

void main() {
	vec4 albedo = texture2D(texture, texcoord.st) * color;
	vec2 lightmap = lmcoord.st;
	lightmap = clamp((lightmap - 0.03125) * 1.06667, vec2(0.0), vec2(1.0));
	
/*DRAWBUFFERS:01*/
	gl_FragData[0] = albedo;
	gl_FragData[1] = vec4(lightmap, 0.0, 1.0);
}