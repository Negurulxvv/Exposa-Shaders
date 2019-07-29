const int RGBA16                 = 1;             
const int gcolorFormat           =  RGBA16;
const int shadowMapResolution    = 8192; //Resolution of the Shadows
const int noiseTextureResolution = 256; //Resolution of the noise

const float sunPathRotation   = -40.0;

uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D gdepth;

#define GCOLOR_OUT      gl_FragData[0]
#define GDEPTH_OUT      gl_FragData[1]
#define GNORMAL_OUT     gl_FragData[2]

#define TORCH_INSENITY 7.0

vec3 getAlbedo(in vec2 coord) {
    return texture2D(gcolor, coord).rgb;
}

vec3 getNormal(in vec2 coord) {
    return texture2D(gnormal, coord).rgb * 2.0 - 1.0;
}

float getEmission(in vec2 coord) {
    return texture2D(gdepth, coord).a;
}

float getTorchLightStrength(in vec2 coord) {
    return texture2D(gdepth, coord).r;
}
