#define CloudStyle 0 //[0 1]

uniform sampler2D noisetex;

//smoothstep macro because the order of inputs is dumb on glsl
#define sstep(x, low, high) smoothstep(low, high, x)


//functions for 2d and 3d noise
float Nnoise2D(in vec2 coord, in float size) {
    coord      *= size;
    coord      /= noiseTextureResolution;
    return texture2D(noisetex, coord).x*2.0-1.0;
}

float fake3D(in vec2 coord, in float size) {
    coord *= size;
    vec3 i          = floor(vec3(coord, 0.0));
    vec3 f          = fract(vec3(coord, 0.0));

    vec2 p1         = (i.xy+i.z*vec2(20.0)+f.xy);
    vec2 p2         = (i.xy+(i.z+1.f)*vec2(20.0))+f.xy;
    vec2 c1         = (p1+0.5)/noiseTextureResolution;
    vec2 c2         = (p2+0.5)/noiseTextureResolution;
    float r1        = texture2D(noisetex, c1).r;
    float r2        = texture2D(noisetex, c2).r;
    return mix(r1, r2, f.z)*2.0-1.0;

}
float Nnoise3D(in vec3 pos, in float size) {
    pos            *= size;
    vec3 i          = floor(pos);
    vec3 f          = fract(pos);

    vec2 p1         = (i.xy+i.z*vec2(20.0)+f.xy);
    vec2 p2         = (i.xy+(i.z+1.f)*vec2(20.0))+f.xy;
    vec2 c1         = (p1+0.5)/noiseTextureResolution;
    vec2 c2         = (p2+0.5)/noiseTextureResolution;
    float r1        = texture2D(noisetex, c1).r;
    float r2        = texture2D(noisetex, c2).r;
    return mix(r1, r2, f.z)*2.0-1.0;
}

float shapedclouds(in vec3 pos) {
    const float size    = 0.001;     //an overall size constant can be conveniant
    float tick      = frameTimeCounter*0.1;     //for animation
    vec3 wind       = tick*vec3(1.0, 0.2, 0.0);     //make wind in one direction

    //fades for the cloud shape to be contained in it's volume
    float lowerFade     = sstep(pos.y, altitude-thickness, altitude-1);
    float higherFade    = 1.0-sstep(pos.y, altitude+1, altitude+thickness * 0.2);

    vec2 coord      = pos.xz;

    //makes the noise more interesting if you add noise to the position
    vec2 noiseCoord = pos.xz + Nnoise2D(pos.xz+wind.xz, 10.0*size)*20.0;

    //sample noise in an fbm-like fashion for the cloud shape
    #if CloudStyle == 0
    float shape     = Nnoise2D(noiseCoord+wind.xz, 0.5*size);
        shape      += Nnoise2D(noiseCoord+wind.xz, 2.0*size)*0.25;
        shape      += Nnoise2D(coord+wind.xz, 4.0*size)*0.125;
        shape      += Nnoise2D(coord+wind.xz, 8.0*size)*0.0625;
    #endif

    #if CloudStyle == 1
    float shape     = Nnoise3D(pos+wind, 0.5*size);
        shape      += Nnoise3D(pos+wind, 2.0*size)*0.25;
        shape      += Nnoise3D(pos+wind, 4.0*size)*0.025;
        shape      += Nnoise3D(pos+wind, 8.0*size)*0.0025;
    #endif

        shape      -= 0.0;  //use this for manual coverage adjustment

        shape      *= lowerFade;
        shape      *= higherFade;

    return max(shape, 0.0);     //because negative density values are not allowed
}

float cloudScatter(in vec3 pos, in vec3 lightVec, const int steps) {
    float density   = 0.01;

    //get direction for raymarched lighting
    vec3 direction  = lightVec;
        direction   = normalize(mat3(gbufferModelViewInverse)*direction);
    float stepSize  = thickness/steps;

    vec3 rayStep    = direction*stepSize;
        pos        += rayStep;

    float transmittance = 0.0;

    //raymarch lighting
    for (int i = 0; i<steps; i++) {
        transmittance += shapedclouds(pos);
        pos    += rayStep;
    }
    return exp2(-transmittance*density*stepSize);
}

