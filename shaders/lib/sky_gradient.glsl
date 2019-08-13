#define DRAW_SUN //if not using custom sky
#define SKY_BRIGHTNESS_DAY 0.5 //[0.0 0.5 0.75 1. 1.2 1.4 1.6 1.8 2.0]
#define SKY_BRIGHTNESS_NIGHT 1.0 //[0.0 0.5 0.75 1. 1.2 1.4 1.6 1.8 2.0]

void SkyGradient(in vec3 cameraPosition, in vec3 upPosition, in vec3 sunPosition, in vec3 moonPosition) {
    vec3 viewVec = normalize(cameraPosition);
    vec3 horizonVec = normalize(upPosition+viewVec);
    vec3 sunglowVec = normalize(sunPosition+viewVec);
    vec3 moonglowVec = normalize(moonPosition+viewVec);

    float sunGradient = dot(sunglowVec, viewVec);
    float moonGradient = dot(moonglowVec, viewVec);
    float horizonGradient = dot(horizonVec, viewVec);
}