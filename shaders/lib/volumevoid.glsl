float bayer2(vec2 a) {
    a = floor(a);
    return fract( dot(a, vec2(.5, a.y * .75)) );
}

#define bayer4(a)   (bayer2( .5*(a))*.25+bayer2(a))
#define bayer8(a)   (bayer4( .5*(a))*.25+bayer2(a))
#define bayer16(a)  (bayer8( .5*(a))*.25+bayer2(a))
#define bayer32(a)  (bayer16(.5*(a))*.25+bayer2(a))
#define bayer64(a)  (bayer32(.5*(a))*.25+bayer2(a))
#define bayer128(a) (bayer64(.5*(a))*.25+bayer2(a))
#define bayer256(a) (bayer128(.5*(a))*.25+bayer2(a))

//noise functions
float noise2D(in vec2 coord, in float size, in vec2 offset) {
    coord      *= size;
    coord      += offset;
    coord      /= noiseTextureResolution;
    return texture2D(noisetex, coord).x*2.0-1.0;
}
float depthLin(float depth) {           //get linear depth
    return (2.0*near) / (far+near-depth * (far-near));
}
float depthLinInv(float depth) {         //inverse linear depth function
    return -((2.0*near / depth) - far-near)/(far-near);
}

vec3 rayPos(in float depth, const float scale) {           //funtion to get the ray position in world space
    vec2 coord = gl_FragCoord.xy;
        coord.x /= viewWidth;
        coord.y /= viewHeight;
    vec4 posNDC = vec4((coord.x) * 2.0 - 1.0, (coord.y) * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0);
    vec4 posCamSpace = gbufferProjectionInverse * posNDC;
        posCamSpace /= posCamSpace.w;
    vec4 posWorldSpace = gbufferModelViewInverse * posCamSpace;
        posWorldSpace.xyz *= scale;
    return posWorldSpace.xyz+cameraPosition.xyz;
}

float cloud_scatter(in vec3 pos, in vec3 lightVec, const int steps) {
    float density   = 0.25;     //this usually needs some sort of adjustment

    //get direction for raymarched lighting
    vec3 direction  = lightVec;
        direction   = normalize(mat3(gbufferModelViewInverse)*direction);
    float stepSize  = thickness/steps;

    vec3 rayStep    = direction*stepSize;
        pos        += rayStep;

    float transmittance = 0.0;

    //raymarch lighting
    for (int i = 0; i<steps; i++) {
        transmittance += volumeShape(pos);
        pos    += rayStep;
    }
    return exp2(-transmittance*density*stepSize);
}

float scatterIntegral(float transmittance, const float coeff) {
    float a   = -1.0/coeff;
    return transmittance * a - a;
}

#define VolumeSamples 30.0 //[6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 22.0 23.0 24.0 25.0 26.0 27.0 28.0 29.0 30.0]

void volumetric(in float Depth, in vec3 lightVector, inout vec3 scenecol) {
    float rayClip   = 600.0/far;        //this controls the maximum distance
    float dither    = fract(bayer64(gl_FragCoord.xy)+ frameCounter/8.0);
    float rayStart  = 0.0;              //zero unless you want the ray to start at a distance, in this case the clouds are usually a bit far away from the camera
    float rayEnd    = depthLin(Depth);
    float rayStep   = distance(rayEnd, rayStart)/VolumeSamples;
    float rayDepth  = rayStart;         //starting depth
        rayDepth   += rayStep*dither;   //apply dither and go to first ray step position

    float scatter   = 0.0;              //should always be zero
    float transmittance = 0.9;          //transmittance is basically how much of the light behind it will be absorbed
    float scatterCoefficient = 1.1;     //scatter intensity
    float transmittanceCoefficient = 1.0; //controls transmittance falloff
    float density   = 850.0;            //adjust density until it looks good, great numbers are normal with this raymarcher
    float weight    = 1.0/VolumeSamples;      //make density independent from samplecount

    vec3 DarkSkylight = vec3(0.2, 0.5, 1.0)*0.15;
    vec3 DarkerSkylight = vec3(0.1, 0.5, 1.0)*0.15;
    vec3 BrightSkylight = vec3(0.2, 0.5, 0.9) * 0.9;
    vec3 BrightSunlight = vec3(1.0, 0.92, 0.9);
    vec3 Yellowlight = vec3(1.0, 0.36, 0.08);
    vec3 DarkSunlight = vec3(0.8, 0.8, 0.9) * 0.05;
    vec3 sunlight = vec3(TimeSunrise*Yellowlight + TimeNoon*BrightSunlight + TimeSunset*Yellowlight + TimeMidnight*DarkSunlight);
    vec3 skylight = vec3(TimeSunrise*DarkSkylight + TimeNoon*BrightSkylight + TimeSunset*DarkSkylight + TimeMidnight*DarkerSkylight);

    for (int i = 0; i<VolumeSamples; ++i, rayDepth += rayStep) {
        if (rayDepth<rayStart) continue;
        vec3 rayP = rayPos(depthLinInv(rayDepth), rayClip);             //get ray position
        if (rayP.y>altitude+thickness || rayP.y<altitude) continue;     //skip step if ray is outside of cloud volume
        float oD = volumeShape(rayP)*weight*density;                    //get optical depth with shape funtion

        float stepTransmittance = exp2(-oD*transmittanceCoefficient);

        float powder = 2.80-exp(-(oD/weight/density)*2.0)*0.0025;          //this adds some detail to the lighting
        float light = cloud_scatter(rayP, lightVector, 6)*powder*scatterIntegral(stepTransmittance, 1.11)*transmittance;

        scatter += light*scatterCoefficient;   //get scatter value

        transmittance *= stepTransmittance;
    }
    vec3 color      = skylight*(1.0-transmittance) + sunlight*scatter;      //mix colors depending on scatter value
    scenecol        = scenecol*transmittance + color;                    //apply transmittance and add to scene
}