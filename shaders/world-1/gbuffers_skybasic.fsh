#version 120

varying vec3 tintColor;

varying vec3 pos;

uniform vec3 skyColor;
uniform vec3 fogColor;
uniform vec3 upPosition;

void main() {


	float mix_fog = exp(-pow(dot(normalize(pos), normalize(upPosition)), 2.0) * 5.0);

	gl_FragData[0] = vec4(tintColor, 1.0);
	gl_FragData[0].rgb = mix(skyColor, fogColor, mix_fog);
	gl_FragData[1] = vec4(0.0, 0.0, 0.0, 1.0);
}