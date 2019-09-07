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

vec3 BetterColors(in vec3 color) {
    return color * (0.2 * color + 0.9);
}

#define rcp(x) (1.0 / x)

vec3 tonemap(in vec3 x) { return (x*(6.8*x+0.2))*rcp((x*(6.8*x+1.3)+0.06)); }

void main() {

    vec3 color = texture2D(colortex0, texcoord.st).rgb;

    #ifdef Vignette
    SoftVignette(color);
    #endif

    color = tonemap(color);
    color = BetterColors(color);

    gl_FragColor = vec4(color.rgb, 1.0f);

}
