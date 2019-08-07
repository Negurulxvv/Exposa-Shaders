#version 120
#extension GL_ARB_shader_texture_lod : enable

//CODE IS TAKEN FROM BSL MADE BY CAPT TATSU

#define Bloom

uniform sampler2D depthtex2;
uniform sampler2D colortex0;
uniform sampler2D colortex1;

varying vec2 texcoord;

#include "/lib/bloom.glsl"

void main() {

    vec3 color = texture2D(colortex0,texcoord.xy).rgb;

    #ifdef Bloom
    color = bloom(color, texcoord.xy);
    #endif

/*DRAWBUFFERS:0*/
    gl_FragData[0] = vec4(color, 1.0);
}