#version 120

uniform sampler2D tex;

varying vec4 texcoord;
varying vec4 color;
varying float isTransparent;

void main() {
    vec3 fragColor = color.rgb * texture2D(tex, texcoord.st).rgb;
    fragColor = mix(vec3(0), fragColor, isTransparent);

    gl_FragData[0] = vec4(fragColor, 1.0);
}