#version 120

varying vec4 texcoord;
varying vec3 lightVector;
varying vec3 colSky;
varying vec3 colFog;
varying vec3 sunlight;

uniform sampler2D texture;
//uniform sampler2D lightmap;
uniform vec3 shadowLightPosition;

//varying vec4 lmcoord; 	//you cannot get lightmap data like this in composite/deferred passes

uniform vec3 skyColor; 	//vanilla sky color uniform
uniform vec3 fogColor; 	//vanilla fog color

void main(){
	gl_Position = ftransform();

    //vec3 color = texture2D(lightmap,lmcoord.st).xyz; 	//that does not make sense

	sunlight 	= vec3(1.0, 1.0, 1.0); //can use any sunlight color here

	colSky 	= skyColor;
	colFog 	= fogColor;
	
	texcoord = gl_MultiTexCoord0;

	lightVector 	= normalize(shadowLightPosition);

}
