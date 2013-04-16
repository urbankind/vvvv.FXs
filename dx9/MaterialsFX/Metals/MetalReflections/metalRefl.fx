//@author:desaxismundi 
//@tags:metal,reflection,material
//@credits:copyright nVidia corporation

//transforms
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tW:World;
float4x4 tVI:ViewInverse;

//material properties
float3 lPos <string UIName="Light direction";> ={100.0,100.0,-100.0};
float4 lCol:COLOR <string UIName="Light Color";> ={1.0,1.0,1.0,1};
float4 AmbiCol:COLOR<string UIName="Ambient Light Color";> ={0.07,0.07,0.07,1};
float4 SurfCol:COLOR <string UIName="Surface Color";> ={1.0,1.0,1.0,1};
float SpecExpon <string UIName="Specular Power";float UIMin=1.0;float UIMax=128.0;> =12;
float Kd <string UIName="Diffuse (from dirt)";float UIMin=0.0;float UIMax=1.0;> =.1;
float Kr <string UIName="Reflection";float UIMin=0.0;float UIMax=1.0;> =.4;

//samplers
texture ColorTexture;
sampler2D ColorSampler=sampler_state{Texture=(ColorTexture);MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;};
texture CubeEnvMap;
samplerCUBE EnvSampler=sampler_state{Texture=(CubeEnvMap);MinFilter=Linear;MagFilter=Linear;MipFilter=Linear;};

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldView:TEXCOORD5;
};

vs2ps vs(float3 Position:POSITION,float4 UV:TEXCOORD0,float4 Normal:NORMAL){
    vs2ps OUT;
    float4 normal = normalize(Normal);
    OUT.WorldNormal = mul(normal, tWIT).xyz;
    float4 Po = float4(Position.xyz,1);
    float3 Pw = mul(Po, tW).xyz;
    OUT.LightVec = normalize(lPos - Pw);
    OUT.TexCoord = UV;
    OUT.WorldView = normalize(tVI[3].xyz - Pw);
    OUT.HPosition = mul(Po, tWVP);
    return OUT;
}

void metalReflShared(vs2ps IN,out float3 DiffuseContrib,out float3 SpecularContrib,out float3 ReflectionContrib){
    float3 Ln = normalize(IN.LightVec);
    float3 Nn = normalize(IN.WorldNormal);
    float3 Vn = normalize(IN.WorldView);
    float3 Hn = normalize(Vn + Ln);
    float4 litV = lit(dot(Ln,Nn),dot(Hn,Nn),SpecExpon);
    DiffuseContrib = litV.y * Kd * lCol + AmbiCol;
    SpecularContrib = litV.z * lCol;
    float3 reflVect = -reflect(Vn,Nn);
    ReflectionContrib = Kr * texCUBE(EnvSampler,reflVect).xyz;
}

float4 ps(vs2ps IN):COLOR{
    float3 diffContrib;
    float3 specContrib;
    float3 reflColor;
	metalReflShared(IN,diffContrib,specContrib,reflColor);
    float3 map = tex2D(ColorSampler,IN.TexCoord.xy).xyz;
    float3 result = diffContrib + (SurfCol * map * (specContrib + reflColor));
    return float4(result,1);
}

technique Textured {pass p0{VertexShader=compile vs_2_0 vs();PixelShader=compile ps_2_0 ps();}}
