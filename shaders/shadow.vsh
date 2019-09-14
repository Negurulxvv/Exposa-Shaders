#version 120

attribute vec4 mc_Entity;

varying vec4 texcoord;
varying vec4 color;
varying float isTransparent;

float getIsTransparent(in float materialId) {
    if(materialId == 160.0) {    // stained glass pane
        return 1.0;
    }
    if(materialId == 95.0) {   // stained glass
        return 1.0;
    }
    if(materialId == 79.0) {   // ice
        return 1.0;
    }
    return 0.0;
}

#define SHADOW_MAP_BIAS 0.85
vec4 BiasShadowProjection(in vec4 projectedShadowSpacePosition) {

	vec2 pos = abs(projectedShadowSpacePosition.xy * 1.165);
	vec2 posSQ = pos*pos;
	
	float dist = pow(posSQ.x*posSQ.x*posSQ.x + posSQ.y*posSQ.y*posSQ.y, 1.0 / 6.0);

	float distortFactor = (1.0 - SHADOW_MAP_BIAS) + dist * SHADOW_MAP_BIAS;

	projectedShadowSpacePosition.xy /= distortFactor*0.92;



	return projectedShadowSpacePosition;
}

void main() {
    gl_Position = BiasShadowProjection(ftransform());
    texcoord = gl_MultiTexCoord0;
    color = gl_Color;

    isTransparent = getIsTransparent(mc_Entity.x);
}