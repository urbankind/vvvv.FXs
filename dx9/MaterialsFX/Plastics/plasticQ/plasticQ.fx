//@author:desaxismundi
//@tags:plastic,material
//@credits:copyright nVidia corporation

//transforms
float4x4 WorldIT:WorldInverseTranspose;
float4x4 WorldViewProj:WorldViewProjection;
float4x4 World:World;
float4x4 ViewI:ViewInverse;

//light
float3 LightPos ={0.0,0.0,-1.0};
float4 LightColor:COLOR < string UIName="Light Color";> ={1.0,1.0,1.0,1.0};
float LightIntensity <string UIName= "Intensity";float UIMin=1.0;float UIMax=1000.0;> =1;
//material properties
float4 AmbiColor:COLOR <string UIName="Ambient Light Color";> ={0.2,0.2,0.2,1.0};
float4 SurfColor:COLOR <string UIName="Surface Color";> ={0.9,0.5,0.9,1.0};
float SpecExpon <string UIName="specular power";float UIMin=1.0;float UIMax=128.0;> =22;

struct vs2ps{
    float4 HPosition:POSITION;
    float4 TexCoord0:TEXCOORD0;
    float4 diffCol:COLOR0;
    float4 specCol:COLOR1;
};

vs2ps plasticQVS(float3 Position:POSITION,float4 UV:TEXCOORD0,float4 Normal:NORMAL){
    vs2ps OUT;
    float3 Nn = normalize(mul(Normal,WorldIT).xyz);
    float4 Po = float4(Position.xyz,1);
    float3 Pw = mul(Po,World).xyz;
    OUT.HPosition = mul(Po,WorldViewProj);
    float3 LightDelta = (LightPos-Pw);
    float falloff = LightIntensity/dot(LightDelta,LightDelta);
    float3 Ln = normalize(LightDelta);
    float ldn = dot(Ln,Nn);
    float diffComp = max(0,ldn);
    float3 diffContrib = SurfColor*(diffComp*LightColor+AmbiColor);
    OUT.diffCol = float4(diffContrib,1);
    OUT.TexCoord0 = float4(UV.xy,falloff,1);
    float3 Vn = normalize(ViewI[3].xyz-Pw);
    float3 Hn = normalize(Vn+Ln);
    float hdn = pow(max(0,dot(Hn,Nn)),SpecExpon);
    OUT.specCol = float4((diffComp*hdn*LightColor).xyz,1);
    return OUT;
}

float4 plasticQPS(vs2ps IN):COLOR{
    return (IN.TexCoord0.z*(IN.diffCol+IN.specCol));
}

technique ps11 {pass p0{VertexShader=compile vs_1_1 plasticQVS();PixelShader=compile ps_1_1 plasticQPS();}}
