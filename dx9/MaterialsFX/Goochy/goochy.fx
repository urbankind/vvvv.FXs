//@author:desaxismundi
//@tags:gooch,material
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;

//material properties
float3 lPos <string UIName="Light Position";> ={100.0,100.0,100.0};
float4 LiteCol:COLOR <string UIName="Bright Surface Color";> ={0.8,0.5,0.1,1};
float4 DarkCol:COLOR <string UIName="Dark Surface Color";> ={0.0,0.0,0.0,1};
float4 WarmCol:COLOR <string UIName="Gooch Warm Tone";> ={0.5,0.4,0.05,1};
float4 CoolCol:COLOR <string UIName="Gooch Cool Tone";> ={0.05,0.05,0.6,1};
float4 SpecCol:COLOR <string UIName="Hilight Color";> ={0.7,0.7,1.0,1};
float SpecExpon <string UIName="Specular Exponent";float UIMin=1.0;float UIMax=128.0;> =40;
float GlossTop <string UIName="Maximum for Gloss Dropoff";float UIMin=0.2;float UIMax=1.0;> =.7;
float GlossBot <string UIName="Minimum for Gloss Dropoff";float UIMin=0.05;float UIMax=0.95;> =.5;
float GlossDrop <string UIName="Strength of Glossy Dropoff";float UIMin=0.0;float UIMax=1.0;> =.2;

//sampler
texture Tex <string uiname="Texture";>;
sampler Samp=sampler_state{Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;AddressU=WRAP;AddressV=WRAP;};

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldPos:TEXCOORD3;
    float3 WorldEyePos:TEXCOORD4;
};

vs2ps vs(float3 PosO:POSITION,float4 UV:TEXCOORD0,float4 NormO:NORMAL){
    vs2ps OUT=(vs2ps)0;   
    OUT.WorldNormal=mul(NormO,tWIT).xyz;
    float4 Po=float4(PosO.xyz,1);
    float3 Pw=mul(Po,tW).xyz;
    OUT.WorldPos=Pw;
    OUT.LightVec=lPos-Pw;
    OUT.TexCoord=UV;
    OUT.WorldEyePos=tVI[3].xyz;
    OUT.HPosition=mul(Po,tWVP);
    return OUT;
}

static float gMin=min(GlossBot,GlossTop);
static float gMax=max(GlossBot,GlossTop);
static float gDr=(1-GlossDrop);

void GoochShared(vs2ps IN,out float4 DiffuseContrib,out float4 SpecularContrib){
    float3 Ln=normalize(IN.LightVec);
    float3 Nn=normalize(IN.WorldNormal);
    float3 Vn=normalize(IN.WorldEyePos-IN.WorldPos);
    float3 Hn=normalize(Vn+Ln);
    float hdn=pow(max(0,dot(Hn,Nn)),SpecExpon);
    hdn=hdn*(GlossDrop+smoothstep(gMin,gMax,hdn)*gDr);
    SpecularContrib=float4((hdn*SpecCol));
    float ldn=dot(Ln,Nn);
    float mixer=.5*(ldn+1);
    float diffComp=max(0,ldn);
    float3 surfColor=lerp(DarkCol,LiteCol,mixer);
    float3 toneColor=lerp(CoolCol,WarmCol,mixer);
    DiffuseContrib=float4((surfColor+toneColor),1);
}

float4 psGOOCH(vs2ps IN):COLOR{
	float4 diffContrib;
	float4 specContrib;
	GoochShared(IN,diffContrib,specContrib);
    float4 result=tex2D(Samp,IN.TexCoord.xy)*diffContrib+specContrib;
    return result;
}

technique Gooch {pass p0{VertexShader=compile vs_2_0 vs();PixelShader=compile ps_2_0 psGOOCH();}}
