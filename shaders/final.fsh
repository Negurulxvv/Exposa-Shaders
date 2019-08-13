#version 120

#define Vignette

varying vec4 texcoord;

uniform sampler2D colortex0;

void SoftVignette(inout vec3 color) {
    float dist = distance(texcoord.st, vec2(0.5)) * 2.0;
    dist /= 1.9142f;

    dist = pow(dist, 1.1f);

    color.rgb *= (1.0f - dist) / 0.75;

}

vec3 convertToHRD(in vec3 color) {
    vec3 HRDImage;

    vec3 overExposed = color * 0.89f;

    vec3 underExposed = color / 2.0f;

    HRDImage = mix(underExposed, overExposed, color);


    return HRDImage;
}



void main() {

    vec3 color = texture2D(colortex0, texcoord.st).rgb;

    //color = convertToHRD(color);

    #ifdef Vignette
    SoftVignette(color);
    #endif

    gl_FragColor = vec4(color.rgb, 1.0f);

}
