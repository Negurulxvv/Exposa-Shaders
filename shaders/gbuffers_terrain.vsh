#version 120

/*     CREDIT TO REGI24 FOR THE CODE     */

//Crop Vegetation
#define CARROT 				141.0	//Carrot	
#define POTATO 				142.0	//Potato
#define WHEAT 				59.0	//Wheat

//Hanging Vegetation
#define VINE 				106.0	//Vine

//Large Vegetation
#define COCOA 				127.0	//Cocoa
#define LFLOWERS 			175.0	//Sunflower, Lilac, Double Tall Grass, Large Fern, Rose Bush, Peony
#define SUGAR_CANE 			83.0	//Sugar Cane

//Ground Vegetation
#define DEAD_BUSH 			32.0	//Dead Bush
#define FLOWER1 			37.0 	//Dandelion
#define FLOWER2				38.0	//Poppy, Blue Orchid, Allium, Azure Bluet, Red/Orange/White/Pink Tulip, Oxeye Daisy 
#define GRASS 				31.0	//Grass
#define NETHER_WART		    115.0	//Nether Wart
#define SAPLING 			6.0		//Saplings
#define SHROOM1 			39.0	//Brown Mushroom
#define SHROOM2 			40.0	//Red Mushroom
#define STEM1 				104.0	//Pumpkin Stem
#define STEM2 				105.0	//Melon Stem

//Leaf Vegetation
#define LEAF1				18.0	//Oak/Spruce/Birch/Jungle Leaves
#define LEAF2 				161.0	//Acacia/Dark Oak Leaves

//High Viscosity Liquid
#define LAVA1 				10.0	//Flowing Lava
#define LAVA2 				11.0	//Stationary Lava

//Low Viscocity Liquid
#define WATER1 				8.0 	//Flowing Water
#define WATER2 				9.0		//Stationary Water

//Water Vegetation
#define LILY_PAD 			111.0	//Lily Pad

//Leave Alone
#define CROP_VEGETATION
#define HANGING_VEGETATION
#define LARGE_VEGETATION
#define GROUND_VEGETATION 
#define LEAF_VEGETATION 
#define LIQUID_HIGH_VISCOSITY
#define LIQUID_LOW_VISCOSITY
#define WATER_VEGETATION

attribute vec4 mc_Entity;

uniform float frameTimeCounter;
uniform float rainStrength;

varying vec3 binormal;
varying vec3 normal;
varying vec3 tangent;
varying vec3 viewVector;

varying vec4 color;
varying vec4 lmcoord;
varying vec4 texcoord;

