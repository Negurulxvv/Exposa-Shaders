#version 120

uniform sampler2D colortex0;
uniform sampler2D depthtex0;

varying vec4 texcoord;

float getDepth = 0.0;

void main() {
    getDepth = texture2D(depthtex0, texcoord.st).r;
    vec3 color = texture2D(colortex0,texcoord.st).rgb;

    gl_FragColor = vec4(color, 1.0);
}