#version 120

varying vec3 tintColor;

varying vec3 pos;

void main() {

	pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	
	gl_Position = ftransform();

	tintColor = gl_Color.rgb;
}