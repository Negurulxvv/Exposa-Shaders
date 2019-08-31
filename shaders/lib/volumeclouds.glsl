

#define sstep(x, low, high) smoothstep(low, high, x)


float noise3D(in vec3 pos, in float size, in vec3 offset) {
    pos            *= size;
    pos            += offset;
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

float cubeSmooth(float x) {
    return (x*x) * (3.0-2.0*x);
}

float density = 1.5;

float volumeShape(in vec3 pos) {
    float tick = frameTimeCounter;
    vec3 wind = vec3(tick)*0.1;

    float size = 0.01;

    float hfade     = 1.0-sstep(pos.y, altitude+thickness*0.2, altitude+thickness);
    float lfade     = sstep(pos.y, altitude, altitude+thickness*0.23);

    float divider   = 0.5;  //this is to correct the maximum value of the resulting noise

    float noise = noise3D(pos, size*0.5, wind);         divider += 1.0;     //this is a noise octave
        noise  += noise3D(pos, 2.0*size, wind)*0.5;     divider += 0.5;     //this is another one
        pos    += noise*0.5/size;                                           //offsetting the position with noise gives a nice curly effect
        noise  += noise3D(pos, 7.0*size, wind)*0.355;    divider += 0.355;    //make sure that the multiplier of the noise and the add of the divider stay roughly the same
        noise  += noise3D(pos, 14.0*size, wind)*0.0555;  divider += 0.0555;   //the bigger the size the smaller the noise
        noise  += noise3D(pos, 28.0*size, wind)*0.005555; divider += 0.005555;  //small scale noise adds detail
         noise  += noise3D(pos, 38.0*size, wind)*0.0005555; divider += 0.0005555;  //small scale noise adds detail

        noise += (0.85*rainStrength + 0.05*rainStrength);

        noise   = max(noise/divider, 0.0);  //we don't want negative noise values
        noise   = cubeSmooth(noise);    //this gives a nicer falloff
        noise  *= hfade*lfade;          //apply fading

    return max(noise*density, 0.0)*4.0;
}