#define AOAmount 0.75	//[0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]

vec2 offsetDist(float x, int s){
	float n = fract(x*1.414)*3.1415;
    return vec2(cos(n),sin(n))*x/s;
}

float dbao(sampler2D depth, float dither, vec2 coord){
	float ao = 0.0;

	int samples = 5;
	dither = fract(frameTimeCounter * 4.0 + dither);

	float d = texture2D(depth,coord).r;
	float hand = float(d < 0.56);
	d = ld(d);
	
	float sd = 0.0;
	float angle = 0.0;
	float dist = 0.0;
	vec2 scale = 1.6 * vec2(1.0/aspectRatio,1.0) * gbufferProjection[1][1] / (2.74747742 * max(far*d,6.0));

	for (int i = 1; i <= samples; i++) {
		vec2 offset = offsetDist(i + dither, samples) * scale;

		sd = ld(texture2D(depth,coord+offset).r);
		float sample = far*(d-sd)*3.0;
		if (hand > 0.5) sample *= 1024.0;
		angle = clamp(0.5-sample,0.0,1.0);
		dist = clamp(0.25*sample-1.0,0.0,1.0);

		sd = ld(texture2D(depth,coord-offset).r);
		sample = far*(d-sd)*3.0;
		if (hand > 0.5) sample *= 1024.0;
		angle += clamp(0.5-sample,0.0,1.0);
		dist += clamp(0.25*sample-1.0,0.0,1.0);
		
		ao += clamp(angle + dist,0.0,1.0);
	}
	ao /= samples;
	
	return pow(ao,AOAmount);
}