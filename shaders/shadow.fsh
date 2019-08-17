#version 120

uniform sampler2D tex;
uniform sampler2D texture;
uniform sampler2D gdepth;

varying vec4 texcoord;
varying vec4 color;
varying vec4 mcEntity;
varying float isTransparent;

float 	GetMaterialIDs(in vec2 coord) {			//Function that retrieves the texture that has all material IDs stored in it
	return texture2D(gdepth, coord).r;
}

void main() {

    float matID = GetMaterialIDs(texcoord.st);

    if (texture2D(texture, texcoord.st).a < 0.35) {
        discard;
    }
    vec3 fragColor = color.rgb * texture2D(tex, texcoord.st).rgb;
    fragColor = mix(vec3(0), fragColor, isTransparent);

    gl_FragData[0] = vec4(fragColor, 1.0);
}