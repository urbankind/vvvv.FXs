//@author:desaxismundi
//@help:procedural 4dnoise bump
//@tags:perlin,inoise,bump,procedural
//@credits:sanch,nvidia

//transforms
float4x4 tW:WORLD;
float4x4 tV:VIEW;
float4x4 tP:PROJECTION;
float4x4 tWVP:WORLDVIEWPROJECTION;

//material properties
float4 cAmb : COLOR <String uiname="Color";> =1;

//samplers
texture permTexture;
sampler permSampler = sampler_state{texture=(permTexture);AddressU=Wrap;AddressV=Clamp;MAGFILTER=POINT;MINFILTER=POINT;MIPFILTER=NONE;};
texture gradTexture4d;
sampler gradSampler4d=sampler_state{texture=(gradTexture4d);AddressU=Wrap;AddressV=Clamp;MAGFILTER=POINT;MINFILTER=POINT;MIPFILTER=NONE;};
float4x4 tTex;

int octaves = 1;
float lacunarity = 1;
float gain = 0.05;
float offset = 1.0;

struct vs2ps{
    float4 Pos:POSITION;
    float4 TexCd:TEXCOORD0;
	float4 wPosition:TEXCOORD1;
	float3 Light:TEXCOORD2;
	float3 Normal:NORMAL;
};

float4 fade(float4 t){return t * t * t * (t * (t * 6 - 15) + 10);}
float perm(float x){return tex1D(permSampler, x);}
float grad(float x, float4 p){return dot(tex1D(gradSampler4d, x), p);}

// 4D noise
float inoise(float4 p){
	float4 P = fmod(floor(p), 256.0);
  	p -= floor(p);
	float4 f = fade(p);
	P = P / 256.0;
const float one = 1.0 / 256.0;

	// HASH COORDINATES OF THE 16 CORNERS OF THE HYPERCUBE
  	float A = perm(P.x) + P.y;
  	float AA = perm(A) + P.z;
  	float AB = perm(A + one) + P.z;
  	float B =  perm(P.x + one) + P.y;
  	float BA = perm(B) + P.z;
  	float BB = perm(B + one) + P.z;

	float AAA = perm(AA)+P.w, AAB = perm(AA+one)+P.w;
    float ABA = perm(AB)+P.w, ABB = perm(AB+one)+P.w;
    float BAA = perm(BA)+P.w, BAB = perm(BA+one)+P.w;
    float BBA = perm(BB)+P.w, BBB = perm(BB+one)+P.w;


  	// INTERPOLATE DOWN
  	return lerp(
  				lerp( lerp( lerp( grad(perm(AAA), p ),  
                                  grad(perm(BAA), p + float4(-1, 0, 0, 0) ), f.x),
                            lerp( grad(perm(ABA), p + float4(0, -1, 0, 0) ),
                                  grad(perm(BBA), p + float4(-1, -1, 0, 0) ), f.x), f.y),
                                  
                      lerp( lerp( grad(perm(AAB), p + float4(0, 0, -1, 0) ),
                                  grad(perm(BAB), p + float4(-1, 0, -1, 0) ), f.x),
                            lerp( grad(perm(ABB), p + float4(0, -1, -1, 0) ),
                                  grad(perm(BBB), p + float4(-1, -1, -1, 0) ), f.x), f.y), f.z),
                            
  				 lerp( lerp( lerp( grad(perm(AAA+one), p + float4(0, 0, 0, -1)),
                                   grad(perm(BAA+one), p + float4(-1, 0, 0, -1) ), f.x),
                             lerp( grad(perm(ABA+one), p + float4(0, -1, 0, -1) ),
                                   grad(perm(BBA+one), p + float4(-1, -1, 0, -1) ), f.x), f.y),
                                   
                       lerp( lerp( grad(perm(AAB+one), p + float4(0, 0, -1, -1) ),
                                   grad(perm(BAB+one), p + float4(-1, 0, -1, -1) ), f.x),
                             lerp( grad(perm(ABB+one), p + float4(0, -1, -1, -1) ),
                                   grad(perm(BBB+one), p + float4(-1, -1, -1, -1) ), f.x), f.y), f.z), f.w);
}

float fBm(float4 p, int octaves, float lacunarity = 2.0, float gain = 0.5){
	float freq = 1.0f,
	      amp  = 0.5f;
	float sum  = 0.0f;
	for(int i=0; i < octaves; i++) {
		sum += inoise(p*freq)*amp;
		freq *= lacunarity;
		amp *= gain;
	}
	return sum;
}

float turbulence(float4 p, int octaves, float lacunarity = 2.0, float gain = 0.5){
	float sum = 0;
	float freq = 1.0, amp = 1.0;
	for(int i=0; i < octaves; i++) {
		sum += abs(inoise(p*freq))*amp;
		freq *= lacunarity;
		amp *= gain;
	}
	return sum;
}


