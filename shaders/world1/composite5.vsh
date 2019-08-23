#version 120

varying vec2 texcoord;

varying vec3 lightPosition;

void main() {
    gl_Position = ftransform();

    texcoord = gl_MultiTexCoord0.xy;
}