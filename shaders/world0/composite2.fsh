#version 120
#extension GL_ARB_shader_texture_lod : enable


//INSPIRED BY BSL CAPT TATSU CODE


//#define DOField

varying vec2 texcoord;

uniform float aspectRatio;
uniform float viewWidth;
uniform float viewHeight;
uniform float centerDepthSmooth;

uniform sampler2D colortex0;
uniform sampler2D depthtex1;

#include "/lib/DepthOfField.glsl"

void main() {
	vec3 color = texture2D(colortex0,texcoord.xy).rgb;
	
	//Depth of Field
	#ifdef DOField
	color = depthOfField(color);
	#endif
	
/*DRAWBUFFERS:0*/
	gl_FragData[0] = vec4(color,1.0);
}