float ridge(float h, float offset){
    h = abs(h);
    h = offset - h;
    h = h * h;
    return h;
}

float ridgedmf(float4 p, int octaves, float lacunarity, float gain = 0.05, float offset = 1.0){
	float sum = 0;
	float freq = 1;
	float amp = 0.5;
	float prev = 1;
	for(int i=0; i < octaves; i++)
	{
		float n = ridge(inoise(p*freq), offset);
		sum += n*amp*prev;
		prev = n;
		freq *= lacunarity;
		amp *= gain;
	}
	return sum;
}

vs2ps VS(float4 Pos:POSITION,float4 TexCd:TEXCOORD0,float3 Normal:NORMAL){
    vs2ps Out = (vs2ps)0;
	float4 wPos = mul(Pos, tW);
    float4 viewPos = mul(wPos, tV);
    Out.Pos = mul(viewPos, tP);
	Out.wPosition = mul(Pos, tW);
	Out.TexCd = TexCd;
	Out.Light = normalize(float3(0,0,1));
	Out.Normal = normalize(mul(Normal, tW));
    Out.Pos = mul(Pos, tWVP);
    Out.TexCd = mul(Pos,tTex);
    return Out;
}

float4 PS1(vs2ps In):COLOR{
 	float4 p = In.TexCd;
	float noise =  ridgedmf(p,octaves,lacunarity, gain, offset)*0.5+0.5;
	float E = 0.001;
	
 	float4 pX = In.TexCd;
	pX.x += E;
	float4 pY = In.TexCd;
	pY.y += E;
	float4 pZ = In.TexCd;
	pZ.z += E;
	float4 pW = In.TexCd;
	pW.w += E;
	
	float4 bump = float4(ridgedmf(pX,octaves,lacunarity, gain, offset)*0.5+0.5,ridgedmf(pY,octaves,lacunarity, gain, offset)*0.5+0.5,ridgedmf(pZ,octaves,lacunarity, gain, offset)*0.5+0.5,ridgedmf(pW,octaves,lacunarity, gain, offset)*0.5+0.5);
	float3 modNormal = float4((bump.x-noise)/E, (bump.y-noise)/E, (bump.z-noise)/E , (bump.w-noise)/E);
	float3 Normal = -normalize(In.Normal-modNormal);	
	return cAmb*saturate(dot(In.Light,Normal));
}
           
float4 PS2(vs2ps In):COLOR{
	float4 p = In.TexCd;
	float noise = turbulence(p,octaves, gain, offset)*0.5+0.5;
	float E = 0.001;

 	float4 pX = In.TexCd;
	pX.x += E;
	float4 pY = In.TexCd;
	pY.y += E;
	float4 pZ = In.TexCd;
	pZ.z += E;
	float4 pW = In.TexCd;
	pW.w += E;
	
	float4 bump = float4(turbulence(pX,octaves, gain, offset)*0.5+0.5,turbulence(pY,octaves, gain, offset)*0.5+0.5,turbulence(pZ,octaves, gain, offset)*0.5+0.5,turbulence(pW,octaves, gain, offset)*0.5+0.5);
	float3 modNormal = float4((bump.x-noise)/E, (bump.y-noise)/E, (bump.z-noise)/E, (bump.w-noise)/E);
	float3 Normal = -normalize(In.Normal-modNormal);
	return cAmb*saturate(dot(In.Light,Normal));
}

float4 PS3(vs2ps In):COLOR{
	float4 p = In.TexCd;
	float noise = fBm(p,octaves,lacunarity, gain)*0.5+0.5;
	float E = 0.001;
	
 	float4 pX = In.TexCd;
	pX.x += E;
	float4 pY = In.TexCd;
	pY.y += E;
	float4 pZ = In.TexCd;
	pZ.z += E;
	float4 pW = In.TexCd;
	pW.w += E;
	
	float4 bump = float4(fBm(pX,octaves,lacunarity, gain)*0.5+0.5,fBm(pY,octaves,lacunarity, gain)*0.5+0.5,fBm(pZ,octaves,lacunarity, gain)*0.5+0.5,fBm(pW,octaves,lacunarity, gain)*0.5+0.5);
	float3 modNormal = float4((bump.x-noise)/E, (bump.y-noise)/E, (bump.z-noise)/E, (bump.w-noise)/E);
	float3 Normal = -normalize(In.Normal - modNormal);	
	return cAmb*saturate(dot(In.Light, Normal));
}

technique MultifractalNoise{pass P0{VertexShader=compile vs_3_0 VS();PixelShader=compile ps_3_0 PS1();}}
technique Turbulence{pass P0{VertexShader=compile vs_3_0 VS();PixelShader=compile ps_3_0 PS2();}}
technique FractalSum{pass P0{VertexShader=compile vs_3_0 VS();PixelShader=compile ps_3_0 PS3();}}
