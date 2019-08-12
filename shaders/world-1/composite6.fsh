#version 120
#extension GL_ARB_shader_texture_lod : enable

//TAA code was used from BSL and Chocapic.

#define TAA

uniform sampler2D colortex1;

varying vec4 texcoord;

#include "/lib/taa.glsl"

void main() {

    vec3 color = texture2DLod(colortex1,texcoord.st,0).rgb;

	#ifdef TAA
	float temp = texture2DLod(colortex2,texcoord.st,0).r;
	
	vec2 prvcoord = reprojection(vec3(texcoord.st,texture2DLod(depthtex1,texcoord.st,0).r));
	vec2 view = vec2(viewWidth,viewHeight);
	vec3 tempcolor = neighbourhoodClamping(color,texture2DLod(colortex2,prvcoord.xy,0).gba,1.0/view);
	
	vec2 velocity = (texcoord.st-prvcoord.xy)*view;
	float blendfactor = float(prvcoord.x > 0.0 && prvcoord.x < 1.0 && prvcoord.y > 0.0 && prvcoord.y < 1.0);
	blendfactor *= clamp(1.0-sqrt(length(velocity))/1.999,0.0,1.0)*0.3+0.6;
	
	color = mix(color,tempcolor,blendfactor);
	tempcolor = color;
	#endif
/*DRAWBUFFERS:1*/
    gl_FragData[0] = vec4(color, 1.0);
    #ifdef TAA
/*DRAWBUFFERS:12*/
	gl_FragData[1] = vec4(temp,tempcolor);
	#endif
}