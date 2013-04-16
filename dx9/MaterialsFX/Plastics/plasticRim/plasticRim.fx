//@author:desaxismundi 
//@tags:plastic,material
//@credits:copyright nVidia corporation

//transforms
float4x4 WorldIT:WorldInverseTranspose;
float4x4 WorldViewProj:WorldViewProjection;
float4x4 World:World;
float4x4 ViewI:ViewInverse;

//material properties
float3 LightPos ={-10.0,10.0,-10.0};
float4 LightColor:COLOR ={1.0,1.0,1.0,1.0};
float4 AmbiColor:COLOR <string UIName="Ambiemt Color";> ={0.07,0.07,0.07,1.0};
float4 SurfColor:COLOR <string UIName="Surface Color";> ={0.8,0.2,1.0,1.0};
float4 SpecColor:COLOR <string UIName="Specular Color";> ={1.0,1.0,1.0,1.0};
float SpecExpon <string UIName="Main Specular Exponent";float UIMin=1.0;float UIMax=128.0;> =12;
float EdgeExpon <string UIName="Edge Specular Exponent";float UIMin=1.0;float UIMax=128.0;> =2;
float RimGamma <string UIName="Specular Rollover";float UIMin=0.1;float UIMax=5.0;> =1;
float Wrap <string UIName="Diffuse Wraparound";float UIMin=0.0;float UIMax=1.0;> =0;

struct vs2ps{
    float4 HPosition:POSITION;
    float2 UV:TEXCOORD0;
    float3 LightVec:TEXCOORD1;
    float3 WorldNormal:TEXCOORD2;
    float3 WorldEyeVec:TEXCOORD3;
};

vs2ps vs(float3 Position:POSITION,float4 UV:TEXCOORD0,float4 Normal:NORMAL){
    vs2ps OUT;
    OUT.WorldNormal = mul(Normal,WorldIT).xyz;
    float4 Po = float4(Position.xyz,1);
    float3 Pw = mul(Po,World).xyz;
    //OUT.WorldPos = Pw;
    OUT.LightVec = normalize(LightPos-Pw);
    OUT.UV = UV.xy;
    OUT.WorldEyeVec = normalize(ViewI[3].xyz-Pw);
    OUT.HPosition = mul(Po,WorldViewProj);
    return OUT;
}

float4 ps(vs2ps IN):COLOR{
    float3 Ln = normalize(IN.LightVec);
    float3 Nn = normalize(IN.WorldNormal);
    float3 Vn = normalize(IN.WorldEyeVec);
    float3 Hn = normalize(Vn+Ln);
    float ldn = dot(Ln,Nn);
    ldn = smoothstep(-Wrap,1,ldn);
    float hdn = dot(Hn,Nn);
    float vdn = pow(dot(Vn,Nn),RimGamma);
    float exp2 = lerp(EdgeExpon,SpecExpon,vdn);
    float4 litVec = lit(ldn,hdn,exp2);
    float3 diffContrib = SurfColor*(litVec.y*LightColor+AmbiColor);
    float3 specContrib = litVec.y*litVec.z*LightColor*SpecColor;
    return float4((diffContrib+specContrib).xyz,1);
}

technique rimPlastic {pass p0{VertexShader=compile vs_2_0 vs();PixelShader=compile ps_2_0 ps();}}

