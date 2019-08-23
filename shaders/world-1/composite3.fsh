#version 120

uniform sampler2D gaux1;
uniform sampler2D colortex0;
uniform sampler2D depthtex0;

uniform float far;
uniform float near;

varying vec4 texcoord;

uniform int isEyeInWater;

float     GetDepthLinear(in vec2 coord) {          
   return 2.0f * near * far / (far + near - (2.0f * texture2D(depthtex0, coord).x - 1.0f) * (far - near));
}

void main() {
    vec3 aux = texture2D(gaux1, texcoord.st).rgb;

    float iswater = float(aux.g > 0.04 && aux.g < 0.07);

    vec3 color = texture2D(colortex0, texcoord.st).rgb;

    if(iswater < 0.9 && isEyeInWater == 2) {
        float depth = texture2D(depthtex0, texcoord.st).r;

        vec3 fogColor = pow(vec3(195, 87, 0) / 255.0, vec3(2.2));

        color = mix(color, fogColor, min(GetDepthLinear(texcoord.st) * 5.0f / far, 1.0));
    }

    if(iswater < 0.9 && isEyeInWater == 1) {
        float depth = texture2D(depthtex0, texcoord.st).r;

        vec3 fogColor = pow(vec3(0, 255, 355) / 255.0, vec3(2.2));

        color = mix(color, fogColor, min(GetDepthLinear(texcoord.st) * 0.5f / far, 1.0));
    }

    gl_FragData[0] = vec4(color, 1.0);


}