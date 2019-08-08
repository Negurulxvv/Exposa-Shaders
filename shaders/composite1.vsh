#version 120

uniform int worldTime;
uniform vec3 sunPosition;
uniform vec3 moonPosition;

varying vec4 texcoord;

varying vec3 lightPosition;

void main() {
    gl_Position = ftransform();

    texcoord = gl_MultiTexCoord0;

    if (worldTime < 12700 || worldTime > 23250) {
        lightPosition = normalize(sunPosition);
    } else {
        lightPosition = normalize(moonPosition);
    }
}