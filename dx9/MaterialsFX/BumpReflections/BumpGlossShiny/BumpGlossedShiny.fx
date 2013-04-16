//@author:desaxismundi
//@help:bumpy,shiny,dielectric,textured surface with quadratic-falloff lights
//@tags:bump,gloss,material
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;

//light1
float3 lPos1 <string uiname="light1 Position";> ={1,1,-1};
float4 lCol1:COLOR <string uiname="light1 Color";> =1;
float lInt1 <string uiname="light1 power";float uimin=1.0;float uimax=50.0;> =2;
//light2
float3 lPos2 <string uiname="light2 Position";> ={-1,0,1};
float4 lCol2:COLOR <string uiname="light2 Color";> ={0.5,0.5,1,1};
float lInt2 <string uiname="light2 power";float uimin=1.0;float uimax=50.0;> =.5;
//surface
float4 AmbiCol:COLOR <string uiname="Ambient Light Color";> ={0.07,0.07,0.07,1};
float4 SurfCol:COLOR <string uiname="Surface Color";> =1;
float Kd <string UIName="diffuse";float UIMin=0.0;float UIMax=1.5;> =1;
float Ks <string UIName="specular";float UIMin=0.0;float UIMax=1.5;> =1;
float SpecExpon <string UIName="specular power";float UIMin=1.0;float UIMax=128.0;> =12;
float Bumpy <string UIName="Bumpiness";float UIMin=0.0;float UIMax=4.0;> =1;
float Kr <string UIName="shine";float UIMin=0.0;float UIMax=1.5;> =1;

//samplers
texture ColorTexture;
texture BumpNormalTexture;
texture GlossTexture;
texture EnvironementReflexionTexture;
sampler2D Samp0=sampler_state{Texture=(ColorTexture);MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;AddressU=wrap;AddressV=wrap;};
sampler2D Samp1=sampler_state{Texture=(BumpNormalTexture);MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;AddressU=wrap;AddressV=wrap;};
sampler2D Samp2=sampler_state{Texture=(GlossTexture);MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;AddressU=wrap;AddressV=wrap;};
samplerCUBE Samp3=sampler_state{Texture=(EnvironementReflexionTexture);MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;AddressU=clamp;AddressV=clamp;AddressW=clamp;};

struct vs2ps {
    float4 HPosition:POSITION;
    float4 TexCoord:TEXCOORD0;
    float4 LightVec1:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldPos:TEXCOORD3;
    float3 WorldEyePos:TEXCOORD4;
    float3 WorldTangent:TEXCOORD5;
    float3 WorldBinorm:TEXCOORD6;
    float4 LightVec2:TEXCOORD7;
};

vs2ps vs(
	float3 Position:POSITION,
	float4 UV:TEXCOORD0,
	float4 Normal:NORMAL,
	float4 Tangent:TANGENT0,
	float4 Binormal:BINORMAL0)
{
    vs2ps OUT=(vs2ps)0;
    OUT.WorldNormal = mul(Normal,tWIT);
    OUT.WorldTangent = mul(Tangent,tWIT);
    OUT.WorldBinorm = mul(Binormal,tWIT);
    float4 tempPos = float4(Position.x,Position.y,Position.z,1);
    float3 worldSpacePos = mul(tempPos, tW);
    OUT.WorldPos = worldSpacePos;
    float3 L1 = lPos1 - worldSpacePos;
    float3 L2 = lPos2 - worldSpacePos;
    float Ld1 = 1/length(L1);
    float Ld2 = 1/length(L2);
    OUT.LightVec1 = float4(L1.x,L1.y,L1.z,Ld1);
    OUT.LightVec2 = float4(L2.x,L2.y,L2.z,Ld2);
    OUT.TexCoord = UV;
    OUT.WorldEyePos = tVI[3].xyz;
    OUT.HPosition = mul(tempPos, tWVP);
    return OUT;
}

float4 ps(vs2ps IN):COLOR{
    float4 map = tex2D(Samp0,IN.TexCoord.xy);
    float3 bumps = Bumpy * (tex2D(Samp1,IN.TexCoord.xy).xyz * 2 - 1);
    float gloss = Ks * tex2D(Samp2,IN.TexCoord.xy).x;
    float3 Nn = normalize(IN.WorldNormal);
    float3 Tn = normalize(IN.WorldTangent);
    float3 Bn = normalize(IN.WorldBinorm);
    float3 Nb = Nn + (bumps.x * Tn + bumps.y * Bn);
           Nb = normalize(Nb);
    float3 Vn = normalize(IN.WorldEyePos - IN.WorldPos);
    float3 Ln = normalize(IN.LightVec1.xyz);
    float3 Hn = normalize(Vn + Ln);
    float hdn = pow(max(0,dot(Hn,Nb)),SpecExpon)*gloss;
    float ldn = dot(Ln,Nb);
    ldn = (IN.LightVec1.w*max(0,ldn))*lInt1;
    float4 diffContrib = IN.LightVec1.w*(ldn*lCol1);
    float4 specContrib = IN.LightVec1.w*((ldn*hdn)*lCol1);
    // second light
    Ln=normalize(IN.LightVec2.xyz);
    Hn=normalize(Vn+Ln);
    hdn=pow(max(0,dot(Hn,Nb)),SpecExpon)*gloss;
    ldn=dot(Ln,Nb);
    ldn=(IN.LightVec2.w*max(0,ldn))*lInt2;
    diffContrib=diffContrib+IN.LightVec2.w*(ldn*lCol2);
    specContrib=specContrib+IN.LightVec2.w*((ldn*hdn)*lCol2);
    float3 reflVect=reflect(Vn,Nb);
    float4 reflColor=Kr*texCUBE(Samp3,reflVect);
    float4 result=(SurfCol*map*(Kd*diffContrib+AmbiCol))+specContrib+reflColor;
    /// half4 result = attenuation * (diffContrib + specContrib);
    return result;
}

technique BumpyGlossyShiny {pass p0{vertexshader=compile vs_2_0 vs();pixelshader=compile ps_2_b ps();}}

