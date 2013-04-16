//@author:desaxismundi
//@tags:metal,plastic,reflection,material
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;

//material properties
float3 lPos <string uiname="Light Direction";> ={0,-5,2};
float4 AmbiCol:COLOR <string UIName="Ambient Color";> ={0.07,0.07,0.07,1};
float4 SurfCol:COLOR <string UIName="Diffuse Color";> ={0.546,0.379,0.218,1};
float4 lCol:COLOR <string UIName="Specular Color";> ={1.0,1.0,1.0,1};
float SpecExpon <string UIName="Specular Power";float UIMin=1.0;float UIMax=128.0;> =80;
float Kd <string UIName="Diffuse ";float UIMin=0.0;float UIMax=1.0;> =.1;
float Kr <string UIName="Reflection";float UIMin=0.0;float UIMax=1.0;> =.8;
float FresnelMin <string UIName="Fresnel Reflection Scale";float UIMin=0.0;float UIMax=1.0;> =.05;
static float KrMin=(Kr*FresnelMin);
float FresnelExp <string UIName="Fresnel Exponent";float UIMin=0.0;float UIMax=5.0;> =3.5;
static float InvFrExp = (1.0/FresnelExp);

//sampler
texture Tex <string uiname="Environment Texture";>;
sampler Samp=sampler_state{Texture=(Tex);MipFilter=LINEAR;MinFilter=LINEAR;MagFilter=LINEAR;};

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldView:TEXCOORD5;
};

vs2ps vs(float3 PosO:POSITION,float4 UV:TEXCOORD0,float4 NormO:NORMAL){
    vs2ps OUT=(vs2ps)0;   
    float4 normal=normalize(NormO);
    OUT.WorldNormal=mul(normal,tWIT).xyz;
    float4 Po=float4(PosO.xyz,1);
    float3 Pw=mul(Po,tW).xyz;
    OUT.LightVec=normalize(lPos-Pw);
    OUT.TexCoord=UV;
    OUT.WorldView=normalize(tVI[3].xyz-Pw);
    OUT.HPosition=mul(Po,tWVP);
    return OUT;
}

void sharedLight(vs2ps IN,out float3 DiffuseContrib,out float3 SpecularContrib,out float3 ReflectionContrib){
    float3 Ln=normalize(IN.LightVec);
    float3 Nn=normalize(IN.WorldNormal);
    float3 Vn=normalize(IN.WorldView);
    float3 Hn=normalize(Vn+Ln);
    float4 litV=lit(dot(Ln,Nn),dot(Hn,Nn),SpecExpon);
    DiffuseContrib=litV.y*Kd*lCol+AmbiCol;
    SpecularContrib=litV.z*lCol;
    float3 reflVect=-reflect(Vn,Nn);
    ReflectionContrib=Kr*texCUBE(Samp,reflVect).xyz;
}

float4 psMETAL(vs2ps IN):COLOR{
    float3 diffContrib;
    float3 specContrib;
    float3 reflColor;
	sharedLight(IN,diffContrib,specContrib,reflColor);
    float3 result = diffContrib+(SurfCol*(specContrib+reflColor));
    return float4(result,1);
}

float4 psPLASTIC(vs2ps IN):COLOR{
    float3 diffContrib;
    float3 specContrib;
    float3 reflColor;
    float3 Nn=normalize(IN.WorldNormal);
    float3 Vn=normalize(IN.WorldView);
	float fresnel=lerp(Kr,KrMin,pow(abs(dot(Nn,Vn)),InvFrExp));
	sharedLight(IN,diffContrib,specContrib,reflColor);
    float3 result=(diffContrib*SurfCol)+specContrib+(fresnel*reflColor);
    return float4(result,1);
}

technique Metal {pass p0{VertexShader=compile vs_2_0 vs();PixelShader=compile ps_2_0 psMETAL();}}
technique Plastic {pass p0{VertexShader=compile vs_2_0 vs();PixelShader=compile ps_2_0 psPLASTIC();}}
