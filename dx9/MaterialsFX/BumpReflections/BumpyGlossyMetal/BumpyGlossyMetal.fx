//@author:desaxismundi
//@help:bumpy,metal,fresnel-shiny,dielectric,textured surface with two quadratic-falloff lights
//@tags:bump,reflection,material
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;

//light1
float3 lPos1 <string UIName="Light1 Position";> ={1.0,1.0,-1.0};
float4 lCol1:COLOR <string UIName="Light1 Color";> ={1.0,1.0,1.0,1.0};
float lInt1 <string UIName="Light1 Intensity";float UIMin=1.0;float UIMax=50.0;> =2;
//light2
float3 lPos2 <string UIName="Light2 Position";> ={-1.0,0.0,1.0};
float4 lCol2:COLOR <string UIName="Light2 Color";> ={0.5,0.5,1.0,1.0};
float lInt2 <string UIName="Light2 Intensity";float UIMin=1.0;float UIMax=50.0;> =.5;
//material properties
float4 AmbiCol:COLOR <string UIName="Ambient Color";> ={0.07,0.07,0.07,1.0};
float4 SurfCol:COLOR <string UIName="Surface Color";> ={1.0,1.0,1.0,1.0};
float Kd <string UIName="Diffuse";float UIMin=0.0;float UIMax=1.5;> =1;
float Ks <string UIName="Specular";float UIMin=0.0;float UIMax=1.5;> =1;
float SpecExpon <string UIName="Specular Power";float UIMin=1.0;float UIMax=128.0;> =12;
float Bumpy <string UIName="Bumpiness";float UIMin=0.0;float UIMax=10.0;> =1;
float Kr <string UIName="Reflection Max";float UIMin=0.0;float UIMax=1.5;> =1;

//samplers
texture ColorMapTexture;
sampler2D Samp0=sampler_state{Texture=(ColorMapTexture);MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;AddressU=Wrap;AddressV=Wrap;};
texture NormalMapTexture;
sampler2D Samp1=sampler_state{Texture=(NormalMapTexture);MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;AddressU=Wrap; AddressV=Wrap;};
texture SpecularMapTexture;
sampler2D Samp2=sampler_state{Texture=(SpecularMapTexture);MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;AddressU=Wrap;AddressV=Wrap;};
texture EnvironmentMapTexture;
sampler Samp3=sampler_state{Texture=(EnvironmentMapTexture);MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;AddressU=clamp;AddressV=clamp;AddressW=clamp;};

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord:TEXCOORD0;
    float3 WorldNormal:TEXCOORD1;
    float3 WorldPos:TEXCOORD2;
    float3 WorldEyeVec:TEXCOORD3;
    float3 WorldTangent:TEXCOORD4;
    float3 WorldBinorm:TEXCOORD5;
    float3 LightVec1:TEXCOORD6;
    float3 LightVec2:TEXCOORD7;
};

vs2ps vs(
	float3 PosO:POSITION,
	float4 UV:TEXCOORD0,
	float4 NormO:NORMAL,
	float4 Tan:TANGENT0,
	float4 Binorm:BINORMAL0)
{
    vs2ps OUT = (vs2ps)0;
    OUT.WorldNormal = mul(NormO,tWIT).xyz;
    OUT.WorldTangent = mul(Tan,tWIT).xyz;
    OUT.WorldBinorm = mul(Binorm,tWIT).xyz;
    float4 Po = float4(PosO.xyz,1);
    float3 Pw = mul(Po,tW).xyz;
    OUT.WorldPos = Pw;
    OUT.LightVec1 = lPos1.xyz-Pw;
    OUT.LightVec2 = lPos2.xyz-Pw;
    OUT.TexCoord = UV;
    OUT.WorldEyeVec = tVI[3].xyz-Pw;
    OUT.HPosition = mul(Po,tWVP);
    return OUT;
}

float4 ps(vs2ps IN):COLOR{
    float3 map = tex2D(Samp0,IN.TexCoord.xy).rgb;
    float3 bumps = Bumpy*(tex2D(Samp1,IN.TexCoord.xy).xyz-(.5).xxx);
    float gloss = Ks*tex2D(Samp2,IN.TexCoord.xy).x;
    float3 Nn = normalize(IN.WorldNormal);
    float3 Tn = normalize(IN.WorldTangent);
    float3 Bn = normalize(IN.WorldBinorm);
    float3 Nb = Nn+(bumps.x*Tn+bumps.y*Bn);
           Nb = normalize(Nb);
    float3 Vn = normalize(IN.WorldEyeVec);
	float falloff = lInt1/dot(IN.LightVec1,IN.LightVec1);
    float3 Ln = normalize(IN.LightVec1);
    float3 Hn = normalize(Vn+Ln);
    float hdn = dot(Hn,Nb);
    float ldn = dot(Ln,Nb);
	float4 litV = lit(ldn,hdn,SpecExpon);
	float3 incident = falloff*litV.y*lCol1.rgb;
    float3 diffContrib = incident;
    float3 specContrib = litV.z*gloss*incident;
    // second light
	falloff = lInt2/dot(IN.LightVec2,IN.LightVec2);
    Ln = normalize(IN.LightVec2);
    Hn = normalize(Vn+Ln);
    hdn = dot(Hn,Nb);
    ldn = dot(Ln,Nb);
	litV = lit(ldn,hdn,SpecExpon);
	incident = falloff*litV.y*lCol2.rgb;
    diffContrib += incident;
    specContrib += litV.z*gloss*incident;
	
    float3 reflVect = reflect(Vn,Nb);
    float3 reflColor = Kr*texCUBE(Samp3,float4(reflVect,1)).rgb;
    float3 result = (SurfCol.rgb*map)*(Kd*diffContrib+AmbiCol.rgb+specContrib+reflColor);
    return float4(result.rgb,1);
}

technique Main {pass p0{VertexShader=compile vs_2_0 vs();PixelShader=compile ps_2_b ps();}}
