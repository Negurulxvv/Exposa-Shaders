const int RGBA16                 = 1;             
const int gcolorFormat           =  RGBA16;
const float shadowMapResolution    = 4096; //[2048 4096 8192]
const int noiseTextureResolution = 512;

const float sunPathRotation   = -40.0;

uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D gdepth;

#define GCOLOR_OUT      gl_FragData[0]
#define GDEPTH_OUT      gl_FragData[1]
#define GNORMAL_OUT     gl_FragData[2]


float getTorchLightStrength(in vec2 coord) {
    return texture2D(gdepth, coord).r;
}