void main() {

	const float pi = 3.14159265f;

	float tick = frameTimeCounter;

	lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
	
	texcoord = gl_MultiTexCoord0;
	
	vec4 position = gl_Vertex;
		
float grassW = mod(texcoord.t * 16.0f, 1.2f / 15.0f);

	   if (grassW < 0.01f) {
	  	grassW = 1.0f;
	  } else {
	  	grassW = 0.0f;
	  }

CROP_VEGETATION
	if (mc_Entity.x == CARROT || mc_Entity.x == POTATO || mc_Entity.x == WHEAT) {
		float speed = 0.1;
		
		float magnitude = sin((tick * pi / (28.0)) + position.x + position.z) * 0.12 + 0.02;
			  magnitude *= grassW * 0.2f;
		float d0 = sin(tick * pi / (122.0 * speed)) * 3.0 - 1.5 + position.z;
		float d1 = sin(tick * pi / (152.0 * speed)) * 3.0 - 1.5 + position.x;
		float d2 = sin(tick * pi / (122.0 * speed)) * 3.0 - 1.5 + position.x;
		float d3 = sin(tick * pi / (152.0 * speed)) * 3.0 - 1.5 + position.z;
		position.x += sin((tick * pi / (28.0 * speed)) + (position.x + d0) * 0.1 + (position.z + d1) * 0.1) * magnitude;
		position.z += sin((tick * pi / (28.0 * speed)) + (position.z + d2) * 0.1 + (position.x + d3) * 0.1) * magnitude;
	}
	
	if (mc_Entity.x == CARROT || mc_Entity.x == POTATO || mc_Entity.x == WHEAT) {
		float speed = 0.04;
		
		float magnitude = (sin(((position.y + position.x)/2.0 + tick * pi / ((28.0)))) * 0.025 + 0.075) * 0.2;
			  magnitude *= grassW;
		float d0 = sin(tick * pi / (112.0 * speed)) * 3.0 - 1.5;
		float d1 = sin(tick * pi / (142.0 * speed)) * 3.0 - 1.5;
		float d2 = sin(tick * pi / (112.0 * speed)) * 3.0 - 1.5;
		float d3 = sin(tick * pi / (142.0 * speed)) * 3.0 - 1.5;
		position.x += sin((tick * pi / (18.0 * speed)) + (-position.x + d0)*1.6 + (position.z + d1)*1.6) * magnitude * (1.0f + rainStrength * 2.0f);
		position.z += sin((tick * pi / (18.0 * speed)) + (position.z + d2)*1.6 + (-position.x + d3)*1.6) * magnitude * (1.0f + rainStrength * 2.0f);
		position.y += sin((tick * pi / (11.0 * speed)) + (position.z + d2) + (position.x + d3)) * (magnitude/3.0) * (1.0f + rainStrength * 2.0f);
	}

GROUND_VEGETATION
	if (mc_Entity.x == DEAD_BUSH || mc_Entity.x == FLOWER1 || mc_Entity.x == FLOWER2 || mc_Entity.x == GRASS || mc_Entity.x == NETHER_WART || mc_Entity.x == SAPLING || mc_Entity.x == SHROOM1 || mc_Entity.x == SHROOM2 || mc_Entity.x == STEM1 || mc_Entity.x == STEM2) {
		float speed = 0.9;
		
		float magnitude = sin((tick * pi / (28.0)) + position.x + position.z) * 0.1 + 0.1;
			  magnitude *= grassW * 0.5f;
		float d0 = sin(tick * pi / (122.0 * speed)) * 3.0 - 1.5 + position.z;
		float d1 = sin(tick * pi / (152.0 * speed)) * 3.0 - 1.5 + position.x;
		float d2 = sin(tick * pi / (122.0 * speed)) * 3.0 - 1.5 + position.x;
		float d3 = sin(tick * pi / (152.0 * speed)) * 3.0 - 1.5 + position.z;
		position.x += sin((tick * pi / (28.0 * speed)) + (position.x + d0) * 0.1 + (position.z + d1) * 0.1) * magnitude * (1.0f + rainStrength * 1.4f);
		position.z += sin((tick * pi / (28.0 * speed)) + (position.z + d2) * 0.1 + (position.x + d3) * 0.1) * magnitude * (1.0f + rainStrength * 1.4f);
	}
	
	if (mc_Entity.x == DEAD_BUSH || mc_Entity.x == FLOWER1 || mc_Entity.x == FLOWER2 || mc_Entity.x == GRASS || mc_Entity.x == NETHER_WART || mc_Entity.x == SAPLING || mc_Entity.x == SHROOM1 || mc_Entity.x == SHROOM2 || mc_Entity.x == STEM1 || mc_Entity.x == STEM2) {
		float speed = 0.09;
		
		float magnitude = (sin(((position.y + position.x)/2.0 + tick * pi / ((28.0)))) * 0.05 + 0.15) * 0.4;
			  magnitude *= grassW * 0.5f;
		float d0 = sin(tick * pi / (112.0 * speed)) * 3.0 - 1.5;
		float d1 = sin(tick * pi / (142.0 * speed)) * 3.0 - 1.5;
		float d2 = sin(tick * pi / (112.0 * speed)) * 3.0 - 1.5;
		float d3 = sin(tick * pi / (142.0 * speed)) * 3.0 - 1.5;
		position.x += sin((tick * pi / (18.0 * speed)) + (-position.x + d0)*1.6 + (position.z + d1)*1.6) * magnitude * (1.0f + rainStrength * 1.7f);
		position.z += sin((tick * pi / (18.0 * speed)) + (position.z + d2)*1.6 + (-position.x + d3)*1.6) * magnitude * (1.0f + rainStrength * 1.7f);
		position.y += sin((tick * pi / (11.0 * speed)) + (position.z + d2) + (position.x + d3)) * (magnitude/3.0) * (1.0f + rainStrength * 1.7f);
	}	
	
HANGING_VEGETATION
    if (mc_Entity.x == VINE && texcoord.t < 0.60) {
        float speed = 0.3;
        float magnitude = (sin(((position.y + position.x)/2.0 + tick * pi / ((88.0)))) * 0.05 + 0.15) * 0.26;
        float d0 = sin(tick * pi / (122.0 * speed)) * 3.0 - 1.5;
        float d1 = sin(tick * pi / (152.0 * speed)) * 3.0 - 1.5;
        float d2 = sin(tick * pi / (192.0 * speed)) * 3.0 - 1.5;
        float d3 = sin(tick * pi / (142.0 * speed)) * 3.0 - 1.5;
        position.x += sin((tick * pi / (16.0 * speed)) + (position.x + d0)*0.5 + (position.z + d1)*0.5 + (position.y)) * magnitude;
        position.z += sin((tick * pi / (18.0 * speed)) + (position.z + d2)*0.5 + (position.x + d3)*0.5 + (position.y)) * magnitude;
    }

    if (mc_Entity.x == VINE && texcoord.t < 0.20) {
        float speed = 0.3;
        float magnitude = (sin(((position.y + position.x)/8.0 + tick * pi / ((88.0)))) * 0.15 + 0.05) * 0.22;
        float d0 = sin(tick * pi / (112.0 * speed)) * 3.0 + 0.5;
        float d1 = sin(tick * pi / (142.0 * speed)) * 3.0 + 0.5;
        float d2 = sin(tick * pi / (112.0 * speed)) * 3.0 + 0.5;
        float d3 = sin(tick * pi / (142.0 * speed)) * 3.0 + 0.5;
        position.x += sin((tick * pi / (18.0 * speed)) + (-position.x + d0)*1.6 + (position.z + d1)*1.6) * magnitude;
        position.z += sin((tick * pi / (18.0 * speed)) + (position.z + d2)*1.6 + (-position.x + d3)*1.6) * magnitude;
        position.y += sin((tick * pi / (11.0 * speed)) + (position.z + d2) + (position.x + d3)) * (magnitude/4.0);
    }

LARGE_VEGETATION
	if (mc_Entity.x == COCOA || mc_Entity.x == LFLOWERS || mc_Entity.x == SUGAR_CANE) {
		float speed = 0.4;
		
		float magnitude = (sin((position.y + position.x + tick * pi / ((28.0) * speed))) * 0.15 + 0.15) * 0.20;
		float d0 = sin(tick * pi / (112.0 * speed)) * 3.0 - 1.5;
		float d1 = sin(tick * pi / (142.0 * speed)) * 3.0 - 1.5;
		float d2 = sin(tick * pi / (132.0 * speed)) * 3.0 - 1.5;
		float d3 = sin(tick * pi / (122.0 * speed)) * 3.0 - 1.5;
		position.x += sin((tick * pi / (18.0 * speed)) + (-position.x + d0)*1.6 + (position.z + d1)*1.6) * magnitude * (1.0f + rainStrength * 1.1f);
		position.z += sin((tick * pi / (17.0 * speed)) + (position.z + d2)*1.6 + (-position.x + d3)*1.6) * magnitude * (1.0f + rainStrength * 1.1f);
		position.y += sin((tick * pi / (11.0 * speed)) + (position.z + d2) + (position.x + d3)) * (magnitude/2.0) * (1.0f + rainStrength * 1.1f);
		
	}
	
	if (mc_Entity.x == COCOA || mc_Entity.x == LFLOWERS || mc_Entity.x == SUGAR_CANE) {
		float speed = 0.4;
		
		float magnitude = (sin((tick * pi / ((28.0) * speed))) * 0.05 + 0.15) * 0.1;
		float d0 = sin(tick * pi / (122.0 * speed)) * 3.0 - 1.5;
		float d1 = sin(tick * pi / (142.0 * speed)) * 3.0 - 1.5;
		float d2 = sin(tick * pi / (162.0 * speed)) * 3.0 - 1.5;
		float d3 = sin(tick * pi / (112.0 * speed)) * 3.0 - 1.5;
		position.x += sin((tick * pi / (13.0 * speed)) + (position.x + d0)*0.9 + (position.z + d1)*0.9) * magnitude;
		position.z += sin((tick * pi / (16.0 * speed)) + (position.z + d2)*0.9 + (position.x + d3)*0.9) * magnitude;
		position.y += sin((tick * pi / (15.0 * speed)) + (position.z + d2) + (position.x + d3)) * (magnitude/1.0);
	}

LEAF_VEGETATION	
	if (mc_Entity.x == LEAF1 || mc_Entity.x == LEAF2) {
		float speed = 0.10;

		float magnitude = (sin((position.y + position.x + tick * pi / ((28.0) * speed))) * 0.15 + 0.15) * 0.30;
			  magnitude *= grassW;
		float d0 = sin(tick * pi / (112.0 * speed)) * 3.0 - 1.5;
		float d1 = sin(tick * pi / (142.0 * speed)) * 3.0 - 1.5;
		float d2 = sin(tick * pi / (132.0 * speed)) * 3.0 - 1.5;
		float d3 = sin(tick * pi / (122.0 * speed)) * 3.0 - 1.5;
		position.x += sin((tick * pi / (18.0 * speed)) + (-position.x + d0)*1.6 + (position.z + d1)*1.6) * magnitude * (1.0f + rainStrength * 1.0f);
		position.z += sin((tick * pi / (17.0 * speed)) + (position.z + d2)*1.6 + (-position.x + d3)*1.6) * magnitude * (1.0f + rainStrength * 1.0f);
		position.y += sin((tick * pi / (11.0 * speed)) + (position.z + d2) + (position.x + d3)) * (magnitude/2.0) * (1.0f + rainStrength * 1.0f);
		
	}
	
	if (mc_Entity.x == LEAF1 || mc_Entity.x == LEAF2) {
		float speed = 0.075;
		
		float magnitude = (sin((tick * pi / ((28.0) * speed))) * 0.05 + 0.15) * 0.075;
			  magnitude *= 1.0f - grassW;
		float d0 = sin(tick * pi / (122.0 * speed)) * 3.0 - 1.5;
		float d1 = sin(tick * pi / (142.0 * speed)) * 3.0 - 1.5;
		float d2 = sin(tick * pi / (162.0 * speed)) * 3.0 - 1.5;
		float d3 = sin(tick * pi / (112.0 * speed)) * 3.0 - 1.5;
		position.x += sin((tick * pi / (13.0 * speed)) + (position.x + d0)*0.9 + (position.z + d1)*0.9) * magnitude;
		position.z += sin((tick * pi / (16.0 * speed)) + (position.z + d2)*0.9 + (position.x + d3)*0.9) * magnitude;
		position.y += sin((tick * pi / (15.0 * speed)) + (position.z + d2) + (position.x + d3)) * (magnitude/1.0);
	}

LIQUID_HIGH_VISCOSITY
	if (mc_Entity.x == LAVA1 || mc_Entity.x == LAVA2) {
		float speed = 0.8;
        float magnitude = (sin((tick * pi / ((28.0) * speed))) * 0.05 + 0.15) * 0.27;
        float d0 = sin(tick * pi / (122.0 * speed)) * 3.0 - 1.5;
        float d1 = sin(tick * pi / (142.0 * speed)) * 3.0 - 1.5;
        float d2 = sin(tick * pi / (162.0 * speed)) * 3.0 - 1.5;
        float d3 = sin(tick * pi / (112.0 * speed)) * 3.0 - 1.5;
        position.y += sin((tick * pi / (15.0 * speed)) +d2 + d3 + (position.z + position.x) * (pi*2/16*3)) * magnitude;	/* Thanks Karyonix! :D */
	}

LIQUID_LOW_VISCOSITY
	if (mc_Entity.x == WATER1 || mc_Entity.x == WATER2) {
		float speed = 0.2;
        float magnitude = (sin((tick * pi / ((28.0) * speed))) * 0.05 + 0.15) * 0.27;
        float d0 = sin(tick * pi / (122.0 * speed)) * 3.0 - 1.5;
        float d1 = sin(tick * pi / (142.0 * speed)) * 3.0 - 1.5;
        float d2 = sin(tick * pi / (162.0 * speed)) * 3.0 - 1.5;
        float d3 = sin(tick * pi / (112.0 * speed)) * 3.0 - 1.5;
        position.y += sin((tick * pi / (15.0 * speed)) +d2 + d3 + (position.z + position.x) * (pi*2/16*3)) * magnitude;
	}

WATER_VEGETATION
    if (mc_Entity.x == LILY_PAD) {
        float speed = 0.25;
        float magnitude = (sin((tick * pi / ((28.0) * speed))) * 0.05 + 0.15) * 0.17;
        float d0 = sin(tick * pi / (132.0 * speed)) * 3.0 - 1.5;
        float d1 = sin(tick * pi / (132.0 * speed)) * 3.0 - 1.5;
        float d2 = sin(tick * pi / (132.0 * speed)) * 3.0 - 1.5;
        float d3 = sin(tick * pi / (132.0 * speed)) * 3.0 - 1.5;
        position.x += sin((tick * pi / (13.0 * speed)) + (position.x + d0)*0.9 + (position.z + d1)*0.9) * magnitude;
        position.y += sin((tick * pi / (15.0 * speed)) + (position.z + d2) + (position.x + d3)) * magnitude;
        position.y -= 0.04;
    }
	
    if (mc_Entity.x == LILY_PAD) {
        float speed = 0.4;
        float magnitude = (sin((tick * pi / ((28.0) * speed))) * 0.05 + 0.15) * 0.17;
        float d0 = sin(tick * pi / (132.0 * speed)) * 3.0 - 1.5;
        float d1 = sin(tick * pi / (132.0 * speed)) * 3.0 - 1.5;
        float d2 = sin(tick * pi / (132.0 * speed)) * 3.0 - 1.5;
        float d3 = sin(tick * pi / (132.0 * speed)) * 3.0 - 1.5;
        position.x += sin((tick * pi / (13.0 * speed)) + (position.x + d0)*0.9 + (position.z + d1)*0.9) * magnitude;
        position.y += sin((tick * pi / (15.0 * speed)) + (position.z + d2) + (position.x + d3)) * magnitude;
        position.y -= 0.04;
    }
	
	color = gl_Color;
	
	gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * position);

	mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
                          tangent.y, binormal.y, normal.y,
                          tangent.z, binormal.z, normal.z);
}