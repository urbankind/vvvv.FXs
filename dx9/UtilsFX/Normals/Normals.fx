//transforms
float4x4 tW:World;
float4x4 tWIT:WorldInverseTranspose;
float4x4 tWVP:WorldViewProjection;
float4x4 tVI:ViewInverse;
float4x4 tWV:WorldView;

struct vs2ps{
    float4 HPosition:POSITION;
    float3 WorldNormal:TEXCOORD0;
    float3 WorldEyeVec:TEXCOORD1;
    float3 EyePos:TEXCOORD2;
   // float4 Diff:COLOR0;
};

vs2ps simpleVS(
	float3 Pos:POSITION,
    float4 UV:TEXCOORD0,
    float4 Normal:NORMAL,
    float4 Tangent:TANGENT0,
    float4 Binormal:BINORMAL0)
{
    vs2ps OUT = (vs2ps)0;
    float4 Po = float4(Pos,1);
    OUT.HPosition = mul(Po,tWVP);
    float4 Nn = normalize(Normal);
    OUT.WorldNormal = mul(tWIT,Nn).xyz;
    float4 Pw = mul(tW,Po);
    OUT.EyePos = mul(Po,tWV).xyz;
    OUT.WorldEyeVec = normalize(tVI[3].xyz-Pw.xyz);
    return OUT;
}

float4 vecColorN(float3 V){float3 Nc=.5*(normalize(V.xyz)+((1).xxx));return float4(Nc,1);}
float4 normPS(vs2ps IN):COLOR{return vecColorN(IN.WorldNormal);}
technique Main {pass Norms{VertexShader=compile vs_3_0 simpleVS();PixelShader=compile ps_3_0 normPS();}}

