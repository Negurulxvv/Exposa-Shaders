#version 120

varying vec4 texcoord;

uniform sampler2D colortex0;

void main() {
    vec4 color = texture2D(colortex0, texcoord.st);

    color.rgb *= 0.4;

    gl_FragData[0] = color;
}