#version 120

varying vec4 texcoord;

uniform sampler2D colortex0;
uniform sampler2D depthtex1;

void main() {
    vec4 color = texture2D(colortex0, texcoord.st);
    color.rgb *= 0.5;
    float depth = texture2D(depthtex1, texcoord.st).r;

    gl_FragData[0] = color;
    gl_FragData[1] = vec4(depth);
}