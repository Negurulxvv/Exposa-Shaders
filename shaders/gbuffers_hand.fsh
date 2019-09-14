#version 120

uniform sampler2D tex;
uniform sampler2D depthtex1;

varying vec4 color;

varying vec4 texcoord;
varying vec4 lmcoord;

varying vec3 normal;

void main() {

    vec4 handColor = texture2D(tex, texcoord.st);
    float depth = texture2D(depthtex1, texcoord.st).r;
    handColor.rgb *= color.rgb;

    gl_FragData[0] = handColor;
    gl_FragData[1] = vec4(depth);
    gl_FragData[2] = vec4(normal * 0.5 + 0.5, 1.0);
}