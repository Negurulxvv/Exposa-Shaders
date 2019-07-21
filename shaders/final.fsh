#version 120

#include "/lib/framebuffer.glsl"


uniform sampler2D colortex4;
uniform sampler2D colortex0;

varying vec2 texcoord;

vec3 convertToHRD(in vec3 color) {
    vec3 HRDImage;

    vec3 overExposed = color * 1.0f;

    vec3 underExposed = color / 5.0f;

    HRDImage = mix(underExposed, overExposed, color);


    return HRDImage;
}


void main() {

      vec3 color = texture2D(colortex0, texcoord.st).rgb;

      vec3 tex4Col = texture2D(colortex4, texcoord.st).rgb;

    gl_FragColor = vec4(color, 1.0);

}
