//@author:desaxismundi
//@tags:bump,material

//transforms
float4x4 tWVP:WORLDVIEWPROJECTION;
float4x4 tWVI:WORLDVIEWINVERSE;
float4x4 tW:WORLD;   

//material properties
float4 lPos<string uiname="Light Position";> ={100.0,100.0,100.0,0.0};
float4 tColor:COLOR;
float BumpHeight <string UIName="Bump Height";float UIMin=0.0;float UIMax=2.0;> =.1;

//samplers
texture Texture;
sampler2D Samp = sampler_state{Texture=(Texture);MIPFILTER=LINEAR;MAGFILTER=LINEAR;MINFILTER=LINEAR;};
texture NormalMapTexture;
sampler2D Samp0 = sampler_state{Texture=(NormalMapTexture);MIPFILTER=LINEAR;MAGFILTER=LINEAR;MINFILTER=LINEAR;};

struct vs2ps{
     float4 Pos:POSITION0;
     float2 TexCd:TEXCOORD0;
     float3 LightVec:TEXCOORD2;
     float  Att:TEXCOORD3;
};

vs2ps vs(
     float4 PosO:POSITION0,
     float3 NormO:NORMAL,
     float2 TexCd0:TEXCOORD0,
     float3 TanO:TANGENT,
     float3 BinormO:BINORMAL)
{
    vs2ps OUT=(vs2ps)0;
    OUT.Pos = mul(PosO,tWVP);
    float4 posW = mul(PosO,tW);
    float3 light = normalize(lPos-posW);
    float3x3 tBN = float3x3(TanO,BinormO,NormO);
    OUT.LightVec = mul(tBN,light);
    OUT.Att = 1/(1+(.005*distance(lPos.xyz,posW)));
    OUT.TexCd = TexCd0;
    return OUT;
}

float4 ps(vs2ps IN):COLOR{
    float3 normal = 2*tex2D(Samp0,IN.TexCd).rgb-1;
    float3 light = normalize(IN.LightVec);
    float diffuse = saturate(dot(normal,light));
    float4 col = IN.Att*tColor*diffuse;
    col.a = 1;
    return col*tex2D(Samp,IN.TexCd);
}

technique NormalBumpMapping {pass p0{vertexshader=compile vs_1_1 vs();pixelshader=compile ps_2_0 ps();}}
