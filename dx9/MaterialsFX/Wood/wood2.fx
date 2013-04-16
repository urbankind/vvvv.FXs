//@author:desaxismundi
//@tags:wood,material
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;

//light
float3 LightPos:Position <string UIName="Light Position";> ={-10.0,10.0,-10.0};
float4 LightColor:COLOR <string UIName="Lamp";> ={1.0,1.0,1.0,1.0};
//material properties
float4 AmbiColor:COLOR <string UIName="Ambient Light";> ={0.17,0.17,0.17,1.0};
float4 WoodColor1:COLOR <string UIName="Light Wood";> ={0.85,0.55,0.01,1.0};
float4 WoodColor2:COLOR<string UIName="Dark Wood";> ={0.60,0.41,0.0,1.0};
float Ks1 < string UIName="Lighter Specular";float UIMin=0.0;float UIMax=2.0;> =.5;
float Ks2 <string UIName="Darker Specular";float UIMin=0.0;float UIMax=2.0;> =.7;
float SpecExpon <string UIName="Specular Power";float UIMin=1.0;float UIMax=128.0;> =50;
float RingScale <string UIName="Ring Scale";float UIMin=0.0;float UIMax=10.0;> =.46;
float AmpScale <string UIName="Wobbliness";float UIMin=0.01;float UIMax=2.0;> =.7;
float PScale <string UIName="Relative Size of Log";float UIMin=0.01;float UIMax=10.0;> =8;
float3 POffset <string UIName="Log-Center Offset";> ={-10.0,-11.0,7.0f};

#define PROC_NOISE
/////////////
#ifdef PROC_NOISE
#define NOISE_SCALE 40
#include "noise3d.fxh"
#else /* !PROC_NOISE */

//sampler
texture NoiseTex;
sampler3D NoiseSamp=sampler_state{Texture=<NoiseTex>;MinFilter=Point;MagFilter=Point;MipFilter=None;};
#endif /* !PROC_NOISE */

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WoodPos:TEXCOORD3;
    float3 WorldView:TEXCOORD4;
    float3 WorldTangent:TEXCOORD5;
    float3 WorldBinorm:TEXCOORD6;
    float4 ObjPos:TEXCOORD7;
};

vs2ps vs(
	float3 Position:POSITION,
    float4 UV:TEXCOORD0,
    float4 Normal:NORMAL,
    float4 Tangent:TANGENT0,
    float4 Binormal:BINORMAL0)
{
    vs2ps OUT;
    OUT.WorldNormal=mul(Normal,tWIT).xyz;
    OUT.WorldTangent=mul(Tangent,tWIT).xyz;
    OUT.WorldBinorm=mul(Binormal,tWIT).xyz;
    float4 Po=float4(Position.xyz,1);
    float3 Pw=mul(Po,tW).xyz;
    OUT.WoodPos=(PScale*Po)+POffset;
    OUT.LightVec=LightPos-Pw;
    OUT.TexCoord=UV;
    OUT.WorldView=(tVI[3].xyz-Pw);
    float4 hpos=mul(Po,tWVP);
    OUT.ObjPos=Po;
    OUT.HPosition=hpos;
    return OUT;
}

float4 psWOOD(vs2ps IN):COLOR{
    float3 Ln = normalize(IN.LightVec);
    float3 Nn = normalize(IN.WorldNormal);
    float3 Pwood = IN.WoodPos+(AmpScale*tex3D(NoiseSamp,IN.WoodPos.xyz/32).xyz);
    float r = RingScale*sqrt(dot(Pwood.yz,Pwood.yz));
    r = r + tex3D(NoiseSamp,r.xxx/32).x;
    r = r - floor(r);
    r = smoothstep(0,.8,r)-smoothstep(.83,1,r);
    float3 dColor = lerp(WoodColor1,WoodColor2,r);
    float Ks = lerp(Ks1,Ks2,r);
    float3 Vn = normalize(IN.WorldView);
    float3 Hn = normalize(Vn+Ln);
    float hdn = dot(Hn,Nn);
    float ldn = dot(Ln,Nn);
    float4 litV = lit(ldn,hdn,SpecExpon);
    float3 diffContrib = dColor*((litV.y*LightColor)+AmbiColor);
    float3 specContrib = Ks*litV.z*LightColor;
    float3 result = diffContrib+specContrib;
    return float4(result,1);
}

technique wood {pass p0{VertexShader=compile vs_2_0 vs();PixelShader=compile ps_2_0 psWOOD();}}