//worldPos is without camera offset
void clouds_2D(in vec3 worldPos, in vec3 cameraPos, in vec3 lightVec, in vec3 sunlight, in vec3 skylight, bool isTerrain, in float height, inout vec3 sceneColor) {
    float cloud     = 0.0;
    float scatter   = 0.0;
    bool visibility = false;
    height    = altitude;

    vec3 worldVec   = normalize(worldPos-cameraPos.xyz);

    //check if clouds are potentially visible
    if (isTerrain) {
        visibility = (worldPos.y>=height && cameraPos.y<=height) || 
        (worldPos.y<=height && cameraPos.y>=height);
    } else if (!isTerrain) {
        visibility = (worldPos.y>=cameraPos.y && cameraPos.y<=height) || 
        (worldPos.y<=cameraPos.y && cameraPos.y>=height);
    }

    if (visibility) {
        vec3 cloud_plane    = worldVec*((height-cameraPos.y)/worldVec.y);
        vec3 rayPosition    = cameraPos.xyz+cloud_plane;

        //sample cloud shape
        float oD            = shapedclouds(rayPosition);

        //sample lighting only when there are clouds present on that pixel
        if (oD>0.0) scatter = cloudScatter(rayPosition, lightVec, 3);

        cloud              += oD;
    }

    vec3 color      = mix(skylight, sunlight, scatter);
    cloud           = clamp(cloud, 0.0, 1.0);

    //mix clouds with scene color
    sceneColor      = mix(sceneColor, color, cloud);
}

void clouds2D2(in vec3 worldPos, in vec3 cameraPos, in vec3 lightVec, in vec3 sunlight, in vec3 skylight, bool isTerrain, in float height, inout vec3 sceneColor) {
    float cloud     = 0.0;
    float scatter   = 0.0;
    bool visibility = false;

    vec3 worldVec   = normalize(worldPos-cameraPos.xyz);

    //check if clouds are potentially visible
    if (isTerrain) {
        visibility = (worldPos.y>=height && cameraPos.y<=height) || 
        (worldPos.y<=height && cameraPos.y>=height);
    } else if (!isTerrain) {
        visibility = (worldPos.y>=cameraPos.y && cameraPos.y<=height) || 
        (worldPos.y<=cameraPos.y && cameraPos.y>=height);
    }

    if (visibility) {
        vec3 cloud_plane    = worldVec*((height-cameraPos.y)/worldVec.y);
        vec3 rayPosition    = cameraPos.xyz+cloud_plane;

        //sample cloud shape
        float oD            = shapedclouds(rayPosition);

        //sample lighting only when there are clouds present on that pixel
        if (oD>0.0) scatter = cloudScatter(rayPosition, lightVec, 3);

        cloud              += oD;
    }

    vec3 color      = mix(skylight, sunlight, scatter);
    cloud           = clamp(cloud, 0.0, 0.1);

    //mix clouds with scene color
    sceneColor      = mix(sceneColor, color, cloud);
}

void pasted2DClouds(in vec3 worldPos, in vec3 cameraPos, in vec3 lightVec, in vec3 sunlight, in vec3 skylight, bool isTerrain, in float height, inout vec3 sceneColor) {
    height = altitude;
    clouds2D2(worldPos, cameraPos, lightVec, sunlight, skylight, isTerrain, height, sceneColor);
    height = altitude + 10.0;
    clouds2D2(worldPos, cameraPos, lightVec, sunlight, skylight, isTerrain, height, sceneColor);
    height = altitude + 50.0;
    clouds2D2(worldPos, cameraPos, lightVec, sunlight, skylight, isTerrain, height, sceneColor);
    height = altitude + 100.0;
    clouds2D2(worldPos, cameraPos, lightVec, sunlight, skylight, isTerrain, height, sceneColor);
    height = altitude + 150.0;
    clouds2D2(worldPos, cameraPos, lightVec, sunlight, skylight, isTerrain, height, sceneColor);
    height = altitude + 200.0;
    clouds2D2(worldPos, cameraPos, lightVec, sunlight, skylight, isTerrain, height, sceneColor);
    height = altitude + 250.0;
    clouds2D2(worldPos, cameraPos, lightVec, sunlight, skylight, isTerrain, height, sceneColor);
    height = altitude + 350.0;
    clouds2D2(worldPos, cameraPos, lightVec, sunlight, skylight, isTerrain, height, sceneColor);
    height = altitude + 450.0;
    clouds2D2(worldPos, cameraPos, lightVec, sunlight, skylight, isTerrain, height, sceneColor);


}