

float SkyGradient(in vec3 cameraPosition, in vec3 upPosition, in vec3 sunPosition, in vec3 moonPosition, in vec3 pos) {
    vec3 viewVec = normalize(pos);
    vec3 horizonVec = normalize(upPosition+viewVec);
    vec3 sunglowVec = normalize(sunPosition+viewVec);
    vec3 moonglowVec = normalize(moonPosition+viewVec);

    float sunGradient = dot(sunglowVec, viewVec);
    float moonGradient = dot(moonglowVec, viewVec);
    float horizonGradient = dot(horizonVec, viewVec);
    vec3 sundot = (sunglowVec, viewVec);
    vec3 horizondot = (horizonVec, viewVec);

    float mixfog = exp(-pow((sunGradient, horizonGradient), 2.0) * 5.0);

    return mixfog;
}
