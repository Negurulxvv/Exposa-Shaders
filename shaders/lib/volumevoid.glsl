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
    float density   = 0.15;     //this usually needs some sort of adjustment

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

void volumetric(in float Depth, in vec3 lightVector, inout vec3 scenecol) {
    const int samples = 20;              //about 6-20 are fine depending on your preference
    float rayClip   = 600.0/far;        //this controls the maximum distance
    float dither    = bayer32(gl_FragCoord.xy);
    float rayStart  = 0.0;              //zero unless you want the ray to start at a distance, in this case the clouds are usually a bit far away from the camera
    float rayEnd    = depthLin(Depth);
    float rayStep   = distance(rayEnd, rayStart)/samples;
    float rayDepth  = rayStart;         //starting depth
        rayDepth   += rayStep*dither;   //apply dither and go to first ray step position

    float scatter   = 0.0;              //should always be zero
    float transmittance = 1.0;          //transmittance is basically how much of the light behind it will be absorbed
    float scatterCoefficient = 1.4;     //scatter intensity
    float transmittanceCoefficient = 1.0; //controls transmittance falloff
    float density   = 150.0;            //adjust density until it looks good, great numbers are normal with this raymarcher
    float weight    = 1.0/samples;      //make density independent from samplecount

    vec3 sunlight = vec3(1.0, 0.92, 0.9);
    vec3 skylight = vec3(0.2, 0.5, 1.0)*0.25;

    for (int i = 0; i<samples; ++i, rayDepth += rayStep) {
        if (rayDepth<rayStart) continue;
        vec3 rayP = rayPos(depthLinInv(rayDepth), rayClip);             //get ray position
        if (rayP.y>altitude+thickness || rayP.y<altitude) continue;     //skip step if ray is outside of cloud volume
        float oD = volumeShape(rayP)*weight*density;                    //get optical depth with shape funtion

        float stepTransmittance = exp2(-oD*transmittanceCoefficient);

        float powder = 1.0-exp(-(oD/weight/density)*4.0)*0.25;          //this adds some detail to the lighting
        float light = cloud_scatter(rayP, lightVector, 4)*powder*scatterIntegral(stepTransmittance, 1.11)*transmittance;

        scatter += light*scatterCoefficient;   //get scatter value

        transmittance *= stepTransmittance;
    }
    vec3 color      = skylight*(1.0-transmittance) + sunlight*scatter;      //mix colors depending on scatter value
    scenecol        = scenecol*transmittance + color;                    //apply transmittance and add to scene
}