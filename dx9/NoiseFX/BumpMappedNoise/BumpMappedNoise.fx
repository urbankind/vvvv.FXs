//@author:desaxismundi
//@help:procedural 3dnoise bump
//@tags:perlin,inoise,bump,procedural
//@credits:sanch,nvidia

//transforms
float4x4 tW:WORLD;        
float4x4 tV:VIEW;        
float4x4 tP:PROJECTION;  
float4x4 tWVP:WORLDVIEWPROJECTION;

//material properties
float4 cAmb:COLOR <String uiname="Color";> =1;

//samplers
texture permTexture2d;
sampler permSampler2d=sampler_state{texture =(permTexture2d);AddressU=Wrap;AddressV=Wrap;MAGFILTER=POINT;MINFILTER=POINT;MIPFILTER=NONE;};
texture permGradTexture;
sampler permGradSampler=sampler_state{texture=(permGradTexture);AddressU=Wrap;AddressV=Wrap;MAGFILTER=POINT;MINFILTER=POINT;MIPFILTER=NONE;};
float4x4 tTex;

int octaves =1;
float lacunarity =1;
float gain =0.05;
float offset =1;

struct vs2ps{
    float4 Pos:POSITION;
    float4 TexCd:TEXCOORD0;
	float4 wPosition:TEXCOORD1;
	float3 Light:TEXCOORD2;
	float3 Normal:NORMAL;
};

float3 fade(float3 t){return t * t * t * (t * (t * 6 - 15) + 10);}
float4 perm2d(float2 p){return tex2D(permSampler2d, p);}
float gradperm(float x, float3 p){return dot(tex1D(permGradSampler, x), p);}

float inoise(float3 p){
	float3 P = fmod(floor(p),256.0);
  	p -= floor(p);
	float3 f = fade(p);
	P = P / 256.0;
	float4 AA = perm2d(P.xy) + P.z;
  	return lerp( lerp( lerp( gradperm(AA.x, p ),
                             gradperm(AA.z, p + float3(-1, 0, 0) ), f.x),
                       lerp( gradperm(AA.y, p + float3(0, -1, 0) ),
                             gradperm(AA.w, p + float3(-1, -1, 0) ), f.x), f.y),

                 lerp( lerp( gradperm(AA.x+(1.0 / 256.0), p + float3(0, 0, -1) ),
                             gradperm(AA.z+(1.0 / 256.0), p + float3(-1, 0, -1) ), f.x),
                       lerp( gradperm(AA.y+(1.0 / 256.0), p + float3(0, -1, -1) ),
                             gradperm(AA.w+(1.0 / 256.0), p + float3(-1, -1, -1) ), f.x), f.y), f.z);
}

float fBm(float3 p, int octaves,float lacunarity = 2.0,float gain = 0.5){
	float freq = 1.0,
	      amp  = 0.5;
	float sum  = 0.0;
	for(int i=0; i < octaves; i++) {
		sum += inoise(p*freq)*amp;
		freq *= lacunarity;
		amp *= gain;
	}
	return sum;
}

float turbulence(float3 p, int octaves, float lacunarity = 2.0, float gain = 0.5){
	float sum = 0;
	float freq = 1, amp = 1;
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

float ridgedmf(float3 p,int octaves,float lacunarity,float gain = 0.05,float offset = 1.0){
	float sum = 0;
	float freq = 1.0;
	float amp = 0.5;
	float prev = 1.0;
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
 	float3 p = In.TexCd;
	float noise =  ridgedmf(p,octaves,lacunarity, gain, offset)*0.5 + 0.5;
	float E = 0.001;
 	float3 pX = In.TexCd;
	pX.x += E;
	float3 pY = In.TexCd;
	pY.y += E;
	float3 pZ = In.TexCd;
	pZ.z += E;
	
	float3 bump = float3(ridgedmf(pX,octaves,lacunarity, gain, offset)*0.5+0.5,ridgedmf(pY,octaves,lacunarity, gain, offset)*0.5+0.5,ridgedmf(pZ,octaves,lacunarity, gain, offset)*0.5+0.5);
	float3 modNormal = float3((bump.x-noise)/E, (bump.y-noise)/E, (bump.z-noise)/E);
	float3 Normal = -normalize(In.Normal - modNormal);
	return  cAmb*saturate(dot(In.Light, Normal));
}
             
float4 PS2(vs2ps In):COLOR{
	float3 p = In.TexCd;
	float noise = turbulence(p,octaves, gain, offset)*0.5+0.5;
	float E = 0.001;
 	float3 pX = In.TexCd;
	pX.x += E;
	float3 pY = In.TexCd;
	pY.y += E;
	float3 pZ = In.TexCd;
	pZ.z += E;
	
	float3 bump = float3(turbulence(pX,octaves, gain, offset)*0.5+0.5,turbulence(pY,octaves, gain, offset)*0.5+0.5,turbulence(pZ,octaves, gain, offset)*0.5+0.5);
	float3 modNormal = float3((bump.x-noise)/E, (bump.y-noise)/E, (bump.z-noise)/E);
	float3 Normal = -normalize(In.Normal - modNormal);
	return cAmb*saturate(dot(In.Light, Normal));
}


float4 PS3(vs2ps In):COLOR{
	float3 p = In.TexCd;
	float noise = fBm(p,octaves,lacunarity, gain)*0.5+0.5;
	float E = 0.001;
	
 	float3 pX = In.TexCd;
	pX.x += E;
	float3 pY = In.TexCd;
	pY.y += E;
	float3 pZ = In.TexCd;
	pZ.z += E;
	
	float3 bump = float3(fBm(pX,octaves,lacunarity, gain)*0.5+0.5,fBm(pY,octaves,lacunarity, gain)*0.5+0.5,fBm(pZ,octaves,lacunarity, gain)*0.5+0.5);
	float3 modNormal = float3((bump.x-noise)/E, (bump.y-noise)/E, (bump.z-noise)/E);
	float3 Normal = -normalize(In.Normal - modNormal);
	return cAmb*saturate(dot(In.Light, Normal));
}

technique MultifractalNoise{pass P0{VertexShader=compile vs_3_0 VS();PixelShader=compile ps_3_0 PS1();}}
technique Turbulence{pass P0{VertexShader=compile vs_3_0 VS();PixelShader=compile ps_3_0 PS2();}}
technique FractalSum{pass P0{VertexShader=compile vs_3_0 VS();PixelShader=compile ps_3_0 PS3();}}

