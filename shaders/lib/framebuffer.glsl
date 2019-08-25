const int RGBA16                 = 1;             
const int gcolorFormat           =  RGBA16;  
const int colortex5Format        =  RGBA16;
const int shadowMapResolution    =  3548; //Resolution of the Shadows
const bool colortex5Clear = false;

const float sunPathRotation   = -40.0;

uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D gdepth;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

#define GCOLOR_OUT      gl_FragData[0]
#define GDEPTH_OUT      gl_FragData[1]
#define GNORMAL_OUT     gl_FragData[2]

#define TORCH_INSENITY 7.0

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define  projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)

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

vec3 toNDC(vec3 pos){
	vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
    vec3 p3 = pos * 2. - 1.;
    vec4 fragpos = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragpos.xyz / fragpos.w;
}

vec3 toWorld(vec3 pos){
	return mat3(gbufferModelViewInverse) * pos + gbufferModelViewInverse[3].xyz;
}
