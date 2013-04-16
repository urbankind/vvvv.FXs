//@author:desaxismundi
//@tags:bump,reflection,gooch,material
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;
//light
float3 lPos <string UIName="Light Position";> ={-0.5,2.0,1.25};
float4 lCol:COLOR <string UIName="Light Color";> ={1.0,1.0,1.0,1.0};
//material properties
float4 SurfaceColor:COLOR <string UIName="Surface";> ={1.0,1.0,1.0,1.0}; 
float4 AmbiColor:COLOR <string UIName="Ambient Light";> ={0.07,0.07,0.07,1.0};
float4 WarmColor:COLOR <string UIName="Gooch Warm Tone";> ={0.5,0.4,0.05,1.0};
float4 CoolColor:COLOR <string UIName="Gooch Cool Tone";> ={0.05,0.05,0.6,1.0};
float GlossTop <string UIName="Gloss Edge";float UIMin=0.1;float UIMax=0.95;> =.65;
float Ks <string UIName="Specular";float UIMin=0.0;float UIMax=1.0;> =.4;
float GlossDrop <string UIName="Gloss Falloff";float UIMin=0.0;float UIMax=1.0;> =.25;
float GlossEdge <string UIName="Gloss Edge";float UIMin=0.0;float UIMax=0.5;> =.25;
float SpecExpon <string UIName="Specular Power";float UIMin=1.0;float UIMax=128.0;> =5;
float Bump <string UIName="Bumpiness";float UIMin=0.0;float UIMax=3.0;> =1; 
float Kr <string UIName="Reflection Strength";float UIMin=0.0;float UIMax=1.0;> =.5;

//samplers
texture NormalTexture;
sampler2D NormalSampler=sampler_state{Texture=(NormalTexture);MinFilter=Linear;MipFilter=Linear;MagFilter=Linear;AddressU=Wrap;AddressV=Wrap;}; 
texture EnvTexture;
samplerCUBE EnvSampler=sampler_state{Texture=(EnvTexture);MagFilter=Linear;MinFilter=Linear;MipFilter=Linear;AddressU=Clamp;AddressV=Clamp;AddressW=Clamp;};

struct vs2ps{
    float4 HPosition:POSITION;
    float2 UV:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldTangent:TEXCOORD3;
    float3 WorldBinormal:TEXCOORD4;
    float3 WorldView:TEXCOORD5;
};
 
vs2ps vs(
	float3 Position:POSITION,
    float4 UV:TEXCOORD0,
    float4 Normal:NORMAL,
    float4 Tangent:TANGENT0,
    float4 Binormal:BINORMAL0) 
{
    vs2ps OUT=(vs2ps)0;
    OUT.WorldNormal = mul(Normal,tWIT).xyz;
    OUT.WorldTangent = mul(Tangent,tWIT).xyz;
    OUT.WorldBinormal = mul(Binormal,tWIT).xyz;
    float4 Po = float4(Position.xyz,1);
    float3 Pw = mul(Po,tW).xyz;
    OUT.LightVec = (lPos-Pw);
    OUT.UV = UV.xy;
    OUT.WorldView = normalize(tVI[3].xyz-Pw);
    OUT.HPosition = mul(Po,tWVP);
    return OUT;
}

float GlossyDrop(float v,uniform float top,uniform float bot,uniform float drop){
    return (drop+smoothstep(bot,top,v)*(1.0-drop));
}

void gooch(vs2ps IN,float3 LightColor,float3 Nn,float3 Ln,float3 Vn,out float3 DiffuseContrib,out float3 SpecularContrib){
    float3 Hn = normalize(Vn + Ln);
    float ldn = dot(Ln,Nn);
    float hdn = dot(Hn,Nn);
    float4 litV = lit(ldn,hdn,SpecExpon);
    float goochFactor = (1+ldn)/2;
    float3 toneColor = lerp(CoolColor,WarmColor,goochFactor);
    DiffuseContrib = toneColor;
    // now to add glossiness...
    float spec = litV.y*litV.z;
    spec *= GlossyDrop(spec,GlossTop,(GlossTop-GlossEdge),GlossDrop);
    SpecularContrib = spec*Ks*LightColor;
}

float4 ps(vs2ps IN):COLOR{
    float3 diffContrib;
    float3 specContrib;
    float3 Ln = normalize(IN.LightVec);
    float3 Vn = normalize(IN.WorldView);
    float3 Nn = normalize(IN.WorldNormal);
    float3 Tn = normalize(IN.WorldTangent);
    float3 Bn = normalize(IN.WorldBinormal);
    float3 bump = Bump*(tex2D(NormalSampler,IN.UV).rgb - float3(.5,.5,.5));
    Nn = Nn+bump.x*Tn+bump.y*Bn;
    Nn = normalize(Nn);
	gooch(IN,lCol,Nn,Ln,Vn,diffContrib,specContrib);
    float3 diffuseColor = SurfaceColor;
    float3 result = specContrib+(diffuseColor*(diffContrib+AmbiColor));
    float3 R = reflect(Vn,Nn);
    float3 reflColor = Kr*texCUBE(EnvSampler,R.xyz).rgb;
    result += diffuseColor*reflColor;
    return float4(result,1);
}

technique Main {pass p0{VertexShader=compile vs_3_0 vs();PixelShader=compile ps_3_0 ps();}}

