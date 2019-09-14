#version 120

uniform sampler2D texture;
uniform sampler2D colortex0;

varying vec4 texcoord;

void main() {
    if (texture2D(texture, texcoord.st).a < 0.40) {
        discard;
    }

    vec3 color = texture2D(colortex0, texcoord.st).rgb;

    gl_FragData[0] = vec4(color, 1.0);
}