//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tWI:WorldInverse;

//light
float3 lPos<string uiname="Light Position";> ={1,1,-1};
float4 lCol:COLOR<string uiname="Light Color";> ={0.8,0.8,1.0,1.0};
float4 AmbiCol:COLOR<string uiname="Ambient Light Color";> ={0.2,0.2,0.2,1.0};
float4 SurfCol:COLOR<string uiname="Surface Color";> =1;

float RepeatS <float uimin=0.01;float uimax=32.0;float uistep=0.01;> =1;
float RepeatT <float uimin=0.01;float uimax=32.0;float uistep=0.01;> =1;
float RepeatR <float uimin=0.01;float uimax=32.0;float uistep=0.01;> =1;
float OffsetS <float uimin=-10.0;float uimax=10.0;float uistep=0.01;> =0;
float OffsetT <float uimin=-10.0;float uimax=10.0;float uistep=0.01;> =0;
float OffsetR <float uimin=-10.0;float uimax=10.0;float uistep=0.01;> =0;

#define NOISE_VOLUME_SIZE 16
#ifndef _H_NOISE3D
#define _H_NOISE3D

#ifndef NOISE_SCALE
#define NOISE_SCALE 500
#endif /* NOISE_SCALE */

//predefine as 1 for "pure" noise
#ifndef NOISE3D_LIMIT
#define NOISE3D_LIMIT 256
#endif /* NOISE3D_LIMIT */

//function used to fill the volume noise texture
float4 noise_3d(float3 Pos:POSITION):COLOR{
    float4 Noise = (float4)0;
    for (int i = 1; i < NOISE3D_LIMIT; i += i) {
        Noise.r += (noise(Pos*NOISE_SCALE*i))/i;
        Noise.g += (noise((Pos+1)*NOISE_SCALE*i))/i;
        Noise.b += (noise((Pos+2)*NOISE_SCALE*i))/i;
        Noise.a += (noise((Pos+3)*NOISE_SCALE*i))/i;
    }
    return (Noise+0.5);
}

#ifndef NOISE_VOLUME_SIZE
#define NOISE_VOLUME_SIZE 32
#endif /* NOISE_VOLUME_SIZE */

texture NoiseTex  < int width = NOISE_VOLUME_SIZE, height = NOISE_VOLUME_SIZE, depth = NOISE_VOLUME_SIZE;>;
sampler NoiseSamp=sampler_state{texture=<NoiseTex>;AddressU=WRAP;AddressV=WRAP;AddressW=WRAP;MIPFILTER=LINEAR;MINFILTER=LINEAR;MAGFILTER=LINEAR;};

#define NOISE3D(p) tex3D(NoiseSamp,(p))
#define SNOISE3D(p) (NOISE3D(p)-0.5)

#else /*!PROCEDURAL_NOISE */
texture NoiseTex;
sampler3D NoiseSamp=sampler_state{Texture=<NoiseTex>;MinFilter=Point;MagFilter=Point;MipFilter=None;};
#endif /*!PROCEDURAL_NOISE */

struct vs2ps{
    float4 HPosition:POSITION;
    float3 STR:TEXCOORD0;
    float4 diffCol:COLOR0;
};

vs2ps vsDIFFNOISE(
	float3 Position:POSITION,
    float4 UV:TEXCOORD0,
    float4 Tangent:TANGENT0,
    float4 Binormal:BINORMAL0,
    float4 Normal:NORMAL)
{
    vs2ps OUT;
    float4 objPos = float4(Position.xyz,1.0);
    float4 worldPos = mul(objPos, tW);
    float3 LightVec = normalize(lPos-worldPos);
    float4 objSpaceLightVec = normalize(mul(LightVec, tWI));
    float4 Nn = normalize(Normal);
    float ldn = dot(objSpaceLightVec,Nn);
    OUT.diffCol = max(0,ldn).x*lCol*SurfCol+AmbiCol;
    OUT.diffCol.w = 1.0;
    OUT.HPosition = mul(objPos, tWVP);
    OUT.STR = float3(max(0.001,RepeatS)*worldPos.x+OffsetS,max(0.001,RepeatT)*worldPos.y+OffsetT,max(0.001,RepeatR)*worldPos.z+OffsetR);
    return OUT;
}

float4 psDIFFNOISE(vs2ps IN):COLOR{
    float4 map=tex3D(NoiseSamp,IN.STR);
    float4 final=(IN.diffCol*map);
    return final;
}

technique main{pass p0{vertexshader=compile vs_1_1 vsDIFFNOISE();pixelshader=compile ps_1_1 psDIFFNOISE();}}

